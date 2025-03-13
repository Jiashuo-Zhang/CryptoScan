from CryptoScan.core.solidity_types.elementary_type import ElementaryType
from CryptoScan.core.solidity_types.mapping_type import MappingType
from CryptoScan.detectors.abstract_detector import AbstractDetector, DetectorClassification
from CryptoScan.slithir.operations.member import Member
from .cross_contract_signature_replay import get_ecrecover_calls_recursively
from CryptoScan.detectors.abstract_detector import AbstractDetector, DetectorClassification
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall, HighLevelCall, EventCall
from CryptoScan.slithir.variables.reference import ReferenceVariable
from CryptoScan.core.variables.state_variable import StateVariable


from CryptoScan.core.declarations.solidity_variables import (
    SolidityFunction,
)
from CryptoScan.analyses.data_dependency.data_dependency import is_dependent
from CryptoScan.core.declarations.solidity_variables import (
    SolidityVariable,
    SolidityFunction,
    SolidityVariableComposed,
)
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return, TypeConversion
from CryptoScan.core.declarations import Function, FunctionContract, Contract
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

from .signature_frontrunning import call_relations, pre_image_tx_param_analysis, storage_changing_funcs, contains_taint_condition_protector


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
                
                            

def contains_msg_sender_protector(call_path):
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
                    if SolidityVariableComposed('msg.sender') in ir.arguments or SolidityVariableComposed('msg.sender') in ir.function.variables_read:
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

                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") or ir.function == SolidityFunction("ecrecover()")):
                    
                    for argument in ir.arguments:
                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]):
                            return True
                        if  any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address  ]):
                            return True
            if move_to_next_layer :
                break
        current_func_idx = current_func_idx + 1 
    return False    


def contains_balance_protector(call_path, contract):
    read_set, write_set = read_write_set(call_path)
    potential_protectors = list(read_set & write_set)
    pre_image_parameters = pre_image_tx_param_analysis(call_path)

    all_called_function = list(call_relations(call_path).keys())
    all_called_function.extend(list(call_path))
    potential_balance_protectors = []
    for func in all_called_function:
        if isinstance(func, SolidityFunction):
            continue
        value2called_func = {}
        for node in func.nodes:
            for ir in node.irs:
                if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall):
                    func_read_set, _ = read_write_set([ir.function])
                    value2called_func[ir.lvalue] = func_read_set
                if isinstance(ir, Assignment):
                    for var in ir.variables:
                        if var in value2called_func:
                            value2called_func[ir.lvalue] = value2called_func[var]
        used_in_conditional = []
        tainted_var = {}
        for node in func.nodes:
            for ir in node.irs:
                if isinstance(ir, Index):
                    if ir.variable_left in potential_protectors:
                        tainted_var[ir.lvalue] = ir.variable_left
                elif isinstance(ir, Assignment):
                    for var in ir.variables:
                        if var in tainted_var:
                            tainted_var[ir.lvalue] = tainted_var[var]
                    
        
        for n in func.nodes:
            
            
            
            
                
                
                
                
            if n.contains_require_or_assert() or n.contains_if():
                used_in_conditional.extend(n._state_vars_read)
                for var in n._vars_read:
                    for slot in potential_protectors:
                        if is_dependent(var, slot, func):
                            used_in_conditional.append(slot)
                            break
                        for taint in tainted_var:
                            if is_dependent(var, taint, func):
                                used_in_conditional.append(tainted_var[taint])
                for ir in n.irs:
                    if isinstance(ir, Binary) and ir.type.return_bool:
                        vars = [ir.variable_left, ir.variable_right]
                        for var in vars:
                            for taint in value2called_func:
                                if is_dependent(var, taint, func):
                                    used_in_conditional.extend(value2called_func[taint])
                    if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall):
                        all_called_function = list(call_relations([ir.function]).keys())
                        all_called_function.append(ir.function)
                        for called_func in all_called_function:
                            if isinstance(called_func, SolidityFunction) or isinstance(called_func, StateVariable):
                                continue
                            func_read_set, func_write_set = read_write_set([called_func])
                            
                            used_in_conditional.extend(func_read_set)
        
        
        
        
        
        potential_balance_protectors.extend([x for x in list(set(potential_protectors) & set(used_in_conditional))]) 
    
        
    for func in call_path:
        if isinstance(func, SolidityFunction):
            continue
        for n in func.nodes:
            for ir in n.irs:
                if isinstance(ir, Index):
                    if ir.variable_left in potential_balance_protectors and is_dependent(ir.variable_right, SolidityVariableComposed('msg.sender'), func):
                        
                        return True
                    elif ir.variable_left in potential_balance_protectors and any([is_dependent(ir.variable_right, param, contract) for (param_idx, param) in enumerate(func.parameters)]):
                        
                        return True
                if isinstance(ir, Member):
                    
                    if any([is_dependent(ir.variable_left, protector, func) for protector in potential_balance_protectors]):
                        potential_balance_protectors.append(ir.lvalue)
                if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall):
                    for arg in ir.arguments:
                        if is_dependent(arg, SolidityVariableComposed('msg.sender'), func) or any([is_dependent(arg, param, func) for param in func.parameters]):
                            read_set, write_set = read_write_set([ir.function])
                            internal_protectors = list(read_set & write_set)
                            if len(set(internal_protectors) & set(potential_balance_protectors))>0 and any([x for x in set(internal_protectors) & set(potential_balance_protectors) if isinstance(x.type, MappingType)])> 0:
                                
                                return True
  
    return False















