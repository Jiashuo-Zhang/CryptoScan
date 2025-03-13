"""
Module detecting unused return values from low level
"""
import re
from typing import List

from CryptoScan.core.cfg.node import Node, NodeType
from CryptoScan.core.variables.top_level_variable import TopLevelVariable
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall, HighLevelCall
from CryptoScan.analyses.data_dependency.data_dependency import is_dependent

from CryptoScan.core.declarations.function_contract import FunctionContract
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return, Member


from CryptoScan.core.variables.state_variable import StateVariable
from CryptoScan.detectors.abstract_detector import (
    AbstractDetector,
    DetectorClassification,
    DETECTOR_INFO,
)
from CryptoScan.core.declarations.solidity_variables import (
    SolidityFunction,
)
from CryptoScan.utils.output import Output



from .signature_frontrunning import pre_image_tx_param_analysis
from CryptoScan.core.declarations import Function

def get_ecmul_calls_recursively(func: Function):
    ecmul_calls = []
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
            if contains_ecmul_call(call_path):
                ecmul_calls.append(tuple(call_path))
            call_path.pop() 

    dfs(func)
    ecmul_calls = list(set(ecmul_calls))
    
    
    return ecmul_calls



def contains_ecmul_call(call_path):
    for func in call_path:
        for node in func.nodes:
            if node.type == NodeType.ASSEMBLY:
                
                if "assembly" not in func.source_mapping.content:
                    continue
                
                for call_type, address, params in extract_inline_precompiled_call_info(func.source_mapping.content):
                    try:
                        if int(address) == 7:
                            
                            return True
                    except:
                        continue
    return False

def pre_image_tx_param_analysis(call_path):
    
    pre_image_parameters = {}
    current_layer = len(call_path) - 1
    while(current_layer >= 0):
        pre_image_parameters[current_layer] = []
        func = call_path[current_layer]
        if current_layer == len(call_path) - 1:
                pre_image_parameters[current_layer] = extract_ecmul_parameters(func)
        else:
            all_call_return_value = {} 
            assignment = {} 
            for node in func.nodes:
                for ir in node.irs:
                    if (isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, SolidityCall) or isinstance(ir, LibraryCall)):
                        all_call_return_value[ir.lvalue] = ir.arguments
                    if isinstance(ir, Assignment):
                        assignment[ir.lvalue] = ir.rvalue
            for ret in all_call_return_value:
                for arg in all_call_return_value[ret] :
                    if isinstance(arg, list):
                        continue
                    if arg in assignment and assignment[arg] not in all_call_return_value[ret]:
                        all_call_return_value[ret].append(assignment[arg])
                    if arg in all_call_return_value:
                        for x in all_call_return_value[arg]:
                            if x not in all_call_return_value[ret]:
                                all_call_return_value[ret].append(x)
                    
                
            for node in func.nodes:
                next_func_calls = [ir for ir in node.irs if (isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall)) and (ir.function == call_path[current_layer + 1])]
                for next_func_call in next_func_calls:
                    for param_idx in range(0, len(func.parameters)):
                        if any([is_dependent(next_func_call.arguments[arg_idx], func.parameters[param_idx],func) for arg_idx in (range(0, len(next_func_call.arguments))) if arg_idx in pre_image_parameters[current_layer + 1]]):
                            pre_image_parameters[current_layer].append(param_idx)
                        for param_idx in range(0, len(func.parameters)):
                            if func.parameters[param_idx] in all_call_return_value[next_func_call.lvalue]:
                                pre_image_parameters[current_layer].append(param_idx)
        current_layer = current_layer - 1
        
    return pre_image_parameters


def extract_ecmul_parameters(func: Function):
    tainted_params = []
    for node in func.nodes:
        if node.type == NodeType.ASSEMBLY:
            for call_type, address, params in extract_inline_precompiled_call_info(func.source_mapping.content):
                if int(address) == 7:
                    tainted_vars = ([x for x in func.variables if x.name in params])
                    for var in tainted_vars:
                        for param_idx, param in enumerate(func.parameters):
                            if is_dependent(var, param, func):
                                tainted_params.append(param_idx)
                    
    return tainted_params


