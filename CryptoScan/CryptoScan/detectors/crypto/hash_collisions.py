"""
Module detecting usage of more than one dynamic type in abi.encodePacked() arguments which could lead to collision
"""

from CryptoScan.detectors.abstract_detector import AbstractDetector, DetectorClassification
from CryptoScan.core.declarations.solidity_variables import SolidityFunction
from CryptoScan.slithir.operations.assignment import Assignment

from CryptoScan.slithir.operations.length import Length
from CryptoScan.slithir.variables import  ReferenceVariableSSA, ReferenceVariable

from CryptoScan.slithir.operations import SolidityCall, InternalCall, HighLevelCall, LibraryCall
from CryptoScan.analyses.data_dependency.data_dependency import is_tainted
from CryptoScan.core.solidity_types import ElementaryType
from CryptoScan.core.solidity_types import ArrayType
from CryptoScan.slithir.variables.temporary import TemporaryVariable
from CryptoScan.slithir.variables.constant import Constant


def _is_dynamic_type(arg):
    """
    Args:
        arg (function argument)
    Returns:
        Bool
    """
    if isinstance(arg.type, ElementaryType) and (arg.type.name in ["string", "bytes"]) and not isinstance(arg, Constant):
        return True
    if isinstance(arg, ReferenceVariable) and arg._type in ["string", "bytes"] and not isinstance(arg, Constant):
        return True
    if isinstance(arg.type, ArrayType) and arg.type.length is None and not isinstance(arg, Constant):
        return True

    return False


def _detect_abi_encodePacked_collision(contract):
    """
    Args:
        contract (Contract)
    Returns:
        list((Function), (list (Node)))
    """
    ret = []
    
    length_vars = []
    white_list = []
    abi_encodepacked_collision_tmps = {}
    for f in contract.functions_and_modifiers_declared:
        for n in f.nodes:
            for ir in n.irs:
                if isinstance(ir, Length):
                    length_vars.append(ir.lvalue)
                if isinstance(ir, InternalCall) or isinstance(ir, HighLevelCall) or isinstance(ir, LibraryCall):
                    try:
                        if len(set(length_vars) & set(ir.arguments)) > 0 and ir.lvalue.type == ElementaryType("string"):
                            white_list.append(ir.lvalue)
                            
                    except:
                        continue
                if isinstance(ir, SolidityCall) and ir.function == SolidityFunction(
                    "abi.encodePacked()"
                ):
                    dynamic_type_count = 0
                    for arg in ir.arguments:
                        if arg in white_list:
                            dynamic_type_count = 0
                            
                        elif is_tainted(arg, contract) and _is_dynamic_type(arg):
                            dynamic_type_count += 1
                        elif dynamic_type_count > 1:
                            abi_encodepacked_collision_tmps[ir.lvalue] = ir
                            dynamic_type_count = 0
                        else:
                            dynamic_type_count = 0
                    if dynamic_type_count > 1:
                        abi_encodepacked_collision_tmps[ir.lvalue] = ir
            
    
    for f in contract.functions_and_modifiers_declared:
        for n in f.nodes:
            for ir in n.irs:
                if isinstance(ir, Assignment):
                    if ir.rvalue in abi_encodepacked_collision_tmps:
                        abi_encodepacked_collision_tmps[ir.lvalue] = abi_encodepacked_collision_tmps[ir.rvalue]
                if isinstance(ir, SolidityCall) :
                    if ir.function == SolidityFunction("keccak256(bytes)") or ir.function == SolidityFunction("keccak256()" or ir.function == SolidityFunction("sha3()")):
                        for arg in ir.arguments:
                            if arg in abi_encodepacked_collision_tmps:
                                ret.append((f, n))
                                break
                    if ir.function == SolidityFunction("keccak256()"):
                        dynamic_type_count = 0
                        dynamic_array_count = 0
                        for arg in ir.arguments:
                            if _is_dynamic_type(arg):
                                dynamic_type_count += 1
                            elif (isinstance(arg, ReferenceVariable) and _is_dynamic_type(arg.points_to)):
                                dynamic_type_count += 1
                                dynamic_array_count +=1
                            elif dynamic_type_count > 1:
                                abi_encodepacked_collision_tmps[ir.lvalue] = ir
                                dynamic_type_count = 0
                                dynamic_array_count = 0
                            else:
                                dynamic_type_count = 0
                            if dynamic_type_count > 1 and dynamic_array_count <= 1:
                                ret.append((f, n))

    return ret


class HashCollision(AbstractDetector):
    """
    Detect usage of more than one dynamic type in abi.encodePacked() arguments which could to collision
    """

    ARGUMENT = "hash-collision"
    HELP = "Hash Collision"
    IMPACT = DetectorClassification.HIGH
    CONFIDENCE = DetectorClassification.HIGH
    WIKI = ' '

    WIKI_TITLE = ' '
    WIKI_DESCRIPTION = ' '
    WIKI_EXPLOIT_SCENARIO = ' '
    WIKI_RECOMMENDATION = ' '


    def _detect(self):
        """Detect usage of more than one dynamic type in abi.encodePacked(..) arguments which could lead to collision"""
        
        results = []
        for c in self.compilation_unit.contracts:
            values = _detect_abi_encodePacked_collision(c)
            for func, node in values:
                info = [
                    func,
                    " calls keccak256(abi.encodePacked()) with multiple dynamic arguments. It could result in hash collisions:",
                    node,
                ]
                json = self.generate_result(info)
                results.append(json)

        return results
