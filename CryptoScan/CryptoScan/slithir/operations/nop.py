from typing import List


from CryptoScan.core.variables.variable import Variable
from CryptoScan.slithir.operations import Operation


class Nop(Operation):
    @property
    def read(self) -> List[Variable]:
        return []

    @property
    def used(self):
        return []

    def __str__(self):
        return "NOP"
