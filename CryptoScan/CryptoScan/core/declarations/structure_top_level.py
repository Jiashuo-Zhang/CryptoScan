from typing import TYPE_CHECKING

from CryptoScan.core.declarations import Structure
from CryptoScan.core.declarations.top_level import TopLevel

if TYPE_CHECKING:
    from CryptoScan.core.scope.scope import FileScope
    from CryptoScan.core.compilation_unit import SlitherCompilationUnit


class StructureTopLevel(Structure, TopLevel):
    def __init__(self, compilation_unit: "SlitherCompilationUnit", scope: "FileScope") -> None:
        super().__init__(compilation_unit)
        self.file_scope: "FileScope" = scope
