"""
Module detecting unused return values from low level
"""
from typing import List

from CryptoScan.core.cfg.node import Node, NodeType
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall
from CryptoScan.analyses.data_dependency.data_dependency import is_dependent_ssa

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

from .signature_frontrunning import get_ecrecover_calls_recursively
from .signature_frontrunning import pre_image_tx_param_analysis

class SignatureMalleability(AbstractDetector):
    """
    """

    ARGUMENT = "sig-mal"
    HELP = "Signature Malleability"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = " "

    WIKI_TITLE = " "
    WIKI_DESCRIPTION = " "

    
    WIKI_EXPLOIT_SCENARIO = """ 
    """
    

    WIKI_RECOMMENDATION = "Ensure that there is protection against signature malleability."


    def _detect(self) -> List[Output]:
        

        results = []
        ret = []

        for c in self.compilation_unit.contracts_derived:
            for f in c.functions:
                if f.visibility in ['internal', 'private'] :
                    continue
                ecrecover_calls = get_ecrecover_calls_recursively(f)
                for (call_path, _) in ecrecover_calls:
                    
                    params = pre_image_tx_param_analysis(call_path, ecrecover_arg_slot=3)
                    checked_malleability = False
                    for idx, func in enumerate(call_path):
                        secp_checks = []
                        secp_consts = [57896044618658097711785492504343953926418782139537452191302581570759080747168, 57896044618658097711785492504343953926634992332820282019728792003956564819967]
                        param_s = [ func.parameters[i] for i in params[idx]]
                        if checked_malleability:
                            break
                        for n in func.nodes:
                            for ir in n.irs:
                                if isinstance(ir, Binary):
                                    if ir.variable_left in secp_consts or ir.variable_right in secp_consts:
                                        secp_checks.append(ir.lvalue)
                                        
                                if isinstance(ir, Condition) and ir.value in secp_checks:
                                    checked_malleability = True
                                    break
                                elif isinstance(ir, SolidityCall) and  (
                                    ir.function == SolidityFunction("assert(bool)") \
                                    or ir.function == SolidityFunction("require(bool)") \
                                    or ir.function == SolidityFunction("require(bool,string)")
                                ):
                                    if ir.arguments[0] in secp_checks:
                                        checked_malleability = True
                                        break
                    if not checked_malleability:
                        ret.append(call_path)
                    
                        
        
        
        
        
        
        
        
        

        for call_path in ret:
            info: DETECTOR_INFO = [call_path[0], "does not contains protect against signature malleability "]
            res = self.generate_result(info)
            results.append(res)

        return results