def read_write_set(call_path):
    all_executed_functions = list(call_relations(call_path).keys())
    all_executed_functions.extend(call_path)
    
    write_set = set()
    read_set = set()
    for func in all_executed_functions:
        if isinstance(func, SolidityFunction) or isinstance(func, StateVariable):
            continue
        for var in func.state_variables_written:
            write_set.add(var)
        for var in func.state_variables_read:
            read_set.add(var)
        taint2state = {}
        for node in func.nodes:
            for ir in node.irs:
                
                if isinstance(ir, Assignment):
                    if any([isinstance(var, StateVariable) for var in ir.variables]):
                        taint2state[ir.lvalue] = var
                    for var in ir.variables:
                        if isinstance(var, ReferenceVariable) and isinstance(var.points_to, StateVariable) :
                            taint2state[ir.lvalue] = var.points_to
                            break

                elif isinstance(ir, Index):
                    if isinstance(ir.variable_left, StateVariable):
                        taint2state[ir.lvalue] = ir.variable_left
                        
                if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall):
                    if isinstance(ir.function, StateVariable):
                        continue
                    func_read_param_idxs = [param_idx for (param_idx, param) in enumerate(ir.function.parameters) if param in ir.function.variables_written]
                    
                    written_args = [ arg for (arg_idx, arg) in enumerate(ir.arguments) if arg_idx in func_read_param_idxs]
                    for written_arg in written_args:
                        for taint in taint2state:
                            if is_dependent(written_arg, taint, func):
                                write_set.add(taint2state[taint])
                                read_set.add(taint2state[taint])
                    
                    for arg in written_args:
                        if isinstance(arg, ReferenceVariable) and isinstance(arg.points_to, StateVariable):
                            write_set.add(arg.points_to)
                            read_set.add(arg.points_to)
                        elif isinstance(arg, StateVariable):
                            read_set.add(arg)
                            write_set.add(arg)
                    
        
        


        
        
        
        
        
    return read_set, write_set


def var_used_in_signature(start_func, call_path, contract, var):
    
    after_start = False
    taints = [var]
    tx_param_used_in_signature = pre_image_tx_param_analysis(call_path)

    for (func_idx, func) in enumerate(call_path):  
        if func != start_func and not after_start:
            continue  
        elif func == start_func:
            after_start = True
        
        for node in func.nodes:
            for ir in node.irs:    
                
                if (isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall)) and ir.function in call_path:
                    
                    for arg in ir.arguments:
                        if any([is_dependent(arg, taint, func) for taint in taints]):
                            return True
                elif (isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall)):
                     for arg in ir.arguments:
                        if any([is_dependent(arg, taint, func) for taint in taints]):
                            taints.append(ir.lvalue)
                if isinstance(ir, SolidityCall) or isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall)  or isinstance(ir, LibraryCall):
                    for arg in ir.arguments:
                        if any([is_dependent(arg, taint, func) for taint in taints]):
                            taints.append(ir.lvalue)
                            break
                if isinstance(ir, Assignment):
                    for arg in ir.variables:
                        if any([is_dependent(arg, taint, func) for taint in taints]):
                            taints.append(ir.lvalue)
                            break
    return False


