from typing import TYPE_CHECKING

from CryptoScan.core.declarations.contract_level import ContractLevel
from CryptoScan.core.declarations import Enum

if TYPE_CHECKING:
    from CryptoScan.core.declarations import Contract


class EnumContract(Enum, ContractLevel):
    def is_declared_by(self, contract: "Contract") -> bool:
        """
        Check if the element is declared by the contract
        :param contract:
        :return:
        """
        return self.contract == contract
