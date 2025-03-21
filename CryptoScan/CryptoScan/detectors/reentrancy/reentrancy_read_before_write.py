""""
    Re-entrancy detection

    Based on heuristics, it may lead to FP and FN
    Iterate over all the nodes of the graph until reaching a fixpoint
"""
from collections import namedtuple, defaultdict
from typing import Dict, Set, List

from CryptoScan.detectors.abstract_detector import DetectorClassification
from .reentrancy import Reentrancy, to_hashable
from ...utils.output import Output

FindingKey = namedtuple("FindingKey", ["function", "calls"])
FindingValue = namedtuple("FindingValue", ["variable", "node", "nodes", "cross_functions"])


class ReentrancyReadBeforeWritten(Reentrancy):
    ARGUMENT = "reentrancy-no-eth"
    HELP = "Reentrancy vulnerabilities (no theft of ethers)"
    IMPACT = DetectorClassification.MEDIUM
    CONFIDENCE = DetectorClassification.MEDIUM

    WIKI = (
        "https://github.com/crytic/slither/wiki/Detector-Documentation#reentrancy-vulnerabilities-1"
    )

    WIKI_TITLE = "Reentrancy vulnerabilities"

    # region wiki_description
    WIKI_DESCRIPTION = """
Detection of the [reentrancy bug](https://github.com/trailofbits/not-so-smart-contracts/tree/master/reentrancy).
Do not report reentrancies that involve Ether (see `reentrancy-eth`)."""
    # endregion wiki_description

    # region wiki_exploit_scenario
    WIKI_EXPLOIT_SCENARIO = """
```solidity
    function bug(){
        require(not_called);
        if( ! (msg.sender.call() ) ){
            throw;
        }
        not_called = False;
    }   
```
"""
    # endregion wiki_exploit_scenario

    WIKI_RECOMMENDATION = "Apply the [`check-effects-interactions` pattern](http://solidity.readthedocs.io/en/v0.4.21/security-considerations.html#re-entrancy)."

    STANDARD_JSON = False

    # pylint: disable=too-many-locals
    def find_reentrancies(self) -> Dict[FindingKey, Set[FindingValue]]:
        result: Dict[FindingKey, Set[FindingValue]] = defaultdict(set)
        for contract in self.contracts:  # pylint: disable=too-many-nested-blocks
            variables_used_in_reentrancy = contract.state_variables_used_in_reentrant_targets
            for f in contract.functions_and_modifiers_declared:
                for node in f.nodes:
                    # dead code
                    if self.KEY not in node.context:
                        continue
                    if node.context[self.KEY].calls and not node.context[self.KEY].send_eth:
                        read_then_written = set()
                        for c in node.context[self.KEY].calls:
                            if c == node:
                                continue
                            read_then_written |= {
                                FindingValue(
                                    v,
                                    node,
                                    tuple(sorted(nodes, key=lambda x: x.node_id)),
                                    tuple(
                                        sorted(
                                            variables_used_in_reentrancy[v], key=lambda x: str(x)
                                        )
                                    ),
                                )
                                for (v, nodes) in node.context[self.KEY].written.items()
                                if v in node.context[self.KEY].reads_prior_calls[c]
                                and (f.is_reentrant or v in variables_used_in_reentrancy)
                            }

                        # We found a potential re-entrancy bug
                        if read_then_written:
                            # calls are ordered
                            finding_key = FindingKey(
                                function=node.function,
                                calls=to_hashable(node.context[self.KEY].calls),
                            )
                            result[finding_key] |= read_then_written
        return result

    def _detect(self) -> List[Output]:  # pylint: disable=too-many-branches
        """"""

        super()._detect()
        reentrancies = self.find_reentrancies()

        results = []

        result_sorted = sorted(list(reentrancies.items()), key=lambda x: x[0].function.name)
        varsWritten: List[FindingValue]
        varsWrittenSet: Set[FindingValue]
        for (func, calls), varsWrittenSet in result_sorted:
            calls = sorted(list(set(calls)), key=lambda x: x[0].node_id)
            varsWritten = sorted(varsWrittenSet, key=lambda x: (x.variable.name, x.node.node_id))

            info = ["Reentrancy in ", func, ":\n"]

            info += ["\tExternal calls:\n"]
            for (call_info, calls_list) in calls:
                info += ["\t- ", call_info, "\n"]
                for call_list_info in calls_list:
                    if call_list_info != call_info:
                        info += ["\t\t- ", call_list_info, "\n"]
            info += "\tState variables written after the call(s):\n"
            for finding_value in varsWritten:
                info += ["\t- ", finding_value.node, "\n"]
                for other_node in finding_value.nodes:
                    if other_node != finding_value.node:
                        info += ["\t\t- ", other_node, "\n"]
                if finding_value.cross_functions:
                    info += [
                        "\t",
                        finding_value.variable,
                        " can be used in cross function reentrancies:\n",
                    ]
                    for cross in finding_value.cross_functions:
                        info += ["\t- ", cross, "\n"]

            # Create our JSON result
            res = self.generate_result(info)

            # Add the function with the re-entrancy first
            res.add(func)

            # Add all underlying calls in the function which are potentially problematic.
            for (call_info, calls_list) in calls:
                res.add(call_info, {"underlying_type": "external_calls"})
                for call_list_info in calls_list:
                    if call_list_info != call_info:
                        res.add(
                            call_list_info,
                            {"underlying_type": "external_calls_sending_eth"},
                        )

            # Add all variables written via nodes which write them.
            for finding_value in varsWritten:
                res.add(
                    finding_value.node,
                    {
                        "underlying_type": "variables_written",
                        "variable_name": finding_value.variable.name,
                    },
                )
                for other_node in finding_value.nodes:
                    if other_node != finding_value.node:
                        res.add(
                            other_node,
                            {
                                "underlying_type": "variables_written",
                                "variable_name": finding_value.variable.name,
                            },
                        )

            # Append our result
            results.append(res)

        return results
