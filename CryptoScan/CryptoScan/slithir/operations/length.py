from typing import List, Union
from CryptoScan.core.solidity_types import ElementaryType
from CryptoScan.slithir.operations.lvalue import OperationWithLValue
from CryptoScan.slithir.utils.utils import is_valid_lvalue, is_valid_rvalue
from CryptoScan.core.variables.local_variable import LocalVariable
from CryptoScan.core.variables.state_variable import StateVariable
from CryptoScan.slithir.variables.local_variable import LocalIRVariable
from CryptoScan.slithir.variables.reference import ReferenceVariable
from CryptoScan.slithir.variables.reference_ssa import ReferenceVariableSSA
from CryptoScan.slithir.variables.state_variable import StateIRVariable


class Length(OperationWithLValue):
    def __init__(
        self,
        value: Union[StateVariable, LocalIRVariable, LocalVariable, StateIRVariable],
        lvalue: Union[ReferenceVariable, ReferenceVariableSSA],
    ) -> None:
        super().__init__()
        assert is_valid_rvalue(value)
        assert is_valid_lvalue(lvalue)
        self._value = value
        self._lvalue = lvalue
        lvalue.set_type(ElementaryType("uint256"))

    @property
    def read(self) -> List[Union[LocalVariable, StateVariable, LocalIRVariable, StateIRVariable]]:
        return [self._value]

    @property
    def value(self) -> Union[StateVariable, LocalVariable]:
        return self._value

    def __str__(self):
        return f"{self.lvalue} -> LENGTH {self.value}"
