from typing import List, Union
from CryptoScan.slithir.operations.call import Call
from CryptoScan.core.variables.variable import Variable
from CryptoScan.core.declarations.solidity_variables import SolidityVariable
from CryptoScan.core.variables.local_variable import LocalVariable
from CryptoScan.slithir.variables.constant import Constant
from CryptoScan.slithir.variables.local_variable import LocalIRVariable


class Transfer(Call):
    def __init__(self, destination: Union[LocalVariable, LocalIRVariable], value: Constant) -> None:
        assert isinstance(destination, (Variable, SolidityVariable))
        self._destination = destination
        super().__init__()

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
        return f"Transfer dest:{self.destination} {value}"
