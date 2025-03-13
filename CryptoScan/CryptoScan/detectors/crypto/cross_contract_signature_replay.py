from CryptoScan.core.variables.state_variable import StateVariable
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
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return
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



def call_relations(contract: Contract):
    called_by = {}

    def collect_calls(func, visited):
        if func in visited:
            return
        if isinstance(func, SolidityFunction):
            return
        visited.add(func)
        called_functions = [f for (_, f) in func.high_level_calls + func.library_calls]
        called_functions += func.internal_calls
        called_functions += func.modifiers
        for cf in called_functions:
            if isinstance(cf, StateVariable):
                continue
            if cf not in called_by:
                called_by[cf] = {func}
            else:
                called_by[cf].add(func)
            
            collect_calls(cf, visited)
            
    visited = set()
    for func in contract.functions_and_modifiers:
        collect_calls(func, visited)

    return called_by

def contains_domain_seperator_protector(contract, call_path):
    domain_seperator_funcs = domain_seperator_functions(contract)
    called_functions = call_relations(contract)

    if any([func in called_functions for func in domain_seperator_funcs]):
        
        return True
    return False

def domain_seperator_functions(contract: Contract):
    domain_seperator_functions = []
    for func in contract.functions_and_modifiers:
        for node in func.nodes:
            for ir in node.irs:
                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                            or ir.function == SolidityFunction("keccak256()") \
                            or ir.function == SolidityFunction("sha3()") or ir.function == SolidityFunction("sha256(bytes)")):
                    if any([is_dependent(arg, SolidityVariable("this"), func) for arg in ir.arguments]):
                        domain_seperator_functions.append(func)
    return domain_seperator_functions

def domain_seperator_state_variables(contract: Contract):
    state_protectors = []
    for func in contract.functions_and_modifiers:
        keccak_taints = []
        for node in func.nodes:
            for ir in node.irs:
                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                            or ir.function == SolidityFunction("keccak256()") \
                            or ir.function == SolidityFunction("sha3()") or ir.function == SolidityFunction("sha256(bytes)")):
                    if any([is_dependent(arg, SolidityVariable("this"), func) for arg in ir.arguments]):
                        keccak_taints.append(ir.lvalue)
                if isinstance(ir, Assignment):
                    if isinstance(ir.lvalue, StateVariable):
                        for val in ir.variables:
                            if val in keccak_taints:
                                state_protectors.append(ir.lvalue)
    
    return state_protectors
class CrossContractSignatureReplay(AbstractDetector):
    """
    Documentation
    """

    ARGUMENT = 'cross-contract-sig' 
    HELP = 'Cross Contract Signature Replay'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = ' '

    WIKI_TITLE = ' '
    WIKI_DESCRIPTION = ' '
    WIKI_EXPLOIT_SCENARIO = ' '
    WIKI_RECOMMENDATION = ' '

    def _detect(self):
        

        info = ['Cross Contract Signature Replay ']
        ret = []
        
        func_has_hashes = []
        for c in self.compilation_unit.contracts_derived:
            for f in c.functions:
                for n in f.nodes:
                    for ir in n.irs:
                        if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                            or ir.function == SolidityFunction("keccak256()")
                            or ir.function == SolidityFunction("sha3()")):
                                func_has_hashes.append(f)
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
                    param_tainted_by_address = []
                    while(current_func_idx < len(call_path)):
                        func = call_path[current_func_idx]
                        current_layer_taints = [SolidityVariable("this")]
                        current_layer_taints.extend(domain_seperator_state_variables(c))

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
                                    
                                    if not any([is_dependent(ir.arguments[0], taint, func) for taint in current_layer_taints]):
                                        if not any([is_dependent(ir.arguments[0], func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address  ]):
                                            
                                            if not contains_domain_seperator_protector(c, call_path):
                                                ret.append((call_path[0], func, n))
                            if move_to_next_layer :
                                break
                        current_func_idx = current_func_idx + 1
        results = []
        for external,f,node in ret:
            info: DETECTOR_INFO = [external, '->', f, " allows cross-contract signature replay: ", node, "\n"]
            res = self.generate_result(info)
            results.append(res)

        return results