def contains_nonce_protectors(call_path, contract):
    
    pre_image_parameters = pre_image_tx_param_analysis(call_path)
    
    read_set, write_set = read_write_set(call_path)
    
    
    
    potential_protectors = list(read_set & write_set)
    
    Mapping_protected = [x for x in potential_protectors if isinstance(x.type, MappingType) and x.type._from == ElementaryType("address")]
    
    
    
    
    
    
    for (func_idx, func) in enumerate(call_path):    
        vars_tainted_by_nonce = []

        for node in func.nodes:
            for ir in node.irs:
                if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall) :
                    func_read_set, _,  = read_write_set([ir.function])
                    
                    
                    if len(set(func_read_set) & set(Mapping_protected)) > 0:
                        vars_tainted_by_nonce.append(ir.lvalue)
                if isinstance(ir, Index):
                    if ir.variable_left in Mapping_protected:
                        vars_tainted_by_nonce.append(ir.lvalue)
                        
        
        for var in vars_tainted_by_nonce:
            if var_used_in_signature(func, call_path, contract, var):
                return True
                        
                        
                    
    all_called_function = list(call_relations(call_path).keys())
    for (func_idx, func) in enumerate(call_path):
        for n in func.nodes:
            for ir in n.irs:
                if isinstance(ir, Index):
                    
                    if ir.variable_left in potential_protectors:
                        if any([is_dependent(ir.variable_right, func.parameters[param_idx], contract) for param_idx in pre_image_parameters[func_idx]]):
                            
                            return True
                        
                        
                        
                        potential_protectors.append(ir.lvalue)
                        
                        
    
    
    
    
    
    

                        
    return False

class SingleContractSignatureReplay(AbstractDetector):
    """
    Documentation
    """

    ARGUMENT = 'single-sig-replay' 
    HELP = 'Single Contract Signature Replay'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = ' '
    WIKI_TITLE = ' '
    WIKI_DESCRIPTION = ' '
    WIKI_EXPLOIT_SCENARIO = ' '
    WIKI_RECOMMENDATION = ' '
    
    

    def _detect(self):
        

        ret = []
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
                    
                    pre_image_tx_param_analysis(call_path)
                    current_func_idx = 0
                    param_tainted_by_address = []
                    while(current_func_idx < len(call_path)):
                        func = call_path[current_func_idx]
                        current_layer_taints = list(set(func.state_variables_written) & set(func._state_vars_read))
                        
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
                                
                                
                                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                                    or ir.function == SolidityFunction("keccak256()")
                                    or ir.function == SolidityFunction("sha3()")
                                    or ir.function == SolidityFunction("abi.encodePacked()")
                                    or ir.function == SolidityFunction("abi.encode()")):
                                    for argument in ir.arguments:
                                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]) \
                                        or any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address]):
                                            current_layer_taints.append(ir.lvalue)
                                            break
                                    hash_calls[ir.lvalue] = ir.arguments
                                    
                                elif (isinstance(ir, InternalCall) or isinstance(ir, LibraryCall)):
                                    for argument in ir.arguments:
                                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]) \
                                        or any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address]):
                                            current_layer_taints.append(ir.lvalue)
                                            break
                                    

                                elif isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") or ir.function == SolidityFunction("ecrecover()")):
                                    
                                    tainted = False
                                    if not any([is_dependent(ir.arguments[0], taint, func) for taint in current_layer_taints]):
                                        if not any([is_dependent(ir.arguments[0], func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address  ]):
                                            
                                            tainted = True
                                            protected = contains_nonce_protectors(call_path, c)
                                            protected = protected | ((contains_balance_protector(call_path, c) and (contains_msg_sender_protector(call_path) or not unprotected_storage_change(call_path, pre_image_tx_param_analysis(call_path)))))
                                            if not protected:
                                                ret.append((call_path[0], func, n))
                                    
                                    

                            if move_to_next_layer :
                                break
                        current_func_idx = current_func_idx + 1
        results = []
        for external,f,node in ret:
            info: DETECTOR_INFO = [external, '->', f, "allows single-contract signature replay:", node, "\n"]
            res = self.generate_result(info)
            results.append(res)
        

        return results