from typing import List, Union, TYPE_CHECKING

from CryptoScan.core.solidity_types.array_type import ArrayType
from CryptoScan.slithir.operations.call import Call
from CryptoScan.slithir.operations.lvalue import OperationWithLValue
from CryptoScan.slithir.utils.utils import RVALUE

if TYPE_CHECKING:
    from CryptoScan.slithir.variables.temporary import TemporaryVariable
    from CryptoScan.slithir.variables.temporary_ssa import TemporaryVariableSSA


class NewArray(Call, OperationWithLValue):
    def __init__(
        self,
        array_type: "ArrayType",
        lvalue: Union["TemporaryVariableSSA", "TemporaryVariable"],
    ) -> None:
        super().__init__()
        assert isinstance(array_type, ArrayType)
        self._array_type = array_type

        self._lvalue = lvalue

    @property
    def array_type(self) -> "ArrayType":
        return self._array_type

    @property
    def read(self) -> List[RVALUE]:
        return self._unroll(self.arguments)

    def __str__(self):
        args = [str(a) for a in self.arguments]
        lvalue = self.lvalue
        return f"{lvalue}({lvalue.type})  = new {self.array_type}({','.join(args)})"
