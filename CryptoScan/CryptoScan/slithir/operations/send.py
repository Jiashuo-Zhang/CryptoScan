from typing import List, Union

from CryptoScan.core.declarations.solidity_variables import SolidityVariable
from CryptoScan.core.variables.variable import Variable
from CryptoScan.slithir.operations.call import Call
from CryptoScan.slithir.operations.lvalue import OperationWithLValue
from CryptoScan.slithir.utils.utils import is_valid_lvalue
from CryptoScan.core.variables.local_variable import LocalVariable
from CryptoScan.slithir.variables.constant import Constant
from CryptoScan.slithir.variables.local_variable import LocalIRVariable
from CryptoScan.slithir.variables.temporary import TemporaryVariable
from CryptoScan.slithir.variables.temporary_ssa import TemporaryVariableSSA


class Send(Call, OperationWithLValue):
    def __init__(
        self,
        destination: Union[LocalVariable, LocalIRVariable],
        value: Constant,
        result: Union[TemporaryVariable, TemporaryVariableSSA],
    ) -> None:
        assert is_valid_lvalue(result)
        assert isinstance(destination, (Variable, SolidityVariable))
        super().__init__()
        self._destination = destination
        self._lvalue = result

        self._call_value = value

    def can_send_eth(self) -> bool:
        return True

    @property
    def call_value(self) -> Constant:
        return self._call_value

    @property
    def read(self) -> List[Union[Constant, LocalIRVariable, LocalVariable]]:
        return [self.destination, self.call_value]

    @property
    def destination(self) -> Union[LocalVariable, LocalIRVariable]:
        return self._destination

    def __str__(self):
        value = f"value:{self.call_value}"
        return str(self.lvalue) + f" = SEND dest:{self.destination} {value}"


#
