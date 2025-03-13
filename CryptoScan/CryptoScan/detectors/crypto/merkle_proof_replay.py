"""
Module detecting unused return values from low level
"""
from typing import List

from CryptoScan.core.cfg.node import Node, NodeType
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall, HighLevelCall
from CryptoScan.analyses.data_dependency.data_dependency import is_dependent

from CryptoScan.core.declarations.function_contract import FunctionContract
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return
from CryptoScan.core.solidity_types.elementary_type import ElementaryType

from CryptoScan.core.variables.state_variable import StateVariable
from CryptoScan.detectors.abstract_detector import (
    AbstractDetector,
    DetectorClassification,
    DETECTOR_INFO,
)
from CryptoScan.core.declarations import Function, FunctionContract, Contract

from CryptoScan.core.declarations.solidity_variables import (
    SolidityFunction,
    SolidityVariableComposed,
)
from CryptoScan.utils.output import Output

from .single_contract_signature_replay import contains_balance_protector, read_write_set
from .signature_frontrunning import call_relations

def merkle_pre_image_tx_param_analysis(call_path, merkle_ir):
    
    
    pre_image_parameters = {}
    current_layer = len(call_path) - 1
    while(current_layer >= 0):
        pre_image_parameters[current_layer] = []
        func = call_path[current_layer]
        if current_layer == len(call_path) - 1:
            for node in func.nodes: 
                merkle_call_irs = [ir for ir in node.irs if ir == merkle_ir]
                for merkle_call_ir in merkle_call_irs:
                    for param_idx in range(0, len(func.parameters)):
                        if is_dependent(merkle_call_ir.arguments[0], func.parameters[param_idx], func):
                            pre_image_parameters[current_layer].append(param_idx)
                        
                        
        else:
            all_call_return_value = {} 
            assignment = {} 
            for node in func.nodes:
                for ir in node.irs:
                    if (isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, SolidityCall)):
                        all_call_return_value[ir.lvalue] = ir.arguments
                    if isinstance(ir, Assignment):
                        assignment[ir.lvalue] = ir.rvalue
            for ret in all_call_return_value:
                for arg in all_call_return_value[ret] :
                    if isinstance(arg, list):
                        continue
                    if arg in assignment:
                        all_call_return_value[ret].extend([assignment[arg]])
                    
                    
                    
                
            for node in func.nodes:
                next_func_calls = [ir for ir in node.irs if (isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall)) and (ir.function == call_path[current_layer + 1])]
                for next_func_call in next_func_calls:
                    for param_idx in range(0, len(func.parameters)):
                        if any([is_dependent(next_func_call.arguments[arg_idx], func.parameters[param_idx],func) for arg_idx in (range(0, len(next_func_call.arguments))) if arg_idx in pre_image_parameters[current_layer + 1]]):
                            pre_image_parameters[current_layer].append(param_idx)
                        
                        
                        for param_idx in range(0, len(func.parameters)):
                            if func.parameters[param_idx] in all_call_return_value[next_func_call.lvalue]:
                                pre_image_parameters[current_layer].append(param_idx)
        current_layer = current_layer - 1
    return pre_image_parameters


def contains_check(call_path, target_ir):
    Binary_Checks = []
    for func in call_path:
        for node in func.nodes:
            for ir in node.irs:
                if isinstance(ir, Binary) and ir.type.return_bool(ir.type):
                    Binary_Checks.append((ir.variable_left, func))
                    Binary_Checks.append((ir.variable_right, func))
    current_layer = len(call_path) - 1
    func_with_tainted_return_value = []
    Binary_Checks = []
    while(current_layer >= 0):
        func = call_path[current_layer]
        current_layer_taints = []
        if current_layer == len(call_path) - 1:
            current_layer_taints = [target_ir.lvalue]
            for node in func.nodes: 
                for ir in node.irs:
                    if isinstance(ir, Binary) and ir.type.return_bool(ir.type):
                        Binary_Checks.append(ir.variable_left)
                        Binary_Checks.append(ir.variable_right)
                    if isinstance(ir, Assignment):
                        if any([is_dependent(ir.rvalue, taint, func) for taint in current_layer_taints]):
                            current_layer_taints.append(ir.lvalue)
                    if isinstance(ir, Return):
                        for value in ir.values:
                            func_with_tainted_return_value.append(func)
                            
        else:
            for node in func.nodes: 
                for ir in node.irs:
                    if isinstance(ir, Binary) and ir.type.return_bool(ir.type):
                        Binary_Checks.append(ir.variable_left)
                        Binary_Checks.append(ir.variable_right)
                    if isinstance(ir, Assignment):
                        if any([is_dependent(ir.rvalue, taint, func) for taint in current_layer_taints]):
                            current_layer_taints.append(ir.lvalue)
                    if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall):
                        if ir.function in func_with_tainted_return_value:
                            current_layer_taints.append(ir.lvalue)
                    if isinstance(ir, Return):
                        for value in ir.values:
                            func_with_tainted_return_value.append(func)
                            
        for check in Binary_Checks:
            for taint in current_layer_taints:
                if is_dependent(check, taint, func):
                    
                    return True
        current_layer = current_layer - 1
    return False          
    
    
    
        


