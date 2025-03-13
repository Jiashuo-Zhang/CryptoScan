//SPDX License Identifier: MIT

pragma solidity ^0.8.19;



/**

                             ,

                            /|      __

                           / |   ,-~ /

                          Y :|  //  /

                          | jj /( .^

                          >-"~"-v"

                         /       Y

                        jo  o    |

                       ( ~T~     j

                        >._-' _./

                       /   "~"  |

                      Y     _,  |

                     /| ;-"~ _  l

                    / l/ ,-"~    \

                    \//\/      .- \

                     Y        /    Y   

                     l       I     !

                     ]\      _\    /"\

                    (" ~----( ~   Y.  )

                ~~~~~~~~~~~~~~~~~~~~~~~~~~



 _______          _       ______   ______   _____  _________  

|_   __ \        / \     |_   _ \ |_   _ \ |_   _||  _   _  | 

  | |__) |      / _ \      | |_) |  | |_) |  | |  |_/ | | \_| 

  |  __ /      / ___ \     |  __'.  |  __'.  | |      | |     

 _| |  \ \_  _/ /   \ \_  _| |__) |_| |__) |_| |_    _| |_    

|____| |___||____| |____||_______/|_______/|_____|  |_____|   

                                                              

    https://twitter.com/Karrot_gg 



 */



import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "./interfaces/IConfig.sol";

import "./interfaces/IKarrotsToken.sol";

import "./interfaces/IStolenPool.sol";

import "./interfaces/IRandomizer.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";



/**

Rabbit: destroyer of $KARROT

- Non-transferrable ERC721

- Mintable by burning $KARROT

- Minted as one of 3 tiers: white, gold, diamond, which have different reward rates per attack for karrots in the stolen pool

- Each rabbit has 5 HP (can fail 5 attacks, each failed attack is -1 HP), and has a 50/50 chance of attack success

- When a rabbit loses all HP, it is burned

- Rabbits cannot be burned by the owner, but can be rerolled for the same price in karrots paid to mint

- 

 */



