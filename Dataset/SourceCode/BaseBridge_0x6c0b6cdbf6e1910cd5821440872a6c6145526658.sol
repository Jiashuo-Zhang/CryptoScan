// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
pragma abicoder v2;

// import "hardhat/console.sol";
import "./lz/lzApp/NonblockingLzApp.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract BaseBridge is NonblockingLzApp, Pausable, ReentrancyGuard {
    uint16 public immutable l1ChainId;
    uint16 public immutable l2ChainId;

    uint256 public immutable currentChainId;
    uint16 public immutable destChainId;
    address public otherSideOfBridge;
    address public bridgeFeeRecipient;

    uint256 public totalBridgedOn;
    uint256 public totalReleased;
    uint256 public totalUnclaimedOwed;

    uint256 public totalFeesEarned;
    uint256 public totalFeesWithdrawn;

    uint256 public bridgeFee;
    bool public bridgingEnabled = true;

    mapping(address => uint256) public balances;

    event FundsReceived(address indexed sender, uint256 amount);
    event FundsReleased(address indexed recipient, uint256 amount);
    event OwnerWithdrew(uint256 amount);
    event EarnedFeesWithdrawn(uint256 amount);

    error WithdrawFailed();
    error NoBalanceToClaim();
    error NotAllowed();
    error ConfigError();
    error WrongChain();

    modifier whenBridgingEnabled() {
        if (!bridgingEnabled) {
            revert NotAllowed();
        }
        _;
    }

    constructor(
        uint256 l1ChainId_, // will be ETH Mainnet in production
        uint256 l2ChainId_, // will be Base Mainnet in production
        address lzEndpoint_, // the LayerZero endpoint contract address on the source chain
        uint256 currentChainId_, // the current chain id
        uint256 destChainId_, // the destination chain id
        address bridgeFeeRecipient_ // the address to receive bridge fees
    ) NonblockingLzApp(lzEndpoint_) {
        l1ChainId = uint16(l1ChainId_);
        l2ChainId = uint16(l2ChainId_);

        if (l1ChainId == l2ChainId || l1ChainId == 0 || l2ChainId == 0) {
            revert ConfigError();
        }

        currentChainId = uint16(currentChainId_);
        destChainId = uint16(destChainId_);

        if (currentChainId == destChainId) {
            revert ConfigError();
        }

        bridgeFee = 5;
        bridgeFeeRecipient = bridgeFeeRecipient_;
    }

    function _nonblockingLzReceive(
        uint16 /* srcChainId_ */,
        bytes memory srcAddress_,
        uint64 /* nonce_ */,
        bytes memory payload_
    ) internal override {
        // Extract the address from the bytes memory parameter.
        address senderAddress;
        assembly {
            senderAddress := mload(add(srcAddress_, 20))
        }

        // Require that the sending contract is the other side of this bridge.
        if (senderAddress != otherSideOfBridge) {
            revert NotAllowed();
        }

        // Decode the original sender address and value from the payload.
        (address decodedAddress, uint256 decodedFullValue) = abi.decode(
            payload_,
            (address, uint256)
        );

        uint256 fee = (decodedFullValue * bridgeFee) / 100;
        uint256 amountToRelease = decodedFullValue - fee;

        totalFeesEarned += fee;

        // Send the value to the original sender.
        (bool success, ) = decodedAddress.call{value: amountToRelease}("");

        // If the send failed, store the account balance so it can be claimed later.
        if (!success) {
            balances[decodedAddress] += amountToRelease;
            totalUnclaimedOwed += amountToRelease;
        } else {
            emit FundsReleased(msg.sender, amountToRelease);
            totalReleased += amountToRelease;
        }
    }

    function claimBalance() external whenNotPaused nonReentrant {
        // Get the balance for the caller.
        uint256 userBalance = balances[msg.sender];

        // Require that the user has a balance to claim.
        if (userBalance == 0) {
            revert NoBalanceToClaim();
        }

        // Reset the user's balance.
        delete balances[msg.sender];

        // Increment the total released counter.
        totalReleased += userBalance;

        // Deduct the user's balance from the total unclaimed.
        totalUnclaimedOwed -= userBalance;

        // Send the total bridged to the caller.
        (bool success, ) = msg.sender.call{value: userBalance}("");

        // If the send failed, revert to reset the state.
        if (!success) {
            revert WithdrawFailed();
        }

        emit FundsReleased(msg.sender, userBalance);
    }

    function _sendETHReceivedMessage() internal {
        require(
            address(this).balance > 0,
            "balance too low for gas for message fees"
        );

        // Emit event for ETH received.
        emit FundsReceived(msg.sender, msg.value);

        // encode the payload
        bytes memory payload = abi.encode(msg.sender, msg.value);

        // Increment the total bridged counter.
        totalBridgedOn += msg.value;

        // send LayerZero message
        _lzSend( // {value: messageFee} will be paid out of this contract!
            destChainId, // destination chainId
            payload, // abi.encode()'ed bytes
            payable(this), // (msg.sender will be this contract) refund address (LayerZero will refund any extra gas back to caller of send()
            address(0x0), // future param, unused
            bytes(""), // adapterParams, // adapterParams, // v1 adapterParams, specify custom destination gas qty
            msg.value
        );
    }

    function withdrawableAfterUsersMadeWhole() public view returns (uint256) {
        if (totalUnclaimedOwed >= address(this).balance) {
            return 0;
        } else {
            return address(this).balance - totalUnclaimedOwed;
        }
    }

    function ownerWithdraw(uint256 amount_) external onlyOwner nonReentrant {
        if (amount_ == 0 || amount_ > withdrawableAfterUsersMadeWhole()) {
            revert WithdrawFailed();
        }

        (bool success, ) = msg.sender.call{value: amount_}("");
        if (!success) {
            revert WithdrawFailed();
        }

        emit OwnerWithdrew(amount_);
    }

    // Fees can be withdrawn by anyone to the fee address, as long as there's still enough eth to cover what users are owed.
    // Can only withdraw up to the amount earned minus the amount already withdrawn.
    function withdrawFeesEarned(uint256 amount_) external nonReentrant {
        if (
            amount_ == 0 ||
            totalFeesEarned < amount_ ||
            totalFeesEarned - amount_ < totalFeesWithdrawn ||
            amount_ > withdrawableAfterUsersMadeWhole()
        ) {
            revert WithdrawFailed();
        }

        totalFeesWithdrawn += amount_;

        (bool success, ) = bridgeFeeRecipient.call{value: amount_}("");
        if (!success) {
            revert WithdrawFailed();
        }

        emit EarnedFeesWithdrawn(amount_);
    }

    function setBridgeFeeRecipient(address recipient_) external onlyOwner {
        bridgeFeeRecipient = recipient_;
    }

    function setBridgeFee(uint256 fee_) external onlyOwner {
        if (fee_ > 10) {
            revert ConfigError();
        }
        bridgeFee = fee_;
    }

    function setOtherSideOfBridge(
        address otherSideOfBridge_
    ) external onlyOwner {
        otherSideOfBridge = otherSideOfBridge_;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setBridgingEnabled(bool enabled_) external onlyOwner {
        bridgingEnabled = enabled_;
    }

    function bridge() external payable whenNotPaused whenBridgingEnabled {
        if (otherSideOfBridge == address(0)) {
            revert ConfigError();
        }

        _sendETHReceivedMessage();
    }

    // Must be allowed to accept ETH for refunds from LayerZero.
    // Can also receive funds from anywhere, so users must use the bridge function.
    receive() external payable {}

    fallback() external payable {}
}