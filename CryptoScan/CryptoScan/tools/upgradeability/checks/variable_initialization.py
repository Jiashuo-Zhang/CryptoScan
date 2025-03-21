from typing import List

from CryptoScan.tools.upgradeability.checks.abstract_checks import (
    CheckClassification,
    AbstractCheck,
    CHECK_INFO,
)
from CryptoScan.utils.output import Output


class VariableWithInit(AbstractCheck):
    ARGUMENT = "variables-initialized"
    IMPACT = CheckClassification.HIGH

    HELP = "State variables with an initial value"
    WIKI = "https://github.com/crytic/slither/wiki/Upgradeability-Checks#state-variable-initialized"
    WIKI_TITLE = "State variable initialized"

    # region wiki_description
    WIKI_DESCRIPTION = """
Detect state variables that are initialized.
"""
    # endregion wiki_description

    # region wiki_exploit_scenario
    WIKI_EXPLOIT_SCENARIO = """
```solidity
contract Contract{
    uint variable = 10;
}
```
Using `Contract` will the delegatecall proxy pattern will lead `variable` to be 0 when called through the proxy.
"""
    # endregion wiki_exploit_scenario

    # region wiki_recommendation
    WIKI_RECOMMENDATION = """
Using initialize functions to write initial values in state variables.
"""
    # endregion wiki_recommendation

    REQUIRE_CONTRACT = True

    def _check(self) -> List[Output]:
        results = []
        for s in self.contract.stored_state_variables_ordered:
            if s.initialized:
                info: CHECK_INFO = [s, " is a state variable with an initial value.\n"]
                json = self.generate_result(info)
                results.append(json)
        return results