contract Rabbit is ERC721, Ownable, ReentrancyGuard {

    //================================================================================================

    // SETUP

    //================================================================================================

    using SafeERC20 for IERC20;



    string public baseURI = "https://bafybeicblns3rjbuqytxlh6rj6vv6isevkowtyoa7h6fitazvz5js4uxwy.ipfs.nftstorage.link/";



    IConfig public config;



    bool private isInitialized;

    bool public rabbitMintIsOpen;

    bool public rabbitAttackIsOpen;



    uint16 public constant PERCENTAGE_DENOMINATOR = 10000;

    uint32 public amountMinted;

    uint32 public startTimestamp;

    uint16 public rabbitBatchSize = 50;

    uint32 public rabbitMintSecondsBetweenBatches = 1 days;

    uint8 public rabbitMaxPerWallet = 3;

    uint32 public rabbitAttackCooldownSeconds = 8 hours;

    uint8 public rabbitAttackHpDeductionAmount = 1;



    uint128 public rabbitMintPriceInKarrots = 1500000000 * 1e18; //1.5B Karrot



    uint16 public rabbitMintKarrotFeePercentageToBurn = 2000; //20%

    uint16 public rabbitMintKarrotFeePercentageToStolenPool = 8000; //80%

    uint16 public rabbitMintTier1Threshold = 6000; //60%

    uint16 public rabbitMintTier2Threshold = 3000; //30%, used as chance > tier1, chance <= tier1+tier2

    uint8 public rabbitHP = 5; //number of survivable attacks

    uint16 public rabbitHitRate = 5000; //50%



    uint16 public rabbitAttackHpDeductionThreshold = 7500; //75%



    uint24 public requestNonce;

    uint32 public constant claimRequestTimeout = 15 minutes; 



    struct RabbitEntry {

        uint16 healthPoints;

        uint8 tier;

        uint32 lastAttackTimestamp;

        string tokenURI;

        bool hasAttacked;

    }

    mapping(uint256 => RabbitEntry) public rabbits;

    mapping(address => uint256[]) public ownerToRabbitIds;

    mapping(uint256 => uint256) public batchNumberToAmountMinted;

    mapping(uint256 => uint256) public batchNumberToNumRerolls; // used to expand number minted per batch for rerolls since one is being burned, i.e. mintable0 = 50, reroll, mintable1 = 51, but there are still 50 since 1 was burned. just so that rerolls can't be used to drain the batch.

    

    event RabbitMint(uint256 rabbitId, uint256 tier, uint256 healthPoints, address owner);

    event RabbitReroll(address owner, uint256 rabbitId);

    event RabbitHealthPointsUpdated(uint256 rabbitId, uint256 healthPoints);

    event AttackResult(uint256 rabbitId, address attackSender, string attackResult);



    error ForwardFailed();

    error RabbitsPerWalletLimitReached();

    error TisSoulbound();

    error EOAsOnly(address sender);

    error InsufficientKarrotsForRabbitMint();

    error MaxRabbitsMinted();

    error NoRabbitsOwned();

    error InvalidAttackVerdict(uint256 verdict);

    error CallerIsNotConfig();

    error AttackOnCooldown();

    error MintIsClosed();

    error AttacksAreClosed();

    error NotOwnerOfRabbit();

    error CantRerollRabbitThatHasAttacked();



    constructor(address _configManagerAddress) ERC721("Rabbit", "RBT") {

        config = IConfig(_configManagerAddress);

        startTimestamp = uint32(block.timestamp);

    }



    //================================================================================================

    // MINT + REROLL LOGIC

    //================================================================================================



    /**

        @dev requestToMintRabbits - mints rabbits after necessary checks

        @notice requires prior approval of this contract to spend user's $KARROT!

            3 Args:

                _amount: number of rabbits to mint

                _isReroll: true if this is a reroll, false if it's a new mint

                _idToBurn: if _isReroll is true, this is the rabbitId to burn

        @notice checks rabbit mint is open

        @notice if reroll, calls _burnRabbit, and negates effect on total mintable rabbits this batch

        @notice checks if max rabbits have been minted within this batch

        @notice checks if user has enough $KARROT to mint

        @notice checks if user has reached max rabbits per wallet

        @notice checks if user is an EOA

        @notice karrots "sent" to the stolen pool are burned here and "virtually deposited" to the stolen pool via depositFromRabbit()

     */



    function requestToMintRabbits(uint8 _amount, bool _isReroll, uint256 _idToBurn) public payable nonReentrant returns (uint256) {



        IERC20 karrots = IERC20(config.karrotsAddress());

        

        uint256 mintTransactionKarrotsTotal = rabbitMintPriceInKarrots * _amount;

        uint256 amountToBurn = Math.mulDiv(

            mintTransactionKarrotsTotal,

            rabbitMintKarrotFeePercentageToBurn,

            PERCENTAGE_DENOMINATOR

        );

        uint256 amountToStolenPool = Math.mulDiv(

            mintTransactionKarrotsTotal,

            rabbitMintKarrotFeePercentageToStolenPool,

            PERCENTAGE_DENOMINATOR

        );



        if (msg.sender != tx.origin && msg.sender != address(this)) {

            revert EOAsOnly(msg.sender);

        }



        if (!rabbitMintIsOpen) {

            revert MintIsClosed();

        }



        if (karrots.balanceOf(msg.sender) < mintTransactionKarrotsTotal) {

            revert InsufficientKarrotsForRabbitMint();

        }



        if (balanceOf(msg.sender) + _amount > rabbitMaxPerWallet && !_isReroll) {

            revert RabbitsPerWalletLimitReached();

        }



        if(_isReroll){

            if(ownerOf(_idToBurn) != msg.sender){

                revert NotOwnerOfRabbit();

            }

            if(rabbits[_idToBurn].hasAttacked){

                revert CantRerollRabbitThatHasAttacked();

            }

            ++batchNumberToNumRerolls[getBatchNumber()];

            _burnRabbit(_idToBurn);

            emit RabbitReroll(msg.sender, _idToBurn);

        }



        uint256 thisBatchNumber = getBatchNumber();

        if (batchNumberToAmountMinted[thisBatchNumber] + _amount > rabbitBatchSize + batchNumberToNumRerolls[thisBatchNumber]) {

            revert MaxRabbitsMinted();

        }



        if(karrots.allowance(msg.sender, config.karrotStolenPoolAddress()) < mintTransactionKarrotsTotal){

            karrots.forceApprove(address(this), mintTransactionKarrotsTotal);

        }



        karrots.safeTransferFrom(msg.sender, address(this), mintTransactionKarrotsTotal);

        IKarrotsToken(address(karrots)).burn(mintTransactionKarrotsTotal);



        IStolenPool(config.karrotStolenPoolAddress()).virtualDeposit(amountToStolenPool);



        uint256 randomNumber = IRandomizer(config.randomizerAddress()).getRandomNumber(

            msg.sender, 

            block.timestamp, 

            requestNonce

        );



        batchNumberToAmountMinted[thisBatchNumber] += _amount;

        ++requestNonce;



        _mintNRabbits(randomNumber, _amount);

    }



    //------------------------------------------------------------------------------------------------

    // MINT / REROLL - RELATED INTERNAL FUNCTIONS

    //------------------------------------------------------------------------------------------------

    /**

        @dev wrapper to call _mintRabbit multiple times

        @notice uses first random to generate more by hashing that number and the iterator value

     */

    function _mintNRabbits(uint256 _randomNumber, uint256 _amount) private {

        for (uint256 i = 0; i < _amount; i++) {

            uint256 newRandom = uint256(keccak256(abi.encode(_randomNumber, i)));

            _mintRabbit(newRandom);

        }

    }



    /**

        @dev mints a rabbit using rng to determine tier. 

        @notice important that ++amountMinted happens before anything that depends on amountMinted,

            this is the token ID.

        @notice sets tokenURI to the baseURI + tier + .json

        @notice pushes latest tokenId to the ownerToRabbitIds mapping

     */

    function _mintRabbit(uint256 _randomNumber) private {

        address recipient = msg.sender;

        uint256 randValMod = _randomNumber % PERCENTAGE_DENOMINATOR;

        

        ++amountMinted;

        

        RabbitEntry storage rabbit = rabbits[amountMinted];

        rabbit.healthPoints = rabbitHP;



        if (randValMod <= rabbitMintTier1Threshold) {

            rabbit.tier = 1;

        } else if (randValMod > rabbitMintTier1Threshold && randValMod <= rabbitMintTier1Threshold + rabbitMintTier2Threshold) {

            rabbit.tier = 2;

        } else {

            rabbit.tier = 3;

        }

        

        string memory thisTokenURI = string(

            abi.encodePacked(baseURI, Strings.toString(rabbit.tier), ".json")

        );



        rabbit.tokenURI = thisTokenURI;

        ownerToRabbitIds[recipient].push(amountMinted);



        _safeMint(recipient, amountMinted);



        emit RabbitMint(amountMinted, rabbit.tier, rabbit.healthPoints, recipient);

    }



    /**

        @dev burns rabbit nft, and removes it's corresponding entries in all related mappings and from the owner's array of owned rabbit ids...

        ...finds index in owned rabbit ids array corresponding to desired rabbit id, and replaces it with the last element in the array, then pops the last element

    */

    function _burnRabbit(uint256 _id) private {

        //remove rabbit ownerToRabbitIds mapping



        address rabbitOwner = ownerOf(_id);

        uint256[] storage rabbitIds = ownerToRabbitIds[rabbitOwner];



        if(rabbitIds.length == 0){

            revert NoRabbitsOwned();

        }



        if (rabbitIds.length == 1) {

            delete ownerToRabbitIds[rabbitOwner];

        } else {

            uint256 rabbitIdIndex = 0;

            for (uint256 i = 0; i < rabbitIds.length; i++) {

                if (rabbitIds[i] == _id) {

                    rabbitIdIndex = i;

                    break;

                }

            }



            rabbitIds[rabbitIdIndex] = rabbitIds[rabbitIds.length - 1];

            rabbitIds.pop();

        }



        delete rabbits[_id];



        _burn(_id);

    }



    //================================================================================================

    // ATTACK LOGIC

    //================================================================================================



    

    /**

        @dev called by user to request an attack on a rabbit

        @notice requires that the caller is the owner of the rabbit

        @notice requires that the rabbit is not on cooldown

        @notice requires that the caller is an EOA (not a contract)

        @notice generates random number and calls _completeAttack

     */

    function requestAttack(uint32 _rabbitId) external payable nonReentrant returns (uint256) {

        // cant call if request is already pending

        // needs to have one rabbit in wallet to attack



        if(ownerOf(_rabbitId) != msg.sender){

            revert NotOwnerOfRabbit();

        }



        if (!rabbitAttackIsOpen) {

            revert AttacksAreClosed();

        }



        // [!] check if caller is an EOA (optional - review)

        if (msg.sender != tx.origin) {

            revert EOAsOnly(msg.sender);

        }



        //enforce cooldown, set last attack timestamp at end of function with other mappings...

        if (

            getRabbitCooldownSecondsRemaining(_rabbitId) > 0

        ) {

            revert AttackOnCooldown();

        }



        //set that the rabbit has attempted an attack

        rabbits[_rabbitId].hasAttacked = true;



        //set new last attack timestamp

        rabbits[_rabbitId].lastAttackTimestamp = uint32(block.timestamp);



        uint256 randomNumber = IRandomizer(config.randomizerAddress()).getRandomNumber(

            msg.sender,

            block.timestamp,

            requestNonce

        );



        _completeAttack(_rabbitId, randomNumber);

        ++requestNonce;



    }



    //------------------------------------------------------------------------------------------------

    // ATTACK-RELATED PRIVATE FUNCTIONS

    //------------------------------------------------------------------------------------------------



    function _completeAttack(uint256 _rabbitId, uint256 _randomNumber) private {

        //reveal random number and perform attack



        //perform attack

        RabbitEntry storage rabbit = rabbits[_rabbitId];



        uint256 verdict = _getAttackVerdict(_randomNumber);

        address attackSender = msg.sender;



        //carry out actions based on attackVerdict / values defined above

        if (verdict == 1) {

            IStolenPool(config.karrotStolenPoolAddress()).attack(attackSender, rabbit.tier, _rabbitId); //input what stolen pool needs to calculate attack size

            emit AttackResult(_rabbitId, attackSender, "Attack succeeded. No HP Lost.");

        } else if (verdict == 2) {

            //subtract health points

            _manageRabbitHealthPoints(_rabbitId);

            emit AttackResult(_rabbitId, attackSender, "Attack failed. 1 HP Lost.");

        } else {

            revert InvalidAttackVerdict(verdict);

        }

    }



    /**

     *  @dev subtracts health points from rabbit, and burns it if it reaches 0 health points

     */

    function _manageRabbitHealthPoints(uint256 _rabbitId) private {

        RabbitEntry storage rabbit = rabbits[_rabbitId];

        rabbit.healthPoints -= rabbitAttackHpDeductionAmount;

        emit RabbitHealthPointsUpdated(_rabbitId, rabbit.healthPoints);

        if (rabbit.healthPoints == 0) {

            _burnRabbit(_rabbitId);

        }

    }



    /**

     * @dev outputs a verdict based on the random number and rabbit hit rate

     */

    function _getAttackVerdict(uint256 _randomNumber) private view returns (uint256) {

        uint256 verdict;

        uint256 randValModAttackSuccess = _randomNumber % PERCENTAGE_DENOMINATOR;

        if (randValModAttackSuccess <= rabbitHitRate) {

            verdict = 1;

        } else {

            verdict = 2;

        }

        return verdict;

    }



    //================================================================================================

    // PUBLIC GET FUNCTIONS FOR FRONTEND, ETC.

    //================================================================================================



    function rabbitIdToTier(uint256 _rabbitId) public view returns (uint256) {

        return rabbits[_rabbitId].tier;

    }



    function rabbitIdToHealthPoints(uint256 _rabbitId) public view returns (uint256) {

        return rabbits[_rabbitId].healthPoints;

    }

    

    function rabbitIdToLastAttackTimestamp(uint256 _rabbitId) public view returns (uint256) {

        return rabbits[_rabbitId].lastAttackTimestamp;

    }



    function getRabbitIdsByOwner(address _rabbitOwner) public view returns (uint256[] memory) {

        return ownerToRabbitIds[_rabbitOwner];

    }



    function getRabbitHealthPoints(uint256 _rabbitId) public view returns (uint256) {

        return rabbits[_rabbitId].healthPoints;

    }



    function getRabbitHasAttacked(uint256 _rabbitId) public view returns (bool) {

        return rabbits[_rabbitId].hasAttacked;

    }



    function getRabbitCooldownSecondsRemaining(uint256 _rabbitId) public view returns (uint256) {

        RabbitEntry storage rabbit = rabbits[_rabbitId];

        if(rabbit.lastAttackTimestamp == 0){

            return 0;

        } else {

            //this should never revert. if it does, it means the rabbitIdToLastAttackTimestamp[_rabbitId] is somehow in the future, which should be impossible

            return rabbitAttackCooldownSeconds > (block.timestamp - rabbit.lastAttackTimestamp) ? 

            rabbitAttackCooldownSeconds - (block.timestamp - rabbit.lastAttackTimestamp) : 

            0;

        }

    }



    function getSecondsUntilNextBatchStarts() public view returns (uint256) {

        //number of batches since start time

        uint256 numBatchesSincestartTimestamp = Math.mulDiv(

            (block.timestamp - startTimestamp),

            1,

            rabbitMintSecondsBetweenBatches

        );



        // get the number of seconds that have passed since the start of the last batch, then seconds until next batch starts

        uint256 secondsSinceLastBatchEnded = (block.timestamp - startTimestamp) -

            Math.mulDiv(numBatchesSincestartTimestamp, rabbitMintSecondsBetweenBatches, 1);

        uint256 secondsUntilNextBatchStarts = rabbitMintSecondsBetweenBatches - secondsSinceLastBatchEnded;



        return secondsUntilNextBatchStarts;

    }



    function getNumberOfRemainingMintableRabbits() public view returns (uint256) {

        uint256 batchNumber = getBatchNumber();

        return batchNumberToNumRerolls[batchNumber] + rabbitBatchSize - batchNumberToAmountMinted[batchNumber];

    }



    function getBatchNumber() public view returns (uint256) {

        // get number of batches that have passed since the first batch

        uint256 numBatchesSincestartTimestamp = Math.mulDiv(

            (block.timestamp - startTimestamp),

            1,

            rabbitMintSecondsBetweenBatches

        );



        return numBatchesSincestartTimestamp;

    }



    //================================================================================================

    // SETTERS (those not handled by the config manager contract via structs)

    //================================================================================================



    function setBaseUri(string memory _baseUri) external onlyOwner {

        baseURI = _baseUri;

    }



    function setConfigManagerAddress(address _configManagerAddress) external onlyOwner {

        config = IConfig(_configManagerAddress);

    }





    modifier onlyConfig() {

        if (msg.sender != address(config)) {

            revert CallerIsNotConfig();

        }

        _;

    }



    function setRabbitMintIsOpen(bool _rabbitMintIsOpen) external onlyConfig {

        rabbitMintIsOpen = _rabbitMintIsOpen;

    }



    function setRabbitBatchSize(uint16 _rabbitBatchSize) external onlyConfig{

        rabbitBatchSize = _rabbitBatchSize;

    }



    function setRabbitMintSecondsBetweenBatches(uint32 _rabbitMintSecondsBetweenBatches) external onlyConfig{

        rabbitMintSecondsBetweenBatches = _rabbitMintSecondsBetweenBatches;

    }



    function setRabbitMaxPerWallet(uint8 _rabbitMaxPerWallet) external onlyConfig {

        rabbitMaxPerWallet = _rabbitMaxPerWallet;

    }



    function setRabbitMintPriceInKarrots(uint128 _rabbitMintPriceInKarrots) external onlyConfig {

        rabbitMintPriceInKarrots = _rabbitMintPriceInKarrots;

    }



    function setRabbitMintKarrotFeePercentageToBurn(uint16 _rabbitMintKarrotFeePercentageToBurn) external onlyConfig {

        rabbitMintKarrotFeePercentageToBurn = _rabbitMintKarrotFeePercentageToBurn;

    }



    function setRabbitMintKarrotFeePercentageToStolenPool(uint16 _rabbitMintKarrotFeePercentageToStolenPool) external onlyConfig {

        rabbitMintKarrotFeePercentageToStolenPool = _rabbitMintKarrotFeePercentageToStolenPool;

    }



    function setRabbitMintTier1Threshold(uint16 _rabbitMintTier1Threshold) external onlyConfig {

        rabbitMintTier1Threshold = _rabbitMintTier1Threshold;

    }



    function setRabbitMintTier2Threshold(uint16 _rabbitMintTier2Threshold) external onlyConfig {

        rabbitMintTier2Threshold = _rabbitMintTier2Threshold;

    }



    function setRabbitHP(uint8 _rabbitHP) external onlyConfig {

        rabbitHP = _rabbitHP;

    }



    function setRabbitHitRate(uint16 _rabbitHitRate) external onlyConfig {

        rabbitHitRate = _rabbitHitRate;

    }



    function setRabbitAttackIsOpen(bool _rabbitAttackIsOpen) external onlyConfig {

        rabbitAttackIsOpen = _rabbitAttackIsOpen;

    }



    function setAttackCooldownSeconds(uint32 _attackCooldownSeconds) external onlyConfig {

        rabbitAttackCooldownSeconds = _attackCooldownSeconds;

    }



    function setAttackHPDeductionAmount(uint8 _attackHPDeductionAmount) external onlyConfig {

        rabbitAttackHpDeductionAmount = _attackHPDeductionAmount;

    }



    function setAttackHPDeductionThreshold(uint16 _attackHPDeductionThreshold) external onlyConfig {

        rabbitAttackHpDeductionThreshold = _attackHPDeductionThreshold;

    }



    //================================================================================================

    // ERC721 OVERRIDES

    //================================================================================================



    //erc721 overrides

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {

        revert TisSoulbound();

    }



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {

        revert TisSoulbound();

    }



    function transferFrom(address from, address to, uint256 tokenId) public override {

        revert TisSoulbound();

    }

    

    //"just in case lol"

    function _transfer(address from, address to, uint256 tokenId) internal override {

        revert TisSoulbound();

    }



    // overrides with uri assigned based on tier

    function tokenURI(uint256 _id) public view override returns (string memory) {

        return rabbits[_id].tokenURI;

    }



    //=========================================================================

    // WITHDRAWALS

    //=========================================================================



    function withdrawERC20FromContract(address _to, address _token) external onlyOwner {

        bool os = IERC20(_token).transfer(_to, IERC20(_token).balanceOf(address(this)));

        if (!os) {

            revert ForwardFailed();

        }

    }



    function withdrawEthFromContract() external onlyOwner {

        address out = config.treasuryAddress();

        require(out != address(0));

        (bool os, ) = payable(out).call{value: address(this).balance}("");

        if (!os) {

            revert ForwardFailed();

        }

    }

}