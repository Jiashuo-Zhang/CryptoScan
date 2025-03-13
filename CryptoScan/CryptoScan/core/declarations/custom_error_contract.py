from typing import TYPE_CHECKING
from CryptoScan.core.declarations.contract_level import ContractLevel


from CryptoScan.core.declarations.custom_error import CustomError

if TYPE_CHECKING:
    from CryptoScan.core.declarations import Contract


class CustomErrorContract(CustomError, ContractLevel):
    def is_declared_by(self, contract: "Contract") -> bool:
        """
        Check if the element is declared by the contract
        :param contract:
        :return:
        """
        return self.contract == contract

    @property
    def canonical_name(self) -> str:
        return self.contract.name + "." + self.full_name
