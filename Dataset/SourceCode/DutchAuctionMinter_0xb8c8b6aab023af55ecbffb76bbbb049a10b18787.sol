// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721CreatorCore} from "@manifoldxyz/creator-core-solidity/contracts/core/IERC721CreatorCore.sol";
import {ERC721Creator} from "@manifoldxyz/creator-core-solidity/contracts/ERC721Creator.sol";
import {Blacklist} from "./Blacklist.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DutchAuctionMinter is Pausable, AccessControl, Blacklist, ReentrancyGuard {
    ///@notice Limit by maximum auction duration
    uint256 public constant MAX_AUCTION_DURATION = 7 days;

    // @notice Amount of time in seconds after each price drops
    uint256 public priceDropSlot;

    // @notice Role for pausing the contract
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /// @notice ERC-721 pass contract whose tokens are minted by this auction
    /// @dev Must implement mint(address)
    IERC721CreatorCore public passes;

    /// @notice ERC-721 pass contract, which tokens needed to mint passes
    IERC721 public mintPasses;

    /// @notice Minimum amount of mint passes to mint pass
    uint256 public minMintPasses;

    /// @notice Timestamp when this auction starts allowing minting
    uint256 public startTime;

    /// @notice Starting price for the Dutch auction
    uint256 public startPrice;

    /// @notice Resting price where price descent ends
    uint256 public restPrice;

    /// @notice Amount that the price drops every slot (every 12 seconds)
    uint256 public priceDropPerSlot;

    /// @notice total amount of minted passes
    uint256 public totalSupply;

    /// @notice maximum amount of passes which can be minted
    uint256 public maxMint;

    mapping(address => uint256) public mintCount;

    uint256 private pauseStart;
    uint256 private pastPauseDelay;

    address public beneficiary;

    /// @notice Determines if users without mint passes can mint item
    bool public mintPublic;

    /// @notice An event to be emitted upon pass purchases for the benefit of the UI
    event Purchase(address purchaser, uint256 tokenId, uint256 price);

    /// @notice An event emitted when mint being open for everyone or not.
    /// @dev open - true if mint open for everyone, false if not
    event MintPublicUpdated(bool open);

    /// @notice An event emitted when mint passes contract changed
    /// @dev newMintPasses - address of new mint passes contract
    event MintPassesUpdated(address newMintPasses);

    /// @notice An error returned when the auction has already started.
    error AlreadyStarted();
    /// @notice An error returned when the auction has not yet started.
    error NotYetStarted();
    /// @notice An error returned when funds transfer was not passed.
    error FailedPaying(address payee, bytes data);
    /// @notice An error returned when minting is not available for user.
    /// (mint not yet open for everyone and user don't have enough mint passes)
    error MintNotAvailable();

    constructor(
        IERC721CreatorCore passes_,
        IERC721 mintPasses_,
        uint256 startTime_,
        uint256 startPrice_,
        uint256 restPrice_,
        uint256 priceDropPerSlot_,
        uint256 priceDropSlot_,
        uint256 maxMint_,
        uint256 minMintPasses_,
        address beneficiary_,
        address pauser
    ) {
        // CHECKS inputs
        require(address(passes_) != address(0), "Pass contract must not be the zero address");
        require(address(mintPasses_) != address(0), "Mint pass contract must not be the zero address");
        // require(passes_.supportsInterface(0x6a627842), "Pass contract must implement mint(address)"); // TODO: fix support of manifold mitner
        require(startTime_ >= block.timestamp, "Start time cannot be in the past");

        require(startPrice_ > 1e15, "Start price too low: check that prices are in wei");
        require(restPrice_ > 1e15, "Rest price too low: check that prices are in wei");
        require(startPrice_ >= restPrice_, "Start price must not be lower than rest price");
        require(priceDropSlot_ > 0, "Price drop slot must be greater than 0");
        require(minMintPasses_ > 0, "Minimum mint passes must be greater than 0");
        require(beneficiary_ != address(0), "Beneficiary must not be the zero address");

        uint256 priceDifference;
        uint256 totalTime;
        unchecked {
            priceDifference = startPrice_ - restPrice_;
            totalTime = priceDifference * priceDropSlot_ / priceDropPerSlot_;
        }
        require(totalTime / 1 minutes >= 5, "Auction must last at least 5 minutes");
        require(totalTime <= MAX_AUCTION_DURATION, "Auction must not last longer than maximum duration limit");
        require(maxMint_ > 0, "Max mint must be greater than 0");

        // EFFECTS
        passes = passes_;
        startTime = startTime_;
        startPrice = startPrice_;
        restPrice = restPrice_;
        priceDropPerSlot = priceDropPerSlot_;
        priceDropSlot = priceDropSlot_;
        maxMint = maxMint_;
        beneficiary = beneficiary_;
        mintPasses = mintPasses_;
        minMintPasses = minMintPasses_;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, pauser);
    }

    modifier started() {
        if (!isStarted()) revert NotYetStarted();
        _;
    }

    modifier unstarted() {
        if (isStarted()) revert AlreadyStarted();
        _;
    }

    // PUBLIC FUNCTIONS

    /// @notice Mint a pass on the `passes` contract. Must include at least `currentPrice`.
    function mint() external payable started whenNotPaused onlyNotBlacklisted nonReentrant {
        // CHECKS inputs
        uint256 price = msg.value;
        uint256 cPrice = currentPrice();
        require(price >= cPrice, "Insufficient payment");
        require(totalSupply < maxMint, "Maximum mint reached");

        if (!mintPublic && mintPasses.balanceOf(msg.sender) < minMintPasses) {
            revert MintNotAvailable();
        }

        // EFFECTS
        unchecked {
            // Unchecked arithmetic: mintCount cannot exceed maxMint
            mintCount[msg.sender]++;
        }

        // EFFECTS + INTERACTIONS: call mint on known contract (passes.mint contains no external interactions)
        totalSupply++;
        uint256 id = passes.mintBase(msg.sender);
        emit Purchase(msg.sender, id, cPrice);

        refundIfOver(cPrice);
    }

    /// @notice Mint up to three passes on the `passes` contract. Must include at least `currentPrice` * `quantity`.
    /// @param quantity The number of passes to mint: must be 1, 2, or 3
    function mintMultiple(uint256 quantity) external payable started whenNotPaused onlyNotBlacklisted nonReentrant {
        // CHECKS inputs
        uint256 alreadyMinted = mintCount[msg.sender];
        require(quantity > 0, "Must mint at least one pass");
        uint256 payment = msg.value;
        uint256 price = payment / quantity;
        uint256 cPrice = currentPrice();
        require(price >= cPrice, "Insufficient payment");
        require(totalSupply + quantity <= maxMint, "Maximum mint reached");

        if (!mintPublic && mintPasses.balanceOf(msg.sender) < minMintPasses) {
            revert MintNotAvailable();
        }

        // EFFECTS
        unchecked {
            // Unchecked arithmetic: totalSupply cannot exceed max mint
            totalSupply = totalSupply + quantity;
            // Unchecked arithmetic: mintCount cannot exceed totalSupply and maxMint
            mintCount[msg.sender] = alreadyMinted + quantity;
        }

        // EFFECTS + INTERACTIONS: call mint on known contract (passes.mint contains no external interactions)
        // One call without try/catch to make sure at least one is minted.
        for (uint256 i = 0; i < quantity; i++) {
            uint256 id = passes.mintBase(msg.sender);
            emit Purchase(msg.sender, id, cPrice);
        }

        refundIfOver(cPrice * quantity);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH.");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    // OWNER FUNCTIONS

    /// @notice Update the passes contract address
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setPasses(IERC721CreatorCore passes_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        // CHECKS inputs
        require(address(passes_) != address(0), "Pass contract must not be the zero address");
        // require(passes_.supportsInterface(0x6a627842), "Pass contract must support mint(address)"); // TODO
        // EFFECTS
        passes = passes_;
    }

    /// @notice Pause this contract
    /// @dev Can only be called by the contract `owner`
    function pause() public onlyRole(PAUSER_ROLE) {
        // CHECKS + EFFECTS: `Pausable` handles checking permissions and setting pause state
        super._pause();
        // More EFFECTS
        pauseStart = block.timestamp;
    }

    /// @notice Resume this contract
    /// @dev Can only be called by the contract `owner`. Pricing tiers will pick up where they left off.
    function unpause() public onlyRole(PAUSER_ROLE) {
        // CHECKS + EFFECTS: `Pausable` handles checking permissions and setting pause state
        super._unpause();
        // More EFFECTS
        if (block.timestamp <= startTime) {
            return;
        }
        // Find the amount time the auction should have been live, but was paused
        unchecked {
            // Unchecked arithmetic: computed value will be < block.timestamp and >= 0
            if (pauseStart < startTime) {
                pastPauseDelay = block.timestamp - startTime;
            } else {
                pastPauseDelay += (block.timestamp - pauseStart);
            }
        }
    }

    /// @notice adds an address to blacklist blocking them from minting
    /// @dev Can only be called by the contract `owner`.
    /// @param account The address to add to the blacklist
    function addBlacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _addBlacklist(account);
    }

    /// @notice removes an address from blacklist allowing them to once again mint
    /// @dev Can only be called by the contract `owner`.
    /// @param account The address to removed to the blacklist
    function removeBlacklist(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _removeBlacklist(account);
    }

    function withdraw() public onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
        uint256 balanceAvailable = address(this).balance;
        (bool success, bytes memory data) = beneficiary.call{value: balanceAvailable}("");
        if (!success) revert FailedPaying(beneficiary, data);
    }

    /// @notice Update the auction start time
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setStartTime(uint256 startTime_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        // CHECKS inputs
        require(startTime_ >= block.timestamp, "New start time cannot be in the past");
        // EFFECTS
        startTime = startTime_;
    }

    /// @notice Update the auction start time
    /// @dev Can only be called by the contract `owner`. Reverts if the auction has already started.
    function setMaxMint(uint256 maxMint_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        // CHECKS inputs
        require(maxMint_ > 0, "Max mint must be greater than 0");
        // EFFECTS
        maxMint = maxMint_;
    }

    ///@notice Update the minimum number of passes required to mint
    ///@dev Can only be called by the contract `owner`.
    function setMinMintPasses(uint256 minMintPasses_) external unstarted onlyRole(DEFAULT_ADMIN_ROLE) {
        // CHECKS inputs
        require(minMintPasses_ > 0, "Min mint passes must be greater than 0");
        // EFFECTS
        minMintPasses = minMintPasses_;
    }

    /// @notice Update the auction price range and rate of decrease
    /// @dev Since the values are validated against each other, they are all set together. Can only be called by the
    ///  contract `owner`. Reverts if the auction has already started.
    function setPriceRange(uint256 startPrice_, uint256 restPrice_, uint256 priceDropPerSlot_, uint256 priceDropSlot_)
        external
        unstarted
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        // CHECKS inputs
        require(startPrice_ > 1e15, "Start price too low: check that prices are in wei");
        require(restPrice_ > 1e15, "Rest price too low: check that prices are in wei");
        require(startPrice_ >= restPrice_, "Start price must not be lower than rest price");
        require(priceDropSlot_ > 0, "Price drop slot must be greater than 0");

        uint256 priceDifference;
        uint256 totalTime;
        unchecked {
            priceDifference = startPrice_ - restPrice_;
            totalTime = priceDifference * priceDropSlot_ / priceDropPerSlot_;
        }
        require(totalTime / 1 minutes >= 5, "Auction must last at least 5 minutes");
        require(totalTime <= MAX_AUCTION_DURATION, "Auction must not last longer than maximum duration limit");

        // EFFECTS
        startPrice = startPrice_;
        restPrice = restPrice_;
        priceDropPerSlot = priceDropPerSlot_;
        priceDropSlot = priceDropSlot_;
    }

    function setMintPasses(IERC721 mintPasses_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintPasses = mintPasses_;
        emit MintPassesUpdated(address(mintPasses));
    }

    function setMintPublic(bool mintPublic_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintPublic = mintPublic_;
        emit MintPublicUpdated(mintPublic);
    }

    // VIEW FUNCTIONS

    /// @notice Query the current price
    function currentPrice() public view returns (uint256) {
        uint256 time = timeElapsed();
        unchecked {
            uint256 drop = priceDropPerSlot * (time / priceDropSlot);
            if (startPrice < restPrice + drop) return restPrice;
            return startPrice - drop;
        }
    }

    /// @notice Returns timestamp of next price drop
    function nextPriceDrop() public view returns (uint256) {
        if (!isStarted()) return startTime + priceDropSlot;

        uint256 timeUntilNextDrop = priceDropSlot - (timeElapsed() % priceDropSlot);

        return block.timestamp + timeUntilNextDrop;
    }

    function endTime() public view returns (uint256) {
        uint256 totalDropsNeeded = (startPrice - restPrice) / priceDropPerSlot;

        uint256 expectedAuctionDuration = totalDropsNeeded * priceDropSlot;

        return startTime + expectedAuctionDuration + pastPauseDelay;
    }

    // PRIVATE FUNCTIONS

    function isStarted() internal view returns (bool) {
        return (paused() ? pauseStart : block.timestamp) >= startTime;
    }

    function timeElapsed() internal view returns (uint256) {
        if (!isStarted()) return 0;
        unchecked {
            // pastPauseDelay cannot be greater than the time passed since startTime.
            if (!paused()) {
                return block.timestamp - startTime - pastPauseDelay;
            }

            // pastPauseDelay cannot be greater than the time between startTime and pauseStart.
            return pauseStart - startTime - pastPauseDelay;
        }
    }
}