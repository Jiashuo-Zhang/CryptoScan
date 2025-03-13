// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.17;
import "@solidstate/contracts/security/reentrancy_guard/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "solady/src/utils/SafeTransferLib.sol";
import "solady/src/utils/ECDSA.sol";
import "solady/src/utils/ERC1967FactoryConstants.sol";
import "./EthscriptionsEscrower.sol";

contract MemeScribeMarket is ReentrancyGuard, EthscriptionsEscrower, Ownable {
    using SafeTransferLib for address;
    using ECDSA for bytes32;

    constructor() Ownable(msg.sender) {
        // Your constructor logic here
    }

    uint public fee = 250; // 2.5%
    uint public constant FEE_DENOMINATOR = 10000;
    uint public feesAccumulated = 0;

    struct Listing {
        bool isForSale;
        bytes32 ethscriptionId;
        address seller;
        uint price;
    }

    mapping(bytes32 => Listing) public ethscriptionsOfferedForSale;

    event EthscriptionListed(
        bytes32 indexed ethscriptionId,
        uint price,
        address indexed seller
    );

    event EthscriptionDelisted(
        bytes32 indexed ethscriptionId,
        address indexed seller
    );

    event EthscriptionPurchased(
        bytes32 indexed ethscriptionId,
        uint price,
        address indexed seller,
        address indexed buyer
    );

    function listEthscription(
        bytes32 ethscriptionId,
        uint price
    ) external nonReentrant {
        _listEthscription(ethscriptionId, price);
    }

    function _listEthscription(bytes32 ethscriptionId, uint price) internal {
        require(
            !userEthscriptionDefinitelyNotStored(msg.sender, ethscriptionId),
            "Sender is not depositor"
        );

        ethscriptionsOfferedForSale[ethscriptionId] = Listing({
            isForSale: true,
            ethscriptionId: ethscriptionId,
            seller: msg.sender,
            price: price
        });

        emit EthscriptionListed(ethscriptionId, price, msg.sender);
    }

    function delistEthscription(bytes32 ethscriptionId) public nonReentrant {
        require(
            !userEthscriptionDefinitelyNotStored(msg.sender, ethscriptionId),
            "Sender is not depositor"
        );

        ethscriptionsOfferedForSale[ethscriptionId] = Listing(
            false,
            ethscriptionId,
            msg.sender,
            0
        );

        emit EthscriptionDelisted(ethscriptionId, msg.sender);
    }

    function batchListEthscriptions(
        bytes32[] memory ethscriptionIds,
        uint[] memory prices
    ) external nonReentrant {
        require(
            ethscriptionIds.length == prices.length,
            "Array lengths do not match"
        );

        for (uint i = 0; i < ethscriptionIds.length; i++) {
            _listEthscription(ethscriptionIds[i], prices[i]);
        }
    }

    function buyEthscription(
        bytes32 ethscriptionId,
        uint price
    ) public payable nonReentrant {
        _buyEthscription(ethscriptionId, price);
    }

    function _buyEthscription(bytes32 ethscriptionId, uint price) internal {
        Listing memory listing = ethscriptionsOfferedForSale[ethscriptionId];

        if (!listing.isForSale) revert("Ethscription is not for sale");

        if (msg.value != listing.price) revert("Not enough ether");

        address seller = listing.seller;

        if (seller == msg.sender) revert("Seller is buyer");

        ethscriptionsOfferedForSale[ethscriptionId] = Listing(
            false,
            ethscriptionId,
            msg.sender,
            0
        );

        _transferEthscription(seller, msg.sender, ethscriptionId);

        // send ether to seller
        uint feeAmount = (listing.price * fee) / FEE_DENOMINATOR;
        uint amountToSendtoSeller = listing.price - feeAmount;
        feesAccumulated += feeAmount;
        payable(seller).transfer(amountToSendtoSeller);

        emit EthscriptionPurchased(
            ethscriptionId,
            listing.price,
            seller,
            msg.sender
        );
    }

    function batchBuyEthscription(
        bytes32[] calldata ethscriptionIds,
        uint[] calldata prices
    ) external payable nonReentrant {
        require(
            ethscriptionIds.length == prices.length,
            "Array lengths do not match"
        );

        uint totalSalePrice = 0;
        for (uint i = 0; i < ethscriptionIds.length; i++) {
            _buyEthscription(ethscriptionIds[i], prices[i]);
            totalSalePrice += prices[i];
        }

        require(msg.value == totalSalePrice, "Incorrect total Ether sent");
    }

    function withdrawEthscription(bytes32 ethscriptionId) public override {
        require(
            !userEthscriptionDefinitelyNotStored(msg.sender, ethscriptionId),
            "Sender is not depositor"
        );

        // Withdraw ethscription
        super.withdrawEthscription(ethscriptionId);

        Listing memory listing = ethscriptionsOfferedForSale[ethscriptionId];
        // Check that the offer is valid
        if (listing.isForSale) {
            // Invalidate listing
            _invalidateListing(ethscriptionId);
        }
    }

    function _invalidateListing(bytes32 ethscriptionId) internal {
        ethscriptionsOfferedForSale[ethscriptionId] = Listing(
            false,
            ethscriptionId,
            msg.sender,
            0
        );

        emit EthscriptionDelisted(ethscriptionId, msg.sender);
    }

    // Owner functions
    function setMarketPlaceFee(uint updatedFee) public onlyOwner {
        fee = updatedFee;
    }

    function withdrawFees() public onlyOwner {
        uint amount = feesAccumulated;
        feesAccumulated = 0;
        payable(msg.sender).transfer(amount);
    }

    function transferContractOwner(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

    // Overrides
    function _onPotentialEthscriptionDeposit(
        address previousOwner,
        bytes memory userCallData
    ) internal virtual override {
        require(userCallData.length % 32 == 0, "InvalidEthscriptionLength");

        // Process each ethscriptionId
        for (uint256 i = 0; i < userCallData.length / 32; i++) {
            bytes32 potentialEthscriptionId = abi.decode(
                slice(userCallData, i * 32, 32),
                (bytes32)
            );

            if (
                userEthscriptionPossiblyStored(
                    previousOwner,
                    potentialEthscriptionId
                )
            ) {
                revert EthscriptionAlreadyReceivedFromSender();
            }

            EthscriptionsEscrowerStorage.s().ethscriptionReceivedOnBlockNumber[
                previousOwner
            ][potentialEthscriptionId] = block.number;
        }
    }

    // Utils
    function slice(
        bytes memory data,
        uint256 start,
        uint256 len
    ) internal pure returns (bytes memory) {
        bytes memory b = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            b[i] = data[i + start];
        }
        return b;
    }

    fallback() external {
        _onPotentialEthscriptionDeposit(msg.sender, msg.data);
    }
}