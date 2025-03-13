// SPDX-License-Identifier: MIT
// Copyright (c) 2022-2023 Fellowship

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Delegation.sol";
import "./EarlyAccessSale.sol";
import "./MintableById.sol";
import "./Shuffler.sol";

contract PPPArtworkSale is EarlyAccessSale, Shuffler {
    string private publicLimitRevertMessage = "Limited to one purchase without a pass";

    /// @notice The number of mints available for each pass
    uint256 public passLimit = 1;

    /// @notice The number of mints available without a pass (per address), after the early access period
    uint256 public publicLimit = 1;

    /// @notice The total number of mints available until the contract is sold out
    uint256 public mintLimit;

    /// @notice ERC-721 contract whose tokens are minted by this sale
    /// @dev Must implement MintableById and allow minting out of order
    MintableById public tokenContract;

    /// @notice Price during the early access phase (in wei)
    uint256 public earlyAccessPrice;

    /// @notice Price after early access phase ends (in wei)
    uint256 public publicPrice;

    /// @notice Number of tokens that have been minted without a pass, per address
    mapping(address => uint256) public publicMintCount;

    /// @notice An event emitted upon purchases
    event Purchase(address purchaser, uint256 mintId, uint256 tokenId, uint256 price, bool passMint);

    /// @notice An error returned when the sale has reached its `mintLimit`
    error SoldOut();

    error FailedWithdraw(uint256 amount, bytes data);

    constructor(
        MintableById tokenContract_,
        uint256 startTime_,
        uint256 earlyAccessPrice_,
        uint256 publicPrice_,
        uint256 mintLimit_,
        uint256 earlyAccessDuration_
    ) EarlyAccessSale(startTime_, earlyAccessDuration_) Shuffler(mintLimit_) {
        // CHECKS inputs
        require(address(tokenContract_) != address(0), "Token contract must not be the zero address");
        require(earlyAccessPrice_ <= publicPrice_, "Early access price cannot be more than the public price");
        require(publicPrice_ > 1e15, "Public price too low: check that prices are in wei");
        require(mintLimit_ >= 10, "Mint limit too low");

        // EFFECTS
        tokenContract = tokenContract_;
        earlyAccessPrice = earlyAccessPrice_;
        publicPrice = publicPrice_;
        mintLimit = mintLimit_;
    }

    // PUBLIC FUNCTIONS

    /// @notice Mint a token on the `tokenContract` contract. Must include at least `publicPrice`.
    function mint() external payable publicMint whenNotPaused {
        // CHECKS
        if (remainingValueCount == 0) revert SoldOut();
        require(msg.value >= publicPrice, "Insufficient payment");
        require(publicMintCount[msg.sender] < publicLimit, publicLimitRevertMessage);

        // EFFECTS
        unchecked {
            // Unchecked arithmetic: publicMintCount cannot exceed publicLimit
            publicMintCount[msg.sender]++;
        }

        uint256 mintId = mintLimit - remainingValueCount;
        uint256 tokenId = drawNext();
        emit Purchase(msg.sender, mintId, tokenId, msg.value, false);

        // INTERACTIONS: call mint on known contract (tokenContract.mint contains no external interactions)
        tokenContract.mint(msg.sender, tokenId);
    }

    /// @notice Mint multiple tokens on the `tokenContract` contract. Must pay at least `currentPrice` * `publicPrice`.
    /// @param quantity The number of tokens to mint: must not be greater than `publicLimit`
    function mintMultiple(uint256 quantity) public payable virtual publicMint whenNotPaused {
        // CHECKS state and inputs
        uint256 remaining = remainingValueCount;
        if (remaining == 0) revert SoldOut();
        require(quantity > 0, "Must mint at least one token");

        uint256 publicMinted = publicMintCount[msg.sender];
        require(publicMinted < publicLimit && quantity <= publicLimit, publicLimitRevertMessage);

        require(msg.value >= publicPrice * quantity, "Insufficient payment");

        // EFFECTS
        if (quantity > remaining) {
            quantity = remaining;
        }

        unchecked {
            if (publicMinted + quantity > publicLimit) {
                quantity = publicLimit - publicMinted;
            }

            // Unchecked arithmetic: publicMintCount cannot exceed publicLimit
            publicMintCount[msg.sender] += quantity;
        }

        // INTERACTIONS: call mint on known contract (tokenContract.mint contains no external interactions)
        uint256 refund;
        unchecked {
            uint256 startMintId = mintLimit - remainingValueCount;
            for (uint256 i = 0; i < quantity; i++) {
                uint256 tokenId = drawNext();
                emit Purchase(msg.sender, startMintId + i, tokenId, publicPrice, false);
                tokenContract.mint(msg.sender, tokenId);
            }

            // Unchecked arithmetic: already checked that msg.value >= publicPrice * quantity
            refund = msg.value - quantity * publicPrice;
        }

        // INTERACTIONS
        if (refund > 0) {
            (bool refunded, ) = msg.sender.call{value: refund}("");
            require(refunded, "Refund for unavailable quantity was reverted");
        }
    }

    // PASS HOLDER FUNCTIONS

    /// @notice Mint a token on the `tokenContract` to the caller, using a pass
    /// @param passId The pass token ID: must not have already been used for this sale
    function mintFromPass(uint256 passId) external payable started whenNotPaused {
        // CHECKS
        if (remainingValueCount == 0) revert SoldOut();
        require(msg.value >= earlyAccessPrice, "Insufficient payment");

        // CHECKS that the caller has permissions and the pass can be used
        require(passAllowance(passId) > 0, "No mints remaining for provided pass");

        // INTERACTIONS: mark the pass as used (known contract with no external interactions)
        passes.logPassUse(passId, passProjectId);

        // EFFECTS
        uint256 mintId = mintLimit - remainingValueCount;
        uint256 tokenId = drawNext();
        emit Purchase(msg.sender, mintId, tokenId, msg.value, true);

        // INTERACTIONS: call mint on known contract (tokenContract.mint contains no external interactions)
        tokenContract.mint(msg.sender, tokenId);
    }

    /// @notice Mint multiple tokens on the `tokenContract` to the caller, using passes
    /// @param passIds The pass token IDs: caller must be owner or operator and passes must have mints remaining
    function mintMultipleFromPasses(
        uint256 quantity,
        uint256[] calldata passIds
    ) external payable started whenNotPaused {
        // CHECKS state and inputs
        uint256 remaining = remainingValueCount;
        if (remaining == 0) revert SoldOut();
        require(quantity > 0, "Must mint at least one token");
        require(quantity <= mintLimit, "Quantity exceeds auction size");

        require(msg.value >= earlyAccessPrice * quantity, "Insufficient payment");

        uint256 passCount = passIds.length;
        require(passCount > 0, "Must include at least one pass");

        // EFFECTS
        if (quantity > remaining) {
            quantity = remaining;
        }

        // CHECKS: check passes and log their usages
        uint256 passUses = 0;
        for (uint256 i = 0; i < passCount; i++) {
            uint256 passId = passIds[i];

            // CHECKS
            uint256 allowance = passAllowance(passId);

            // INTERACTIONS
            for (uint256 j = 0; j < allowance && passUses < quantity; j++) {
                passes.logPassUse(passId, passProjectId);
                passUses++;
            }

            // Don't check more passes than needed
            if (passUses == quantity) break;
        }

        require(passUses > 0, "No mints remaining for provided passes");
        quantity = passUses;

        // INTERACTIONS: call mint on known contract (tokenContract.mint contains no external interactions)
        uint256 refund;
        unchecked {
            uint256 startMintId = mintLimit - remainingValueCount;
            for (uint256 i = 0; i < quantity; i++) {
                uint256 tokenId = drawNext();
                emit Purchase(msg.sender, startMintId + i, tokenId, earlyAccessPrice, true);
                tokenContract.mint(msg.sender, tokenId);
            }

            // Unchecked arithmetic: already checked that msg.value >= earlyAccessPrice * quantity
            refund = msg.value - quantity * earlyAccessPrice;
        }

        // INTERACTIONS
        if (refund > 0) {
            (bool refunded, ) = msg.sender.call{value: refund}("");
            require(refunded, "Refund for unavailable quantity was reverted");
        }
    }

    // OWNER FUNCTIONS

    /// @notice withdraw sale proceeds
    /// @dev Can only be called by the contract `owner`. Reverts if proceeds have already been withdrawn or if the fund
    ///  transfer fails.
    function withdraw(address recipient) external onlyOwner {
        // CHECKS contract state
        uint256 balance = address(this).balance;
        require(balance > 0, "All funds have been withdrawn");

        // INTERACTIONS
        (bool success, bytes memory data) = recipient.call{value: balance}("");
        if (!success) revert FailedWithdraw(balance, data);
    }

    /// @notice Update the tokenContract contract address
    /// @dev Can only be called by the contract `owner`. Reverts if the sale has already started.
    function setMintable(MintableById tokenContract_) external unstarted onlyOwner {
        // CHECKS inputs
        require(address(tokenContract_) != address(0), "Token contract must not be the zero address");
        // EFFECTS
        tokenContract = tokenContract_;
    }

    /// @notice Update the sale prices
    /// @dev Since the values are validated against each other, they are all set together. Can only be called by the
    ///  contract `owner`. Reverts if the sale has already started.
    function setPrices(uint256 earlyAccessPrice_, uint256 publicPrice_) external unstarted onlyOwner {
        // CHECKS inputs
        require(earlyAccessPrice_ <= publicPrice_, "Early access price cannot be more than the public price");
        require(publicPrice_ > 1e15, "Public price too low: check that prices are in wei");

        // EFFECTS
        earlyAccessPrice = earlyAccessPrice_;
        publicPrice = publicPrice_;
    }

    /// @notice Update the number of total mints
    function setMintLimit(uint256 mintLimit_) external unstarted onlyOwner {
        // CHECKS inputs
        require(mintLimit_ >= 10, "Mint limit too low");
        require(passLimit < mintLimit_, "Mint limit must be higher than pass limit");
        require(publicLimit < mintLimit_, "Mint limit must be higher than public limit");

        // EFFECTS
        mintLimit = remainingValueCount = mintLimit_;
    }

    /// @notice Update the per-pass mint limit
    function setPassLimit(uint256 passLimit_) external onlyOwner {
        // CHECKS inputs
        require(passLimit_ != 0, "Pass limit must not be zero");
        require(passLimit_ < mintLimit, "Pass limit must be lower than mint limit");

        // EFFECTS
        passLimit = passLimit_;
    }

    /// @notice Update the public per-wallet mint limit
    function setPublicLimit(uint256 publicLimit_) external onlyOwner {
        // CHECKS inputs
        require(publicLimit_ != 0, "Public limit must not be zero");
        require(publicLimit_ < mintLimit, "Public limit must be lower than mint limit");

        // EFFECTS
        publicLimit = publicLimit_;
        publicLimitRevertMessage = publicLimit_ == 1
            ? "Limited to one purchase without a pass"
            : string.concat("Limited to ", Strings.toString(publicLimit_), " purchases without a pass");
    }

    // INTERNAL VIEW FUNCTIONS

    function passAllowance(uint256 passId) internal view returns (uint256) {
        // Uses view functions of the passes contract
        require(Delegation.check(msg.sender, passes, passId), "Caller is not pass owner or approved");

        uint256 uses = passes.passUses(passId, passProjectId);
        unchecked {
            return uses >= passLimit ? 0 : passLimit - uses;
        }
    }
}