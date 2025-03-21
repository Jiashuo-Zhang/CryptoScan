"""
    Function module
"""
from typing import Dict, List, Tuple, TYPE_CHECKING, Optional

from CryptoScan.core.declarations import Function
from CryptoScan.core.declarations.top_level import TopLevel
from CryptoScan.utils.using_for import USING_FOR, merge_using_for

if TYPE_CHECKING:
    from CryptoScan.core.compilation_unit import SlitherCompilationUnit
    from CryptoScan.core.scope.scope import FileScope
    from CryptoScan.slithir.variables.state_variable import StateIRVariable


class FunctionTopLevel(Function, TopLevel):
    def __init__(self, compilation_unit: "SlitherCompilationUnit", scope: "FileScope") -> None:
        super().__init__(compilation_unit)
        self._scope: "FileScope" = scope
        self._using_for_complete: Optional[USING_FOR] = None

    @property
    def file_scope(self) -> "FileScope":
        return self._scope

    @property
    def using_for_complete(self) -> USING_FOR:
        """
        USING_FOR: Dict of top level directive
        """

        if self._using_for_complete is None:
            result = {}
            for uftl in self.file_scope.using_for_directives:
                result = merge_using_for(result, uftl.using_for)
            self._using_for_complete = result
        return self._using_for_complete

    @property
    def canonical_name(self) -> str:
        """
        str: contract.func_name(type1,type2)
        Return the function signature without the return values
        """
        if self._canonical_name is None:
            name, parameters, _ = self.signature
            self._canonical_name = (
                ".".join(self._internal_scope + [name]) + "(" + ",".join(parameters) + ")"
            )
        return self._canonical_name

    # endregion
    ###################################################################################
    ###################################################################################
    # region Functions
    ###################################################################################
    ###################################################################################

    @property
    def functions_shadowed(self) -> List["Function"]:
        return []

    # endregion
    ###################################################################################
    ###################################################################################
    # region Summary information
    ###################################################################################
    ###################################################################################

    def get_summary(
        self,
    ) -> Tuple[str, str, str, List[str], List[str], List[str], List[str], List[str]]:
        """
            Return the function summary
        Returns:
            (str, str, str, list(str), list(str), listr(str), list(str), list(str);
            contract_name, name, visibility, modifiers, vars read, vars written, internal_calls, external_calls_as_expressions
        """
        return (
            "",
            self.full_name,
            self.visibility,
            [str(x) for x in self.modifiers],
            [str(x) for x in self.state_variables_read + self.solidity_variables_read],
            [str(x) for x in self.state_variables_written],
            [str(x) for x in self.internal_calls],
            [str(x) for x in self.external_calls_as_expressions],
        )

    # endregion
    ###################################################################################
    ###################################################################################
    # region SlithIr and SSA
    ###################################################################################
    ###################################################################################

    def generate_slithir_ssa(
        self, all_ssa_state_variables_instances: Dict[str, "StateIRVariable"]
    ) -> None:
        # pylint: disable=import-outside-toplevel
        from CryptoScan.slithir.utils.ssa import add_ssa_ir, transform_slithir_vars_to_ssa
        from CryptoScan.core.dominators.utils import (
            compute_dominance_frontier,
            compute_dominators,
        )

        compute_dominators(self.nodes)
        compute_dominance_frontier(self.nodes)
        transform_slithir_vars_to_ssa(self)

        add_ssa_ir(self, all_ssa_state_variables_instances)
