"""
Module detecting unused return values from low level
"""
from typing import List

from CryptoScan.core.cfg.node import Node, NodeType
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall
from CryptoScan.analyses.data_dependency.data_dependency import is_dependent

from CryptoScan.core.declarations.function_contract import FunctionContract
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return


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


class UncheckedSignature(AbstractDetector):
    """
    If the return value of a low-level call to Ecreciver is not checked, it might lead to losing ether
    """

    ARGUMENT = "insufficient-sig-check"
    HELP = "Insufficient Signature Verification"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = " "

    WIKI_TITLE = "Insufficient Signature Verification"
    WIKI_DESCRIPTION = " "

    
    WIKI_EXPLOIT_SCENARIO = """  
    """
    

    WIKI_RECOMMENDATION = "Ensure that the return value of ecrecover is properly checked."


    def _detect(self) -> List[Output]:
        

        """Detect low level calls where the success value is not checked"""
        results = []
        
        funcs_return_is_ecrecover_result = []
        for c in self.compilation_unit.contracts_derived:
            ecrecover_result = []
            for f in c.functions_and_modifiers:
                 for n in f.nodes:
                    for ir in n.irs:
                        if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") or ir.function == SolidityFunction("ecrecover()")):
                            if ir.lvalue:
                                ecrecover_result.append(ir.lvalue)
                        if isinstance(ir, Return):
                            for return_value in ir.values:
                                if return_value in ecrecover_result:
                                    funcs_return_is_ecrecover_result.append((c,f))
                                    break
        ret = []
        for c in self.compilation_unit.contracts_derived:
            for f in c.functions_and_modifiers:
                ecrecover_results = {}
                ecrecover_results_checks = {} 
                ecrecover_lead_to_modify_storage = set()
                ecrecover_non_eq_cmp = {}
                
                is_condition_protected = False
                if_layer = 0
                nodes_origin = {}
                for n in f.nodes:
                    
                    
                    
                    
                    
                    if n.type == NodeType.IF:
                        for r in n.variables_read :
                            if any([is_dependent(r, ecrecover_result, f) for ecrecover_result in ecrecover_results]):
                                is_condition_protected = True
                        if_layer = if_layer + 1
                    if n.type == NodeType.ENDIF:
                        if_layer = if_layer - 1
                        if if_layer == 0 and is_condition_protected:
                            is_condition_protected = False
                    
                    for dominator in n.dominators:
                        for ecrecover in ecrecover_results:
                            if dominator == ecrecover_results[ecrecover] \
                            and (len(n.state_variables_written) > 0 or (len(n.internal_calls) + len(n.external_calls_as_expressions))>0 or any(var for var in n.local_variables_written if var.is_storage)
                            ):
                                ecrecover_lead_to_modify_storage.add(ecrecover)
                    for ir in n.irs:
                        if isinstance(ir, Binary) and ir.type == BinaryType.NOT_EQUAL:
                            for ecrecover in ecrecover_results:
                                if (is_dependent(ir.variable_left, ecrecover, f) and str(ir.variable_left.type) == 'address') \
                                or (is_dependent(ir.variable_right, ecrecover, f) and str(ir.variable_right.type) == 'address') :
                                    if ecrecover not in ecrecover_non_eq_cmp:
                                        ecrecover_non_eq_cmp[ecrecover] = [ir.lvalue]
                                    else:
                                        ecrecover_non_eq_cmp[ecrecover].append(ir.lvalue)
                            
                            
                        if isinstance(ir, SolidityCall) and (ir.function == SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)") or ir.function == SolidityFunction("ecrecover()")):
                            if ir.lvalue:
                                ecrecover_results[ir.lvalue] = n
                                nodes_origin[ir.lvalue] = ir
                        elif isinstance(ir, InternalCall) :
                            if (c, ir.function) in funcs_return_is_ecrecover_result:
                                ecrecover_results[ir.lvalue] = n
                        elif isinstance(ir, LibraryCall):
                            if (ir.destination, ir.function) in funcs_return_is_ecrecover_result:
                                ecrecover_results[ir.lvalue] = n
                        
                        if isinstance(ir, SolidityCall) and (
                            ir.function == SolidityFunction("assert(bool)") \
                            or ir.function == SolidityFunction("require(bool)")
                            or ir.function == SolidityFunction("require(bool,string)")
                        ):
                            for ecrecover_result in ecrecover_results:
                                if any([is_dependent(argument, ecrecover_result, f) for argument in ir.arguments]) and not any( [x == ir.arguments[0] for x in ecrecover_non_eq_cmp[ecrecover_result]]):
                                    if ecrecover_result not in ecrecover_non_eq_cmp:
                                        ecrecover_results_checks[ecrecover_result] = True
                                        
                for ecrecover in ecrecover_results:
                    if (ecrecover not in ecrecover_results_checks) and (ecrecover in ecrecover_lead_to_modify_storage):
                        ret.append((f,ecrecover_results[ecrecover]))
                        

                for f,node in ret:
                    info: DETECTOR_INFO = [f, " contans the insufficient signature verification defect, the following signature is not properly checked:", node, "\n"]
                    res = self.generate_result(info)
                    results.append(res)

        return results
