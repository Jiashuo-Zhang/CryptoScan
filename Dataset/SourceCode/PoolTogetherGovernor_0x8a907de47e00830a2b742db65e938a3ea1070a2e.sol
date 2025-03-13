// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.18;

import {
  Governor, GovernorCountingFractional
} from "flexible-voting/src/GovernorCountingFractional.sol";
import {IERC165} from "@openzeppelin/contracts/interfaces/IERC165.sol";
import {
  ERC20VotesComp,
  GovernorVotesComp
} from "@openzeppelin/contracts/governance/extensions/GovernorVotesComp.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {ICompoundTimelock} from
  "@openzeppelin/contracts/governance/extensions/GovernorTimelockCompound.sol";
import {GovernorSettings} from "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";

import {IPoolTogetherTimelock} from "src/interfaces/IPoolTogetherTimelock.sol";
import {GovernorTimelockCompound} from "src/lib/GovernorTimelockCompound.sol";

/// @notice The upgraded PoolTogether Governor: Bravo compatible and built with OpenZeppelin.
contract PoolTogetherGovernor is
  GovernorCountingFractional,
  GovernorVotesComp,
  GovernorTimelockCompound,
  GovernorSettings
{
  /// @notice The address of the POOL token on Ethereum mainnet from which this Governor derives
  /// delegated voting weight.
  ERC20VotesComp private constant POOL_TOKEN =
    ERC20VotesComp(0x0cEC1A9154Ff802e7934Fc916Ed7Ca50bDE6844e);

  /// @notice The address of the existing PoolTogether DAO Timelock on Ethereum mainnet through
  /// which
  /// this Governor executes transactions.
  IPoolTogetherTimelock private constant TIMELOCK =
    IPoolTogetherTimelock(payable(0x42cd8312D2BCe04277dD5161832460e95b24262E));

  /// @notice Human readable name of this Governor.
  string private constant GOVERNOR_NAME = "PoolTogether Governor Bravo";

  /// @notice The number of POOL (in "wei") that must participate in a vote for it to meet quorum
  /// threshold.
  ///
  /// TODO: placeholder
  uint256 private constant QUORUM = 100_000e18; // 100,000 POOL

  /// @param _initialVotingDelay The deployment value for the voting delay this Governor will
  /// enforce.
  /// @param _initialVotingPeriod The deployment value for the voting period this Governor will
  /// enforce.
  /// @param _initialProposalThreshold The deployment value for the number of POOL required to
  /// submit
  /// a proposal this Governor will enforce.
  constructor(
    uint256 _initialVotingDelay,
    uint256 _initialVotingPeriod,
    uint256 _initialProposalThreshold
  )
    GovernorVotesComp(POOL_TOKEN)
    GovernorSettings(_initialVotingDelay, _initialVotingPeriod, _initialProposalThreshold)
    GovernorTimelockCompound(TIMELOCK)
    Governor(GOVERNOR_NAME)
  {}

  /// @dev We override this function to resolve ambiguity between inherited contracts.
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(Governor, GovernorTimelockCompound)
    returns (bool)
  {
    return GovernorTimelockCompound.supportsInterface(interfaceId);
  }

  /// @dev We override this function to resolve ambiguity between inherited contracts.
  function castVoteWithReasonAndParamsBySig(
    uint256 proposalId,
    uint8 support,
    string calldata reason,
    bytes memory params,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public override(Governor, GovernorCountingFractional, IGovernor) returns (uint256) {
    return GovernorCountingFractional.castVoteWithReasonAndParamsBySig(
      proposalId, support, reason, params, v, r, s
    );
  }

  /// @dev We override this function to resolve ambiguity between inherited contracts.
  function proposalThreshold()
    public
    view
    virtual
    override(Governor, GovernorSettings)
    returns (uint256)
  {
    return GovernorSettings.proposalThreshold();
  }

  /// @dev We override this function to resolve ambiguity between inherited contracts.
  function state(uint256 proposalId)
    public
    view
    virtual
    override(Governor, GovernorTimelockCompound)
    returns (ProposalState)
  {
    return GovernorTimelockCompound.state(proposalId);
  }

  /// @notice The amount of POOL required to meet the quorum threshold for a proposal
  /// as of a given block.
  /// @dev Our implementation ignores the block number parameter and returns a constant.
  function quorum(uint256) public pure override returns (uint256) {
    return QUORUM;
  }

  /// @dev We override this function to resolve ambiguity between inherited contracts.
  function _execute(
    uint256 proposalId,
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  ) internal virtual override(Governor, GovernorTimelockCompound) {
    return
      GovernorTimelockCompound._execute(proposalId, targets, values, calldatas, descriptionHash);
  }

  /// @dev We override this function to resolve ambiguity between inherited contracts.
  function _cancel(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  ) internal virtual override(Governor, GovernorTimelockCompound) returns (uint256) {
    return GovernorTimelockCompound._cancel(targets, values, calldatas, descriptionHash);
  }

  /// @dev We override this function to resolve ambiguity between inherited contracts.
  function _executor()
    internal
    view
    virtual
    override(Governor, GovernorTimelockCompound)
    returns (address)
  {
    return GovernorTimelockCompound._executor();
  }
}