// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./Malartic.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";



contract MalarticSale is Ownable {

    //MERKLE ROOT FOR WHITELIST MINTS

    bytes32 public merkleRoot;



    //PRICE ORACLE

    AggregatorV3Interface private usdByEthFeed;

    AggregatorV3Interface private usdByEuroFeed;

    AggregatorV3Interface private usdByUsdcFeed;

    AggregatorV3Interface private usdByUsdtFeed;



    //PRICE

    uint8 constant priceInEuro = 250;



    //MALARTIC COLLECTION

    Malartic public immutable malarticContract;



    //GENESIS COLLECTION

    address public immutable genesisCollectionAddress;



    //USDC AND USDT CONTRACT ADDRESSES

    address public immutable usdcAddress;

    address public immutable usdtAddress;



    //ENUM THAT REPRESENTS THE DIFERRENT MINTING PHASES

    enum Phase {

        Pause,

        PreMint,

        PublicSale

    }



    Phase public currentPhase;



    constructor(

        address _malarticContractAddress,

        address _genesisCollectionAddress,

        address _usdcAddress,

        address _usdtAddress,

        address _usdByEthOracleAddress,

        address _usdByEuroOracleAddress,

        address _usdByUsdcOracleAddress,

        address _usdByUsdtOracleAddress

    ) {

        malarticContract = Malartic(_malarticContractAddress);

        genesisCollectionAddress = _genesisCollectionAddress;

        usdByEthFeed = AggregatorV3Interface(_usdByEthOracleAddress);

        usdByEuroFeed = AggregatorV3Interface(_usdByEuroOracleAddress);

        usdByUsdcFeed = AggregatorV3Interface(_usdByUsdcOracleAddress);

        usdByUsdtFeed = AggregatorV3Interface(_usdByUsdtOracleAddress);

        usdcAddress = _usdcAddress;

        usdtAddress = _usdtAddress;

        currentPhase = Phase(1);

    }



    /**

     * @dev Funtion that allows only Genesis and Moussie holders or Whitelisted addresses to mint as long as they pay the respective price

     * @param to Address that will receive the NFTs after the payment

     * @param proof The merkle tree proof that proofs the "to" address is whitelisted

     * @param amount The amount of NFTs to be minted

     */

    function preMint(

        address to,

        bytes32[] calldata proof,

        uint8 amount

    ) public payable {

        require(

            currentPhase == Phase(Phase.PreMint),

            "Pre mint phase not enabled"

        );

        if (proof.length == 0) {

            //On the first pre mint phase only whitelisted addresses, Genesis holders and Moussie holders can mint

            require(

                ERC721(genesisCollectionAddress).balanceOf(to) > 0,

                "Minting wallet is not a WBC Genesis holder"

            );

        } else {

            require(isWhitelistedAddress(to, proof), "Invalid merkle proof");

        }

        uint256 usdcAmount = getUsdcPrice(amount);

        uint256 usdtAmount = getUsdtPrice(amount);



        if (msg.value > 0) {

            _checkPayment(amount);

            malarticContract.batchMint(to, amount);

            return;

        } else if (

            ERC20(usdcAddress).allowance(to, address(this)) >= usdcAmount

        ) {

            ERC20(usdcAddress).transferFrom(to, address(this), usdcAmount);

            malarticContract.batchMint(to, amount);

            return;

        } else if (

            ERC20(usdtAddress).allowance(to, address(this)) >= usdtAmount

        ) {

            ERC20(usdtAddress).transferFrom(to, address(this), usdtAmount);

            malarticContract.batchMint(to, amount);

            return;

        } else {

            revert("Not enough funds");

        }

    }



    /**

     * @dev Funtion that allows everyone to mint as long as they pay the respective price

     * @param to Address that will receive the NFTs after the payment

     * @param amount The amount of NFTs to be minted

     */

    function publicMint(address to, uint8 amount) public payable {

        require(

            currentPhase == Phase(Phase.PublicSale),

            "Public mint phase not enabled"

        );

        uint256 usdcAmount = getUsdcPrice(amount);

        uint256 usdtAmount = getUsdtPrice(amount);

        if (msg.value > 0) {

            _checkPayment(amount);

            malarticContract.batchMint(to, amount);

            return;

        } else if (

            ERC20(usdcAddress).allowance(usdcAddress, address(this)) >=

            usdcAmount

        ) {

            ERC20(usdcAddress).transferFrom(to, address(this), usdcAmount);

            malarticContract.batchMint(to, amount);

            return;

        } else if (

            ERC20(usdtAddress).allowance(usdtAddress, address(this)) >=

            usdtAmount

        ) {

            ERC20(usdtAddress).transferFrom(to, address(this), usdtAmount);

            malarticContract.batchMint(to, amount);

            return;

        }

    }



    //PRICE CALCULATION FUNCTIONS

    function getUsdByEth() private view returns (uint256) {

        (, int256 price, , , ) = usdByEthFeed.latestRoundData();

        require(price > 0, "negative price");

        return uint256(price);

    }



    function getUsdByEuro() private view returns (uint256) {

        // Fetches the latest Usd/Euro price

        (, int256 price, , , ) = usdByEuroFeed.latestRoundData();

        require(price > 0, "negative price");

        return uint256(price);

    }



    function getUsdByUsdc() private view returns (uint256) {

        // Fetches the latest Usd/Usdc price

        (, int256 price, , , ) = usdByUsdcFeed.latestRoundData();

        require(price > 0, "negative price");

        return uint256(price);

    }



    function getUsdByUsdt() private view returns (uint256) {

        // Fetches the latest Usd/Usdt price

        (, int256 price, , , ) = usdByUsdtFeed.latestRoundData();

        require(price > 0, "negative price");

        return uint256(price);

    }



    /**

     * @dev Internal function used to calculate the amount of wei needed to mint

     */

    function getWeiPrice(uint256 amount) public view returns (uint256) {

        // Calculates the amount of wei based on the price of each NFT (price in euros)

        uint256 priceInDollar = (priceInEuro * getUsdByEuro() * 10 ** 18) /

            10 ** usdByEuroFeed.decimals();

        uint256 weiPrice = (priceInDollar * 10 ** usdByEthFeed.decimals()) /

            getUsdByEth();

        return (weiPrice * amount);

    }



    /**

     * @dev Internal function used to calculate the amount of Usdc needed to mint

     */

    function getUsdcPrice(uint256 amount) public view returns (uint256) {

        // Calculates the amount of wei based on the price of each NFT (price in euros)

        uint256 priceInDollar = ((priceInEuro * getUsdByEuro()) /

            10 ** usdByEuroFeed.decimals()) * 10 ** 6;

        uint256 priceInUsdc = (priceInDollar * 10 ** usdByUsdcFeed.decimals()) /

            getUsdByUsdc();



        return (priceInUsdc * amount);

    }



    /**

     * @dev Internal function used to calculate the amount of Usdt needed to mint

     */

    function getUsdtPrice(uint256 amount) public view returns (uint256) {

        // Calculates the amount of wei based on the price of each NFT (price in euros)

        uint256 priceInDollar = ((priceInEuro * getUsdByEuro()) /

            10 ** usdByEuroFeed.decimals()) * 10 ** 6;

        uint256 priceInUsdt = (priceInDollar * 10 ** usdByUsdtFeed.decimals()) /

            getUsdByUsdt();

        return (priceInUsdt * amount);

    }



    /**

     * @dev Internal function that allows a margin of 0.05% on minting payment

     */

    function _checkPayment(uint256 amount) private view {

        //Checks for the difference between the price to be paid for all the NFTs being minted and the amount of ether sent in the transaction

        uint256 priceInWei = getWeiPrice(amount);

        uint256 minPrice = ((priceInWei * 995) / 1000);

        uint256 maxPrice = ((priceInWei * 1005) / 1000);

        require(msg.value >= minPrice, "Not enough ETH");

        require(msg.value <= maxPrice, "Too much ETH");

    }



    //MERKLE TREE FUNCTIONS



    function isWhitelistedAddress(

        address _address,

        bytes32[] calldata _proof

    ) private view returns (bool) {

        bytes32 addressHash = keccak256(abi.encodePacked(_address));

        return MerkleProof.verifyCalldata(_proof, merkleRoot, addressHash);

    }



    //SETTERS



    function setUsdByEthFeedAddress(

        address _usdByEthFeedAddress

    ) external onlyOwner {

        usdByEthFeed = AggregatorV3Interface(_usdByEthFeedAddress);

    }



    function setUsdByEurFeedAddress(

        address _usdByEuroFeedAddress

    ) external onlyOwner {

        usdByEuroFeed = AggregatorV3Interface(_usdByEuroFeedAddress);

    }



    function setUsdByUsdcFeedAddress(

        address _usdByUsdcFeedAddress

    ) external onlyOwner {

        usdByUsdcFeed = AggregatorV3Interface(_usdByUsdcFeedAddress);

    }



    function setUsdByUsdtFeedAddress(

        address _usdByUsdtFeedAddress

    ) external onlyOwner {

        usdByUsdtFeed = AggregatorV3Interface(_usdByUsdtFeedAddress);

    }



    function setMerkleRoot(bytes32 root) public onlyOwner {

        merkleRoot = root;

    }



    function setPhase(Phase _phase) public onlyOwner {

        currentPhase = Phase(_phase);

    }



    /**

     * @dev Retrieve the funds of the sales to the contract owner

     */

    function retrieveEth() external onlyOwner {

        // Only the owner can withraw the funds

        bool sent = payable(owner()).send(address(this).balance);

        require(sent, "Eth withdrawal not executed");

    }



    function retrieveUsdc() external onlyOwner {

        ERC20 usdc = ERC20(usdcAddress);

        bool sent = usdc.transfer(owner(), usdc.balanceOf(address(this)));

        require(sent, "Usdc withdrawal not executed");

    }



    function retrieveUsdt() external onlyOwner {

        ERC20 usdt = ERC20(usdtAddress);

        bool sent = usdt.transfer(owner(), usdt.balanceOf(address(this)));

        require(sent, "Usdt withdrawal not executed");

    }



    //UTILITY FUNCTIONS FOR PAPER XYZ MINTS

    function checkPreMintEligibility(

        address to,

        bytes32[] calldata proof,

        uint8 amount

    ) public view returns (string memory) {

        if (currentPhase != Phase(Phase.PreMint)) {

            return "Pre mint phase not enabled";

        } else if (

            malarticContract.addressMints(to) + amount >

            malarticContract.MAX_MINT_PER_WALLET()

        ) {

            return "Mint limit per wallet was exceeded";

        } else if (

            malarticContract.totalSupply() + amount >

            malarticContract.MAX_SUPPLY()

        ) {

            return "Mint supply limit was exceeded";

        }

        if (proof.length == 0) {

            if (ERC721(genesisCollectionAddress).balanceOf(to) == 0) {

                return "Minting wallet is not a WBC Genesis holder";

            }

        } else {

            if (!isWhitelistedAddress(to, proof)) {

                return "Invalid merkle proof";

            }

        }

        return "";

    }



    function checkPublicMintEligibility(

        address to,

        uint8 amount

    ) public view returns (string memory) {

        if (currentPhase != Phase(Phase.PublicSale)) {

            return "Public mint phase not enabled";

        } else if (

            malarticContract.addressMints(to) + amount >

            malarticContract.MAX_MINT_PER_WALLET()

        ) {

            return "Mint limit per wallet was exceeded";

        } else if (

            malarticContract.totalSupply() + amount >

            malarticContract.MAX_SUPPLY()

        ) {

            return "Mint supply limit was exceeded";

        }

        return "";

    }

}