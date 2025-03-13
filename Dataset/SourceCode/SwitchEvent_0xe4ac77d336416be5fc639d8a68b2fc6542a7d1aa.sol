// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../lib/DataTypes.sol";
import "hardhat/console.sol";

contract SwitchEvent is Ownable, AccessControl {
    bytes32 public constant EMITTOR_ROLE=keccak256("EMITTOR_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    event Swapped(
        address from,
        address recipient,
        IERC20 fromToken,
        IERC20 destToken,
        uint256 fromAmount,
        uint256 destAmount,
        uint256 reward
    );

    event ParaswapSwapped(
        address from,
        IERC20 fromToken,
        uint256 fromAmount
    );

    event CrosschainSwapRequest(
        bytes32 indexed id,
        bytes32 bridgeTransferId,
        bytes32 indexed bridge, // bridge slug
        address indexed from, // user address
        address fromToken, // source token on sending chain
        address bridgeToken, // bridge token on sending chain
        address destToken, // dest token on receiving chain
        uint256 fromAmount, // source token amount on sending chain
        uint256 bridgeAmount, // swapped amount on sending chain
        uint256 dstAmount, // estimated amount of dest token on receiving chain
        DataTypes.SwapStatus status
    );

    event CrosschainSwapDone(
        bytes32 indexed id,
        bytes32 indexed bridge,
        address indexed from, // user address
        address bridgeToken, // source token on receiving chain
        address destToken, // dest token on receiving chain
        uint256 bridgeAmount, // bridge token amount on receiving chain
        uint256 destAmount, //dest token amount on receiving chain
        DataTypes.SwapStatus status
    );

    event CrosschainDepositRequest(
        bytes32 indexed id,
        bytes32 bridgeTransferId,
        bytes32 indexed bridge, // bridge slug
        address indexed from, // user address
        address depositContract, // contract address for deposit
        address toApprovalAddress, // the approval address for deposit
        address fromToken, // source token on sending chain
        address depositToken, // deposit token on receiving chain
        uint256 fromAmount, // source token amount on sending chain
        uint256 depositAmount, // estimated amount of dest token on receiving chain
        DataTypes.DepositStatus status
    );

    event CrosschainDepositDone(
        bytes32 indexed id,
        bytes32 indexed bridge,
        address indexed from, // user address
        address depositContract, // contract address for deposit
        address toApprovalAddress, // the approval address for deposit
        address bridgeToken, // source token on receiving chain
        address depositToken, // dest token on receiving chain
        uint256 bridgeAmount, // bridge token amount on receiving chain
        uint256 depositAmount, //dest token amount on receiving chain
        DataTypes.DepositStatus status
    );

    function emitSwapped(
        address from,
        address recipient,
        IERC20 fromToken,
        IERC20 destToken,
        uint256 fromAmount,
        uint256 destAmount,
        uint256 reward
    )
        external onlyRole(EMITTOR_ROLE)
    {
        emit Swapped(from, recipient, fromToken, destToken, fromAmount, destAmount, reward);
    }

    function emitParaswapSwapped(
        address from,
        IERC20 fromToken,
        uint256 fromAmount
    )
        external onlyRole(EMITTOR_ROLE)
    {
        emit ParaswapSwapped(from, fromToken, fromAmount);
    }

    function emitCrosschainSwapRequest(
        bytes32 id,
        bytes32 bridgeTransferId,
        bytes32 bridge, // bridge slug
        address from, // user address
        address fromToken, // source token on sending chain
        address bridgeToken, // bridge token on sending chain
        address destToken, // dest token on receiving chain
        uint256 fromAmount, // source token amount on sending chain
        uint256 bridgeAmount, // swapped amount on sending chain
        uint256 destAmount, // estimated amount of dest token on receiving chain
        DataTypes.SwapStatus status
    ) external onlyRole(EMITTOR_ROLE) {
        emit CrosschainSwapRequest(id, bridgeTransferId, bridge, from, fromToken, bridgeToken, destToken, fromAmount, bridgeAmount, destAmount, status);
    }

    function emitCrosschainSwapDone(
        bytes32 id,
        bytes32 bridge,
        address from, // user address
        address bridgeToken, // source token on receiving chain
        address destToken, // dest token on receiving chain
        uint256 bridgeAmount, // bridge token amount on receiving chain
        uint256 destAmount, //dest token amount on receiving chain
        DataTypes.SwapStatus status
    ) external onlyRole(EMITTOR_ROLE) {
        emit CrosschainSwapDone(id, bridge, from, bridgeToken, destToken, bridgeAmount, destAmount, status);
    }

    function emitCrosschainDepositRequest(
        bytes32 id,
        bytes32 bridgeTransferId,
        bytes32 bridge, // bridge slug
        address from, // user address
        address depositContract,
        address toApprovalAddress, // the approval address for deposit
        address fromToken, // source token on sending chain
        address depositToken, // dest token on receiving chain
        uint256 fromAmount, // source token amount on sending chain
        uint256 depositAmount, // estimated amount of dest token on receiving chain
        DataTypes.DepositStatus status
    ) external onlyRole(EMITTOR_ROLE) {
        emit CrosschainDepositRequest(id, bridgeTransferId, bridge, from, depositContract, toApprovalAddress, fromToken, depositToken, fromAmount, depositAmount, status);
    }

    function emitCrosschainDepositDone(
        bytes32 id,
        bytes32 bridge,
        address from, // user address
        address depositContract,
        address toApprovalAddress, // the approval address for deposit
        address bridgeToken, // source token on receiving chain
        address depositToken, // dest token on receiving chain
        uint256 bridgeAmount, // bridge token amount on receiving chain
        uint256 depositAmount, //dest token amount on receiving chain
        DataTypes.DepositStatus status
    ) external onlyRole(EMITTOR_ROLE) {
        emit CrosschainDepositDone(id, bridge, from, depositContract, toApprovalAddress, bridgeToken, depositToken, bridgeAmount, depositAmount, status);
    }
}