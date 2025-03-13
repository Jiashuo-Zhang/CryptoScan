// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";



pragma solidity ^0.8.13;



contract RiseOfTheMemes_1155 is

    Ownable,

    Pausable,

    ReentrancyGuard,

    ERC1155Holder

{

    IShibaDogeArmy public SD_NFT;



    IERC20 public Burn;



    address public treasury;



    address public signerAddress;



    bool public stakingLaunched;

    uint256 public stakingEndTime;



    bool public depositPaused;

    bool public isWithdrawPaused;



    uint256 public totalStaked;



    struct Staker {

        uint256 currentYield;

        uint256 accumulatedAmount;

        uint256 lastCheckpoint;

        uint256[] stakedSD;

    }



    mapping(address => Staker) public _stakers;

    mapping(uint256 => address) public _ownerOfToken;



    mapping(uint256 => uint256) public _nftYield;



    mapping(address => uint256) public spentAmount;



    event Deposit(

        address indexed staker,

        uint256 tokensAmount

    );

    event Withdraw(

        address indexed staker,

        uint256 tokensAmount

    );

    event WithdrawStuckERC721(

        address indexed receiver,

        address indexed tokenAddress,

        uint256 indexed tokenId

    );

    event WithdrawRewards(address indexed staker, uint256 tokens);



    constructor(address _SDNFT, address _BURN_TOKEN, address _treasury) {

        SD_NFT = IShibaDogeArmy(_SDNFT);



        Burn = IERC20(_BURN_TOKEN);



        signerAddress = 0xf1eaDDf8453CC8953448b0a21e64C77B4203d230; // frontend signing address



        treasury = _treasury;

    }



    /**

     * @dev Function allows admin to pause reward withdraw.

     */

    function pauseWithdraw(bool _pause) external onlyOwner {

        isWithdrawPaused = _pause;

    }



    function validateEquipment(uint256 tokenId, bytes32 equipmentHash) public view returns (bool){

        uint24[15] memory equipped = SD_NFT.viewNFTTraitsArray(tokenId);

        return keccak256(abi.encodePacked(equipped)) == equipmentHash;

    }



    function deposit(

        uint256[] memory tokenIds,

        uint256[] memory tokenValues,

        bytes32[] calldata equipmentHashes,

        uint256 validUntil,

        bytes calldata signature

    ) public nonReentrant {

        require(!depositPaused, "Deposit paused");

        require(stakingLaunched, "Staking is not launched yet");

        require(block.timestamp < stakingEndTime, "Staking has ended");



        require(

            _validateSignature(

                signature,

                address(SD_NFT),

                tokenIds,

                tokenValues,

                equipmentHashes,

                validUntil

            ),

            "Invalid data provided"

        );

        _setTokensValues(tokenIds, tokenValues);



        Staker storage user = _stakers[_msgSender()];

        uint256 newYield = user.currentYield;



        for (uint256 i; i < tokenIds.length; i++) {

            require(

                SD_NFT.balanceOf(_msgSender(), tokenIds[i]) == 1,

                "Not the owner"

            );



            require(validateEquipment(tokenIds[i], equipmentHashes[i]), "Currently equipped EFTs do not match signature");



            SD_NFT.lockNft(tokenIds[i]);



            _ownerOfToken[tokenIds[i]] = _msgSender();



            newYield += getTokenYield(tokenIds[i]);



            user.stakedSD.push(tokenIds[i]);



            totalStaked++;

        }



        accumulate(_msgSender());

        user.currentYield = newYield;



        emit Deposit(_msgSender(), tokenIds.length);

    }



    function withdraw(uint256[] memory tokenIds) public nonReentrant {

        Staker storage user = _stakers[_msgSender()];

        uint256 newYield = user.currentYield;



        for (uint256 i; i < tokenIds.length; i++) {

            require(

                _ownerOfToken[tokenIds[i]] != address(0),

                "NFT not staked in contract"

            );



            _ownerOfToken[tokenIds[i]] = address(0);



            if (user.currentYield != 0) {

                uint256 tokenYield = getTokenYield(tokenIds[i]);

                newYield -= tokenYield;

            }



            user.stakedSD = _moveTokenInTheList(user.stakedSD, tokenIds[i]);

            user.stakedSD.pop();



            SD_NFT.unlockNft(tokenIds[i]);

            totalStaked--;

        }



        if (user.stakedSD.length == 0) {

            newYield = 0;

        }



        accumulate(_msgSender());

        user.currentYield = newYield;



        emit Withdraw(_msgSender(), tokenIds.length);

    }



    function getTokenYield(uint256 tokenId) public view returns (uint256) {

        uint256 tokenYield = _nftYield[tokenId];



        return tokenYield;

    }



    function getStakerYield(address staker) public view returns (uint256) {

        return _stakers[staker].currentYield;

    }



    function getStakerTokens(

        address staker

    ) public view returns (uint256[] memory) {

        return (_stakers[staker].stakedSD);

    }



    function isTokenYieldSet(uint256 tokenId) public view returns (bool) {

        return _nftYield[tokenId] > 0;

    }



    function _moveTokenInTheList(

        uint256[] memory list,

        uint256 tokenId

    ) internal pure returns (uint256[] memory) {

        uint256 tokenIndex = 0;

        uint256 lastTokenIndex = list.length - 1;

        uint256 length = list.length;



        for (uint256 i = 0; i < length; i++) {

            if (list[i] == tokenId) {

                tokenIndex = i + 1;

                break;

            }

        }

        require(tokenIndex != 0, "msg.sender is not the owner");



        tokenIndex -= 1;



        if (tokenIndex != lastTokenIndex) {

            list[tokenIndex] = list[lastTokenIndex];

            list[lastTokenIndex] = tokenId;

        }



        return list;

    }



    function _validateSignature(

        bytes calldata signature,

        address contractAddress,

        uint256[] memory tokenIds,

        uint256[] memory tokenValues,

        bytes32[] calldata equipmentHashes,

        uint256 validUntil

    ) internal view returns (bool) {

        if (block.timestamp > validUntil) {

            return false;

        }

        bytes32 dataHash = keccak256(

            abi.encodePacked(contractAddress, tokenIds, tokenValues, equipmentHashes, validUntil)

        );

        bytes32 message = ECDSA.toEthSignedMessageHash(dataHash);



        address receivedAddress = ECDSA.recover(message, signature);

        return (receivedAddress != address(0) &&

            receivedAddress == signerAddress);

    }



    function _setTokensValues(

        uint256[] memory tokenIds,

        uint256[] memory tokenValues

    ) internal {

        require(tokenIds.length == tokenValues.length, "Wrong arrays provided");

        for (uint256 i; i < tokenIds.length; i++) {

            if (tokenValues[i] != 0) {

                _nftYield[tokenIds[i]] = tokenValues[i];

            }

        }

    }



    function getCurrentReward(address staker) public view returns (uint256) {

        Staker memory user = _stakers[staker];

        if (user.lastCheckpoint == 0) {

            return 0;

        }



        return

            ((Math.min(block.timestamp, stakingEndTime) - user.lastCheckpoint) *

                user.currentYield) / 1 days;

    }



    function accumulate(address staker) internal {

        _stakers[staker].accumulatedAmount += getCurrentReward(staker);

        _stakers[staker].lastCheckpoint = Math.min(

            block.timestamp,

            stakingEndTime

        );

    }



    /**

     * @dev Returns token owner address (returns address(0) if token is not inside the gateway)

     */

    function ownerOf(

        // address contractAddress,

        uint256 tokenId

    ) public view returns (address) {

        return _ownerOfToken[tokenId];

    }



    /**

     * @dev Function allows to pause deposits if needed. Withdraw remains active.

     */

    function pauseDeposit(bool _pause) public onlyOwner {

        depositPaused = _pause;

    }



    function updateSignerAddress(address _signer) public onlyOwner {

        signerAddress = _signer;

    }



    function updateTreasuryAddress(address _treasury) public onlyOwner {

        treasury = _treasury;

    }



    function launchStaking() public onlyOwner {

        require(!stakingLaunched, "Staking has been launched already");

        stakingLaunched = true;

        stakingEndTime = 1694645975;

    }



    function setStakingEndTime(uint256 endTime) external onlyOwner {

        require(endTime > stakingEndTime);

        stakingEndTime = endTime;

    }



    /**

     * @dev Function to withdraw staked rewards

     */

    function withdrawRewards() public nonReentrant whenNotPaused {

        require(!isWithdrawPaused, "Withdraw Paused");



        uint256 amount = getUserBalance(_msgSender());

        require(amount > 0, "Insufficient balance");



        spentAmount[_msgSender()] += amount;

        Burn.transferFrom(treasury, _msgSender(), amount);



        emit WithdrawRewards(_msgSender(), amount);

    }



    /**

     * @dev user's lifetime earnings

     */

    function getAccumulatedAmount(

        address staker

    ) public view returns (uint256) {

        return _stakers[staker].accumulatedAmount + getCurrentReward(staker);

    }



    /**

     * @dev Returns current withdrawable balance of a specific user.

     */

    function getUserBalance(address user) public view returns (uint256) {

        return (getAccumulatedAmount(user) - spentAmount[user]);

    }



    // Safety functions



    /**

     * @dev Allows owner to withdraw any ERC20 Token sent directly to the contract

     */

    function rescueTokens(address _stuckToken) external onlyOwner {

        uint256 balance = IERC20(_stuckToken).balanceOf(address(this));

        IERC20(_stuckToken).transfer(msg.sender, balance);

    }



    /**

     * @dev Allows owner to withdraw any ERC721 Token sent directly to the contract

     */

    function rescueERC721(address _stuckToken, uint256 id) external onlyOwner {

        IERC721(_stuckToken).safeTransferFrom(address(this), msg.sender, id);

    }



    function rescueERC1155(

        address _stuckToken,

        uint256 id,

        bytes calldata data

    ) external onlyOwner {

        uint256 amount = IERC1155(_stuckToken).balanceOf(address(this), id);

        IERC1155(_stuckToken).safeTransferFrom(

            address(this),

            msg.sender,

            id,

            amount,

            data

        );

    }

}



interface IShibaDogeArmy is IERC1155 {

    function lockNft(uint256 id) external;



    function unlockNft(uint256 id) external;



    function nftLocked(uint256 id) external returns (bool);



    function viewNFTTraitsArray(uint256 id) external view returns (uint24[15] memory);

}