"""
Module detecting unused return values from low level
"""
from typing import List

from CryptoScan.core.cfg.node import Node, NodeType
from CryptoScan.core.declarations.function import Function
from CryptoScan.core.solidity_types.elementary_type import ElementaryType
from CryptoScan.core.solidity_types.mapping_type import MappingType
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall, HighLevelCall
from CryptoScan.analyses.data_dependency.data_dependency import is_dependent

from CryptoScan.core.declarations.function_contract import FunctionContract
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return, TypeConversion, Member, Unary


from CryptoScan.core.variables.state_variable import StateVariable
from CryptoScan.detectors.abstract_detector import (
    AbstractDetector,
    DetectorClassification,
    DETECTOR_INFO,
)
from CryptoScan.core.declarations.solidity_variables import (
    SolidityFunction,
    SolidityVariable,
)
from CryptoScan.slithir.operations.unpack import Unpack
from CryptoScan.utils.output import Output
from .cross_chain_signature_replay import get_ecrecover_calls_recursively
from .single_contract_signature_replay import read_write_set


def contains_checks_agains_paramenerts(func: Function):
    for node in func.nodes:
        for ir in node.irs:
            if isinstance(ir, Condition):
                if any([is_dependent(ir.value, param, func) for param in func.parameters]):
                    return True
            if isinstance(ir, SolidityCall) and (
                        ir.function == SolidityFunction("assert(bool)") \
                        or ir.function == SolidityFunction("require(bool)")
                        or ir.function == SolidityFunction("require(bool,string)")
                    ):
                if any([is_dependent(ir.arguments[0], param, func) for param in func.parameters]):
                    return True
    return False

def contains_check(call_path, target_ir):    
    read_set, write_set = read_write_set(call_path)
    potential_nonce_protector = [x for x in  list(set(read_set) & set(write_set)) if  isinstance(x.type, MappingType) and x.type._from == ElementaryType("address")]
    
    for idx, func in enumerate(call_path):
        next_func_call = target_ir
        if idx < len(call_path) - 1:
            for node in func.nodes:
                for ir in node.irs:
                    if isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall) or isinstance(ir, InternalCall):
                        if ir.function == call_path[idx + 1]:
                            next_func_call = ir
                            break
        else:
            next_func_call = target_ir
        current_layer_taints = []
        whitelist = []
        
        Checks = []
        for node in func.nodes:
            for ir in node.irs:
                if ir == next_func_call:
                    if hasattr(ir.lvalue, "type") and (ir.lvalue.type == ElementaryType("address") or ir.lvalue.type ==  ElementaryType("bool") or (isinstance(ir.lvalue.type, list) and ElementaryType("address") in ir.lvalue.type) or "address" in str(ir.lvalue.type)):
                        current_layer_taints.append(ir.lvalue)
                        
                    
                        
                if isinstance(ir, Unpack):
                    if ir.tuple in current_layer_taints:
                        current_layer_taints.append(ir.lvalue)
                if isinstance(ir, Unary):
                    if ir.rvalue in current_layer_taints:
                        current_layer_taints.append(ir.lvalue)
                if isinstance(ir, Index):
                    
                    if ir.variable_right in current_layer_taints and ir.variable_left not in potential_nonce_protector:
                        current_layer_taints.append(ir.lvalue)
                if isinstance(ir, Member):
                    if ir.variable_left in current_layer_taints:
                        current_layer_taints.append(ir.lvalue)
                if isinstance(ir, Condition):
                    Checks.append(ir.value)
                if isinstance(ir, SolidityCall) and (
                        ir.function == SolidityFunction("assert(bool)") \
                        or ir.function == SolidityFunction("require(bool)")
                        or ir.function == SolidityFunction("require(bool,string)")
                    ):
                    if not any([is_dependent(ir.arguments[0], white, func) for white in whitelist]):
                        Checks.append(ir.arguments[0])
                if isinstance(ir, TypeConversion):
                    if ir.type == ElementaryType('address') and (ir.variable == 0):
                        whitelist.append(ir.lvalue)
                if isinstance(ir, Binary) and ir.type.return_bool(ir.type):
                    if ir.variable_left not in whitelist and ir.variable_right not in whitelist:
                        
                        
                        Checks.append(ir.variable_left)
                        Checks.append(ir.variable_right)
                if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LowLevelCall) or isinstance(ir, LibraryCall):
                    for arg in ir.arguments:
                        if any([is_dependent(arg, taint, func) for taint in current_layer_taints]):
                            current_layer_taints.append(ir.lvalue)
                            if contains_checks_agains_paramenerts(ir.function):
                                
                                return True
                    
                if isinstance(ir, Assignment):
                    if ir.rvalue in current_layer_taints:
                        current_layer_taints.append(ir.lvalue)
                if isinstance(ir, Index):
                    if ir.variable_right in current_layer_taints and ir.lvalue.type != ElementaryType("uint256"):
                        current_layer_taints.append(ir.lvalue)
        for check in Checks:
            for taint in current_layer_taints:
                if check == taint:
                    
                    return True

        




    















































































    

class UncheckedSignature(AbstractDetector):
    """
    If the return value of a low-level call to Ecreciver is not checked, it might lead to losing ether
    """

    ARGUMENT = "insufficient-sig-check"
    HELP = "Insufficient Signature Verification"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = "https://github.com/crytic/slither/wiki/Detector-Documentation"

    WIKI_TITLE = "Insufficient Signature Verification"
    WIKI_DESCRIPTION = " "

    
    WIKI_EXPLOIT_SCENARIO = """ 
    """
    

    WIKI_RECOMMENDATION = "Ensure that the return value of ecrecover is properly checked."


    def _detect(self) -> List[Output]:
        """Detect low level calls where the success value is not checked"""
        

        results = []
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        ret = []
        for c in self.compilation_unit.contracts_derived:
            for f in c.functions:
                if f.visibility in ['internal', 'private'] or f.view:
                    continue
                ecrecover_calls = get_ecrecover_calls_recursively(f)
                for (call_path, _) in ecrecover_calls:
                    
                    ecrecover_call_to_check = []
                    for func in call_path:
                        for node in func.nodes:
                            for ir in node.irs:
                                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") or ir.function == SolidityFunction("ecrecover()")):
                                    ecrecover_call_to_check.append(ir)

                    checked = False
                    for ecrecover_call in ecrecover_call_to_check:
                        if contains_check(call_path, ecrecover_call):
                            checked = True
                            break
                    if not checked:
                        ret.append(call_path)




                
                
                
                
                
                
                
                
                
                
                
                
                    
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                            
                            
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                        

                for call_path in ret:
                    info: DETECTOR_INFO = [call_path[0], f" contans the insufficient signature verification defect, the signature used in function {call_path[-1]} is not properly checked"]
                    res = self.generate_result(info)
                    results.append(res)

        return results