def extract_inline_precompiled_call_info(asm_code: str):
    """
    从内联汇编代码中提取 call, staticcall, delegatecall 和 callcode 信息。

    Args:
        asm_code (str): 内联汇编代码字符串。

    Returns:
        list of tuples: 每个元组包含 (call_type, address)，表示调用类型和对应的地址参数。
    """
    
    if asm_code is None:
        return []
    asm_code = asm_code.replace(" ", "").replace("\n", "")
    
    
    call_types = ["staticcall", "delegatecall", "callcode", "call"]
    results = []

    for call_type in call_types:
        if call_type == 'call' and ("delegatecall" in asm_code or "staticcall" in asm_code):
            continue
        search_str = call_type + "("
        start_pos = asm_code.find(search_str)
        while start_pos != -1:
            
            start_pos += len(search_str)
            bracket_count = 1
            param_start_index = start_pos
            
            
            while bracket_count > 0 and param_start_index < len(asm_code):
                char = asm_code[param_start_index]
                if char == "(":
                    bracket_count += 1
                elif char == ")":
                    bracket_count -= 1
                elif char == "," and bracket_count == 1:
                    
                    break
                param_start_index += 1

            
            param_start_index += 1
            param_end_index = param_start_index
            
            while param_end_index < len(asm_code):
                char = asm_code[param_end_index]
                if char == "," and bracket_count == 1:
                    
                    break
                elif char == "(":
                    bracket_count += 1
                elif char == ")":
                    bracket_count -= 1
                param_end_index += 1

            
            call_address = asm_code[param_start_index:param_end_index]
            
            
            
            param_start_index = param_end_index + 1
            param_end_index = param_start_index
            
            while param_end_index < len(asm_code):
                char = asm_code[param_end_index]
                if char == "," and bracket_count == 1:
                    
                    break
                elif char == "(":
                    bracket_count += 1
                elif char == ")":
                    bracket_count -= 1
                param_end_index += 1
            if call_type not in ["staticcall", 'delegatecall']:
                param_start_index = param_end_index + 1
            param_end_index = param_start_index
            
            while param_end_index < len(asm_code):
                char = asm_code[param_end_index]
                if char == "," and bracket_count == 1:
                    
                    break
                elif char == "(":
                    bracket_count += 1
                elif char == ")":
                    bracket_count -= 1
                param_end_index += 1
                
            input_var_str = asm_code[param_start_index:param_end_index]
            pattern = r'[a-zA-Z_][a-zA-Z0-9_]*'
            
            matches = re.findall(pattern, input_var_str)
                
            results.append((call_type, call_address, matches))
            
            start_pos = asm_code.find(search_str, param_end_index)

    return results


class ProofMalleability(AbstractDetector):
    """
    """

    ARGUMENT = "proof-mal"
    HELP = "Proof Malleability"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = " "

    WIKI_TITLE = " "
    WIKI_DESCRIPTION = " "

    
    WIKI_EXPLOIT_SCENARIO = """ 
    """
    

    WIKI_RECOMMENDATION = "Ensure that there is protection against Proof Malleability."


    def _detect(self) -> List[Output]:
        

        results = []
        ret = []
        func_that_call_scalar_ecmul = {} 
        scalar_consts = [21888242871839275222246405745257275088548364400416034343698204186575808495617]

        for c in self.compilation_unit.contracts_derived:
            for func in c.functions:
                for node in func.nodes:
                    for ir in node.irs:
                        
                        if isinstance(ir, Assignment):
                            if any([var in scalar_consts for var in ir.variables]):
                                scalar_consts.append(ir.lvalue)

                            
        
        if len(set(scalar_consts)) > 1:
            return []
        for c in self.compilation_unit.contracts_derived:
            for func in c.functions:                  
                if func.visibility in ['internal', 'private'] :
                    continue

                ecmul_calls = get_ecmul_calls_recursively(func)
                for call_path in ecmul_calls:
                    
                    params = pre_image_tx_param_analysis(call_path)
                    checked_malleability = False
                    for idx, func in enumerate(call_path):
                        scalar_checks = []
                        param_s = [func.parameters[i] for i in params[idx]]
                        if checked_malleability:
                            break
                        for n in func.nodes:
                            for ir in n.irs:
                                if isinstance(ir, Binary):
                                    if ir.variable_left in scalar_consts or ir.variable_right in scalar_consts:
                                        scalar_checks.append(ir.lvalue)
                                        
                                        checked_malleability = True
                                    elif isinstance(ir.variable_left, TopLevelVariable) or isinstance(ir.variable_right, TopLevelVariable):
                                        scalar_checks.append(ir.lvalue)
                                        checked_malleability = True
                                
                                    
                                    
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                                
                    if not checked_malleability:
                        ret.append(call_path)
                    else:
                        
                        break
        
        
        
        
        
        
        
        

        for call_path in ret:
            info: DETECTOR_INFO = [call_path[0], "does not contain protect agains proof malleability "]
            res = self.generate_result(info)
            results.append(res)

        return results