def contains_merkle_proof_verification(call_path):
    
    abi_encode_values_with_two_args = {}
    func_in_the_loop = []
    current_func_idx = 0
    
    
    while(current_func_idx < len(call_path)):
        func = call_path[current_func_idx]
        keccak_lvalues = [] 
        for node in func.nodes:
            for ir in node.irs:
                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                        or ir.function == SolidityFunction("keccak256(uint256,uint256)")):
                            keccak_lvalues.append(ir.lvalue)
                if isinstance(ir, Assignment):
                    if any([var in keccak_lvalues for var in ir.variables]):
                        keccak_lvalues.append(ir.lvalue)
                
                
        for node in func.nodes:
            move_to_next_layer = False

            for ir in node.irs:
                if (isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall)) and (current_func_idx < len(call_path) - 1 and ir.function == call_path[current_func_idx + 1]):
                    move_to_next_layer = True
                    
                    if any([n.type == NodeType.IFLOOP for n in node.dominators]):
                        
                            func_in_the_loop.append(ir.function)
                    break
                
                
                
                
                if isinstance(ir, SolidityCall) and (
                    ir.function == SolidityFunction("abi.encode()") or
                    ir.function == SolidityFunction("abi.encodePacked()")
                ):
                    if len(ir.arguments) == 2 and (ir.arguments[0].type == ElementaryType("bytes32") and ir.arguments[1].type == ElementaryType("bytes32")):
                        if ir.arguments[0] in keccak_lvalues or ir.arguments[1] in keccak_lvalues:
                            abi_encode_values_with_two_args[ir.lvalue] = ir.arguments
                if isinstance(ir, SolidityCall):
                    if ((ir.function == SolidityFunction("keccak256(bytes)")) and ir.arguments[0] in abi_encode_values_with_two_args) :
                            if any([n.type == NodeType.IFLOOP for n in node.dominators]) or func in func_in_the_loop:
                                
                                if contains_check(call_path, ir):
                                    return ir
                    elif ir.function == SolidityFunction("keccak256(uint256,uint256)"):
                        if func in func_in_the_loop:
                            if contains_check(call_path, ir):
                                return ir
            
            if move_to_next_layer :
                break
        current_func_idx = current_func_idx + 1
            
                
            
                

            
    return None

def get_merkle_proof_path(func: Function):
    merkle_proof_paths = []
    call_path = []

    def dfs(current_func: Function):
        if isinstance(current_func, Function) or isinstance(current_func, FunctionContract):
            if current_func not in call_path:
                call_path.append(current_func)
            else:
                return
            for call in current_func.internal_calls:
                dfs(call)
            for contract, call in current_func.library_calls:
                dfs(call)
            for contract, f in current_func.high_level_calls:
                dfs(f)
            merkle_proof_verify_ir = contains_merkle_proof_verification(call_path) 
            if merkle_proof_verify_ir is not None:
                merkle_proof_paths.append((tuple(call_path.copy()), merkle_proof_verify_ir))
            call_path.pop() 

    dfs(func)
    merkle_proof_paths = list(set(merkle_proof_paths))
    
    
    return merkle_proof_paths



    
