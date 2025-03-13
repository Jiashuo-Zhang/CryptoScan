from CryptoScan.core.cfg.node import NodeType
from CryptoScan.core.declarations.modifier import Modifier
from CryptoScan.core.variables.state_variable import StateVariable
from CryptoScan.detectors.abstract_detector import AbstractDetector, DetectorClassification
from CryptoScan.detectors.crypto.signature_frontrunning import call_relations
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall, HighLevelCall, TypeConversion
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
import re



def get_ecrecover_calls_recursively(func: Function):
    ecrecover_calls = []
    call_path = []
    
    def extend_call_path_with_modifier(call_path):
        new_call_path = []
        for func in call_path:
            new_call_path.append(func)
            modifiers = [x for x in func.internal_calls if isinstance(x, Modifier)]
            for modifier in modifiers :
                if modifier not in call_path:
                    new_call_path.append(modifier)
        return new_call_path

    def dfs(current_func: Function):
        if isinstance(current_func, Function) or isinstance(current_func, FunctionContract):
            if current_func not in call_path:
                call_path.append(current_func)
            else:
                return
            if not hasattr(current_func, "internal_calls"):
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
























            






def domain_seperator_state_variables(contract: Contract):
    state_protectors = []
    for func in contract.functions_and_modifiers:
        keccak_taints = []
        assembly_taints = []
        for node in func.nodes:
            if node.type == NodeType.ASSEMBLY:
                pattern = r'\s*(\w+)\s*:=\s*chainid\(\)\s*'
                
                match = re.search(pattern, func.source_mapping.content)
                if match:
                    variable_name = match.group(1)
                    assembly_taints.append(variable_name)
            for ir in node.irs:
                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                                    or ir.function == SolidityFunction("keccak256()")
                                    or ir.function == SolidityFunction("sha3()")
                                    or ir.function == SolidityFunction("abi.encodePacked()")
                                    or ir.function == SolidityFunction("abi.encode()")):
                                    for arg in ir.arguments:
                                        if arg.name in assembly_taints:
                                            assembly_taints.append(ir.lvalue.name)
                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                            or ir.function == SolidityFunction("keccak256()") \
                            or ir.function == SolidityFunction("sha3()") or ir.function == SolidityFunction("sha256(bytes)")):
                    if any([is_dependent(arg, SolidityVariableComposed("block.chainid"), func) for arg in ir.arguments]) :
                        keccak_taints.append(ir.lvalue)
                    for arg in ir.arguments:
                        if any(arg.name ==  taint for taint in assembly_taints):
                            keccak_taints.append(ir.lvalue)   
                if isinstance(ir, Assignment):
                    if isinstance(ir.lvalue, StateVariable):
                        for val in ir.variables:
                            if val in keccak_taints:
                                state_protectors.append(ir.lvalue)
    
    return state_protectors


def contains_domain_seperator_protector(contracts, call_path):
    domain_seperator_funcs = []
    for contract in contracts:
        domain_seperator_funcs.extend(domain_seperator_functions(contract))
    
    called_functions = call_relations(call_path)

    if any([func in called_functions for func in domain_seperator_funcs]):
        
        return True
    return False

def domain_seperator_functions(contract: Contract):
    domain_seperator_functions = []
    constant_1 = []
    for func in contract.functions_and_modifiers:
        assembly_taints = []
        for node in func.nodes:
            if node.type == NodeType.ASSEMBLY:
                pattern = r'\s*(\w+)\s*:=\s*chainid\(\)\s*'
                
                match = re.search(pattern, func.source_mapping.content)
                if match:
                    variable_name = match.group(1)
                    assembly_taints.append(variable_name)
            for ir in node.irs:
                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                                    or ir.function == SolidityFunction("keccak256()")
                                    or ir.function == SolidityFunction("sha3()")
                                    or ir.function == SolidityFunction("abi.encodePacked()")
                                    or ir.function == SolidityFunction("abi.encode()")):
                                    for arg in ir.arguments:
                                        if arg.name in assembly_taints:
                                            assembly_taints.append(ir.lvalue.name)
    
                if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                            or ir.function == SolidityFunction("keccak256()") \
                            or ir.function == SolidityFunction("sha3()") or ir.function == SolidityFunction("sha256(bytes)")):
                    if any([is_dependent(arg, SolidityVariableComposed("block.chainid"), func) for arg in ir.arguments]) or  \
                        any([is_dependent(arg, SolidityVariableComposed("chain.id"), func) for arg in ir.arguments]):
                        domain_seperator_functions.append(func)
                    for arg in ir.arguments:
                        if any(arg.name ==  taint for taint in assembly_taints):
                            domain_seperator_functions.append(func)   
    return domain_seperator_functions


