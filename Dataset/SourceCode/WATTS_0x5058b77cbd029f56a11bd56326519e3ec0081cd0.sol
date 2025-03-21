// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WATTS is AccessControl, Ownable, ERC20 {
    using ECDSA for bytes32;

    /** CONTRACTS */
    IERC721 public slotieNFT;
    IERC721 public slotieJrNFT;

    /** ROLES */
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    
    /** GENERAL */
    uint256 public deployedTime = block.timestamp;
    uint256 public lockPeriod = 90 days;
    event setLockPeriodEvent(uint256 indexed lockperiod);
    event setDeployTimeEvent(uint256 indexed deployTime);

    /** ADDITIONAL ERC-20 FUNCTIONALITY */
    mapping(address => uint256) private _claimableBalances;
    uint256 private _claimableTotalSupply;

    /** === SLOTIE === */

    /** CLAIMING */
    uint256 public slotieIssuanceRate = 10 * 10**18; // 10 per day
    uint256 public slotieIssuancePeriod = 1 days; 
    uint256 public slotieClaimStart = 1644624000; // 12 feb 00:00:00 UTC
    uint256 public slotieDeployTime = 1638877989; // 7 dec 11:53:09 UTC
    uint256 public slotieEarnPeriod = lockPeriod - (deployedTime - slotieDeployTime); // lock period minus time since slotie deploy
    uint256 public slotieClaimEndTime = deployedTime + slotieEarnPeriod;
    
    mapping(address => uint256) slotieAddressToAccumulatedWATTs; // accumulated watts before 12 feb 00:00
    mapping(address => uint256) slotieAddressToLastClaimedTimeStamp; // last time a claimed happened for a user

    /**  GIVEAWAYS */    
    bytes32 public slotiePreClaimMerkleProof = "";
    bytes32 public slotieEHRMerkleProof = "";
    mapping(address => uint256) public slotieAddressToPreClaim; // whether an address claimed their initial claim or not
    mapping(address => uint256) public slotieAddressToEHRNonce; // safeguard against reusing proofs attack

    /** EVENTS */
    event ClaimedRewardFromSlotie(address indexed user, uint256 reward, uint256 timestamp);
    event AccumulatedRewardFromSlotie(address indexed user, uint256 reward, uint256 timestamp);
    event setSlotieNFTEvent(address indexed slotieNFT);

    event setSlotieIssuanceRateEvent(uint256 indexed issuanceRate);
    event setSlotieIssuancePeriodEvent(uint256 indexed issuancePeriod);
    event setSlotieClaimStartEvent(uint256 indexed slotieClaimStart);
    event setSlotieEarnPeriodEvent(uint256 indexed slotieEarnPeriod);
    event setSlotieClaimEndTimeEvent(uint256 indexed slotieClaimEndTime);

    event setSlotiePreClaimMerkleProofEvent(bytes32 indexed slotiePreClaimMerkleProof);
    event setSlotieEHRMerkleProofEvent(bytes32 indexed slotieEHRMerkleProof);


    /** === SLOTIE JR. === */

    /** CLAIMING */
    uint256 public slotieJrIssuanceRate = 10 * 10**18; // 10 per day
    uint256 public slotieJrIssuancePeriod = 1 days;
    //uint256 public slotieJrClaimStart = 1644620400;
    uint256 public slotieJrDeployTime; // will be set as soon as slotie jr is deployed
    uint256 public slotieJrEarnPeriod = lockPeriod; // earn period is 3 months
    uint256 public slotieJrClaimEndTime;
    mapping(address => uint256) slotieJrAddressToLastClaimedTimeStamp;

    /**  GIVEAWAYS */    
    bytes32 public slotieJrEHRMerkleProof = "";
    mapping(address => uint256) public slotieJrAddressToEHRNonce; // safeguard against reusing proofs attack

    /** EVENTS */
    event ClaimedRewardFromSlotieJr(address indexed user, uint256 reward, uint256 timestamp);
    event setSlotieJrNFTEvent(address indexed slotieJrNFT);

    event setSlotieJrIssuanceRateEvent(uint256 indexed issuanceRate);
    event setSlotieJrIssuancePeriodEvent(uint256 indexed issuancePeriod);
    //event setSlotieJrClaimStart(uint256 indexed slotieJrClaimStart);
    event setSlotieJrDeployTimeEvent(uint256 indexed slotieJrDeployTime);
    event setSlotieJrEarnPeriodEvent(uint256 indexed slotieJrEarnPeriod);
    event setSlotieJrClaimEndTimeEvent(uint256 indexed slotieJrClaimEndTime);

    event setSlotieJrEHRMerkleProofEvent(bytes32 indexed slotieEHRMerkleProof);

    /** ANTI BOT */
    uint256 public blackListPeriod = 15 minutes;
    uint256 public blackListPeriodStart;
    mapping(address => bool) public isBlackListed;
    mapping(address=> bool) public isDex;

    /** MODIFIERS */
    modifier slotieCanClaim() {
        require(slotieNFT.balanceOf(msg.sender) > 0, "NOT A SLOTIE HOLDER");
        require(block.timestamp >= slotieClaimStart, "SLOTIE CLAIM LOCKED");
        require(address(slotieNFT) != address(0), "SLOTIE NFT NOT SET");
        _;
    }

    modifier slotieJrCanClaim() {
        require(slotieJrNFT.balanceOf(msg.sender) > 0, "NOT A SLOTIE JR HOLDER");
        require(address(slotieJrNFT) != address(0), "SLOTIE JR NFT NOT SET");
        _;
    }

    modifier notBlackListed(address from) {
        require(!isBlackListed[from], "ACCOUNT BLACKLISTED");
        _;
    }

    constructor(
        address _slotieNFT
    ) ERC20("WATTS", "$WATTS") Ownable() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
        slotieNFT = IERC721(_slotieNFT);
    }

    /** OVERRIDE ERC-20 */
    function balanceOf(address account) public view override returns (uint256) {
        return super.balanceOf(account) + _claimableBalances[account];
    }

    function totalSupply() public view override returns (uint256) {
        return super.totalSupply() + _claimableTotalSupply;
    }

    /** CLAIMING */
    function _slotieClaim(address recipient, uint256 preClaimAmount, uint256 ehrAmount, uint256 nonce, bytes32[] memory preClaimProof, bytes32[] memory ehrProof) internal {
        uint256 preClaimApplicable;
        uint256 ehrApplicable;

        if (preClaimProof.length > 0 && preClaimAmount != 0) {
            bytes32 leaf = keccak256(abi.encodePacked(recipient, preClaimAmount));
            require(MerkleProof.verify(preClaimProof, slotiePreClaimMerkleProof, leaf), "SLOTIE INVALID PRE CLAIM PROOF");
            require(slotieAddressToPreClaim[recipient] == 0, "SLOTIE PRE CLAIM ALREADY DONE");
            slotieAddressToPreClaim[recipient] = 1;
            preClaimApplicable = 1;
        } 
        
        if (ehrProof.length > 0 && ehrAmount != 0) {
            bytes32 leaf = keccak256(abi.encodePacked(recipient, ehrAmount, nonce));
            require(nonce == slotieAddressToEHRNonce[recipient], "SLOTIE INCORRECT NONCE");
            require(MerkleProof.verify(ehrProof, slotieEHRMerkleProof, leaf), "SLOTIE INVALID EHR PROOF");
            slotieAddressToEHRNonce[recipient] = slotieAddressToEHRNonce[recipient] + 1;
            ehrApplicable = 1;
        }

        uint256 balance = slotieNFT.balanceOf(recipient);
        uint256 lastClaimed = slotieAddressToLastClaimedTimeStamp[recipient];  
        uint256 accumulatedWatts = slotieAddressToAccumulatedWATTs[recipient];
        uint256 currentTime = block.timestamp;

        if (currentTime >= slotieClaimEndTime) {
            currentTime = slotieClaimEndTime; // we can only claim up to slotieClaimEndTime
        }

        if (deployedTime > lastClaimed) {
            lastClaimed = deployedTime; // we start from time of deployment
        } else if (lastClaimed == slotieClaimEndTime) {
            lastClaimed = currentTime; // if we claimed all we set reward to zero
        }
        
        uint256 reward = (currentTime - lastClaimed) * slotieIssuanceRate * balance / slotieIssuancePeriod;

        if (currentTime >= slotieClaimStart && accumulatedWatts != 0) {
            reward = reward + accumulatedWatts;
            delete slotieAddressToAccumulatedWATTs[recipient];
        }

        if (preClaimApplicable != 0) {
            reward = reward + preClaimAmount;
        }

        if (ehrApplicable != 0) {
            reward = reward + ehrAmount;
        }

        slotieAddressToLastClaimedTimeStamp[recipient] = currentTime;
        if (reward > 0) {            
            if (currentTime < slotieClaimStart) {
                slotieAddressToAccumulatedWATTs[recipient] = slotieAddressToAccumulatedWATTs[recipient] + reward;
                emit AccumulatedRewardFromSlotie(recipient, reward, currentTime);
            } else {
                _mintClaimable(recipient, reward);
                emit ClaimedRewardFromSlotie(recipient, reward, currentTime);
            }
        }            
    }    

    function _slotieJrClaim(address recipient, uint256 giftAmount, uint256 nonce, bytes32[] memory proof) internal {
        uint256 giftApplicable;
        if (proof.length > 0) {
            bytes32 leaf = keccak256(abi.encodePacked(recipient, giftAmount, nonce));
            require(nonce == slotieJrAddressToEHRNonce[recipient], "SLOTIE JR INCORRECT NONCE");
            require(MerkleProof.verify(proof, slotieJrEHRMerkleProof, leaf), "SLOTIE JR INVALID EHR PROOF");
            slotieJrAddressToEHRNonce[recipient] = slotieJrAddressToEHRNonce[recipient] + 1;
            giftApplicable = 1;
        }

        uint256 balance = slotieJrNFT.balanceOf(recipient);
        uint256 lastClaimed = slotieJrAddressToLastClaimedTimeStamp[recipient];
        uint256 currentTime = block.timestamp;

        if (currentTime >= slotieJrClaimEndTime) {
            currentTime = slotieJrClaimEndTime; // we can only claim up to slotieJrClaimEndTime
        }

        if (slotieJrDeployTime > lastClaimed) {
            lastClaimed = slotieJrDeployTime; // we start from time of deployment
        } else if (lastClaimed == slotieJrClaimEndTime) {
            lastClaimed = currentTime; // if we claimed all we set reward to zero
        }
        
        uint256 reward = (currentTime - lastClaimed) * slotieJrIssuanceRate * balance / slotieJrIssuancePeriod;

        if (giftApplicable != 0) {
            reward = reward + giftApplicable;
        }

        slotieJrAddressToLastClaimedTimeStamp[recipient] = currentTime;
        if (reward > 0) {
            _mintClaimable(recipient, reward);
            emit ClaimedRewardFromSlotieJr(recipient, reward, currentTime);
        }     
    }

    function slotieGetClaimableBalance(address recipient, uint256 preClaimAmount, uint256 ehrAmount, uint256 nonce, bytes32[] memory preClaimProof, bytes32[] memory ehrProof) external view returns (uint256) {
        require(address(slotieNFT) != address(0), "SLOTIE NFT NOT SET");

        uint256 preClaimApplicable;
        uint256 ehrApplicable;

        if (preClaimProof.length > 0 && preClaimAmount != 0) {
            bytes32 leaf = keccak256(abi.encodePacked(recipient, preClaimAmount));
            preClaimApplicable = MerkleProof.verify(preClaimProof, slotiePreClaimMerkleProof, leaf) && slotieAddressToPreClaim[recipient] == 0 ? 1 : 0;
        } 
        
        if (ehrProof.length > 0 && ehrAmount != 0) {
            bytes32 leaf = keccak256(abi.encodePacked(recipient, ehrAmount, nonce));
            ehrApplicable = MerkleProof.verify(ehrProof, slotieEHRMerkleProof, leaf) && nonce == slotieAddressToEHRNonce[recipient] ? 1 : 0;
        }

        uint256 balance = slotieNFT.balanceOf(recipient);
        uint256 lastClaimed = slotieAddressToLastClaimedTimeStamp[recipient];  
        uint256 accumulatedWatts = slotieAddressToAccumulatedWATTs[recipient];
        uint256 currentTime = block.timestamp;

        if (currentTime >= slotieClaimEndTime) {
            currentTime = slotieClaimEndTime;
        }

        if (deployedTime > lastClaimed) {
            lastClaimed = deployedTime;
        } else if (lastClaimed == slotieClaimEndTime) {
            lastClaimed = currentTime;
        }
        
        uint256 reward = (currentTime - lastClaimed) * slotieIssuanceRate * balance / slotieIssuancePeriod;

        if (accumulatedWatts != 0) {
            reward = reward + accumulatedWatts;
        }

        if (preClaimApplicable != 0) {
            reward = reward + preClaimAmount;
        }

        if (ehrApplicable != 0) {
            reward = reward + ehrAmount;
        }

        return reward;
    }

    function slotieJrGetClaimableBalance(address recipient, uint256 giftAmount, uint256 nonce, bytes32[] memory proof) external view returns (uint256) {
        require(address(slotieJrNFT) != address(0), "SLOTIE JR NFT NOT SET");

        uint256 giftApplicable;
        if (proof.length > 0) {
            bytes32 leaf = keccak256(abi.encodePacked(recipient, giftAmount, nonce));
            giftApplicable = MerkleProof.verify(proof, slotieJrEHRMerkleProof, leaf) && nonce == slotieJrAddressToEHRNonce[recipient] ? 1 : 0;
        }

        uint256 balance = slotieJrNFT.balanceOf(recipient);
        uint256 lastClaimed = slotieJrAddressToLastClaimedTimeStamp[recipient];
        uint256 currentTime = block.timestamp;

        if (currentTime >= slotieJrClaimEndTime) {
            currentTime = slotieJrClaimEndTime;
        }

        if (slotieJrDeployTime > lastClaimed) {
            lastClaimed = slotieJrDeployTime;
        } else if (lastClaimed == slotieJrClaimEndTime) {
            lastClaimed = currentTime;
        }
        
        uint256 reward = (currentTime - lastClaimed) * slotieJrIssuanceRate * balance / slotieJrIssuancePeriod;

        if (giftApplicable != 0) {
            reward = reward + giftApplicable;
        }

        return reward;
    }

    function slotieClaim(uint256 preClaimAmount, uint256 ehrAmount, uint256 nonce, bytes32[] memory preClaimProof, bytes32[] memory ehrProof) external slotieCanClaim {
        _slotieClaim(msg.sender, preClaimAmount, ehrAmount, nonce, preClaimProof, ehrProof);
    }

    function slotieJrClaim(uint256 giftAmount, uint256 nonce, bytes32[] calldata proof) external slotieJrCanClaim {
        _slotieJrClaim(msg.sender, giftAmount, nonce, proof);
    }

    function updateReward(address from, address to) external {
        require(msg.sender == address(slotieNFT), "ONLY CALLABLE FROM SLOTIE");
        bytes32[] memory empty;

        if (from != address(0)) {
            _slotieClaim(from, 0, 0, 0, empty, empty);
        }

        if (to != address(0)) {
            _slotieClaim(to, 0, 0, 0, empty, empty);
        }
    }

    function slotieJrUpdateReward(address from, address to) external {
        require(msg.sender == address(slotieJrNFT), "ONLY CALLABLE FROM SLOTIE JR");
        bytes32[] memory empty;

        if (from != address(0)) {
            _slotieJrClaim(from, 0, 0, empty);
        }
        
        if (to != address(0)) {
            _slotieJrClaim(to, 0, 0, empty);
        }
    }

    /** TRANSFERS */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override notBlackListed(from) {
        if (from != address(0)) {
            uint256 claimableBalanceSender = _claimableBalances[from];
            if (block.timestamp >= deployedTime + lockPeriod && claimableBalanceSender != 0) {
                _burnClaimable(from, claimableBalanceSender);
                _mint(from, claimableBalanceSender);
            }
        }

        super._beforeTokenTransfer(from, to, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override notBlackListed(sender) notBlackListed(recipient) {
        if(
            block.timestamp >= blackListPeriodStart && 
            block.timestamp < blackListPeriodStart + blackListPeriod && 
           !isDex[recipient] &&
           recipient != address(0)) {
            isBlackListed[recipient] = true; // black list buyers that are not dex and buy in blacklist period
        } else {
            super._transfer(sender, recipient, amount);
        }
    }

    /** VIEW */
    function seeClaimableBalanceOfUser(address user) external view onlyOwner returns(uint256) {
        return _claimableBalances[user];
    }

    function seeClaimableTotalSupply() external view onlyOwner returns(uint256) {
        return _claimableTotalSupply;
    }

    /** ROLE BASED */    
    function mint(address _to, uint256 _amount) public onlyRole(MINTER_ROLE) {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyRole(BURNER_ROLE) {
        _burn(_from, _amount);
    }

    function _mintClaimable(address _to, uint256 _amount) internal {
        require(_to != address(0), "ERC20-claimable: mint to the zero address");

        _claimableBalances[_to] += _amount;
        _claimableTotalSupply += _amount;
    }

    function mintClaimable(address _to, uint256 _amount) public onlyRole(MINTER_ROLE) {
        _mintClaimable(_to, _amount);
    }

    function _burnClaimable(address _from, uint256 _amount) internal {
        require(_from != address(0), "ERC20-claimable: burn from the zero address");

        uint256 accountBalance = _claimableBalances[_from];
        require(accountBalance >= _amount, "ERC20-claimable: burn amount exceeds balance");
        unchecked {
            _claimableBalances[_from] = accountBalance - _amount;
        }
        _claimableTotalSupply -= _amount;
    }

    function burnClaimable(address _from, uint256 _amount) public onlyRole(BURNER_ROLE) {
        _burnClaimable(_from,  _amount);
    }


    /** OWNER */
    function setSlotieNFT(address newSlotieNFT) external onlyOwner {
        slotieNFT = IERC721(newSlotieNFT);
        emit setSlotieNFTEvent(newSlotieNFT);
    }

    function setSlotieJrNFT(address newSlotieJrNFT) external onlyOwner {
        slotieJrNFT = IERC721(newSlotieJrNFT);
        emit setSlotieJrNFTEvent(newSlotieJrNFT);
    }

    function setDeployTime(uint256 newDeployTime) external onlyOwner {
        deployedTime = newDeployTime;
        emit setDeployTimeEvent(newDeployTime);
    }

    function setLockPeriod(uint256 newLockPeriod) external onlyOwner {
        lockPeriod = newLockPeriod;
        emit setLockPeriodEvent(newLockPeriod);
    }

    /** Slotie Claim variables */
    function setSlotieIssuanceRate(uint256 newSlotieIssuanceRate) external onlyOwner {
        slotieIssuanceRate = newSlotieIssuanceRate;
        emit setSlotieIssuanceRateEvent(newSlotieIssuanceRate);
    }

    function setSlotieIssuancePeriod(uint256 newSlotieIssuancePeriod) external onlyOwner {
        slotieIssuancePeriod = newSlotieIssuancePeriod;
        emit setSlotieIssuancePeriodEvent(newSlotieIssuancePeriod);
    }

    function setSlotieClaimStart(uint256 newSlotieClaimStart) external onlyOwner {
        slotieClaimStart = newSlotieClaimStart;
        emit setSlotieClaimStartEvent(newSlotieClaimStart);
    }

    function setSlotieEarnPeriod(uint256 newSlotieEarnPeriod) external onlyOwner {
        slotieEarnPeriod = newSlotieEarnPeriod;       
        emit setSlotieEarnPeriodEvent(newSlotieEarnPeriod);
    }

    function setSlotieClaimEndTime(uint256 newSlotieClaimEndTime) external onlyOwner {
        slotieClaimEndTime = newSlotieClaimEndTime;
        emit setSlotieClaimEndTimeEvent(newSlotieClaimEndTime);
    }

    function setSlotiePreClaimMerkleProof(bytes32 newSlotiePreClaimMerkleProof) external onlyOwner {
        slotiePreClaimMerkleProof = newSlotiePreClaimMerkleProof;
        emit setSlotiePreClaimMerkleProofEvent(newSlotiePreClaimMerkleProof);
    }

    function setSlotieEHRMerkleProof(bytes32 newSlotieEHRMerkleProof) external onlyOwner {
        slotieEHRMerkleProof = newSlotieEHRMerkleProof;
        emit setSlotieEHRMerkleProofEvent(newSlotieEHRMerkleProof);
    }

    function setSlotieDeployTimeAndClaimEndTime(uint256 newDeployTime, uint256 newSlotieClaimEndTime) external onlyOwner {
        deployedTime = newDeployTime;
        slotieClaimEndTime = newSlotieClaimEndTime;
        emit setDeployTimeEvent(newDeployTime);
        emit setSlotieClaimEndTimeEvent(newSlotieClaimEndTime);
    }

    /** Slotie Jr. Claim variables */
    function setSlotieJrIssuanceRate(uint256 newSlotieJrIssuanceRate) external onlyOwner {
        slotieJrIssuanceRate = newSlotieJrIssuanceRate;
        emit setSlotieJrIssuanceRateEvent(newSlotieJrIssuanceRate);
    }

    function setSlotieJrIssuancePeriod(uint256 newSlotieJrIssuancePeriod) external onlyOwner {
        slotieJrIssuancePeriod = newSlotieJrIssuancePeriod;
        emit setSlotieJrIssuancePeriodEvent(newSlotieJrIssuancePeriod);
    }

    function setSlotieJrDeployTime(uint256 newSlotieJrDeployTime) external onlyOwner {
        slotieJrDeployTime = newSlotieJrDeployTime;
        emit setSlotieJrDeployTimeEvent(newSlotieJrDeployTime);
    }

    function setSlotieJrEarnPeriod(uint256 newSlotieJrEarnPeriod) external onlyOwner {
        slotieJrEarnPeriod = newSlotieJrEarnPeriod;
        emit setSlotieJrEarnPeriodEvent(newSlotieJrEarnPeriod);
    }

    function setSlotieJrClaimEndTime(uint256 newSlotieJrClaimEndTime) external onlyOwner {
        slotieJrClaimEndTime = newSlotieJrClaimEndTime;
        emit setSlotieJrClaimEndTimeEvent(newSlotieJrClaimEndTime);
    }

    function setSlotieJrEHRMerkleProof(bytes32 newSlotieJrEHRMerkleProof) external onlyOwner {
        slotieJrEHRMerkleProof = newSlotieJrEHRMerkleProof;
        emit setSlotieJrEHRMerkleProofEvent(newSlotieJrEHRMerkleProof);
    }

    function setSlotieJrDeployTimeAndClaimEndTime(uint256 newSlotieJrDeployTime, uint256 newSlotieJrClaimEndTime) external onlyOwner {
        slotieJrDeployTime = newSlotieJrDeployTime;        
        slotieJrClaimEndTime = newSlotieJrClaimEndTime;
        emit setSlotieJrDeployTimeEvent(newSlotieJrDeployTime);
        emit setSlotieJrClaimEndTimeEvent(newSlotieJrClaimEndTime);
    }

    /** ANTI SNIPE */
    function setBlackListPeriodStart(uint256 newBlackListPeriodStart) external onlyOwner {
        blackListPeriodStart = newBlackListPeriodStart;
    }

    function setBlackListPeriod(uint256 newBlackListPeriod) external onlyOwner {
        blackListPeriod = newBlackListPeriod;
    }

    function setIsBlackListed(address _address, bool _isBlackListed) external onlyOwner {
        isBlackListed[_address] = _isBlackListed;
    }

    function setIsDex(address _address, bool _isDex) external onlyOwner {
        isDex[_address] = _isDex;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}