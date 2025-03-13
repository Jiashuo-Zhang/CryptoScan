"""
Module detecting bad PRNG due to the use of block.timestamp, now or blockhash (block.blockhash) as a source of randomness
"""

from typing import List, Tuple
from CryptoScan.core.cfg.node import Node, NodeType

from CryptoScan.analyses.data_dependency.data_dependency import is_dependent_ssa, is_dependent
from CryptoScan.core.solidity_types.elementary_type import ElementaryType
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
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return
from CryptoScan.slithir.operations import SolidityCall, InternalCall, LibraryCall, HighLevelCall, TypeConversion
from CryptoScan.utils.output import Output, AllSupportedOutput
from .signature_frontrunning import get_ecrecover_calls_recursively, call_relations

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
        for ir in n.irs_ssa:
            if (
                isinstance(ir, SolidityCall)
                and ir.function == SolidityFunction("blockhash(uint256)")
                and ir.lvalue
            ):
                values_returned.append(ir.lvalue)
    return values_returned


def bad_random_sources(keccak_result_tmp_var, func: Function, arguments, contract: Contract):
    contained_bad_sources = []
    
    
    bad_sources = [SolidityVariableComposed("msg.sender"), SolidityVariableComposed("tx.origin")]
    for bad_source in bad_sources:
        if is_dependent(keccak_result_tmp_var, bad_source, func):
            
            contained_bad_sources.append(bad_source)
        if any([is_dependent(argument, bad_source, func) for argument in arguments]):
            contained_bad_sources.append(bad_source)
    
    return contained_bad_sources

def used_in_signature(contract, target_func):
    for f in contract.functions:
        
        
        result = get_ecrecover_calls_recursively(f)
        for call_path, _ in result:
            
            
            if target_func in call_relations(call_path).keys() or target_func in call_path:
                
                return True
                
    return False

def used_as_index(contract_list, contract, func, random_value):
    for contract in contract_list:
        for f in contract.functions:
        
            current_taints = [random_value]
            for n in f.nodes:
                for ir in n.irs:
                    if isinstance(ir, SolidityCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall):
                        if ir.function == func:
                            current_taints.append(ir.lvalue)
                    elif isinstance(ir, Assignment):
                        for var in ir.variables:
                            if var in current_taints:
                                current_taints.append(ir.lvalue)
                                break
                    elif isinstance(ir, TypeConversion):
                        if ir.variable in current_taints:
                            current_taints.append(ir.lvalue)
                    if isinstance(ir, Index) and ir.variable_right in current_taints:
                        
                        return True
    
    return False


def contains_sig_checks(contract_list, contract, func, random_value):
    if used_in_signature(contract, func):
        return True
    return_values = False
    for node in func.nodes:
        for ir in node.irs:
            if isinstance(ir, Binary) and ir.type.return_bool(ir.type):
                if ir.variable_left.type == ElementaryType('address') or ir.variable_right.type == ElementaryType('address')  \
                    or  ir.variable_left.type == ElementaryType('bytes32') or ir.variable_right.type == ElementaryType('bytes32'):
                    if any([is_dependent(var, random_value, func) for var in [ir.variable_left, ir.variable_right]]):
                        
                        return True 
            if isinstance(ir, SolidityCall) and (
                        ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") \
                        or ir.function == SolidityFunction("ecrecover()")
                ):
                if is_dependent(ir.arguments[0], random_value, contract):
                    return True
            elif isinstance(ir, InternalCall) or isinstance(ir, LibraryCall) or isinstance(ir, HighLevelCall):
                if isinstance(ir.function, StateVariable):
                    continue
                if (ir.function.return_type == [ElementaryType('bool')] or ir.function.return_type == [ElementaryType('address')]) and any([is_dependent(arg, random_value, func) for arg in ir.arguments]):
                    return True
            if isinstance(ir, Return):
                for idx, v in enumerate(ir.values):
                    if is_dependent(v, random_value, func):
                        return_values = True
    for contract in contract_list:
        for f in contract.functions:
            current_layer_taints = []
            for node in f.nodes:
                for ir in node.irs:
                    if isinstance(ir, InternalCall) or isinstance(ir, SolidityCall) or isinstance(ir, LibraryCall) or isinstance(ir, HighLevelCall):
                        if ir.function == func and return_values:
                            current_layer_taints.append(ir.lvalue)
                    if isinstance(ir, Assignment):
                        if any([var in current_layer_taints for var in ir.variables]):
                            current_layer_taints.append(ir.lvalue)
                    if isinstance(ir, Binary) and ir.type.return_bool(ir.type):
                        if ir.variable_left.type == ElementaryType('address') or ir.variable_right.type == ElementaryType('address')  \
                            or  ir.variable_left.type == ElementaryType('bytes32') or ir.variable_right.type == ElementaryType('bytes32'):
                            for taint in current_layer_taints:
                                if any([is_dependent(var, taint, func) for var in [ir.variable_left, ir.variable_right]]):
                                    
                                    return True 
                    if isinstance(ir, SolidityCall) and (
                                ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") \
                                or ir.function == SolidityFunction("ecrecover()")
                        ):
                        for taint in current_layer_taints:
                            if is_dependent(ir.arguments[0], taint, contract):
                                return True
                    elif isinstance(ir, InternalCall) or isinstance(ir, LibraryCall) or isinstance(ir, HighLevelCall):
                        if isinstance(ir.function, StateVariable):
                            continue
                        if (ir.function.return_type == [ElementaryType('bool')] or ir.function.return_type == [ElementaryType('address')]):
                            for taint in current_layer_taints:
                                if any([is_dependent(arg, taint, func) for arg in ir.arguments]):
                                    return True
                    
    return False

    
                    
