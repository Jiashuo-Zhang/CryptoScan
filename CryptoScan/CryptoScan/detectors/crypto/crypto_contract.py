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

from .proof_malleability import extract_inline_precompiled_call_info

class Crypto(AbstractDetector):
    """
    """

    ARGUMENT = "crypto"
    HELP = "Contains Crypto API Call"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = " "

    WIKI_TITLE = " "
    WIKI_DESCRIPTION = " "

    
    WIKI_EXPLOIT_SCENARIO = """ 
    """
    

    WIKI_RECOMMENDATION = " "


    def _detect(self) -> List[Output]:
        

        results = []
        ret = []

        for c in self.compilation_unit.contracts_derived:
            for f in c.functions:
                for node in f.nodes:
                    for ir in node.irs:
                        if isinstance(ir, SolidityCall):
                            if ir.function in [SolidityFunction("keccak256()"), SolidityFunction("keccak256(bytes)"), SolidityFunction("sha256()"), SolidityFunction("sha256(bytes)") \
                                , SolidityFunction("sha3()"), SolidityFunction("ripemd160()"), SolidityFunction("ripemd160(bytes)"), SolidityFunction("ecrecover(bytes32,uint8,bytes32,bytes32)"), SolidityFunction("ecrecover()")]:
                                ret.append((f, ir.function.name))
                                break
                    if node.type == NodeType.ASSEMBLY:
                        for call_type, address, params in extract_inline_precompiled_call_info(f.source_mapping.content):
                            try:
                                if int(address) <= 10 and int(address) >= 1 and int(address)!=4:
                                    ret.append((f, int(address)))
                                    break
                            except:
                                continue
        

        for func, api in ret:
            info: DETECTOR_INFO = [func, ' uses ', str(api), "\n"]
            res = self.generate_result(info)
            results.append(res)

        return results
