// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error AlreadySetuped();
error NotLiveOrSetuped();
error NotEnoughReserve();
error NotEnoughTokens();
error ContractNotApproved();
error ReceiptAlreadyUsed();
error InvalidReceipt();
error ReceiptDelay();
error UnknownBridge();
error InvalidBridgeID();
error InvalidAmount();

contract Wormhole is Ownable, ReentrancyGuard {
    using ECDSA for bytes32;

    address public signerAddr;
    uint32 public bridgeID;
    uint64 public delay;

    bool public paused;
    address public tokenAddr;

    struct Receipt {
        uint256 amount;
        uint256 time;
        bytes32 id;
        uint32 from;
        uint32 to;
        address user;
    }

    mapping(address => bytes32[]) public receiptsPerAddress;

    mapping(address => uint32) public receiptsNbPerAddress;

    mapping(bytes32 => Receipt) public createdReceipts;

    mapping(bytes32 => bool) public usedReceipts;

    // events
    event ReceiptCreated(address indexed depositer, uint256 amount, uint256 datetime, uint32 toBridge);
    event ReceiptUsed(address indexed withdrawer, uint256 amount, uint256 datetime, uint32 fromBridge);

    constructor(address _signerAddr, address _tokenAddr, uint64 _delay) payable {
        signerAddr = _signerAddr;
        tokenAddr = _tokenAddr;
        delay = _delay;
    }

    modifier isLive() {
        if (paused || bridgeID == 0) {
            _revert(NotLiveOrSetuped.selector);
        }
        _;
    }

    modifier validBridge(uint32 _bridgeID) {
        if (_bridgeID == 0 || _bridgeID == bridgeID) {
            _revert(InvalidBridgeID.selector);
        }
        _;
    }

    function setup(uint32 _bridgeID) external payable onlyOwner validBridge(_bridgeID) {
        if (bridgeID != 0) {
            _revert(AlreadySetuped.selector);
        }
        bridgeID = _bridgeID;
    }

    function setSigner(address _v) external payable onlyOwner {
        signerAddr = _v;
    }

    function setDelay(uint64 _v) external payable onlyOwner {
        delay = _v;
    }

    function flipPaused() external payable onlyOwner {
        paused = !paused;
    }

    function claim(uint256 receiptAmount, uint256 receiptTime, uint8 receiptFromBridge, bytes calldata signature) external isLive validBridge(receiptFromBridge) nonReentrant {
        if (IERC20(tokenAddr).balanceOf(address(this)) < receiptAmount) {
            _revert(NotEnoughReserve.selector);
        }

        if (receiptTime + uint256(delay) > block.timestamp) {
            _revert(ReceiptDelay.selector);
        }

        bytes32 receiptID = getReceiptID(receiptAmount, receiptTime, _msgSender(), receiptFromBridge, bridgeID);

        if (usedReceipts[receiptID]) {
            _revert(ReceiptAlreadyUsed.selector);
        }

        if (!verifyReceiptID(receiptID, signature)) {
            _revert(InvalidReceipt.selector);
        }

        // register claim
        usedReceipts[receiptID] = true;
        IERC20(tokenAddr).transfer(_msgSender(), receiptAmount);

        emit ReceiptUsed(_msgSender(), receiptAmount, receiptTime, receiptFromBridge);
    }

    function deposit(uint256 amount, uint32 toBridge) external isLive validBridge(toBridge) nonReentrant {
        if (IERC20(tokenAddr).allowance(_msgSender(), address(this)) < amount) {
            _revert(ContractNotApproved.selector);
        }

        if (amount == 0) {
            _revert(InvalidAmount.selector);
        }

        // create receipt
        bytes32 receiptID = getReceiptID(amount, block.timestamp, _msgSender(), bridgeID, toBridge);

        Receipt memory receipt = Receipt(amount, block.timestamp, receiptID, bridgeID, toBridge, _msgSender());

        createdReceipts[receiptID] = receipt;
        receiptsPerAddress[_msgSender()].push(receiptID);
        receiptsNbPerAddress[_msgSender()] += 1;

        IERC20(tokenAddr).transferFrom(_msgSender(), address(this), amount);

        emit ReceiptCreated(_msgSender(), amount, block.timestamp, toBridge);
    }

    function getReceiptsFromAddress(address addr) external view returns (bytes32[] memory) {
        return receiptsPerAddress[addr];
    }

    function _revert(bytes4 errorSelector) internal pure {
        assembly {
            mstore(0x00, errorSelector)
            revert(0x00, 0x04)
        }
    }

    function verifyReceiptID(bytes32 _receiptID, bytes memory _signature) private view returns (bool) {
        return signerAddr == _receiptID.toEthSignedMessageHash().recover(_signature);
    }

    function getReceiptID(uint256 _amount, uint256 _time, address _user, uint32 _fromBridge, uint32 _toBridge) private pure returns (bytes32) {
        return hashMessage(abi.encode(_amount, _time, _user, _fromBridge, _toBridge));
    }

    function hashMessage(bytes memory _msg) private pure returns (bytes32) {
        return keccak256(_msg);
    }
}