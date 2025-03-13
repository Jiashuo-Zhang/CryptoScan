"""
Module detecting bad PRNG due to the use of block.timestamp, now or blockhash (block.blockhash) as a source of randomness
"""

from typing import List, Tuple

from CryptoScan.analyses.data_dependency.data_dependency import is_dependent
from CryptoScan.core.variables.state_variable import StateVariable
from CryptoScan.slithir.variables import  ReferenceVariableSSA, ReferenceVariable
from CryptoScan.core.cfg.node import Node
from CryptoScan.core.declarations import Function, Contract
from CryptoScan.core.declarations.solidity_variables import (
    SolidityVariable,
    SolidityFunction,
    SolidityVariableComposed,
)
from CryptoScan.core.variables.variable import Variable
from CryptoScan.detectors.abstract_detector import AbstractDetector, DetectorClassification
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return, TypeConversion
from CryptoScan.slithir.operations import SolidityCall, InternalCall, LibraryCall
from CryptoScan.utils.output import Output, AllSupportedOutput


def collect_return_values_of_bad_PRNG_functions(f: Function) -> List:
    """
        Return the return-values of calls to blockhash()
    Args:
        f (Function)
    Returns:
        list(values)
    """
    values_returned = []
    for n in f.nodes:
        for ir in n.irs:
            if (
                isinstance(ir, SolidityCall)
                and ir.function == SolidityFunction("blockhash(uint256)")
                and ir.lvalue
            ):
                values_returned.append(ir.lvalue)
    return values_returned


def contains_bad_random_sources(keccak_result_tmp_var, func, contract):
    bad_sources = []
    for n in func.nodes:
        for ir in n.irs:
            if (
                isinstance(ir, SolidityCall)
                and ir.function == SolidityFunction("blockhash(uint256)")
                and ir.lvalue
            ):
                bad_sources.append(ir.lvalue)
        bad_sources.extend([SolidityVariableComposed("block.timestamp"), SolidityVariableComposed("block.coinbase"), SolidityVariableComposed("block.number"), SolidityVariable("now")])
    
    for bad_source in bad_sources:
        if is_dependent(keccak_result_tmp_var, bad_source, contract):
            
            return True
    return False

def detect_bad_PRNG(contract_list) -> List[Tuple[Function, List[Node]]]:
    """
    Args:
        contract (Contract)
    Returns:
        list((Function), (list (Node)))
    """

    ret: List[Tuple[Function, List[Node]]] = []
    keccak_call_taints = []
    for contract in contract_list:
        for func in contract.functions:
            for node in func.nodes:
                for ir in node.irs:
                    if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") or ir.function == SolidityFunction("keccak256()") or ir.function == SolidityFunction("sha3()")):
                        if contains_bad_random_sources(ir.lvalue, func, contract):
                            keccak_call_taints.append(ir.lvalue)
    
    keccak_call_taints_cross_contract = []
    for contract in contract_list:
        for func in contract.functions:
            for node in func.nodes:
                for ir in node.irs:
                    if isinstance(ir, Return):
                        for return_value in ir.values:
                            if any([is_dependent(return_value, taint, func) for taint in keccak_call_taints] ):
                                keccak_call_taints_cross_contract.append((contract, func))
                                break
    for contract in contract_list:
        for func in contract.functions:
            for node in func.nodes:
                for ir in node.irs:
                    tainted = False
                    
                    
                    
                    if isinstance(ir, Return):
                        for value in  ir.values:
                            if any([is_dependent(value, taint, func) for taint in keccak_call_taints]):
                                tainted = True
                    if isinstance(ir, TypeConversion):
                        if ir.variable in keccak_call_taints:
                            keccak_call_taints.append(ir.lvalue)
                    if isinstance(ir, InternalCall) or isinstance(ir, LibraryCall):
                        for arg in ir.arguments:
                            if any([is_dependent(arg, taint, contract) for taint in keccak_call_taints]):
                                keccak_call_taints.append(ir.lvalue)
                                break
                        if isinstance(ir, LibraryCall):
                            if (ir.destination, ir.function) in keccak_call_taints_cross_contract:
                                keccak_call_taints.append(ir.lvalue)
                    elif isinstance(ir, Index):
                        if any([is_dependent(ir.variable_right, taint, contract) for taint in keccak_call_taints]):
                            keccak_call_taints.append(ir.lvalue)
                        if any([is_dependent(ir.variable_left, taint, contract) for taint in keccak_call_taints]):
                            keccak_call_taints.append(ir.lvalue)
                    elif isinstance(ir, Assignment) or isinstance(ir, Binary):
                        tainted = tainted | any([is_dependent(ir.lvalue, taint, contract) and isinstance(ir.lvalue, StateVariable) for taint in keccak_call_taints])
                        tainted = tainted | any([ is_dependent(ir.lvalue, taint, contract) and isinstance(ir.lvalue, ReferenceVariableSSA) and isinstance(ir.lvalue.points_to_origin, StateVariable) for taint in keccak_call_taints])
                    elif isinstance(ir, Condition):
                        tainted = tainted | any([is_dependent(ir.value, taint, contract) for taint in keccak_call_taints])
                    if tainted:
                        ret.append((func, node))




    return ret


class WeakRandomnessFromHashingChainAttributes(AbstractDetector):
    """
    Detect weak PRNG due to a modulo operation on block.timestamp, now or blockhash
    """

    ARGUMENT = "weak-prng"
    HELP = "Weak PRNG"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.MEDIUM

    WIKI = "https://github.com/crytic/slither/wiki/Detector-Documentation"

    WIKI_TITLE = "Weak PRNG"
    WIKI_DESCRIPTION = "Weak PRNG due to a modulo on `block.timestamp`, `now` or `blockhash`. These can be influenced by miners to some extent so they should be avoided."

    
    WIKI_EXPLOIT_SCENARIO = """
```solidity
contract Game {

    uint reward_determining_number;

    function guessing() external{
      reward_determining_number = uint256(block.blockhash(10000)) % 10;
    }
}
```
Eve is a miner. Eve calls `guessing` and re-orders the block containing the transaction. 
As a result, Eve wins the game."""
    

    WIKI_RECOMMENDATION = (
        "Do not use `block.timestamp`, `now` or `blockhash` as a source of randomness"
    )

    def _detect(self) -> List[Output]:
        """Detect bad PRNG due to the use of block.timestamp, now or blockhash (block.blockhash) as a source of randomness"""
        

        results = []
        
        values = detect_bad_PRNG(self.compilation_unit.contracts_derived)
        for func, node in values:
                info: List[AllSupportedOutput] = [func, ' uses a weak PRNG: ', node]
                res = self.generate_result(info)
                results.append(res)

        return results
