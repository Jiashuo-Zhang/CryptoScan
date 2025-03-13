from CryptoScan.detectors.abstract_detector import AbstractDetector, DetectorClassification
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall, HighLevelCall
from CryptoScan.core.declarations.solidity_variables import (
    SolidityFunction,
)
from CryptoScan.analyses.data_dependency.data_dependency import is_dependent
from CryptoScan.core.declarations.solidity_variables import (
    SolidityVariable,
    SolidityFunction,
    SolidityVariableComposed,
)
from CryptoScan.core.variables.state_variable import StateVariable
from CryptoScan.core.solidity_types import ElementaryType

from CryptoScan.slithir.operations.event_call import EventCall
from CryptoScan.slithir.variables import ReferenceVariable

from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return, TypeConversion, Member, Unary
from CryptoScan.core.declarations import Function, FunctionContract, Contract
from CryptoScan.core.declarations.modifier import Modifier
from CryptoScan.core.declarations.solidity_variables import (
    SolidityVariable,
    SolidityFunction,
    SolidityVariableComposed,
)
from CryptoScan.detectors.abstract_detector import (
    AbstractDetector,
    DetectorClassification,
    DETECTOR_INFO,
)


def pre_image_tx_param_analysis(call_path, ecrecover_arg_slot = 0):
    
    pre_image_parameters = {}
    current_layer = len(call_path) - 1
    while(current_layer >= 0):
        pre_image_parameters[current_layer] = []
        func = call_path[current_layer]
        if current_layer == len(call_path) - 1:
            for node in func.nodes: 
                ecrecover_call_irs = [ir for ir in node.irs if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") or ir.function == SolidityFunction("ecrecover()"))]
                for ecrecover_call_ir in ecrecover_call_irs:
                    for param_idx in range(0, len(func.parameters)):
                        if is_dependent(ecrecover_call_ir.arguments[ecrecover_arg_slot], func.parameters[param_idx], func):
                            pre_image_parameters[current_layer].append(param_idx)
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
                    if arg in assignment and (assignment[arg] not in all_call_return_value[ret]):
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

def call_relations(call_path):
    called_by = {}

    def collect_calls(func, visited):
        if func in visited:
            return
        if isinstance(func, SolidityFunction) or isinstance(func, StateVariable):
            return
        visited.add(func)
        called_functions = [f for (_, f) in func.high_level_calls + func.library_calls]
        called_functions += func.internal_calls
        
        for cf in called_functions:
            if isinstance(cf, StateVariable):
                continue
            if cf not in called_by:
                called_by[cf] = {func}
            else:
                called_by[cf].add(func)
            
            collect_calls(cf, visited)
            
    visited = set()
    for func in call_path:
        collect_calls(func, visited)
    
    return called_by

def storage_changing_funcs(call_path):
    storage_changing_funcs = set()
    called_by = call_relations(call_path)
    
    current_len = 1
    while current_len > len(storage_changing_funcs):
        current_len = len(storage_changing_funcs)
        for f in called_by:
            if isinstance(f, SolidityFunction):
                continue
            
            if len(f.state_variables_written) > 0 or (isinstance(f, FunctionContract) and f.contract_declarer.is_interface):
                storage_changing_funcs.add(f)
                storage_changing_funcs.update(called_by[f])
        idx = 0
        storage_changing_funcs = list(storage_changing_funcs)
        while(idx < len(storage_changing_funcs)):
            
            if storage_changing_funcs[idx] in called_by:
                for j in called_by[storage_changing_funcs[idx]]:
                    if j not in storage_changing_funcs:
                        storage_changing_funcs.append(j)
            idx = idx + 1
    return storage_changing_funcs


def contains_taint_condition_protector(current_func, taint, tainted_param_idx = [], visited = []):
    
    
    
    
    

    sanitized = False
    current_func_taints = [taint]
    
    
    
    tainted_return_value = False
    
    whitelist = [SolidityVariableComposed('tx.origin')]
    non_eq_taints = []
    for node in current_func.nodes:
        for ir in node.irs:
            if isinstance(ir, TypeConversion):
                if ir.type == ElementaryType('address') and (ir.variable == 0 or ir.variable == SolidityVariable('this')):
                    whitelist.append(ir.lvalue)
            if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall) or isinstance(ir, SolidityCall):
                for arg in ir.arguments:
                    if isinstance(arg, list):
                        continue
                    if any([is_dependent(arg, taint, current_func) for taint in current_func_taints]):
                        current_func_taints.append(ir.lvalue)
            if isinstance(ir, Assignment):
                for value in ir.variables:
                    if any([is_dependent(value, taint, current_func) for taint in current_func_taints]):
                        current_func_taints.append(ir.lvalue)
            
    

    
    potential_sanitized = []
    for node in current_func.nodes:
        for ir in node.irs:
            if isinstance(ir, Unary):
                if ir.rvalue in current_func_taints:
                    current_func_taints.append(ir.lvalue)
                    potential_sanitized.append(ir.lvalue)
            if isinstance(ir, Binary) and (not ir.type.not_exclusive()) and ir.type.return_bool(ir.type):
                s = (ir.variable_left in current_func_taints and ir.variable_right not in whitelist) or (ir.variable_right in current_func_taints and ir.variable_left not in whitelist)
                if s :
                    
                    current_func_taints.append(ir.lvalue)
                    potential_sanitized.append(ir.lvalue)
            if isinstance(ir, Index):
                if ir.variable_right in current_func_taints and ir.lvalue.type == ElementaryType("bool"):
                    potential_sanitized.append(ir.lvalue)
            if isinstance(ir, SolidityCall) and  (
                    ir.function == SolidityFunction("assert(bool)") \
                    or ir.function == SolidityFunction("require(bool)") \
                    or ir.function == SolidityFunction("require(bool,string)")
                ):
                
                if ir.arguments[0] in potential_sanitized or ir.arguments[0] in current_func_taints: 
                    sanitized = True
                    
            elif isinstance(ir, Condition):
                if ir.value in potential_sanitized or ir.value in current_func_taints: 
                    sanitized = True
                    
            elif isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall):
                if isinstance(ir.function, StateVariable):
                    continue
                if isinstance(ir.function, Modifier):
                    for arg in ir.arguments:
                        if any([is_dependent(arg, taint, current_func) for taint in current_func_taints]):
                            sanitized = True
                taint_params = []
                for idx, arg in enumerate(ir.arguments):
                    if any([is_dependent(arg, taint, current_func) for taint in current_func_taints]):
                        taint_params.append(idx)
                        tainted_return, s = contains_taint_condition_protector(ir.function, taint, taint_params, visited)
                        sanitized = sanitized | s
                        if tainted_return:
                            
                            current_func_taints.append(ir.lvalue)
                        break
                        
            if isinstance(ir, Return):
                for return_value in ir.values:
                    if any([is_dependent(return_value, taint, current_func) for taint in current_func_taints]):
                        return True, sanitized
    return tainted_return_value, sanitized



    


    
    






















                















    


