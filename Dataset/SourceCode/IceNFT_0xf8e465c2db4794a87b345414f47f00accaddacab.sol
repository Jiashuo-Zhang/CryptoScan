// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract IceNFT is ERC721, AccessControl, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using Counters for Counters.Counter;
  Counters.Counter public _tokenIds;

  enum NFTCardType {
    WEEK,
    MONTH,
    QUARTER,
    HALFYEAR,
    YEAR,
    LIFETIME
  }

  /// @dev deployer: default admin, grant roles
  /// @param _fundManager: manage the fund
  /// @param operator: manage the NFT
  constructor(address operator, address _fundManager) ERC721("Ice NFT", "ICE") {
    require(operator != address(0), "IceNFT: operator is the zero address");
    require(_fundManager != address(0), "IceNFT: fund manager is the zero address");
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(FUND_MANAGER_ROLE, _fundManager);
    _grantRole(OPERATOR_ROLE, operator);
    mintState = false;
    saveFlag = true;
    claimState = false;
    fundManager = _fundManager;
    lifetimeCardMaxSupply = 10000;
  }

  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
  bytes32 public constant FUND_MANAGER_ROLE = keccak256("FUND_MANAGER_ROLE");

  mapping(address => bool) private blackList;

  mapping(NFTCardType => uint256) public usdPrice;
  mapping(NFTCardType => uint256) public ethPrice;
  mapping(NFTCardType => string) public cardTypeDefaultURI;
  mapping(uint256 => NFTCardType) public cardTypeOfTokenId;
  uint256 public lifetimeCardMaxSupply;
  uint256 public lifetimeCardCurrentSupply;
  address public usdToken; // usdt/usdc/...
  bool public mintState;
  bool public saveFlag;
  bool public claimState;
  bool private transferFlag;
  address public fundManager;

  // whitelist mint
  bool public whitelistMintState;
  bytes32 public whitelistMintMerkleRoot;
  NFTCardType public whitelistMintCardType;
  mapping(address => bool) public whitelistMintClaimed;
  // free mint
  uint256 public freeMintSupply;
  NFTCardType public freeMintCardType;
  bool public freeMintState;
  mapping(address => bool) public freeMintClaimed;

  mapping(address => uint256) public referralRewardEthAmount;
  mapping(address => uint256) public referralRewardUsdAmount;

  /// @dev mapping of users' address and their upline address,
  /// which means the value address that referred the key address.
  /// user should be invited by unique upline address,
  /// and user can invite many other addresses.
  mapping(address => address) public usersUpline;

  /// @dev mapping of users' address and their downlines' address,
  /// user may have invite many other addresses, so we use array to store them.
  /// And a counter to help us get the length of the array.
  mapping(address => address[]) public usersDownlines;

  /// @dev default reward rate is 20% for upline and 10% for upUpline
  uint8 public uplineRewardRate = 20;
  uint8 public upUplineRewardRate = 10;

  event SetRelationship(address indexed user, address indexed upline, address indexed upUpline);
  event Burn(uint256 tokenId);
  event Mint(address indexed to, NFTCardType indexed cardType, uint256 tokenId, string currency, uint256 price);
  event AllocateReward(address indexed user1, uint256 amount1, address indexed user2, uint256 amount2, string currency);
  event ClaimReward(address indexed user, uint256 amount, string currency);
  event Airdrop(address indexed to, NFTCardType indexed cardType, uint256 tokenId);

  modifier notBlackListed() {
    require(!blackList[msg.sender], "You are blacklisted");
    _;
  }

  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not admin");
    _;
  }

  modifier onlyOperator() {
    require(hasRole(OPERATOR_ROLE, msg.sender), "Caller is not operator");
    _;
  }

  modifier onlyFundManager() {
    require(hasRole(FUND_MANAGER_ROLE, msg.sender), "Caller is not fund manager");
    _;
  }

  function addFundManagerRole(address _fundManager) external onlyAdmin {
    _grantRole(FUND_MANAGER_ROLE, _fundManager);
  }

  function removeFundManagerRole(address _fundManager) external onlyAdmin {
    revokeRole(FUND_MANAGER_ROLE, _fundManager);
  }

  function addOperatorRole(address operator) external onlyAdmin {
    _grantRole(OPERATOR_ROLE, operator);
  }

  function removeOperatorRole(address operator) external onlyAdmin {
    revokeRole(OPERATOR_ROLE, operator);
  }

  function transferOwnership(address newOwner) external onlyAdmin {
    grantRole(DEFAULT_ADMIN_ROLE, newOwner);
    revokeRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  function addBlackList(address a) external onlyOperator {
    blackList[a] = true;
  }

  function removeBlackList(address a) external onlyOperator {
    blackList[a] = false;
  }

  function setDefaultTokenURI(NFTCardType cardtype, string memory _tokenURI) external onlyOperator {
    cardTypeDefaultURI[cardtype] = _tokenURI;
  }

  function setEthPrice(NFTCardType cardType, uint256 price) external onlyOperator {
    ethPrice[cardType] = price;
  }

  function setUsdPrice(NFTCardType cardType, uint256 price) external onlyOperator {
    usdPrice[cardType] = price;
  }

  function setUsdTokenAddress(address _address) external onlyOperator {
    usdToken = _address;
  }

  function setFundManagerAddress(address _address) external onlyAdmin {
    fundManager = _address;
  }

  function setLifetimeCardMaxSupply(uint256 maxSupply) external onlyOperator {
    lifetimeCardMaxSupply = maxSupply;
  }

  function setWhitelistMerkleRoot(bytes32 _merkleRoot) external onlyOperator {
    whitelistMintMerkleRoot = _merkleRoot;
  }

  function setWhitelistMintCardType(NFTCardType _cardType) external onlyOperator {
    whitelistMintCardType = _cardType;
  }

  function setFreeMintSupply(uint256 _supply, NFTCardType _cardType) external onlyOperator {
    freeMintCardType = _cardType;
    freeMintSupply = _supply;
  }

  function airDrop(address to, NFTCardType cardType) external onlyOperator {
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    _safeMint(to, tokenId);
    emit Airdrop(to, cardType, tokenId);
    cardTypeOfTokenId[tokenId] = cardType;
  }

  function burn(uint256 tokenId) external onlyOperator {
    _burn(tokenId);
    emit Burn(tokenId);
  }

  function flipMintState() external onlyOperator {
    require(usdToken != address(0), "USD Token address haven't set");
    mintState = !mintState;
  }

  function flipWhitelistMintState() external onlyOperator {
    require(whitelistMintMerkleRoot != bytes32(0), "Merkle root haven't set");
    whitelistMintState = !whitelistMintState;
  }

  function flipFreeMintState() external onlyOperator {
    freeMintState = !freeMintState;
  }

  function flipSaveState() external onlyOperator {
    saveFlag = !saveFlag;
  }

  function flipClaimState() external onlyOperator {
    claimState = !claimState;
  }

  function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
    return cardTypeDefaultURI[cardTypeOfTokenId[tokenId]];
  }

  function whitelistMint(bytes32[] calldata merkleProof) external payable {
    require(whitelistMintState, "Free mint haven't started");
    require(!whitelistMintClaimed[msg.sender], "Free mint already claimed");
    require(
      MerkleProof.verify(merkleProof, whitelistMintMerkleRoot, keccak256(abi.encodePacked(msg.sender))),
      "Invalid merkle proof"
    );

    if (whitelistMintCardType == NFTCardType.LIFETIME) {
      require(lifetimeCardMaxSupply >= lifetimeCardCurrentSupply, "Lifetime card sold out");
    }

    whitelistMintClaimed[msg.sender] = true;
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    transferFlag = true;
    _safeMint(msg.sender, tokenId);
    emit Mint(msg.sender, whitelistMintCardType, tokenId, "eth", 0);
    cardTypeOfTokenId[tokenId] = whitelistMintCardType;
    transferFlag = false;

    if (whitelistMintCardType == NFTCardType.LIFETIME) {
      lifetimeCardCurrentSupply++;
    }
  }

  function freeMint() external payable {
    require(freeMintState, "Free mint haven't started");
    require(freeMintSupply > 0, "Free mint supply is zero");
    require(!freeMintClaimed[msg.sender], "Free mint already claimed");

    if (freeMintCardType == NFTCardType.LIFETIME) {
      require(lifetimeCardMaxSupply >= lifetimeCardCurrentSupply, "Lifetime card sold out");
    }

    freeMintClaimed[msg.sender] = true;
    freeMintSupply--;
    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    transferFlag = true;
    _safeMint(msg.sender, tokenId);
    emit Mint(msg.sender, freeMintCardType, tokenId, "eth", 0);
    cardTypeOfTokenId[tokenId] = freeMintCardType;
    transferFlag = false;

    if (freeMintCardType == NFTCardType.LIFETIME) {
      lifetimeCardCurrentSupply++;
    }
  }

  /// @dev mint NFT with ETH
  /// @param cardType NFT available duration
  /// @param referredBy referral address, only provide in the first time mint,
  ///   if no referral or have set referral relationship, set address(0) or caller's address
  /// @notice require mint state is true
  /// @notice require ETH sell price is not zero
  /// @notice if card type is lifetime, require lifetime card max supply is not reached
  /// @notice if card type is not lifetime, token can't transfer after mint
  function mint(NFTCardType cardType, address referredBy) external payable nonReentrant notBlackListed {
    require(mintState, "Mint haven't started");
    require(ethPrice[cardType] != 0, "ETH price haven't set");
    require(msg.value >= ethPrice[cardType], "Ether value sent is not correct");
    if (cardType == NFTCardType.LIFETIME) {
      require(lifetimeCardMaxSupply >= lifetimeCardCurrentSupply, "Lifetime card sold out");
    }

    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    transferFlag = true;
    _safeMint(msg.sender, tokenId);
    emit Mint(msg.sender, cardType, tokenId, "eth", ethPrice[cardType]);
    cardTypeOfTokenId[tokenId] = cardType;
    transferFlag = false;

    if (cardType == NFTCardType.LIFETIME) {
      lifetimeCardCurrentSupply++;
    }

    if (referredBy != address(0) && referredBy != msg.sender) {
      (address upline, ) = getReferralRelationship(msg.sender);
      if (upline == address(0)) {
        // only set referral relationship when user haven't had one
        setReferralRelationship(msg.sender, referredBy);
      }
    }
    _allocateEthReward(msg.value);
  }

  /// @dev mint NFT with USD
  /// @param cardType NFT available duration
  /// @param referredBy referral address, only provide in the first time mint,
  ///   if no referral or have set referral relationship, set address(0) or caller's address
  /// @param amount USD amount to pay for
  /// @notice require mint state is true
  /// @notice require USD token address is set
  /// @notice require USD sell price is not zero
  /// @notice if card type is lifetime, require lifetime card max supply is not reached
  /// @notice if card type is not lifetime, token can't transfer after mint
  function mintWithUsd(NFTCardType cardType, address referredBy, uint256 amount) external nonReentrant notBlackListed {
    require(mintState, "Mint haven't started");
    require(usdToken != address(0), "USD token address is not set");
    require(usdPrice[cardType] != 0, "USD price haven't set");
    require(amount >= usdPrice[cardType], "USD value sent is not correct");
    if (cardType == NFTCardType.LIFETIME) {
      require(lifetimeCardMaxSupply >= lifetimeCardCurrentSupply, "Lifetime card sold out");
    }

    IERC20(usdToken).safeTransferFrom(msg.sender, address(this), amount);

    _tokenIds.increment();
    uint256 tokenId = _tokenIds.current();
    transferFlag = true;
    _safeMint(msg.sender, tokenId);
    emit Mint(msg.sender, cardType, tokenId, "usd", usdPrice[cardType]);
    cardTypeOfTokenId[tokenId] = cardType;
    transferFlag = false;
    if (cardType == NFTCardType.LIFETIME) {
      lifetimeCardCurrentSupply++;
    }

    if (referredBy != address(0) && referredBy != msg.sender) {
      (address upline, ) = getReferralRelationship(msg.sender);
      if (upline == address(0)) {
        // only set referral relationship when user haven't had one
        setReferralRelationship(msg.sender, referredBy);
      }
    }
    _allocateERC20Reward(usdToken, amount);
  }

  function _allocateEthReward(uint256 amount) internal {
    (address upline, address upUpline) = getReferralRelationship(msg.sender);

    uint256 remains = 0;
    uint256 uplineReward = 0;
    uint256 upUplineReward = 0;
    if (upline != address(0)) {
      uplineReward = (amount * uplineRewardRate) / 100;
      referralRewardEthAmount[upline] += uplineReward;
      remains += uplineReward;
    }

    if (upUpline != address(0)) {
      upUplineReward = (amount * upUplineRewardRate) / 100;
      referralRewardEthAmount[upUpline] += upUplineReward;
      remains += upUplineReward;
    }

    emit AllocateReward(upline, uplineReward, upUpline, upUplineReward, "eth");

    if (saveFlag) {
      (bool success, ) = payable(fundManager).call{value: msg.value - remains}("");
      require(success, "Transfer to fund mananger address failed");
    }
  }

  function _allocateERC20Reward(address token, uint256 amount) internal {
    (address upline, address upUpline) = getReferralRelationship(msg.sender);
    uint256 remains = 0;
    uint256 uplineReward = 0;
    uint256 upUplinReward = 0;
    if (upline != address(0)) {
      uplineReward = (amount * uplineRewardRate) / 100;
      referralRewardUsdAmount[upline] += uplineReward;
      remains += uplineReward;
    }

    if (upUpline != address(0)) {
      upUplinReward = (amount * upUplineRewardRate) / 100;
      referralRewardUsdAmount[upUpline] += upUplinReward;
      remains += upUplinReward;
    }

    emit AllocateReward(upline, uplineReward, upUpline, upUplinReward, "usd");

    if (saveFlag) {
      IERC20(token).safeTransfer(fundManager, amount - remains);
    }
  }

  function setReferralRelationship(address user, address referredBy) internal {
    require(user != address(0), "Referral: user is zero address");
    require(referredBy != address(0), "Referral: referredBy is zero address");

    // check if user's upline is already set
    require(usersUpline[user] == address(0), "Referral: user's upline is already set");

    // check if cycle referral
    require(usersUpline[referredBy] != user, "Referral: cycle referral");

    // find upline's upline(referrer's referrer)
    address upUpline = usersUpline[referredBy];

    // set relationship
    usersUpline[user] = referredBy;
    usersDownlines[referredBy].push(user);

    emit SetRelationship(user, referredBy, upUpline);
  }

  function getReferralRelationship(address user) public view returns (address, address) {
    return (usersUpline[user], usersUpline[usersUpline[user]]);
  }

  function getReferralCount(address user) external view returns (uint256) {
    return (usersDownlines[user].length);
  }

  function setRewardRate(uint8 upline, uint8 upUpline) external onlyOperator {
    require(upline <= 100, "Referral: upline reward rate is over 100%");
    require(upUpline <= 100, "Referral: upline's upline reward rate is over 100%");

    uplineRewardRate = upline;
    upUplineRewardRate = upUpline;
  }

  function claimEthReward() external nonReentrant {
    require(claimState, "Claim haven't started");
    require(referralRewardEthAmount[msg.sender] > 0, "No reward to claim");
    require(address(this).balance >= referralRewardEthAmount[msg.sender], "Balance insufficient for reward");
    uint256 amount = referralRewardEthAmount[msg.sender];
    referralRewardEthAmount[msg.sender] = 0;

    (bool success, ) = payable(msg.sender).call{value: amount}("");
    require(success, "Transfer to fund mananger address failed");
    emit ClaimReward(msg.sender, amount, "eth");
  }

  function claimUsdReward() external nonReentrant {
    require(claimState, "Claim haven't started");
    require(referralRewardUsdAmount[msg.sender] > 0, "No reward to claim");
    require(
      IERC20(usdToken).balanceOf(address(this)) >= referralRewardUsdAmount[msg.sender],
      "Balance insufficient for reward"
    );

    uint256 amount = referralRewardUsdAmount[msg.sender];
    referralRewardUsdAmount[msg.sender] = 0;
    IERC20(usdToken).safeTransfer(msg.sender, amount);
    emit ClaimReward(msg.sender, amount, "usd");
  }

  function withdrawEth(address payable to, uint256 amount) external onlyFundManager {
    require(amount <= address(this).balance, "Not enough balance");
    (bool success, ) = to.call{value: amount}("");
    require(success, "Transfer to fund mananger address failed");
  }

  function withdrawERC20Token(address token, address to, uint256 amount) external onlyFundManager {
    require(amount <= IERC20(token).balanceOf(address(this)), "Not enough balance");
    IERC20(token).safeTransfer(to, amount);
  }

  function _burn(uint256 tokenId) internal override(ERC721) {
    super._burn(tokenId);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 firstTokenId,
    uint256 batchSize
  ) internal override(ERC721) {
    require(transferFlag || cardTypeOfTokenId[firstTokenId] == NFTCardType.LIFETIME, "Token is not transferable");
    super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}