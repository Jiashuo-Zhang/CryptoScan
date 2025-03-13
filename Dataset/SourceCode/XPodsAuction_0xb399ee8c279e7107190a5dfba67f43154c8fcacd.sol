// SPDX-License-Identifier: UNLICENCED



pragma solidity 0.8.19;



import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/token/common/ERC2981.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

import "@openzeppelin/contracts/utils/math/SafeCast.sol";

import "erc721a/contracts/extensions/ERC721AQueryable.sol";

import "erc721a/contracts/IERC721A.sol";

import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

import "./Interfaces.sol";

import "./AuctionEnums.sol";



contract XPodsAuction is

    DefaultOperatorFilterer,

    ERC721AQueryable,

    ReentrancyGuard,

    AccessControl,

    ERC2981,

    Ownable

{

    using Math for uint256;

    using SafeCast for uint256;



    bytes32 public constant SUPPORT_ROLE = keccak256("SUPPORT");



    // initial stage

    AuctionStage public stage;



    // the maximum pods that can be minted by this contract

    uint256 public constant MAX_SUPPLY = 20;



    // the maximum pods that can be minted to the team by the support role

    uint256 public constant MAX_TEAM_MINT = 10;



    // this applies only during auction distribution of items own

    uint256 public constant MAX_PODS_WIN_PER_WALLET = 1;



    // the current minimum bid

    uint256 public minimumBid = 0.1 ether;



    // counter for the pods minted to the team

    uint256 public podsMintedToTeam;



    // the amount of funds already withdrawhn by the owner for pod sales

    uint256 public podSalesWithdrawnByOwner;



    // the base URI for the metadata

    string public baseURI;



    // the URI for the contract level metadata

    // @dev see https://docs.opensea.io/docs/contract-level-metadata

    string public contractMetadataURI;



    // the address of the XDroids contract

    address public xDroidsContractAddress;



    // uint120 is 15 bytes, therefore the whole struct is 31 bytes

    // this improves gas perfomance of claim and bid by quite a large margin

    struct User {

        // cumulative sum of ETH bids

        uint120 totalBid;

        // whether or not the user has claimed already

        // @dev 1 byte

        bool claimed;

        // total funds refunded to the user

        uint120 refundedFunds;

    }



    // users bids and refunds

    mapping(address => User) public userData;



    // the price as computed by the binary search algorithm

    // it get set after the bidding is closed

    uint256 public price;



    /**

     * EVENTS

     */

    event Bid(

        address bidder,

        uint256 bidAmount,

        uint256 bidderTotal,

        uint256 bucketTotal

    );



    // when a bidder is refunded

    event RefundSent(address recipient, uint256 value);



    // when a pod is exchanged for an XDroid

    event XDroidRevealed(address owner, uint256 droidTokenId, uint256 burnedPodTokenId);



    event XDroidContractSet(address contractAddress);

    event AuctionStarted();

    event MinimumBidChanged(uint256 newMinBid);

    event AuctionEnded();

    event PriceSet(uint256 newPrice);

    event ClaimsAndRefundsStarted();

    event RevealsOpen();

    event FundsWithdrawn(address recipient, uint256 amount);

    event MintedToTeam(address recipient, uint256 podsCount);

    event BaseURISet(string baseURI);

    event RoyaltyChanged(address receiver, uint96 feeNumerator);



    // when a user claims their pods and/or refunds

    event Claimed(address recipient, uint256 totalBid, uint256 podsWon, uint256 refund);



    /**

     * ERRORS

     */

    error WithdrawToNullAddress();

    error RefundToNullAddress();

    error NoClaimsDuringBiddingStage();

    error StageMustBeClaimsAndRefunds(AuctionStage currentStage);

    error MinBidMustBeGreaterThanZero(uint256 minBidInput);

    error PriceIsLowerThanTheMinBid(uint256 priceInput, uint256 minBid);

    error PriceMustBeSet();

    error FinalPriceMustMatchSetPrice();

    error CannotWithdrawBeforeClaimsStage(AuctionStage currentStage);

    error NoClaimsAllowedInCurrentStage(AuctionStage currentStage);

    error BidLowerThanMinimum(uint256 bid, uint256 minBid);

    error AuctionMustNotBeStarted();

    error StageMustBeBiddingClosed(AuctionStage currentStage);

    error AuctionMustBeActive(AuctionStage currentStage);

    error NullAddressParameter(string paramName);

    error XDroidChangeAfterAuctionStarted();

    error WithdrawFailed(address recipient, uint256 amount);

    error RefundFailed(address recipient, uint256 amount);

    error AlreadyRefunded(address recipient);

    error AlreadyClaimed(address claimaint);

    error RevealsNotOpenYet();

    error TokenNotMinted(uint256 tokenId);

    error MustBeTokenOwner(address wallet, uint256 tokenId);

    error ExceedsMaxTeamMint(uint256 requestedPods, uint256 maxPods);

    error ZeroBids(address user);

    error NotEnoughPodsSold();

    error BaseURICannotBeEmpty();

    error XDroidContractNotSet();

    error NoFundsToWithdraw();



    constructor() ERC721A("X Pods", "X-POD") {

        // set up roles

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _setupRole(SUPPORT_ROLE, msg.sender);



        // set the default royalty to 7.5%

        _setDefaultRoyalty(msg.sender, 750);

    }



    /**

     * @notice begin the auction

     */

    function startAuction() external onlyRole(SUPPORT_ROLE) {

        if (stage != AuctionStage.NOT_STARTED) {

            revert AuctionMustNotBeStarted();

        }



        // the XDroid contract must be known and set before the auction starts

        if (xDroidsContractAddress == address(0)) {

            revert XDroidContractNotSet();

        }



        stage = AuctionStage.ACTIVE;



        emit AuctionStarted();

    }



    /**

     * @notice A wallet with the support role starts the claims and refund stage

     * if the price in Wei was not set correctly, there's a chance the claims and refunds

     * will start with the wrong price and then the will be no way of rectifying this mistake

     * therefore the price @param finalPrice must be sent again here to confirm the price

     */

    function startClaimsAndRefunds(uint256 finalPrice) external onlyRole(SUPPORT_ROLE) {

        // storage to memory

        AuctionStage stageMem = stage;



        // revert if the stage is not "bidding closed"

        if (stageMem != AuctionStage.BIDDING_CLOSED) {

            revert StageMustBeBiddingClosed(stageMem);

        }



        uint256 priceMem = price;

        if (priceMem == 0) {

            revert PriceMustBeSet();

        }



        if (finalPrice != priceMem) {

            revert FinalPriceMustMatchSetPrice();

        }



        emit ClaimsAndRefundsStarted();

        stage = AuctionStage.CLAIMS_AND_REFUNDS;

    }



    /*

     * @notice determine whether the stage is after the bidding stage

     */

    function stageIsAfterBidding(AuctionStage stageMem) public pure returns (bool) {

        return

            stageMem == AuctionStage.CLAIMS_AND_REFUNDS ||

            stageMem == AuctionStage.REVEALS_OPEN;

    }



    /**

     * @notice A wallet with the support role starts the reveals stage

     */

    function startReveals() external onlyRole(SUPPORT_ROLE) {

        // storage to memory

        AuctionStage _stage = stage;

        if (_stage != AuctionStage.CLAIMS_AND_REFUNDS) {

            revert StageMustBeClaimsAndRefunds(_stage);

        }



        emit RevealsOpen();

        stage = AuctionStage.REVEALS_OPEN;

    }



    /**

     * @notice end the auction.

     */

    function endAuction() external onlyRole(SUPPORT_ROLE) {

        // storage to memory

        AuctionStage _stage = stage;



        if (_stage != AuctionStage.ACTIVE) {

            revert AuctionMustBeActive(_stage);

        }



        stage = AuctionStage.BIDDING_CLOSED;



        emit AuctionEnded();

    }



    /**

     * @notice place a bid in ETH or add to your existing bid. Calling this

     *   multiple times will increase your bid amount. All bids placed are final

     *   and cannot be reversed.

     */

    function bid() external payable {

        // storage to memory

        AuctionStage _stage = stage;

        if (stage != AuctionStage.ACTIVE) {

            revert AuctionMustBeActive(_stage);

        }



        User memory bidder = userData[msg.sender]; // user into memory



        uint256 minBid = minimumBid; // storage to memory

        // bidder.totalBid is uint216

        uint256 totalUserBid = bidder.totalBid;



        // increment the bid of the user

        totalUserBid += msg.value;



        // if their new total bid is less than the current minimum bid

        // revert with an error

        // note: we don't validate the current incoming bid increment against

        // the minimum bid, the requirement is bid (0 iniitally) + increment < minimim bid

        // rather than increment < minimum bid

        if (totalUserBid < minBid) {

            revert BidLowerThanMinimum(totalUserBid, minBid);

        }



        bidder.totalBid = SafeCast.toUint120(totalUserBid);

        emit Bid(msg.sender, msg.value, totalUserBid, address(this).balance);



        // reassign

        userData[msg.sender] = bidder;

    }



    /**

     * @notice set the minimum contribution required to place a bid

     * @dev set this price in wei, not eth!

     * @param newMinimumBid new price, set in wei

     */

    function setMinimumBid(uint256 newMinimumBid) external onlyRole(SUPPORT_ROLE) {

        if (newMinimumBid == 0) {

            revert MinBidMustBeGreaterThanZero(newMinimumBid);

        }



        emit MinimumBidChanged(newMinimumBid);

        minimumBid = newMinimumBid;

    }



    /**

     * @notice set the clearing price after all bids have been placed.

     * @dev set this price in wei, not eth!

     * @param newPrice new price, set in wei

     */

    function setPrice(uint256 newPrice) external onlyRole(SUPPORT_ROLE) {

        AuctionStage stageMem = stage; // storage to memory

        if (stageMem != AuctionStage.BIDDING_CLOSED) {

            revert StageMustBeBiddingClosed(stageMem);

        }



        uint256 minBid = minimumBid; // storage to memory

        if (newPrice < minBid) {

            revert PriceIsLowerThanTheMinBid(newPrice, minBid);

        }

        price = newPrice;

        emit PriceSet(newPrice);

    }



    function remainingSupply() public view returns (uint256) {

        return MAX_SUPPLY - MAX_TEAM_MINT - _totalMinted();

    }



    // function hasMoreSupplyFor(uint256 numberOfTokens) internal view returns (bool) {

    //     return remainingSupply() >= numberOfTokens;

    // }



    /**

     * @dev handles all minting.

     * @param to address to mint tokens to.

     * @param numberOfTokens number of tokens to mint.

     */

    function _internalMint(address to, uint256 numberOfTokens) internal {

        _safeMint(to, numberOfTokens);

    }



    /**

     * @dev overriding from ERC721: start at the 1st token instead of 0

     */

    function _startTokenId() internal pure override returns (uint256) {

        return 1;

    }



    /**

     * @dev calculate the reufund for a bid and a price

     * @param userBid total bid

     * @param _price final price

     */

    function _refundAmount(

        uint256 userBid,

        uint256 _price

    ) internal pure returns (uint256) {

        // @dev taking the whole part only from the division and limiting to

        // the max pods number that can be won

        uint256 podsWon = Math.min(userBid / _price, MAX_PODS_WIN_PER_WALLET);



        // the refund is the difference between the bid and the price

        // to pay for the pods

        return userBid - (podsWon * _price);

    }



    /**

     * @notice send refund to an address. Refunds are unsuccessful bids or

     * an address's remaining eth after all their tokens have been paid for.

     * @dev can only be called after the price has been set

     * @param to the address to refund to

     */

    function sendRefund(address to) public onlyRole(SUPPORT_ROLE) {

        if (to == address(0)) {

            revert RefundToNullAddress();

        }



        uint256 priceMem = price; // storage to memory

        if (priceMem == 0) {

            revert PriceMustBeSet();

        }



        User memory user = userData[to]; // get user data in memory



        if (user.refundedFunds > 0) {

            revert AlreadyRefunded(to);

        }



        uint256 refundValue = _refundAmount(user.totalBid, priceMem);



        if (refundValue > 0) {

            emit RefundSent(msg.sender, refundValue);



            user.refundedFunds = SafeCast.toUint120(refundValue);

            // reassign

            // @dev this is the only write, hence inside the if statement

            userData[to] = user;



            // send the refund

            (bool success, ) = to.call{value: refundValue}("");

            if (!success) {

                revert RefundFailed(to, refundValue);

            }

        }

    }



    /**

     * @notice send refunds to a batch of addresses.

     * @param addresses array of addresses to refund.

     */

    function sendRefundBatch(

        address[] calldata addresses

    ) external onlyRole(SUPPORT_ROLE) {

        for (uint256 i; i < addresses.length; ++i) {

            sendRefund(addresses[i]);

        }

    }



    /**

     * @notice for claiming pods and refunds

     */

    function claim() public nonReentrant {

        _internalClaim(msg.sender);

    }



    /**

     * @notice claim tokens and refund for an address.

     * @dev it is needed, since the withdraw function only allows to withdraw

     * funds for claimed pods

     * @param receiver the address to claim tokens for.

     */

    function claimOnBehalfOf(address receiver) external onlyRole(SUPPORT_ROLE) {

        _internalClaim(receiver);

    }



    function claimOnBehalfOfBatch(

        address[] calldata addresses

    ) external onlyRole(SUPPORT_ROLE) {

        for (uint256 i; i < addresses.length; ++i) {

            _internalClaim(addresses[i]);

        }

    }



    /**

     * @notice claim function to be used both by the user and by the support role

     * @dev used by claim() and claimOnBehalfOf()

     * @param claimant the address to claim tokens for.

     */

    function _internalClaim(address claimant) internal {

        if (claimant == address(0)) {

            revert NullAddressParameter("claimant");

        }



        // early revert if the auction is not in the right stage

        AuctionStage stageMem = stage; // memory

        if (!stageIsAfterBidding(stageMem)) {

            revert NoClaimsAllowedInCurrentStage(stageMem);

        }



        // read user in memory

        User memory user = userData[claimant]; // get user data



        if (user.claimed) {

            revert AlreadyClaimed(claimant);

        }



        uint256 userTotalBid = user.totalBid;



        if (userTotalBid == 0) {

            revert ZeroBids(claimant);

        }



        // determine the split between tokens and refund

        // limit to the maximum tokens a wallet can win in the auction

        uint256 priceMem = price;

        uint256 mintAmount = Math.min(userTotalBid / priceMem, MAX_PODS_WIN_PER_WALLET);



        // the user may have been already refunded by the support role

        uint256 refund = 0;

        if (user.refundedFunds == 0) {

            // if the user has not been refunded, calculate the refund

            // as the reamining amount from the bid afrer the tokens won have been paid for

            refund += userTotalBid - (mintAmount * priceMem);

        }



        // if the contribution is not enough for any mints, simply exit

        if (mintAmount > 0) {

            uint256 supplyLeft = remainingSupply();



            // if the supply is less than the mint amount won

            if (supplyLeft < mintAmount) {

                // refund the remaining amount for any items which cannot be minted

                uint256 refundablePods = mintAmount - supplyLeft;



                // mint only the remaining items from the supply

                mintAmount = supplyLeft;



                // refund the difference

                // @dev cannot be 0 since price is not 0 and

                // the above if statment leads to refundablePods being at least 1

                refund += refundablePods * price;

            }



            // the mintAmount is adjusted for supply above,

            // hence it can be 0 again if no supply has been left

            if (mintAmount > 0) {

                _internalMint(claimant, mintAmount);

            }

        }



        emit Claimed(claimant, userTotalBid, mintAmount, refund);

        user.claimed = true;



        // send the refund

        if (refund > 0) {

            emit RefundSent(claimant, refund);

            user.refundedFunds += SafeCast.toUint120(refund);



            (bool success, ) = claimant.call{value: refund}("");

            if (!success) {

                revert RefundFailed(claimant, refund);

            }

        }



        // reassign changes back to storage

        userData[claimant] = user;

    }



    /**

     * @notice reveal a pod to mint an XDroid

     * @param tokenId the token ID of the pod to reveal

     */

    function revealPod(uint256 tokenId) external nonReentrant returns (uint256) {

        if (stage != AuctionStage.REVEALS_OPEN) {

            revert RevealsNotOpenYet();

        }



        if (!_exists(tokenId)) {

            revert TokenNotMinted(tokenId);

        }



        if (ownerOf(tokenId) != msg.sender) {

            revert MustBeTokenOwner(msg.sender, tokenId);

        }



        // droids contract interface set

        XDroidsInterface xdroidsContract = XDroidsInterface(xDroidsContractAddress);



        // get a droid in exchange

        uint256 droidId = xdroidsContract.mintFromXPod(msg.sender);



        // emit reveal event

        emit XDroidRevealed(msg.sender, droidId, tokenId);



        // burning the pod after minting a droid to ensure that pods are not

        // burned prematurely if anything fails in the transaction

        _burn(tokenId, false);



        return droidId; // Return the minted ID

    }



    /**

     * @notice read the bid of the user

     * @param bidder address of the bidder

     */

    function bidOf(address bidder) external view returns (uint216) {

        User memory user = userData[bidder];

        return user.totalBid;

    }



    /**

     * @notice mint reserved tokens for the team

     * @param n number of tokens to mint

     * @param to address to mint to

     */

    function mintToTeam(uint256 n, address to) external onlyRole(SUPPORT_ROLE) {

        if (podsMintedToTeam + n > MAX_TEAM_MINT) {

            revert ExceedsMaxTeamMint(podsMintedToTeam + n, MAX_TEAM_MINT);

        }

        podsMintedToTeam += n;

        _internalMint(to, n);



        emit MintedToTeam(to, n);

    }



    /**

     * @dev sets the base uri for {_baseURI}

     */

    function setBaseURI(string calldata newBaseURI) external onlyRole(SUPPORT_ROLE) {

        if (bytes(newBaseURI).length == 0) {

            revert BaseURICannotBeEmpty();

        }



        baseURI = newBaseURI;

        emit BaseURISet(newBaseURI);

    }



    /**

     * @dev override from ERC721A

     */

    function _baseURI() internal view override returns (string memory) {

        return baseURI;

    }



    /**

     * @dev sets the contract address of the X Droids contract

     */

    function setXDroidsContract(

        address xDroidsContractAddress_

    ) external onlyRole(SUPPORT_ROLE) {

        if (xDroidsContractAddress_ == address(0)) {

            revert NullAddressParameter("xDroidsContractAddress");

        }



        if (stage != AuctionStage.NOT_STARTED) {

            revert XDroidChangeAfterAuctionStarted();

        }



        emit XDroidContractSet(xDroidsContractAddress_);

        xDroidsContractAddress = xDroidsContractAddress_;

    }



    /**

     * @notice Withdraw function for the owner

     * Since only pod sales funds can be withdrawn at any time

     * and users' funds need to be protected, this is marked as nonReentrant

     */

    function withdraw(address payable receiver) external onlyOwner nonReentrant {

        // allow the owner to withdraw the balance for any minted pods

        AuctionStage stageMem = stage;

        if (!stageIsAfterBidding(stageMem)) {

            revert CannotWithdrawBeforeClaimsStage(stageMem);

        }



        // all minted pods so far

        uint256 mintCount = _totalMinted();



        uint256 withdrawablePodsSales = mintCount - podsMintedToTeam;



        if (withdrawablePodsSales < 1) {

            revert NotEnoughPodsSold();

        }



        // substract any funds already withdrawn by the owner

        uint256 funds = (withdrawablePodsSales * price) - podSalesWithdrawnByOwner;



        if (funds == 0) {

            revert NoFundsToWithdraw();

        }



        // emit the withdraw event

        emit FundsWithdrawn(receiver, funds);



        // increment the funds withdrawn by the owner

        podSalesWithdrawnByOwner += funds;



        // send the funds to the receiver

        (bool success, ) = receiver.call{value: funds}("");

        if (!success) {

            revert WithdrawFailed(receiver, funds);

        }

    }



    ////////////////

    // ERC2981 royalty standard

    ////////////////

    /**

     * @dev See {ERC2981-_setDefaultRoyalty}.

     */

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {

        _setDefaultRoyalty(receiver, feeNumerator);



        emit RoyaltyChanged(receiver, feeNumerator);

    }



    /**

     * @dev See {ERC2981-_deleteDefaultRoyalty}.

     */

    function deleteDefaultRoyalty() external onlyOwner {

        _deleteDefaultRoyalty();

    }



    function contractURI() public view returns (string memory) {

        return contractMetadataURI;

    }



    function setContractURI(string calldata newURI) external onlyOwner {

        contractMetadataURI = newURI;

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(

        bytes4 interfaceId

    )

        public

        view

        virtual

        override(AccessControl, ERC2981, IERC721A, ERC721A)

        returns (bool)

    {

        return super.supportsInterface(interfaceId);

    }



    ////////////////

    // overrides for using OpenSea's OperatorFilter to filter out platforms which are know to not enforce

    // creator earnings

    ////////////////

    function setApprovalForAll(

        address operator,

        bool approved

    ) public override(ERC721A, IERC721A) onlyAllowedOperatorApproval(operator) {

        super.setApprovalForAll(operator, approved);

    }



    function approve(

        address operator,

        uint256 tokenId

    ) public payable override(ERC721A, IERC721A) onlyAllowedOperatorApproval(operator) {

        super.approve(operator, tokenId);

    }



    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public payable override(ERC721A, IERC721A) onlyAllowedOperator(from) {

        super.transferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public payable override(ERC721A, IERC721A) onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId);

    }



    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory data

    ) public payable override(ERC721A, IERC721A) onlyAllowedOperator(from) {

        super.safeTransferFrom(from, to, tokenId, data);

    }

    //////////

    // end of OpenSea DefaultOperatorFilter overrides

}