def unprotected_storage_change(call_path, pre_image_tx_params):
    
    
    storage_changing_functions = storage_changing_funcs(call_path)
    
    
    is_protected = {}
    lead_to_storage = False
    
    tainted = False
    params_not_protected_by_signature = []
    params_not_protected_by_signature.append(SolidityVariableComposed("msg.sender"))
    Ref2StateVars = []
    for func_idx, func in enumerate(call_path):
        
        
        
        for node in func.nodes:
            if node.is_conditional():
                
                called_funcs = []
                for ir in node.irs:
                    if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall):
                        called_funcs.append(ir.function)
                for called_func in called_funcs:
                    for param in params_not_protected_by_signature:
                        if param == SolidityVariableComposed("msg.sender") :
                            _, sanitized = contains_taint_condition_protector(called_func, SolidityVariableComposed("msg.sender"))
                            if sanitized:
                                
                                
                                return False
        _, sanitized = contains_taint_condition_protector(func, SolidityVariableComposed("msg.sender"))
        if sanitized:
            
            
            return False
                
                
                
        if SolidityVariableComposed("msg.sender") not in params_not_protected_by_signature:
            return False
        
        
    for func_idx, func in enumerate(call_path):
        if lead_to_storage:
            break
        for node in func.nodes:
            for ir in node.irs:
                
                if isinstance(ir, InternalCall) or isinstance(ir, SolidityCall) or  isinstance(ir, LibraryCall) or isinstance(ir, HighLevelCall):
                    for arg in ir.arguments:
                        if isinstance(arg, list):
                            continue
                        if any([is_dependent(arg, taint, func) for taint in params_not_protected_by_signature]):
                            params_not_protected_by_signature.append(ir.lvalue)
                    if ir.function in storage_changing_functions:  
                        
                        for param in ir.arguments: 
                            if any([is_dependent(param, x, func) for x in params_not_protected_by_signature]):
                                tainted = True
                        if (isinstance(ir, InternalCall) or isinstance(ir, SolidityCall)) and (SolidityVariableComposed("msg.sender") in ir.function._vars_read) or (isinstance(ir.function, FunctionContract) and ir.function.contract_declarer.is_interface and SolidityVariableComposed("msg.sender") in ir.arguments):
                            tainted = True
                elif isinstance(ir, EventCall):
                    for arg in ir.arguments:
                        if isinstance(arg, list):
                            continue
                        if any([is_dependent(arg, taint, func) for taint in params_not_protected_by_signature]):
                            tainted = True

                    
                        
                        
                        
                elif isinstance(ir, Member):
                    if  hasattr(ir.variable_left, 'is_storage') and ir.variable_left.is_storage and ir.variable_right in params_not_protected_by_signature:
                        Ref2StateVars.append(ir.lvalue)

                elif isinstance(ir, TypeConversion):
                    if any([is_dependent(ir.variable, taint, func) for taint in params_not_protected_by_signature]):
                        params_not_protected_by_signature.append(ir.lvalue)

                elif isinstance(ir, Index):
                    if any([is_dependent(ir.variable_right, taint, func) for taint in params_not_protected_by_signature]):
                        params_not_protected_by_signature.append(ir.lvalue)

                elif isinstance(ir, Assignment):
                    for var in ir.variables:
                        taint_storage = any([is_dependent(var, taint, func) and (isinstance(ir.lvalue, StateVariable)) for taint in params_not_protected_by_signature])
                        taint_var = any([is_dependent(var, taint, func)  for taint in params_not_protected_by_signature])
                        if taint_var:
                            params_not_protected_by_signature.append(ir.lvalue)
                        tainted = tainted | taint_storage
                    
                elif isinstance(ir, Binary):
                    taint_storage = any([is_dependent(ir.lvalue, taint, func) and (isinstance(ir.lvalue, StateVariable)) for taint in params_not_protected_by_signature])
                    taint_var = any([ is_dependent(ir.lvalue, taint, func)  for taint in params_not_protected_by_signature])
                    tainted = tainted | taint_storage
                    if taint_var:
                        params_not_protected_by_signature.append(ir.lvalue)
                    
                
                
                if tainted:
                    
                    lead_to_storage = True
                    break
                            
                
    return lead_to_storage

