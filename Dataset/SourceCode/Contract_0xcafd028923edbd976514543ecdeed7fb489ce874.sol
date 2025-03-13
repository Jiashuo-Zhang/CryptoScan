//     _____  ________  _______   __    __ 

//    |     \|        \|       \ |  \  /  \

//     \$$$$$| $$$$$$$$| $$$$$$$\| $$ /  $$

//       | $$| $$__    | $$__| $$| $$/  $$ 

//  __   | $$| $$  \   | $$    $$| $$  $$  

// |  \  | $$| $$$$$   | $$$$$$$\| $$$$$\  

// | $$__| $$| $$_____ | $$  | $$| $$ \$$\ 

//  \$$    $$| $$     \| $$  | $$| $$  \$$\

//   \$$$$$$  \$$$$$$$$ \$$   \$$ \$$   \$$

//

// JERK Token

// The world's first Fap-to-Earn (F2E) token & NFT! 🍆💦💰 

// Earn $JERK tokens with Proof of Jerk™.

// https://twitter.com/JERK_ETH



// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



import "@thirdweb-dev/contracts/base/ERC20Drop.sol";



/// @title JERK Token ERC20 contract

/// @author kzoink

/// @notice Fungible token for the JERK ecosystem

/// @dev Inherits ERC20Drop contract from thirdweb

contract Contract is ERC20Drop { //, Pausable {



    /// @notice Pause flag

    bool private isPaused;



    /// @notice Blacklist of wallets that to prevent from transacting this token (used to blacklist bad actors)

    mapping(address => bool) private blacklisted;



    /// @notice Maximum transfer amount per transaction in basis points (used for antiwhale protection)

    /// @dev E.g., 50 - 0.5% of total supply. Set to 0 to turn off.

    uint256 private maxTransferAmountRate;



    constructor(

        address _defaultAdmin,

        string memory _name,

        string memory _symbol,

        address _primarySaleRecipient

    )

        ERC20Drop(

            _defaultAdmin,

            _name,

            _symbol,

            _primarySaleRecipient

        )

    {

        isPaused = false;



        maxTransferAmountRate = 0; // Max transfer amount rate set to 0 by default to turn off

    }



    /// @notice Returns true if the contract is paused, and false otherwise

    function paused() public view virtual returns (bool) {

        //return isPaused;

        return isPaused;

    }



    /// @notice Pauses transfers

    function pause() public onlyOwner {

        _pause();

    }



    /// @notice Pauses transfers

    function _pause() internal virtual whenNotPaused {

        isPaused = true;

        emit Paused(_msgSender());

    }



    /// @notice Unpauses transfers

    function unpause() public onlyOwner {

        _unpause();

    }



    /// @notice Unpauses transfers

    function _unpause() internal virtual whenPaused {

        isPaused = false;

        emit Unpaused(_msgSender());

    }



    /// @notice Function to set the maximum transfer amount rate per transaction

    /// @param _maxTransferAmountRate Max amount of supply that can be transferred in basis points (E.g., 50 - 0.5% of total supply)

    function setMaxTransferAmountRate(uint256 _maxTransferAmountRate) external onlyOwner {

        maxTransferAmountRate = _maxTransferAmountRate;

        emit MaxTransferAmountRateSet(_maxTransferAmountRate);

    }



    /// @notice Returns the max buy amount

    /// @return Max transfer amount (in tokens)

    function maxTransferAmount() public view returns (uint256) {

        return totalSupply() * maxTransferAmountRate / 10000;

    }



    /// @notice Add a wallet to the blacklist

    /// @param _address The address to be added to the blacklist

    function addToBlacklist(address _address) external onlyOwner {

        blacklisted[_address] = true;

        emit AddedToBlacklist(_address);

    }



    /// @notice Remove a wallet from the blacklist

    /// @param _address The address to be removed from the blacklist

    function removeFromBlacklist(address _address) external onlyOwner {

        blacklisted[_address] = false;

        emit RemovedFromBlacklist(_address);

    }



    /// @notice Pause functionality

    /// @param from The sender of the transfer

    /// @param to The recipient of the transfer

    /// @param amount The amount of the transfer (prior to any applicable tax)

    function _beforeTokenTransfer(address from, address to, uint256 amount)

        internal

        whenNotPaused

        override

    {

        super._beforeTokenTransfer(from, to, amount);

    }



    /// @notice Override the transfer function to apply tax based on the whitelist

    /// @param sender The sender of the transfer

    /// @param recipient The recipient of the transfer

    /// @param amount The amount of the transfer (prior to any applicable tax)

    function _transfer(

        address sender,

        address recipient,

        uint256 amount

    ) internal override antiWhale(sender, recipient, amount) notBlacklisted(msg.sender) notBlacklisted(recipient) {

        super._transfer(sender, recipient, amount);

    }



    /// @notice Override the transferFrom function to apply anti-whale, tax, and blacklist functions

    /// @param sender The sender of the transfer

    /// @param recipient The recipient of the transfer

    /// @param amount The amount of the transfer (prior to any applicable tax)

    /// @return True if the transfer succeeded

    function transferFrom(

        address sender,

        address recipient,

        uint256 amount

    ) public override antiWhale(sender, recipient, amount) notBlacklisted(msg.sender) notBlacklisted(recipient) returns (bool) {

        return super.transferFrom(sender, recipient, amount);

    }



    /// @notice Throws if the contract is paused

    function _requireNotPaused() internal view virtual {

        require(!paused(), "Pausable: paused");

    }



    /// @notice Throws if the contract is not paused

    function _requirePaused() internal view virtual {

        require(paused(), "Pausable: not paused");

    }



    /// @notice Modifier to make a function callable only when the contract is paused

    modifier whenNotPaused() {

        _requireNotPaused();

        _;

    }



    /// @notice Modifier to make a function callable only when the contract is paused

    modifier whenPaused() {

        _requirePaused();

        _;

    }



    /// @notice Modifier to insert antiwhale protections

    /// @param sender The sender of the transfer

    /// @param recipient The recipient of the transfer

    /// @param amount The amount of the transfer

    modifier antiWhale(address sender, address recipient, uint256 amount) 

    {

        if (maxTransferAmount() > 0) 

        {

            require(amount <= maxTransferAmount(), "Transfer amount exceeds the maxTransferAmount");

        }

        _;

    }



    /// @notice Modifier to insert blacklist check

    /// @param _address The address to check for blacklisting

    modifier notBlacklisted(address _address) {

        require(!blacklisted[_address], "Account is blacklisted");

        _;

    }



    /// @dev Emitted when the pause is triggered

    /// @param account The account that triggered the pause

    event Paused(address account);

    /// @dev Emitted when the pause is lifted

    /// @param account The account that lifted the pause

    event Unpaused(address account);

    /// @dev Emitted when a max transfer amount rate is set

    /// @param rate The max transfer rate (percentage of the total supply) in basis points

    event MaxTransferAmountRateSet(uint256 rate);

    /// @dev Emitted when an account is blacklisted

    /// @param account The account added to the blacklist

    event AddedToBlacklist(address indexed account);

    /// @dev Emitted when an account is removed from the blacklist

    /// @param account The account removed from the blacklist

    event RemovedFromBlacklist(address indexed account);

}