def contains_msg_sender_protector(call_path, merkle_ir):
    current_func_idx = 0
    param_tainted_by_address = []
    while(current_func_idx < len(call_path)):
        func = call_path[current_func_idx]
        current_layer_taints = [SolidityVariableComposed("msg.sender")]

        for n in call_path[current_func_idx].nodes:
            move_to_next_layer = False
            for ir in n.irs:
                
                if isinstance(ir, InternalCall) and (current_func_idx < len(call_path) - 1 and ir.function == call_path[current_func_idx + 1]):
                    new_param_tainted_by_address = []
                    for idx in range(0, len(ir.arguments)):
                        if any([is_dependent(ir.arguments[idx], taint, func) for taint in current_layer_taints]) \
                        or any([is_dependent(ir.arguments[idx], func.parameters[x], func) for x in range(0,len(func.parameters)) if x in param_tainted_by_address]):
                            new_param_tainted_by_address.append(idx)
                    param_tainted_by_address = new_param_tainted_by_address.copy()
                    
                    move_to_next_layer = True
                    break
                elif isinstance(ir, HighLevelCall) and (current_func_idx < len(call_path) - 1 and ir.function == call_path[current_func_idx + 1]):
                    new_param_tainted_by_address = []
                    for idx in range(0, len(ir.arguments)):
                        if any([is_dependent(ir.arguments[idx], taint, func) for taint in current_layer_taints]) \
                        or any([is_dependent(ir.arguments[idx], func.parameters[x], func) for x in range(0,len(func.parameters)) if x in param_tainted_by_address]):
                            new_param_tainted_by_address.append(idx)
                    param_tainted_by_address = new_param_tainted_by_address.copy()
                    
                    move_to_next_layer = True
                    break
                
                if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall):
                    if SolidityVariableComposed('msg.sender') in ir.arguments or (hasattr(ir.function, 'variables_read') and SolidityVariableComposed('msg.sender') in ir.function.variables_read):
                        if SolidityFunction("keccak256(bytes)") in ir.function.solidity_calls or \
                            SolidityFunction("keccak256()") in ir.function.solidity_calls:
                                current_layer_taints.append(ir.lvalue)
                                return True
                                
                
                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                    or ir.function == SolidityFunction("keccak256()")
                    or ir.function == SolidityFunction("sha3()")
                    or ir.function == SolidityFunction("abi.encodePacked()")
                    or ir.function == SolidityFunction("abi.encode()")):
                    for argument in ir.arguments:
                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]) \
                        or any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address]):
                            current_layer_taints.append(ir.lvalue)
                            return True
                elif (isinstance(ir, InternalCall) or isinstance(ir, LibraryCall)):
                    for argument in ir.arguments:
                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]) \
                        or any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address]):
                            current_layer_taints.append(ir.lvalue)
                            break

                elif ir == merkle_ir:
                    
                    for argument in ir.arguments:
                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]):
                            return True
                        if  any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address  ]):
                            return True
            if move_to_next_layer :
                break
        current_func_idx = current_func_idx + 1 
    return False    


def contains_nonce_protectors(call_path, contract, merkle_ir):
    
    pre_image_parameters = merkle_pre_image_tx_param_analysis(call_path, merkle_ir)
    
    read_set, write_set = read_write_set(call_path)
    potential_protectors = list(read_set & write_set)
    
    contains_msg_sender_check = contains_msg_sender_protector(call_path, merkle_ir)
    all_called_function = list(call_relations(call_path).keys())
    for (func_idx, func) in enumerate(call_path):
        for n in func.nodes:
            for ir in n.irs:
                if isinstance(ir, Index):
                    
                    if ir.variable_left in potential_protectors:
                        if any([is_dependent(ir.variable_right, func.parameters[param_idx], func) for param_idx in pre_image_parameters[func_idx]]):
                            
                            return True
                        elif is_dependent(ir.variable_right, SolidityVariableComposed("msg.sender"), func) :
                            
                            return True
                        potential_protectors.append(ir.lvalue)
                elif isinstance(ir, LibraryCall) or isinstance(ir, HighLevelCall) or isinstance(ir, InternalCall):
                    if len(set(ir.function.state_variables_read) & set(potential_protectors)) > 0:
                        for arg in ir.arguments:
                            if any([is_dependent(arg, func.parameters[param_idx], func) for param_idx in pre_image_parameters[func_idx]]):
                                
                                return True

                        
    return False

class MerkleProofReplay(AbstractDetector):
    """
    If the return value of a low-level call to Ecreciver is not checked, it might lead to losing ether
    """

    ARGUMENT = "merkle-proof-replay"
    HELP = "Merkle Proof Replay"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = " "

    WIKI_TITLE = "Merkle Proof Replay"
    WIKI_DESCRIPTION = " "

    
    WIKI_EXPLOIT_SCENARIO = """ 
    """
    

    WIKI_RECOMMENDATION = " "


    def _detect(self) -> List[Output]:
        

        ret = []
        results = []
        
        for c in self.compilation_unit.contracts_derived:
            for f in c.functions:
                if f.visibility in ['internal', 'private'] or f.view:
                    continue
                merkle_proof_paths = get_merkle_proof_path(f)
                for (call_path, merkle_ir) in merkle_proof_paths:
                    
                    if not ( ((contains_balance_protector(call_path, c))) \
                        or contains_nonce_protectors(call_path, c, merkle_ir)):
                        ret.append((call_path[0], call_path[-1]))
                
                
                    
                        
            for f1, fn in ret:
                info: DETECTOR_INFO = [f1, '->', fn, "allows merkle proof replay"]
                res = self.generate_result(info)
                results.append(res)

        return results
    