def get_ecrecover_calls_recursively(func: Function):
    ecrecover_calls = []
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
            ecrecover_calls.extend( 
                [(tuple(call_path.copy()), x) for x in current_func.internal_calls 
                 if x == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") 
                 or x == SolidityFunction("ecrecover()")]
            )
            call_path.pop() 

    dfs(func)
    ecrecover_calls = list(set(ecrecover_calls))
    
    
    return ecrecover_calls




class SignatureFrontRunning(AbstractDetector):
    """
    Documentation
    """

    ARGUMENT = 'sig-front-run' 
    HELP = 'Signature Frontrunning'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = ' '

    WIKI_TITLE = ' '
    WIKI_DESCRIPTION = ' '
    WIKI_EXPLOIT_SCENARIO = ' '
    WIKI_RECOMMENDATION = ' '

    def _detect(self):
        

        info = ['Signature Frontrunning']
        ret = []
        
        func_has_msg_sender_hashes = []
        for c in self.compilation_unit.contracts_derived:
            for f in c.functions:
                for n in f.nodes:
                    for ir in n.irs:
                        if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                            or ir.function == SolidityFunction("keccak256()")
                            or ir.function == SolidityFunction("sha3()")):
                                if any([is_dependent(arg, SolidityVariableComposed("msg.sender"),f) for arg in ir.arguments]):  
                                    func_has_msg_sender_hashes.append(f)
                                break
                
        for c in self.compilation_unit.contracts_derived:
            for f in c.functions:
                if f.visibility in ['internal', 'private'] or f.view:
                    continue
                ecrecover_to_check = get_ecrecover_calls_recursively(f)
                if len(ecrecover_to_check) == 0:
                    continue
                hash_calls = {} 
                
                                    
                for check_task in ecrecover_to_check:
                    call_path, _ = check_task
                    call_path = list(call_path)
                    
                    current_func_idx = 0
                    param_tainted_by_msg_sender = []
                    while(current_func_idx < len(call_path)):
                        func = call_path[current_func_idx]
                        current_layer_taints = [SolidityVariableComposed("msg.sender")]

                        for n in call_path[current_func_idx].nodes:
                            move_to_next_layer = False
                            for ir in n.irs:
                                
                                if isinstance(ir, InternalCall) and (current_func_idx < len(call_path) - 1 and ir.function == call_path[current_func_idx + 1]):
                                    new_param_tainted_by_msg_sender = []
                                    for idx in range(0, len(ir.arguments)):
                                        if any([is_dependent(ir.arguments[idx], taint, func) for taint in current_layer_taints]) \
                                        or any([is_dependent(ir.arguments[idx], func.parameters[x], func) for x in range(0,len(func.parameters)) if x in param_tainted_by_msg_sender]):
                                            new_param_tainted_by_msg_sender.append(idx)
                                    param_tainted_by_msg_sender = new_param_tainted_by_msg_sender.copy()
                                    
                                    move_to_next_layer = True
                                    break
                                elif isinstance(ir, HighLevelCall) and (current_func_idx < len(call_path) - 1 and ir.function == call_path[current_func_idx + 1]):
                                    new_param_tainted_by_msg_sender = []
                                    for idx in range(0, len(ir.arguments)):
                                        if any([is_dependent(ir.arguments[idx], taint, func) for taint in current_layer_taints]) \
                                        or any([is_dependent(ir.arguments[idx], func.parameters[x], func) for x in range(0,len(func.parameters)) if x in param_tainted_by_msg_sender]):
                                            new_param_tainted_by_msg_sender.append(idx)
                                    param_tainted_by_msg_sender = new_param_tainted_by_msg_sender.copy()
                                    
                                    move_to_next_layer = True
                                    break
                                
                                
                                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                                    or ir.function == SolidityFunction("keccak256()")
                                    or ir.function == SolidityFunction("sha3()")
                                    or ir.function == SolidityFunction("abi.encodePacked()")
                                    or ir.function == SolidityFunction("abi.encode()")):
                                    for argument in ir.arguments:
                                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]) \
                                        or any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_msg_sender]):
                                            current_layer_taints.append(ir.lvalue)
                                            break
                                    hash_calls[ir.lvalue] = ir.arguments
                                    
                                elif (isinstance(ir, InternalCall) or isinstance(ir, LibraryCall) or isinstance(ir, HighLevelCall)):
                                    for argument in ir.arguments:
                                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]) \
                                        or any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_msg_sender]):
                                            current_layer_taints.append(ir.lvalue)
                                            break
                                    if ir.function in func_has_msg_sender_hashes:
                                        current_layer_taints.append(ir.lvalue)
                                    

                                elif isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") or ir.function == SolidityFunction("ecrecover()")):
                                    
                                    if not any([is_dependent(ir.arguments[0], taint, func) for taint in current_layer_taints]):
                                        if not any([is_dependent(ir.arguments[0], func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_msg_sender]):
                                            
                                            if unprotected_storage_change(call_path, pre_image_tx_param_analysis(call_path)):
                                                ret.append((call_path[0], func, n))
                            if move_to_next_layer :
                                break
                        current_func_idx = current_func_idx + 1
        results = []
        for external,f,node in ret:
            info: DETECTOR_INFO = [external, '->', f, "allows signature front running "]
            res = self.generate_result(info)
            results.append(res)

        return results