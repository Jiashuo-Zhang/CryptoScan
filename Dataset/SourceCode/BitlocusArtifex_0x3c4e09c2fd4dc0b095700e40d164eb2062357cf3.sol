// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

//compiled with optimization=5



import "ERC1155.sol";  //import "@openzeppelin/[email protected]/token/ERC1155/ERC1155.sol"; // direct import required for etherscan.io verification

import "IERC20.sol";   //import "@openzeppelin/[email protected]/token/ERC20/IERC20.sol";

import "Ownable.sol";  //import "@openzeppelin/[email protected]/access/Ownable.sol";

import "Strings.sol";  //import "@openzeppelin/[email protected]/utils/Strings.sol";

import "IERC721.sol";  //import "@openzeppelin/[email protected]/token/ERC721/IERC721.sol";

import "IERC1155.sol"; //import "@openzeppelin/[email protected]/token/ERC1155/IERC1155.sol";



contract BitlocusArtifex is //0xa4cc911C20BD8Fb61a72b074E798dE88e9366bD7

    ERC1155,

    Ownable 

{

    string public name = "Bitlocus Artifex NFT";

    string public symbol = "BTL_ART";



    mapping(uint256 => bytes) public TokenInstructions; // drawing instructions for the token

    mapping(uint256 => address) public TokenMinter; // who minted a token

    mapping(uint256 => address) public TokenOwner; // a convenience function, possible because each token is unique

    mapping(address => uint256) public StakedBTLByHolder; // convenience function

    mapping(uint256 => uint256) public TokenBTLBalance; // what is the BTL balance staked by an NFT

    mapping(uint256 => uint256) public TokenMintedBlock; // at which block was this NFT minted

    mapping(uint256 => uint256) public RewardsLastClaimedBlock; // at which block has this NFT last claimed rewards

    mapping(uint256 => bool) public BurntToken; // has an NFT been burnt

    mapping(uint256 => uint256) public _SequentialListOfTokens; // a convenience function/array, listing all token

    mapping(uint256 => uint256) public _TokenNumber; // a convenience function/array, # of minted NFT

    uint256 public _NumTokensMinted = 0; // index/counter for convenience functions

    uint256 public _NumTokensBurnt = 0; // index/counter for convenience functions

    uint256 public _MaxLiveNFTs = 5000; // specifies the maximum number of NFTs that can be minted (minus burned)



    bool public _ContractIsLive = false; // no minting allowed until go-live



    mapping(bytes20 => uint256) public TokenImageHash; // stores a hash of the image pixels, to check for duplicate images



    // Convenience structure (_pointer*) to record NFTs owned by an address, without having to rely on events.

    // Costs a little more gas for transfers, but makes hosting of static dapp websites possible (e.g. on github pages)



    mapping(address => uint256) public _pointer_address_nft; // points to one of the address' NFTs, or points at 0x0 (or self) if address has no NFTs

    mapping(uint256 => uint256) public _pointer_next_nft; // points from one NFT to the next one in double linked list

    mapping(uint256 => uint256) public _pointer_prev_nft; // points from one NFT to the previous one in double linked list

    // this is how this works:  address --> nft1 <--> nft2 <--> nft3 <--> ... <..> nft1   (ring)



    uint256 public BTLStakingRewardPool; // How many BTL held by this contract are available in the reward pool for payout

    uint256 public BTLStakedWithNFT; // How many BTL held by this contract are staked BTL



    // convenience function

    function BTLHeldByContract() public view returns (uint256) {

        return BTLToken.balanceOf(address(this));

    }



    // Official BTL Token address (BTL wormhole contract ETHEREUM)

    address _BTL_Token_address = 0x93e32efaFd24973d45f363A76D73ccB9Edf59986;

    IERC20 private BTLToken = IERC20(_BTL_Token_address); // The BTL Token Contract



    uint256 public min_BTL_to_mint = 10000_000_000; // minimum BTL needed to mint an NFT: initially set to 10000 BTL  (BTL has 6 decimals)



    // minimum amount of time in blocks a newly minted

    // NFT will be staked before it can be burnt by the

    // owner and release the staked BTL

    // = 182.5 days * 86400 / 12 seconds per block = 1314000 blocks

    uint256 public TokenLockBlocks = 1_314_000; // starting at 6 months (cannot be increased, only reduced)

    // Store per token its lock period (that is, value of TokenLockBlocks at time of mint).

    mapping(uint256 => uint256) public TokenLockBlocks_Token;



    uint256 public StakingRewardsAnnualPercentage = 10; // annual staking rewards in %

    uint256 public TransferFeesPercentage = 1; // transfer fee in % for transfer of staked NFTs (fee will go directly go into the reward pool for future staking rewards)



    // Admin/Owner Helper Functions, allows adjusting of contract parameter while ownership has not been renounced

    function _adminSetMinBTL(

        uint256 p_min_BTL_needed_to_mint

    ) public onlyOwner {

        min_BTL_to_mint = p_min_BTL_needed_to_mint;

    }



    function _adminSetTokenLockBlocks(

        uint256 p_TokenLockBlocks

    ) public onlyOwner {

        TokenLockBlocks = p_TokenLockBlocks;

    }



    function _adminSetTokenLockBlocks_token(

        uint256 _tokenId,

        uint256 _lock_blocks

    ) public onlyOwner {

        // admin can reduce (only) lock period for a specific NFT.

        // This is intended to be used for recovery under exceptional circumstances.

        require(_lock_blocks < TokenLockBlocks_Token[_tokenId]);

        TokenLockBlocks_Token[_tokenId] = _lock_blocks;

    }



    function _adminSetStakingRewardsAnnualPercentage(

        uint256 p_perc

    ) public onlyOwner {

        StakingRewardsAnnualPercentage = p_perc;

    }



    // set the contract live, when everything is in place.

    function _adminSetContractLive() public onlyOwner {

        _ContractIsLive = true;

    }



    // set the contract to pause, for maintenance or as needed. Note that this does not impact any 

    // existing NFT's, only the creation of new ones.

    function _adminPauseContract() public onlyOwner {

        _ContractIsLive = false;

    }

    



    uint256 public _SecondsPerBlock = 12; // keep "speed" adjustable in case it ever changes



    function _adminSetSecondsPerBlock(uint256 p_sec) public onlyOwner {

        _SecondsPerBlock = p_sec;

    }



    string private url_full; //"https://bitlocus.art/artifex/json/{id}.json"

    string private url_pre; //"https://bitlocus.art/artifex/json/"

    string private url_ext; //".json"



    // Update to the URL in case the hosting of the image changes



    function _adminSetURL(

        string memory p_url_pre,

        string memory p_url_ext

    ) public onlyOwner {

        url_full = string(abi.encodePacked(p_url_pre, "{id}", p_url_ext));

        url_pre = p_url_pre;

        url_ext = p_url_ext;

    }



    // Admin can reduce the total token limit (but never increase it),

    // this can be used to increase scarcity of NFTs depending on market conditions

    // in consultation with the community. Note that decreasing the max number does not affect

    // existing Artifex NFTs (even if the live number of NFTs is higher)



    function _adminSetTokenLimit(uint256 _newTokenLimit) public onlyOwner {

        // Admin can only decrease the limit

        require(

            _MaxLiveNFTs > _newTokenLimit,

            "Token limit can only be reduced."

        );

        _MaxLiveNFTs = _newTokenLimit;

    }



    // TopUpStakingRewards is called to add BTL staking rewards, usually by owner, but really anyone could contribute.



    function TopUpStakingRewards(uint256 p_amount) public {

        // get BTL from sender (contract must have been authorized)

        require(

            BTLToken.transferFrom(msg.sender, address(this), p_amount),

            "insuf auth BTL"

        );

        BTLStakingRewardPool += p_amount; // add to available staking reward pool

    }



    // Removal function of staking rewards. This can only be done if the contract is not enabled.



    function _adminRemoveStakingRewards(uint256 _amount) public onlyOwner {

        require(!_ContractIsLive,"cannot remove reward pool from live contract.");

        require(_amount<=BTLStakingRewardPool,"insufficiant reward pool size");

        require(BTLToken.transfer(msg.sender, _amount));

        BTLStakingRewardPool -= _amount; // add to available staking reward pool

    }



    constructor(

        string memory p_url_pre,

        string memory p_url_ext

    ) ERC1155(string(abi.encodePacked(p_url_pre, "{id}", p_url_ext))) {

        _adminSetURL(p_url_pre, p_url_ext);

    }



    //

    //  The MINT function: Allows minting of a new BTL ART NFT, by providing the drawing instructions (Hex Code)

    //  and the amount of BTL to entangle/stake with the new NFT.

    //

    //  Note, the drawing instructions must follow the drawing protocol as stipulated by the Bitlocus Artifex NFT team.

    //  You can mint with any unique byte sequence, but if it doesnt follow the protocol,

    //  the generated image may not render.

    //

    //  Note that if drawingInstructions generated images do not match the provided hash of the final image, the linked

    //  token png will not render

    //

    //  Note that every transfer/sale of an NFT will deduct 1% of the staked BTL of the token,

    //  and move it into the rewards pool for ongoing NFT claim rewards. Also note, there is NO developer/deployer fee

    //  as this contract has been built solely for the benefit of BTL and the community.



    // flags to prevent reentry attacks

    bool internal _reentry_mint = false;

    bool internal _reentry_burn = false;

    bool internal _reentry_claim = false;



    function mint(

        bytes memory drawingInstructions,

        uint256 BTLtoStake,

        bytes20 imagehash

    ) public returns (uint256) {

        require(!_reentry_mint);

        require(_ContractIsLive || msg.sender == owner(), "contract not live yet.");

        _reentry_mint = true;

        uint256 _tokenid = uint256(keccak256(bytes(drawingInstructions))); // hash drawing instructions to create unique token ID

        require(TokenMinter[_tokenid] == address(0x0), "Token exists");

        require(TokenImageHash[imagehash] == 0x0, "Token image exists");

        require(!BurntToken[_tokenid], "Token burnt");

        require(BTLtoStake >= min_BTL_to_mint, "Insuf BTL");

        require(

            _NumTokensMinted - _NumTokensBurnt <= _MaxLiveNFTs,

            "NFT limit reached, wait for burn"

        );



        TokenImageHash[imagehash] = _tokenid;



        // get BTL from minter (transfer must have been authorized beforehand using the BTL Token's "approve" function)

        require(

            BTLToken.transferFrom(msg.sender, address(this), BTLtoStake),

            "insuf auth BTL"

        );



        TokenBTLBalance[_tokenid] = BTLtoStake;

        TokenMintedBlock[_tokenid] = block.number;

        TokenLockBlocks_Token[_tokenid] = TokenLockBlocks;

        RewardsLastClaimedBlock[_tokenid] = block.number;



        TokenMinter[_tokenid] = msg.sender;

        TokenInstructions[_tokenid] = drawingInstructions;



        _mint(msg.sender, _tokenid, 1, "");



        _NumTokensMinted++;

        _SequentialListOfTokens[_NumTokensMinted] = _tokenid;

        _TokenNumber[_tokenid] = _NumTokensMinted;



        BTLStakedWithNFT += BTLtoStake;

        StakedBTLByHolder[msg.sender] += BTLtoStake;

        _reentry_mint = false;



        return _tokenid;

    }



    //

    //  The burn function burns the NFT after the initial staking period is done (but of course only IF the owner wants to burn it).

    //

    //  Make sure you claim all rewards before burning, or you may miss out on extra rewards

    //



    function burn(uint256 _tokenid) public {

        require(!_reentry_burn);

        _reentry_burn = true;

        require(balanceOf(msg.sender, _tokenid) == 1, "not token owner");

        require(

            TokenMintedBlock[_tokenid] + TokenLockBlocks_Token[_tokenid] <

                block.number,

            "still locked"

        );



        _burn(msg.sender, _tokenid, 1);

        _NumTokensBurnt++;

        BurntToken[_tokenid] = true;



        uint256 stakedBTLBalance = TokenBTLBalance[_tokenid];

        TokenBTLBalance[_tokenid] = 0;

        require(

            BTLToken.transfer(msg.sender, stakedBTLBalance),

            "cannot transfer BTL"

        );

        BTLStakedWithNFT -= stakedBTLBalance;

        StakedBTLByHolder[msg.sender] -= stakedBTLBalance;

        _reentry_burn = false;

    }



    // claim : allows NFT holder to claim staking rewards for an NFT



    function claim(uint256 _tokenid) public {

        require(!_reentry_claim);

        _reentry_claim = true;

        require(!BurntToken[_tokenid], "token already burnt");

        require(

            this.balanceOf(msg.sender, _tokenid) == 1,

            "not owner of token"

        );



        uint256 stakingPeriod = block.number -

            RewardsLastClaimedBlock[_tokenid];

        require(stakingPeriod >= 1); // cannot claim more than once per block (anti hacking, anti reentry)

        //

        // calculate rewards

        uint256 claimAmount = _RewardsAt(block.number, _tokenid);

        RewardsLastClaimedBlock[_tokenid] = block.number; // update last claim block to now.



        require(

            claimAmount <= BTLStakingRewardPool,

            "rewards pool exhausted, try later"

        );

        require(claimAmount > 0, "nothing to claim");



        BTLStakingRewardPool -= claimAmount;

        require(BTLToken.transfer(msg.sender, claimAmount));

        _reentry_claim = false;

    }



    // helper function to query a token id based on the hash of its image



    function _tokenid_for_hash(

        bytes20 _imagehash

    ) public view returns (uint256) {

        return TokenImageHash[_imagehash];

    }



    // calculate rewards



    function _RewardsAt(

        uint256 _blocknum,

        uint256 _tokenid

    ) public view returns (uint256) {

        if (_blocknum < RewardsLastClaimedBlock[_tokenid]) {

            return 0;

        }

        uint256 stakingPeriod = _blocknum - RewardsLastClaimedBlock[_tokenid];



        uint256 blocksPerYear = (365 * 86400) / _SecondsPerBlock;

        uint256 annualReward = (TokenBTLBalance[_tokenid] *

            StakingRewardsAnnualPercentage) / 100;

        uint256 rewardPerBlock = annualReward / blocksPerYear;

        uint256 claimAmount = stakingPeriod * rewardPerBlock;



        return claimAmount;

    }



    function _RewardsAtNow(uint256 _tokenid) public view returns (uint256) {

        return _RewardsAt(block.number, _tokenid);

    }



    // NFT helper functions



    function uri(

        uint256 _tokenid

    ) public view override returns (string memory) {

        return

            string(

                abi.encodePacked(url_pre, Strings.toString(_tokenid), url_ext)

            );

    }



    function tokenURI(uint256 _tokenId) public view returns (string memory) {

        return uri(_tokenId);

    }



    function _TokenInstructions(

        uint256 _tokenid

    ) public view returns (bytes memory) {

        return TokenInstructions[_tokenid];

    }



    // View function to get TokenInstructions as a hex string



    function _getTokenInstructionsAsHexString(

        uint256 tokenIndex

    ) public view returns (string memory) {

        bytes memory instructions = TokenInstructions[tokenIndex];

        return bytesToHexString(instructions);

    }



    // Helper function to convert bytes to hex string



    function bytesToHexString(

        bytes memory data

    ) internal pure returns (string memory) {

        bytes memory hexchar = "0123456789abcdef";

        bytes memory result = new bytes(2 + data.length * 2);

        result[0] = "0";

        result[1] = "x";



        for (uint i = 0; i < data.length; i++) {

            result[2 * i + 2] = hexchar[uint8(data[i] >> 4)];

            result[2 * i + 3] = hexchar[uint8(data[i] & 0x0f)];

        }

        return string(result);

    }



    // so we can log the new owner, and collect transfer fees for the reward pool



    function _afterTokenTransfer(

        address, //operator,

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory //data

    ) internal override {

        // record new owner

        for (uint256 i = 0; i < ids.length; i++) {

            if (amounts[i] > 0) {

                _UPDATE_NFT_OWNED_LINKED_LIST(to, ids[i]); // this function updates the new owner's linked list of NFTs, and updates the TokenOwner[]



                // apply transfer fee

                uint256 _BTLbal = TokenBTLBalance[ids[i]];

                //

                if (

                    from != address(0x0) && // not minting

                    to != address(0x0)

                ) {

                    // not burning



                    StakedBTLByHolder[from] -= _BTLbal;

                    StakedBTLByHolder[to] += _BTLbal;



                    uint256 transferFee = (_BTLbal * TransferFeesPercentage) /

                        100;



                    if (transferFee <= TokenBTLBalance[ids[i]]) {

                        // should be, but checking just in case

                        TokenBTLBalance[ids[i]] -= transferFee;

                        BTLStakingRewardPool += transferFee; //update totals

                        BTLStakedWithNFT -= transferFee; //update totals

                        StakedBTLByHolder[to] -= transferFee;

                    }

                }

            }

        }

    }



    // update function for NFT linked list that allows tracking of all NFTs owned by an address

    function _UPDATE_NFT_OWNED_LINKED_LIST(

        address _to,

        uint256 _tokenid

    ) internal {

        //

        address currentOwner = TokenOwner[_tokenid];



        // Remove from current owner's list if it's already owned

        if (currentOwner != address(0)) {

            uint256 currentNftPrev = _pointer_prev_nft[_tokenid]; // if the token is currently owned, this will point at that owners prev NFT in the closed linked list

            uint256 currentNftNext = _pointer_next_nft[_tokenid]; // if the token is currently owned, this will point at that owners next NFT in the closed linked list



            // first we move the old  address' NFT pointer to another one if it is pointing directly at _tokenid

            if (_pointer_address_nft[currentOwner] == _tokenid) {

                // If it's the only NFT for that owner, the NFT would point at itself, so we would set the address'

                // queue pointer to 0, otherwise point to the next NFT in the old owner's existing list

                _pointer_address_nft[currentOwner] = (currentNftNext ==

                    _tokenid)

                    ? 0

                    : currentNftNext;

            }



            // now we cut the token out of the linked list by updating its neighbors left and right

            if (currentNftPrev != _tokenid) {

                _pointer_next_nft[currentNftPrev] = currentNftNext;

            }

            if (currentNftNext != _tokenid) {

                _pointer_prev_nft[currentNftNext] = currentNftPrev;

            }

        }



        // Add NFT to new owner's list

        if (_to != address(0)) {

            uint256 currentHead = _pointer_address_nft[_to];



            // If the new owner has no NFTs, point the NFT to itself (linked list with only 1 element)

            if (currentHead == 0) {

                _pointer_next_nft[_tokenid] = _tokenid;

                _pointer_prev_nft[_tokenid] = _tokenid;

            } else {

                // otherwise we break open the queue and add it in, and relink

                _pointer_next_nft[_tokenid] = currentHead;

                _pointer_prev_nft[_tokenid] = _pointer_prev_nft[currentHead];

                _pointer_next_nft[_pointer_prev_nft[currentHead]] = _tokenid;

                _pointer_prev_nft[currentHead] = _tokenid;

            }

            _pointer_address_nft[_to] = _tokenid; // and make our token the new head.

        } else {

            // if we are burning (_to is 0x0), clear the

            _pointer_next_nft[_tokenid] = 0x0;

            _pointer_prev_nft[_tokenid] = 0x0;

        }



        // Update token owner

        TokenOwner[_tokenid] = _to;

    }



    // allows updating of the image hash of a token as needed, e.g. for future scaling

    function _adminUpdateTokenImageHash(

        bytes20 _tokenhash,

        uint256 _tokenid

    ) public onlyOwner {

        TokenImageHash[_tokenhash] = _tokenid;

    }



    // Helper functions _UI_Token_Info and _UI_Contract_info return an array of info about a token/NFT + contract, so that

    // the UI doesnt need to execute multiple queries to the RPC

    function _UI_Token_Info(

        uint256 _tokenId

    )

        public

        view

        returns (uint256, uint256, uint256, uint256, address, uint256, uint256)

    {

        return (

            TokenBTLBalance[_tokenId],

            TokenMintedBlock[_tokenId],

            TokenLockBlocks_Token[_tokenId],

            _RewardsAtNow(_tokenId),

            TokenOwner[_tokenId],

            _TokenNumber[_tokenId],

            block.number

        );

    }



    function _UI_Contract_info()

        public

        view

        returns (

            uint256,

            uint256,

            uint256,

            uint256,

            uint256,

            uint256,

            uint256,

            uint256,

            uint256,

            uint256

        )

    {

        return (

            _NumTokensMinted,

            _NumTokensBurnt,

            _MaxLiveNFTs,

            BTLStakingRewardPool,

            BTLStakedWithNFT,

            BTLHeldByContract(),

            min_BTL_to_mint,

            TokenLockBlocks,

            StakingRewardsAnnualPercentage,

            TransferFeesPercentage

        );

    }



    /////////////////////////

    //

    //  Recovery functions. Non-critical and critical

    //

    ////////////////////////



    //

    // Non-critical recovery (unrelated tokens and BNB, no impact on NFT contract functions)

    //



    // Recovery functions for NFTs and BNB sent to this contract directly.

    // While this contract does not need to hold BNB for its main function, the developers would be more than happy to receive contributions.

    // (which we will likely swap into BTL anyways ;)  You can just send BNB directly to this contract if you choose to do so



    function _adminRecoverBNB() public onlyOwner {

        uint amount = address(this).balance;

        // Transfer any BNB to the caller of the function

        (bool success, ) = msg.sender.call{value: amount}("");

        require(success, "Transfer failed.");

    }



    // in case non-BTL ERC20 token (!) are sent to this contract by accident, this allows recovery

    // Function to recover non-BTL ERC20 tokens



    function _adminRecoverNonBTLToken(address _erc20Token) public onlyOwner {

        require(_erc20Token != _BTL_Token_address, "Cannot recover BTL token");

        IERC20 token = IERC20(_erc20Token);

        uint256 tokenBalance = token.balanceOf(address(this));

        require(tokenBalance > 0, "No tokens to recover");

        token.transfer(msg.sender, tokenBalance);

    }



    // if someone sent BTL directly to this contract, but not via the TopUpStakingRewards function,

    // this allows for any non-staked and non-pool-allocated BTLs to be added to the rewards pool, so its not lost

    function _adminRewardsPoolAdjust() public onlyOwner {

        uint256 _contractBTLBalanceTotal = BTLToken.balanceOf(address(this));

        // adjust the Pool, assign all BTL that's not held by NFTs (because it was sent to the contract directly)

        require(

            _contractBTLBalanceTotal >= BTLStakedWithNFT,

            "balance insufficient"

        );

        BTLStakingRewardPool = _contractBTLBalanceTotal - BTLStakedWithNFT;

    }



    // recover NFTs sent to this contract via direct transfer (this contract doesnt accept safeTransfers anyways)

    function _adminRecoverERC721Token(

        address _erc721Token,

        uint256 _tokenId

    ) public onlyOwner {

        IERC721 token = IERC721(_erc721Token);

        require(

            token.ownerOf(_tokenId) == address(this),

            "Contract does not own the NFT"

        );

        // Using transfer instead of safeTransferFrom

        token.safeTransferFrom(address(this), msg.sender, _tokenId);

    }



    function _adminRecoverERC1155Token(

        address _erc1155Token,

        uint256 _tokenId,

        uint256 _amount

    ) public onlyOwner {

        IERC1155 token = IERC1155(_erc1155Token);

        require(

            token.balanceOf(address(this), _tokenId) >= _amount,

            "Contract does not own the NFT"

        );

        // Direct transfer of ERC1155 token

        token.safeTransferFrom(

            address(this),

            msg.sender,

            _tokenId,

            _amount,

            ""

        );

    }



    //////////////////////////////

    ///  RECOVERY / Critical

    //////////////////////////////



    // this is an emergency function that allows recovery of all BTL e.g. in case of imminent risk or ongoing attack.

    // in order to activate this function it requires action from both the Artifex contract creator AND the Official

    // Bitlocus Team to approve/activate.



    uint256 public _totalRecoveryAmountApproved = 0;

    address constant _original_BTL_Token_Deployer =

        0x1FCc389a242BD26A383966a2DCE2A4c2ee6fa6F3;



    // first the official Bitlocus team has to approve recovery:

    function _recovery_enable_bitlocus_team(

        uint256 _recoveryAmountApproved

    ) public {

        require(msg.sender == _original_BTL_Token_Deployer);

        _totalRecoveryAmountApproved = _recoveryAmountApproved;

    }



    // once the official BTL team have approved recovery, the NFT contract deployer (owner) can

    // initiate the recovery of BTL, which will be sent back to the official Bitlocus team.

    // They can then redistribute the funds as required by whichever incident triggered the

    // recovery.



    function _recovery_execute(uint256 _recoveryAmount) public onlyOwner {

        require(

            _recoveryAmount <= _totalRecoveryAmountApproved,

            "approval amount insufficient"

        );

        BTLToken.transfer(_original_BTL_Token_Deployer, _recoveryAmount);

        _totalRecoveryAmountApproved -= _recoveryAmount;

    }



    // Fallback function to accept BNB donations

    receive() external payable {}

}