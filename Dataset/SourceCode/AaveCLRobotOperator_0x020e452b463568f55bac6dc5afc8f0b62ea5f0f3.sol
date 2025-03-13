// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IAaveCLRobotOperator} from '../interfaces/IAaveCLRobotOperator.sol';
import {LinkTokenInterface} from 'chainlink-brownie-contracts/interfaces/LinkTokenInterface.sol';
import {IKeeperRegistrar} from '../interfaces/IKeeperRegistrar.sol';
import {IKeeperRegistry} from '../interfaces/IKeeperRegistry.sol';
import {OwnableWithGuardian} from 'solidity-utils/contracts/access-control/OwnableWithGuardian.sol';

/**
 * @title AaveCLRobotOperator
 * @author BGD Labs
 * @dev Operator contract to perform admin actions on the automation keepers.
 *      The contract can register keepers, cancel it, withdraw excess link,
 *      refill the keeper, configure the gasLimit.
 */
contract AaveCLRobotOperator is OwnableWithGuardian, IAaveCLRobotOperator {
  /// @inheritdoc IAaveCLRobotOperator
  address public immutable LINK_TOKEN;

  /// @inheritdoc IAaveCLRobotOperator
  address public immutable KEEPER_REGISTRY;

  /// @inheritdoc IAaveCLRobotOperator
  address public immutable KEEPER_REGISTRAR;

  address internal _linkWithdrawAddress;

  mapping(uint256 id => KeeperInfo) internal _keepers;

  /**
   * @param linkTokenAddress address of the ERC-677 link token contract.
   * @param keeperRegistry address of the chainlink registry.
   * @param keeperRegistrar address of the chainlink registrar.
   * @param linkWithdrawAddress withdrawal address to send the exccess link after cancelling the keeper.
   * @param operatorOwner address to set as the owner of the operator contract.
   */
  constructor(
    address linkTokenAddress,
    address keeperRegistry,
    address keeperRegistrar,
    address linkWithdrawAddress,
    address operatorOwner
  ) {
    KEEPER_REGISTRY = keeperRegistry;
    KEEPER_REGISTRAR = keeperRegistrar;
    LINK_TOKEN = linkTokenAddress;
    _linkWithdrawAddress = linkWithdrawAddress;
    _transferOwnership(operatorOwner);
  }

  /// @notice In order to fund the keeper we need to approve the Link token amount to this contract
  /// @inheritdoc IAaveCLRobotOperator
  function register(
    string memory name,
    address upkeepContract,
    uint32 gasLimit,
    uint96 amountToFund
  ) external onlyOwner returns (uint256) {
    LinkTokenInterface(LINK_TOKEN).transferFrom(msg.sender, address(this), amountToFund);
    (IKeeperRegistry.State memory state, , ) = IKeeperRegistry(KEEPER_REGISTRY).getState();
    // nonce of the registry before the keeper has been registered
    uint256 oldNonce = state.nonce;

    bytes memory payload = abi.encode(
      name, // name of the keeper to register
      0x0, // encryptedEmail to send alerts to, unused currently
      upkeepContract, // address of the upkeep contract
      gasLimit, // max gasLimit which can be used for an performUpkeep action
      address(this), // admin of the keeper is set to this address of AaveCLRobotOperator
      '', // checkData of the keeper which get passed to the checkUpkeep, unused currently
      amountToFund, // amount of link to fund the keeper with
      0, // source application sending this request
      address(this) // address of the sender making the request
    );
    LinkTokenInterface(LINK_TOKEN).transferAndCall(
      KEEPER_REGISTRAR,
      amountToFund,
      bytes.concat(IKeeperRegistrar.register.selector, payload)
    );

    (state, , ) = IKeeperRegistry(KEEPER_REGISTRY).getState();

    // checks if the keeper has been registered succesfully by checking that nonce has been incremented on the registry
    if (state.nonce == oldNonce + 1) {
      // calculates the id for the keeper registered
      uint256 id = uint256(
        keccak256(abi.encodePacked(blockhash(block.number - 1), KEEPER_REGISTRY, uint32(oldNonce)))
      );
      _keepers[id].upkeep = upkeepContract;
      _keepers[id].name = name;
      emit KeeperRegistered(id, upkeepContract, amountToFund);

      return id;
    } else {
      revert('AUTO_APPROVE_DISABLED');
    }
  }

  /// @inheritdoc IAaveCLRobotOperator
  function cancel(uint256 id) external onlyOwner {
    IKeeperRegistry(KEEPER_REGISTRY).cancelUpkeep(id);
    emit KeeperCancelled(id, _keepers[id].upkeep);
  }

  /// @inheritdoc IAaveCLRobotOperator
  function withdrawLink(uint256 id) external {
    IKeeperRegistry(KEEPER_REGISTRY).withdrawFunds(id, _linkWithdrawAddress);
    emit LinkWithdrawn(id, _keepers[id].upkeep, _linkWithdrawAddress);
  }

  /// @notice In order to refill the keeper we need to approve the Link token amount to this contract
  /// @inheritdoc IAaveCLRobotOperator
  function refillKeeper(uint256 id, uint96 amount) external {
    LinkTokenInterface(LINK_TOKEN).transferFrom(msg.sender, address(this), amount);
    LinkTokenInterface(LINK_TOKEN).approve(KEEPER_REGISTRY, amount);
    IKeeperRegistry(KEEPER_REGISTRY).addFunds(id, amount);
    emit KeeperRefilled(id, msg.sender, amount);
  }

  /// @inheritdoc IAaveCLRobotOperator
  function setGasLimit(uint256 id, uint32 gasLimit) external onlyOwnerOrGuardian {
    IKeeperRegistry(KEEPER_REGISTRY).setUpkeepGasLimit(id, gasLimit);
    emit GasLimitSet(id, _keepers[id].upkeep, gasLimit);
  }

  /// @inheritdoc IAaveCLRobotOperator
  function setWithdrawAddress(address withdrawAddress) external onlyOwner {
    _linkWithdrawAddress = withdrawAddress;
    emit WithdrawAddressSet(withdrawAddress);
  }

  /// @inheritdoc IAaveCLRobotOperator
  function getWithdrawAddress() external view returns (address) {
    return _linkWithdrawAddress;
  }

  /// @inheritdoc IAaveCLRobotOperator
  function getKeeperInfo(uint256 id) external view returns (KeeperInfo memory) {
    return _keepers[id];
  }
}