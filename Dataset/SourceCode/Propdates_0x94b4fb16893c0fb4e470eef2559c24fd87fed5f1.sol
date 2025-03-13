// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {NounsDAOLogicV2} from "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOLogicV2.sol";
import "lib/nouns-monorepo/packages/nouns-contracts/contracts/governance/NounsDAOInterfaces.sol";

import {GasRefund} from "./GasRefund.sol";

contract Propdates {
    struct PropdateInfo {
        // address which can post updates for this prop
        address propUpdateAdmin;
        // when was the last update was posted
        uint88 lastUpdated;
        // is the primary work of the proposal considered done
        bool isCompleted;
    }

    event PropUpdateAdminTransferStarted(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PropUpdateAdminTransfered(uint256 indexed propId, address indexed oldAdmin, address indexed newAdmin);
    event PostUpdate(uint256 indexed propId, bool indexed isCompleted, string update);

    error OnlyPropUpdateAdmin();
    error OnlyPendingPropUpdateAdmin();
    error NoZeroAddress();

    address payable public constant NOUNS_DAO = payable(0x6f3E6272A167e8AcCb32072d08E0957F9c79223d);

    mapping(uint256 => address) public pendingPropUpdateAdmin;
    mapping(uint256 => PropdateInfo) internal _propdateInfo;

    // allow receiving ETH for gas refunds
    receive() external payable {}

    /// @notice Transfers prop update admin power to a new address
    /// @dev reverts if the new admin is the zero address
    /// @dev if current admin is zero address, reverts unless msg.sender is prop proposer
    /// @dev if current admin is not zero address, reverts unless msg.sender is current admin
    /// @dev requires newAdmin to accept the admin power in a separate transaction
    /// @param propId The id of the prop
    /// @param newAdmin The address to transfer admin power to
    function transferPropUpdateAdmin(uint256 propId, address newAdmin) external {
        if (newAdmin == address(0)) {
            // block transferring to zero address because it creates a weird state
            // where the prop proposer has control again
            revert NoZeroAddress();
        }

        address currentAdmin = _propdateInfo[propId].propUpdateAdmin;
        if (
            msg.sender != currentAdmin
                && !(currentAdmin == address(0) && NounsDAOLogicV2(NOUNS_DAO).proposals(propId).proposer == msg.sender)
        ) {
            revert OnlyPropUpdateAdmin();
        }
        pendingPropUpdateAdmin[propId] = newAdmin;

        emit PropUpdateAdminTransferStarted(propId, currentAdmin, newAdmin);
    }

    /// @notice Accepts the pending prop update admin power
    /// @param propId The id of the prop
    function acceptPropUpdateAdmin(uint256 propId) external {
        if (msg.sender != pendingPropUpdateAdmin[propId]) {
            revert OnlyPendingPropUpdateAdmin();
        }

        _acceptPropUpdateAdmin(propId);
    }

    /// @notice Posts an update for a prop
    /// @dev reverts unless msg.sender is propUpdateAdmin or pendingPropUpdateAdmin
    /// @param propId The id of the prop
    /// @param isCompleted Whether the primary work of the prop is considered done
    /// @param update A string describing the update
    function postUpdate(uint256 propId, bool isCompleted, string calldata update) external {
        uint256 startGas = gasleft();

        if (msg.sender != _propdateInfo[propId].propUpdateAdmin) {
            if (msg.sender == pendingPropUpdateAdmin[propId]) {
                // don't love the side effect here, but it saves a tx and so seems worth it?
                // could also just make it multicallable, but this is simpler for clients
                _acceptPropUpdateAdmin(propId);
            } else {
                revert OnlyPropUpdateAdmin();
            }
        }

        _propdateInfo[propId].lastUpdated = uint88(block.timestamp);
        // only set this value if true, so that it can't be unset
        if (isCompleted) {
            _propdateInfo[propId].isCompleted = true;
        }

        emit PostUpdate(propId, isCompleted, update);

        if (NounsDAOLogicV2(NOUNS_DAO).proposals(propId).executed) {
            GasRefund.refundGas(startGas);
        }
    }

    /// @notice Returns the propdate info for a prop
    /// @param propId The id of the prop
    /// @return info propdate info
    function propdateInfo(uint256 propId) external view returns (PropdateInfo memory) {
        return _propdateInfo[propId];
    }

    function _acceptPropUpdateAdmin(uint256 propId) internal {
        delete pendingPropUpdateAdmin[propId];

        address oldAdmin = _propdateInfo[propId].propUpdateAdmin;
        _propdateInfo[propId].propUpdateAdmin = msg.sender;

        emit PropUpdateAdminTransfered(propId, oldAdmin, msg.sender);
    }
}