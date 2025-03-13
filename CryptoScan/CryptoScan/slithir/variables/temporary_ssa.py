"""
    This class is used for the SSA version of slithIR
    It is similar to the non-SSA version of slithIR
    as the TemporaryVariable are in SSA form in both version
"""
from typing import Union
from CryptoScan.slithir.variables.temporary import TemporaryVariable
from CryptoScan.slithir.variables.reference import ReferenceVariable
from CryptoScan.slithir.variables.tuple import TupleVariable


class TemporaryVariableSSA(TemporaryVariable):  # pylint: disable=too-few-public-methods
    def __init__(self, temporary: TemporaryVariable) -> None:
        super().__init__(temporary.node, temporary.index)

        self._non_ssa_version = temporary

    @property
    def non_ssa_version(self) -> Union[TemporaryVariable, TupleVariable, ReferenceVariable]:
        return self._non_ssa_version