class CrossChainSignatureReplay(AbstractDetector):
    """
    Documentation
    """

    ARGUMENT = 'cross-chain-sig' 
    HELP = 'Cross Chain Signature Replay'
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = ' '

    WIKI_TITLE = ' '
    WIKI_DESCRIPTION = ' '
    WIKI_EXPLOIT_SCENARIO = ' '
    WIKI_RECOMMENDATION = ' '

    def _detect(self):
        

        info = ['Cross Chain Signature Replay ']
        ret = []
        
        func_has_domain_seperator_hashes = []
        domain_seperators = []
        for c in self.compilation_unit.contracts_derived:
            domain_seperators.extend(domain_seperator_state_variables(c))
            
        func_has_chain_ids = []
        for c in self.compilation_unit.contracts_derived:
            for f in c.functions:
                for n in f.nodes:
                    if n.type == NodeType.ASSEMBLY:
                        pattern = r'\s*(\w+)\s*:=\s*chainid\(\)\s*'
                        
                        match = re.search(pattern, f.source_mapping.content)
                        if match:
                            variable_name = match.group(1)
                            func_has_chain_ids.append(f)
                            break
        
                        
        for c in self.compilation_unit.contracts_derived:
            domain_seperators.extend([SolidityVariableComposed("block.chainid"), SolidityVariableComposed("chain.id")])
            
            assembly_taints = []
            for f in c.functions:
                for n in f.nodes:
                    if n.type == NodeType.ASSEMBLY:
                        pattern = r'\s*(\w+)\s*:=\s*chainid\(\)\s*'
                        
                        match = re.search(pattern, f.source_mapping.content)
                        if match:
                            variable_name = match.group(1)
                            assembly_taints.append(variable_name)
                    for ir in n.irs:
                        if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                                    or ir.function == SolidityFunction("keccak256()")
                                    or ir.function == SolidityFunction("sha3()")
                                    or ir.function == SolidityFunction("abi.encodePacked()")
                                    or ir.function == SolidityFunction("abi.encode()")):
                                    for arg in ir.arguments:
                                        if arg.name in assembly_taints:
                                            assembly_taints.append(ir.lvalue.name)
                        elif isinstance(ir, SolidityCall) or isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall):
                            if ir.function in func_has_chain_ids:
                                domain_seperators.append(ir.lvalue)
                        if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("keccak256(bytes)") \
                            or ir.function == SolidityFunction("keccak256()")
                            or ir.function == SolidityFunction("sha3()")):
                                for arg in ir.arguments:
                                    if any([is_dependent(arg, taint, f) for taint in domain_seperators]):
                                        func_has_domain_seperator_hashes.append(f)
                                    break
                                for arg in ir.arguments:
                                    if any(arg.name ==  taint for taint in assembly_taints):
                                        func_has_domain_seperator_hashes.append(f)  
                                
        
                
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
                        if func in func_has_domain_seperator_hashes:
                            break
                        current_layer_taints = [SolidityVariableComposed("block.chainid"), SolidityVariableComposed("chain.id") ]
                        current_layer_taints.extend(domain_seperators)
                        
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
                                elif isinstance(ir, Assignment):
                                    for var in ir.variables:
                                        if var in current_layer_taints:
                                            current_layer_taints.append(ir.lvalue)
                                            break
                                    
                                elif isinstance(ir, InternalCall) or isinstance(ir, LibraryCall) or isinstance(ir, HighLevelCall):
                                    for argument in ir.arguments:
                                        if any([is_dependent(argument, taint, func) for taint in current_layer_taints]) \
                                        or any([is_dependent(argument, func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address]):
                                            current_layer_taints.append(ir.lvalue)
                                            break
                                    if ir.function in func_has_domain_seperator_hashes:
                                        current_layer_taints.append(ir.lvalue)

                                elif isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") or ir.function == SolidityFunction("ecrecover()")):
                                    
                                    if not any([is_dependent(ir.arguments[0], taint, func) for taint in current_layer_taints]):
                                        if not any([is_dependent(ir.arguments[0], func.parameters[idx], func) for idx in range(0,len(func.parameters)) if idx in param_tainted_by_address  ]):
                                            if not contains_domain_seperator_protector(self.compilation_unit.contracts_derived, call_path):
                                                ret.append((call_path[0], func, n))
                            if move_to_next_layer :
                                break
                        current_func_idx = current_func_idx + 1
        results = []
        for external,f,node in ret:
            info: DETECTOR_INFO = [external, '->', f, " allows cross-chain signature replay: ", node, "\n"]
            res = self.generate_result(info)
            results.append(res)

        return results