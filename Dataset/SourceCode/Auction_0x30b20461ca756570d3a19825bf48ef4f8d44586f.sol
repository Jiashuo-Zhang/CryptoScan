// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {ReentrancyGuard} from "lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

import {IWassieCollections} from "./IWassieCollections.sol";
import "./errors.sol";

contract Auction is AccessControl, ReentrancyGuard {
    //
    // Events
    //
    event SetCollections(uint16 id1, uint16 id2);
    event Bid(address indexed bidder, uint256 amount);
    event Refund(address indexed bidder, uint256 amount);
    event Redeemed(address indexed bidder);
    event WithdrawWinningFunds(uint256 amount);

    //
    // Structs
    //
    struct Deposit {
        uint256 amount;
        bool isTop;
        bool redeemed;
    }

    //
    // State
    //
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");

    /// start timestamp
    uint256 public start;

    /// end timestamp
    uint256 public end;

    /// The WassieCollections collection
    IWassieCollections public immutable collections;

    /// The ID of the collection
    uint16[] public ids;

    /// all deposits
    mapping(address => Deposit) public deposits;

    /// ordered set of highest bids
    address[] public highest;

    /// total amount of highest bids (grows from 0 up to the total available supply)
    uint16 public highestCount;

    /// amount of funds in the winning bids
    uint256 public winningFunds;

    /// commit for a secreat to be used for rng-reveal after the auction ends
    bytes32 public secret_commit;

    /// rng for picking allocations
    bytes32 public seed;

    /// sizes of each individual collection
    uint32[] public sizes;

    /// amount remaining on each collection
    uint32[] public remaining;

    uint256 lowestWinningBid;

    //
    // Constructor
    //

    /// Constructor
    /// @param _collections The IERC1155 contract
    /// @param _start timestamp of the auction
    /// @param _duration Duration of the auction
    /// @param _secret_commit a secret to later reveal for randomness
    constructor(IWassieCollections _collections, uint256 _start, uint256 _duration, bytes32 _secret_commit) {
        if (address(_collections) == address(0) || _start == 0 || _duration == 0 || _secret_commit == bytes32(0)) {
            revert InvalidArguments();
        }

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, msg.sender);

        collections = _collections;
        start = _start;
        end = _start + _duration;
        secret_commit = _secret_commit;
    }

    //
    // modifiers
    //
    modifier onlyDuringAuction() {
        if (block.timestamp < start || block.timestamp > end) {
            revert AuctionClosed();
        }
        _;
    }

    modifier onlyAfterAuction() {
        if (block.timestamp < end) {
            revert AuctionNotOver();
        }
        _;
    }

    modifier onlyAfterRng() {
        if (seed == bytes32(0)) {
            revert RngNotSet();
        }
        _;
    }

    //
    // Owner
    //

    /// Sets the collection IDs
    /// @param _id1 The ID of the first collection
    /// @param _id2 The ID of the second collection
    function setCollections(uint16 _id1, uint16 _id2) external onlyRole(MANAGER_ROLE) {
        if (highest.length > 0) {
            revert Immutable();
        }

        IWassieCollections.CollectionDetails memory details1 = collections.collectionDetails(_id1);
        IWassieCollections.CollectionDetails memory details2 = collections.collectionDetails(_id2);

        ids = new uint16[](2);
        ids[0] = _id1;
        ids[1] = _id2;

        sizes = new uint32[](2);
        sizes[0] = details1.mintableSupply;
        sizes[1] = details2.mintableSupply;

        remaining = new uint32[](2);
        remaining[0] = details1.mintableSupply;
        remaining[1] = details2.mintableSupply;

        highest = new address[](details1.mintableSupply + details2.mintableSupply);

        emit SetCollections(_id1, _id2);
    }

    function reveal(string calldata secret) external onlyAfterAuction {
        if (keccak256(abi.encodePacked(secret)) != secret_commit) {
            revert InvalidSecret();
        }

        collections.reveal(ids[0]);
        collections.reveal(ids[1]);

        seed = keccak256(abi.encodePacked(secret, block.timestamp));
    }

    /// withdraws all funds from auction winners to the contract owner
    /// can only be called once, as the amount is reset back to 0 after the first withdrawal
    function withdrawWinningFunds() external onlyRole(TREASURY_ROLE) onlyAfterAuction nonReentrant {
        uint256 amount = winningFunds;
        winningFunds = 0;
        (bool success,) = msg.sender.call{value: amount}("");

        emit WithdrawWinningFunds(amount);
        require(success);
    }

    //
    // Public API
    //

    error BidTooLow(address bidder, uint256 bid);

    /// Creates a bid, or increments an existing one
    function bid() external payable onlyDuringAuction {
        Deposit storage deposit = deposits[msg.sender];

        deposit.amount += msg.value;
        if (deposit.amount < 0.05 ether) revert BidTooLow(msg.sender, msg.value);

        if (deposit.isTop) {
            _reorderExisting(msg.sender);
        } else {
            deposit.isTop = true;
            _reorderNew(deposit);
        }

        lowestWinningBid = deposits[highest[highestCount - 1]].amount;

        emit Bid(msg.sender, msg.value);
    }

    error RefundReverted();

    /// Refunds a losing bid
    /// Can only be called once the auction is over, and for a bidder that is not in the top list
    /// @param _bidder The address to refund
    function refund(address _bidder) external nonReentrant onlyAfterAuction {
        Deposit storage deposit = deposits[_bidder];
        if (deposit.amount == 0) {
            revert CannotRefund();
        }

        if (deposit.isTop) {
            (bool ok, ) = _bidder.call{value: deposit.amount - lowestWinningBid}("");
            if (!ok) revert RefundReverted();
        } else {
            (bool ok, ) = _bidder.call{value: deposit.amount}("");
            if (!ok) revert RefundReverted();
        }
        emit Refund(_bidder, deposit.amount);

        deposits[_bidder].amount = 0;
    }

    /// Redeems a winning bid
    /// Mints a new NFT to the bidder
    function redeem(address _bidder) external nonReentrant onlyAfterRng {
        Deposit storage deposit = deposits[_bidder];

        if (!deposit.isTop || deposit.redeemed) {
            revert CannotRedeem();
        }

        deposit.redeemed = true;
        emit Redeemed(_bidder);

        uint256 idx;
        if (remaining[0] == 0) {
            idx = 1;
        } else if (remaining[1] == 0) {
            idx = 0;
        } else {
            idx = _randomizeCollectionId(_bidder);
        }
        uint16 colId = ids[idx];
        remaining[idx] -= 1;

        collections.mint(colId, _bidder, 1);
    }

    function totalSupply() external view returns (uint256) {
        return highest.length;
    }

    function _randomizeCollectionId(address _bidder) internal view returns (uint256) {
        uint256 rng = uint256(keccak256(abi.encodePacked(_bidder, seed))) % (sizes[0] + sizes[1]);

        if (rng < sizes[0]) {
            return 0;
        } else {
            return 1;
        }
    }

    //
    // internal
    //

    // finds the given submission on the highest bids, and reorders it
    // @param target sender the address to re-order
    function _reorderExisting(address target) internal {
        uint256 i = highestCount - 1;

        while (highest[i] != target) {
            --i;
        }

        _insertionSort(i);
    }

    // inserts a new deposit, keeping the collection sorted and truncated to a
    // maximum size
    // @param deposit The deposit to insert
    function _reorderNew(Deposit storage deposit) internal {
        // first bid
        if (highestCount == 0) {
            highest[0] = msg.sender;
            highestCount = 1;
            winningFunds += msg.value;
        } else if (highestCount == highest.length && deposits[highest[highestCount - 1]].amount >= deposit.amount) {
            // new amount is not enough to enter top bids
            revert NotEnough();
        } else {
            if (highestCount == highest.length) {
                Deposit storage last = deposits[highest[highestCount - 1]];

                // if list is full
                // remove last bid from top
                last.isTop = false;
                winningFunds += deposit.amount - last.amount;
                highest[highestCount - 1] = msg.sender;
            } else {
                // if not, just push to the list
                highest[highestCount] = msg.sender;
                winningFunds += msg.value;
                highestCount += 1;
            }

            _insertionSort(highestCount - 1);
        }
    }

    // performs a single insertion sort iteration
    // sorts the given array index
    // assumes all other elements are already sorted
    // @param i the index to sort
    function _insertionSort(uint256 i) internal {
        while (i > 0 && deposits[highest[i - 1]].amount < deposits[highest[i]].amount) {
            address tmp = highest[i - 1];
            highest[i - 1] = highest[i];
            highest[i] = tmp;
            --i;
        }
    }
}