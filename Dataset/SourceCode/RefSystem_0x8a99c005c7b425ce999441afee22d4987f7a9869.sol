// ALL CONTRACTS DEPLOYED USING OUR FACTORY ARE ANTI-RUG BY DEFAULT: CONTRACT RENOUNCED, LIQ LOCKED FOR 30 DAYS ON UNCX, CANT CHANGE ANY VARIABLE BUT TAX RECEIVER!
// Saintbot
// Deploy and manage fair launch anti-rug tokens seamlessly and lightning-fast with low gas on our free-to-use Telegram bot.
// Website: saintbot.app/
// Twitter: twitter.com/TeamSaintbot
// Telegram Bot: https://t.me/saintbot_deployer_bot
// Docs: https://saintbots-organization.gitbook.io/saintbot-docs/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract RefSystem is Ownable {
    // Store keccak256 identification that tracks back to the user who created the referral
    mapping(bytes32 => address) private ref;

    address public refCreator;

    bool public limitedRefCreation = true;
    bool internal paused = false;

    function addNewRef(bytes memory _refCode, address _revenueReceiver) external {
        if (paused) revert();

        if (limitedRefCreation) {
            // Only ref creator can create ref
            if (msg.sender != refCreator) revert Auth();
        }

        uint256 size;

        assembly {
            size := extcodesize(_revenueReceiver)
        }

        // Hash the input
        bytes32 newCode = keccak256(_refCode);

        // Ref code cant exist yet
        if (ref[newCode] != address(0)) revert AlreadyExist();
        // Receiver cant be a contract
        if (size != 0) revert Contract();
        // Cant send ETH to burn address
        if (_revenueReceiver == address(0)) revert BurnAddress();
        // Needs to be at least 3 characters
        if (_refCode.length < 3 || _refCode.length > 11) revert Length();

        ref[newCode] = _revenueReceiver;

        emit NewRefCreated(newCode, _refCode, _revenueReceiver);
    }

    function getRefReceiver(bytes memory _refCode) public view returns (address receiverWallet) {
        receiverWallet = ref[keccak256(_refCode)];
    }

    function onlyRefCreator(bool _toggle) external onlyOwner {
        limitedRefCreation = _toggle;
    }

    function rescueRef(bytes memory _refCode, address _newAddress) external onlyOwner {
        ref[keccak256(_refCode)] = _newAddress;
    }

    function updateRefCreator(address _refCreator) external onlyOwner {
        refCreator = _refCreator;
    }

    function updatePaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    event NewRefCreated(bytes32 refHash, bytes code, address refReceiver);

    error AlreadyExist();
    error Auth();
    error Contract();
    error BurnAddress();
    error Length();
}