// SPDX-License-Identifier: AGPL-3.0

pragma solidity 0.8.17;

import "./libraries/Utils.sol";
import "./roles/Attestable.sol";
import "./interfaces/IBridge.sol";
import "./interfaces/IReceiver.sol";
import "./interfaces/ICallProxy.sol";
import "./interfaces/ITokenMessenger.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Bridge is IBridge, Attestable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address public feeCollector;
    address public tokenMessenger;
    address public callProxy;

    // destination domain => destination bridge
    mapping(uint32 => bytes32) public bridgeHashMap;

    // token => disabled
    mapping(address => bool) public disabledBridgeTokens;

    // token, destination domain => disabled
    mapping(address => mapping(uint32 => bool)) public disabledRoutes;

    event SetTokenMessenger(address tokenMessenger);
    event SetFeeCollector(address feeCollector);
    event SetCallProxy(address callProxy);
    event EnableBridgeToken(address token);
    event DisableBridgeToken(address token);
    event EnableRoute(address token, uint32 destinationDomain);
    event DisableRoute(address token, uint32 destinationDomain);
    event BindBridge(uint32 destinationDomain, bytes32 targetBridge);
    event BindBridgeBatch(uint32[] destinationDomains, bytes32[] targetBridges);

    event BridgeOut(
        address sender,
        address token,
        uint32 destinationDomain,
        uint256 amount,
        uint64 nonce,
        bytes32 recipient,
        bytes callData,
        uint256 fee
    );

    event BridgeIn(
        address sender,
        address recipient,
        address token,
        uint256 amount
    );

    struct TxArgs {
        address token;
        bytes message;
        bytes mintAttestation;
        bytes32 recipient;
        bytes callData;
    }

    receive() external payable { }

    constructor(
        address _tokenMessenger,
        address _attester,
        address _feeCollector
        ) Attestable(_attester) {
        require(_tokenMessenger != address(0), "tokenMessenger address cannot be zero");
        require(_feeCollector != address(0), "feeCollector address cannot be zero");

        tokenMessenger = _tokenMessenger;
        feeCollector = _feeCollector;
    }

    function bridgeOut(
        address token,
        uint256 amount,
        uint32 destinationDomain,
        bytes32 recipient,
        bytes calldata callData
    ) external payable nonReentrant whenNotPaused {
        bytes32 targetBridge = bridgeHashMap[destinationDomain];

        require(targetBridge != bytes32(0), "target bridge not enabled");
        require(msg.sender != callProxy, "forbidden");
        require(recipient != bytes32(0), "recipient address cannot be zero");
        require(!disabledBridgeTokens[token], "token not enabled");
        require(!disabledRoutes[token][destinationDomain], "route disabled");

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(token).safeApprove(tokenMessenger, amount);
        uint64 nonce = ITokenMessenger(tokenMessenger).depositForBurnWithCaller(
            amount, destinationDomain, targetBridge, token, targetBridge
        );

        sendNative(feeCollector, msg.value);
        emit BridgeOut(msg.sender, token, destinationDomain, amount, nonce, recipient, callData, msg.value);
    }

    function bridgeIn(
        bytes calldata args,
        bytes calldata attestation
    ) external nonReentrant whenNotPaused {
        require(args.length > 0, "invalid bridgeIn args");

        _verifyAttestationSignatures(args, attestation);

        TxArgs memory txArgs = deserializeTxArgs(args);
        address token = txArgs.token;

        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        bool success = _getMessageTransmitter().receiveMessage(txArgs.message, txArgs.mintAttestation);
        require(success, "receive message failed");
        uint256 amount = IERC20(token).balanceOf(address(this)) - balanceBefore;
        require(amount > 0, "amount cannot be zero");

        address recipient = bytes32ToAddress(txArgs.recipient);
        require(recipient != address(0), "recipient address cannot be zero");

        if (txArgs.callData.length == 0 || callProxy == address(0)) {
            IERC20(token).safeTransfer(recipient, amount);
        } else {
            IERC20(token).safeTransfer(callProxy, amount);
            require(ICallProxy(callProxy).proxyCall(token, amount, recipient, txArgs.callData), "proxy call failed");
        }

        emit BridgeIn(msg.sender, recipient, token, amount);
    }

    function getMessageTransmitter() external view returns (IReceiver) {
        return _getMessageTransmitter();
    }

    function _getMessageTransmitter() internal view returns (IReceiver) {
        return IReceiver(ITokenMessenger(tokenMessenger).localMessageTransmitter());
    }

    function setTokenMessenger(address newTokenMessenger) onlyOwner external {
        require(newTokenMessenger != address(0), "tokenMessenger address cannot be zero");

        tokenMessenger = newTokenMessenger;
        emit SetTokenMessenger(newTokenMessenger);
    }

    function enableBridgeToken(address token) external onlyOwner {
        require(token != address(0), "token address cannot be zero");
        delete disabledBridgeTokens[token];
        emit EnableBridgeToken(token);
    }

    function disableBridgeToken(address token) external onlyOwner {
        require(token != address(0), "token address cannot be zero");
        disabledBridgeTokens[token] = true;
        emit DisableBridgeToken(token);
    }

    function enableRouter(address token, uint32 destinationDomain) external onlyOwner {
        require(token != address(0), "token address cannot be zero");
        delete disabledRoutes[token][destinationDomain];
        emit EnableRoute(token, destinationDomain);
    }

    function disableRoute(address token, uint32 destinationDomain) external onlyOwner {
        require(token != address(0), "token address cannot be zero");
        disabledRoutes[token][destinationDomain] = true;
        emit DisableRoute(token, destinationDomain);
    }

    function setCallProxy(address newCallProxy) onlyOwner external {
        callProxy = newCallProxy;
        emit SetCallProxy(newCallProxy);
    }

    function setFeeCollector(address newFeeCollector) external onlyOwner {
        require(newFeeCollector != address(0), "feeCollector address cannot be zero");

        feeCollector = newFeeCollector;
        emit SetFeeCollector(newFeeCollector);
    }

    function bindBridge(uint32 destinationDomain, bytes32 targetBridge) onlyOwner external returns (bool) {
        bridgeHashMap[destinationDomain] = targetBridge;
        emit BindBridge(destinationDomain, targetBridge);
        return true;
    }

    function bindBridgeBatch(uint32[] calldata destinationDomains, bytes32[] calldata targetBridgeHashes) onlyOwner external returns (bool) {
        require(destinationDomains.length == targetBridgeHashes.length, "Inconsistent parameter lengths");

        for (uint i = 0; i < destinationDomains.length; i++) {
            bridgeHashMap[destinationDomains[i]] = targetBridgeHashes[i];
        }

        emit BindBridgeBatch(destinationDomains, targetBridgeHashes);
        return true;
    }

    function externalCall(address callee, bytes calldata data) external onlyOwner {
        (bool success, ) = callee.call(data);
        require(success, "external call failed");
    }

    function rescueFund(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        token.safeTransfer(_msgSender(), token.balanceOf(address(this)));
    }

    function rescueNative(address receiver) external onlyOwner {
        sendNative(receiver, address(this).balance);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function sendNative(address receiver, uint256 amount) internal {
        (bool success, ) = receiver.call{ value: amount }("");
        require(success, "unable to send value, recipient may have reverted");
    }

    function deserializeTxArgs(bytes calldata rawArgs) internal pure returns (TxArgs memory) {
        TxArgs memory txArgs;
        uint256 offset = 0;

        bytes memory tokenBytes;
        (tokenBytes, offset) = Utils.NextVarBytes(rawArgs, offset);
        txArgs.token = Utils.bytesToAddress(tokenBytes);

        (txArgs.message, offset) = Utils.NextVarBytes(rawArgs, offset);
        (txArgs.mintAttestation, offset) = Utils.NextVarBytes(rawArgs, offset);

        bytes memory recipientBytes;
        (recipientBytes, offset) = Utils.NextVarBytes(rawArgs, offset);
        txArgs.recipient = addressToBytes32(Utils.bytesToAddress(recipientBytes));

        (txArgs.callData, offset) = Utils.NextVarBytes(rawArgs, offset);

        return txArgs;
    }

    // May revert if current chain does not implement the `BASEFEE` opcode
    function getBasefee() external view returns (uint256 basefee) {
        basefee = block.basefee;
    }

    function addressToBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }
}