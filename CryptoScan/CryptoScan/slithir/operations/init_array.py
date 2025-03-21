from typing import List, Union
from CryptoScan.slithir.operations.lvalue import OperationWithLValue
from CryptoScan.slithir.utils.utils import is_valid_rvalue, RVALUE
from CryptoScan.slithir.variables.temporary import TemporaryVariable
from CryptoScan.slithir.variables.temporary_ssa import TemporaryVariableSSA


class InitArray(OperationWithLValue):
    def __init__(
        self, init_values: List[RVALUE], lvalue: Union[TemporaryVariableSSA, TemporaryVariable]
    ) -> None:
        # init_values can be an array of n dimension
        # reduce was removed in py3
        super().__init__()

        def reduce(xs):
            result = True
            for i in xs:
                result = result and i
            return result

        def check(elem):
            if isinstance(elem, (list,)):
                return reduce(elem)
            return is_valid_rvalue(elem)

        assert check(init_values)
        self._init_values = init_values
        self._lvalue = lvalue

    @property
    def read(self) -> List[RVALUE]:
        return self._unroll(self.init_values)

    @property
    def init_values(self) -> List[RVALUE]:
        return list(self._init_values)

    def __str__(self):
        def convert(elem):
            if isinstance(elem, (list,)):
                return str([convert(x) for x in elem])
            return f"{elem}({elem.type})"

        init_values = convert(self.init_values)
        return f"{self.lvalue}({self.lvalue.type}) = {init_values}"
