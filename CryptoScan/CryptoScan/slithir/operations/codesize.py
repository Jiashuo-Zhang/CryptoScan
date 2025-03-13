from typing import List, Union
from CryptoScan.core.solidity_types import ElementaryType
from CryptoScan.slithir.operations.lvalue import OperationWithLValue
from CryptoScan.slithir.utils.utils import is_valid_lvalue, is_valid_rvalue
from CryptoScan.core.variables.local_variable import LocalVariable
from CryptoScan.slithir.variables.local_variable import LocalIRVariable
from CryptoScan.slithir.variables.reference import ReferenceVariable
from CryptoScan.slithir.variables.reference_ssa import ReferenceVariableSSA


class CodeSize(OperationWithLValue):
    def __init__(
        self,
        value: Union[LocalVariable, LocalIRVariable],
        lvalue: Union[ReferenceVariableSSA, ReferenceVariable],
    ) -> None:
        super().__init__()
        assert is_valid_rvalue(value)
        assert is_valid_lvalue(lvalue)
        self._value = value
        self._lvalue = lvalue
        lvalue.set_type(ElementaryType("uint256"))

    @property
    def read(self) -> List[Union[LocalIRVariable, LocalVariable]]:
        return [self._value]

    @property
    def value(self) -> LocalVariable:
        return self._value

    def __str__(self) -> str:
        return f"{self.lvalue} -> CODESIZE {self.value}"