def func_parameters_checks(func: Function, contract: Contract):
    protected_func_parameters = {}
    paramenters = func.parameters
    paramenters.extend([SolidityVariableComposed("msg.sender"), SolidityVariableComposed("tx.origin")])
 
    Binary_Checks = []
    for param in paramenters:
        protected_func_parameters[param] = []
        for node in func.nodes:
            
            
            
            
            for ir in node.irs:
                if isinstance(ir, Condition):
                    if is_dependent(ir.value, param, contract):
                        
                        protected_func_parameters[param].append(ir)
                if isinstance(ir, SolidityCall) and (
                            ir.function == SolidityFunction("assert(bool)") \
                            or ir.function == SolidityFunction("require(bool)")
                            or ir.function == SolidityFunction("require(bool,string)")
                        ):
                    if is_dependent(ir.lvalue, param, contract):
                        
                        protected_func_parameters[param].append(ir)
    
    
    
    
    return [x for x in protected_func_parameters if len(protected_func_parameters[x]) > 0]

                
                        

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
            checked_parameters = func_parameters_checks(func, contract)
            for node in func.nodes:
                for ir in node.irs:
                    if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") or ir.function == SolidityFunction("keccak256()") or ir.function == SolidityFunction("sha3()")):
                        if len( set(bad_random_sources(ir.lvalue, func, ir.arguments, contract)).difference(set(checked_parameters)) ) > 0:
                            
                            if not contains_sig_checks(contract_list, contract, func, ir.lvalue) and not used_as_index(contract_list, contract, func, ir.lvalue) :
                                keccak_call_taints.append(ir.lvalue)
                                ret.append((func, node))
                   
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    




    return ret


class WeakRandomnessFromHashingTxInputs(AbstractDetector):
    """
    Detect weak PRNG due to a modulo operation on block.timestamp, now or blockhash
    """

    ARGUMENT = "weak-prng-tx"
    HELP = "Weak PRNG from Hashing Transaction Inputs"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.MEDIUM

    WIKI = " "

    WIKI_TITLE = "Weak PRNG from Hashing Transaction Inputs"
    WIKI_DESCRIPTION = "Weak PRNG due to a hash operation on `msg.sender` and other transaction inputs."

    
    WIKI_EXPLOIT_SCENARIO = """ """
    

    WIKI_RECOMMENDATION = (
        " "
    )

    def _detect(self) -> List[Output]:
        """Detect bad PRNG due to the use of msg.sender, other transaction inputs as a source of randomness"""
        

        results = []
        
        values = detect_bad_PRNG(self.compilation_unit.contracts_derived)
        for func, node in values:
                info: List[AllSupportedOutput] = [func, ' uses a weak PRNG due to hashing tx inputs: ', node]
                res = self.generate_result(info)
                results.append(res)

        return results
