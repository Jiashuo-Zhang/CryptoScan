"""
Module detecting unused return values from low level
"""
from typing import List

from CryptoScan.core.cfg.node import Node, NodeType
from CryptoScan.slithir.operations import LowLevelCall, SolidityCall, InternalCall, LibraryCall, HighLevelCall
from CryptoScan.analyses.data_dependency.data_dependency import is_dependent
from CryptoScan.core.declarations.solidity_variables import (
    SolidityVariable,
    SolidityFunction,
    SolidityVariableComposed,
)
from CryptoScan.core.declarations.function_contract import FunctionContract
from CryptoScan.slithir.operations import BinaryType, Binary, Condition, Assignment, Index, Return


from CryptoScan.core.variables.state_variable import StateVariable
from CryptoScan.detectors.abstract_detector import (
    AbstractDetector,
    DetectorClassification,
    DETECTOR_INFO,
)
from CryptoScan.core.declarations import Function, FunctionContract, Contract

from CryptoScan.core.declarations.solidity_variables import (
    SolidityFunction,
)
from CryptoScan.utils.output import Output

from .single_contract_signature_replay import contains_balance_protector
from .merkle_proof_replay import get_merkle_proof_path, contains_msg_sender_protector, merkle_pre_image_tx_param_analysis
from .signature_frontrunning import unprotected_storage_change

class MerkleProofFrontRun(AbstractDetector):

    ARGUMENT = "merkle-proof-front-run"
    HELP = "Merkle Proof Front Running"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH

    WIKI = " "

    WIKI_TITLE = "Merkle Proof Front Run"
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
                for (call_path, merkle_proof_ir) in merkle_proof_paths:
                    
                    pre_image_parameters = merkle_pre_image_tx_param_analysis(call_path, merkle_proof_ir)
                    checked_msg_sender = contains_msg_sender_protector(call_path, merkle_proof_ir)
                    
                    if checked_msg_sender:
                        continue
                    if unprotected_storage_change(call_path, pre_image_parameters):
                        ret.append((call_path[0], call_path[-1]))
                    

            for f1, fn in ret:
                info: DETECTOR_INFO = [f1, '->', fn, "allows merkle proof front run"]
                res = self.generate_result(info)
                results.append(res)

        return results
    
