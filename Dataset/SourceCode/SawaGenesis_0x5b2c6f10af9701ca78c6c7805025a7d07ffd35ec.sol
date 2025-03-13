// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/*
                                                                                                             :YY?~   :?~                              
                                                                                                              ?&&#GY:7&#P!                            
                                                                                                               ?&##&!?&#&&P~                          
                                                                                                                G##&77&###&#7                         
                                                                                                          :     ?&#575#######^                        
            :7JJJY5J:       ^7JY55?^     :7??????7~  :7???????7:   ^7?????7:    :7JY55?^               !5GBBGJ^ ?#7?#&######&J                        
           ?&5^::^J@J     !G5~^^!P@@5     ^!P@@@J^:   ^~J&@@&~^    :^^G@P!^   ~PP!^:~Y@@P:           :G&BP###&#JG77&########&7            :           
          ^@@?     77    Y#P:     G@@7       J@@G        ^@@@7        #J     J#G~     5@@J           P&#P!G####&#~5&#######&P           ~P5           
          :B@@G?^        ^        P@@?        Y@@G       55#@@!      B5      ^        J@@5         ^YBB#&&########G########P:       :~JG&B^           
            ?G@@@GJ^            :^G@@?         Y@@P     YP ^&@&^    PG              :^P@@5         :: :~Y#&###############Y^:^~!7J5GB#&&G:            
              ^?G@@@5:     ^7?JJ?!G@@?          5@@P   JG   !@@#:  5B          :!?JJ?!5@@5               ^5###############BB####&&&####P:             
           :     ~P@@5   ?B&Y~:   P@@?           P@@5 ?B     7@@B J#:        !B&5!:   J@@5                 !G&#########################BJ             
          ^B^      &@Y  ^@@#     ^B@@Y  :         P@@GB:      ?@@B#^         &@&:    :P@@P  :                7G&&#####################&G~             
           #&J~^^!5#J    5&@BY?JJ7J@@&5J7          G@&^        J@@!          J&@#Y?JJ7?@@@PY7                  !5B#&&&&&&&&#BG#&&####BJ               
           !~~!!7!~       :!??!^   ~7!^             !^          !~            :!7?!^   ~7!^                      :~?Y5PP5Y7~  :!YB&#&G                
                                                                                                                                 :?BBP:               
                                                                                                                                   ::                     
*/

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SawaGenesis is ERC721, IERC2981, Ownable, ReentrancyGuard {
  using Counters for Counters.Counter;
  using Strings for uint256;
  using ECDSA for bytes32;

  Counters.Counter private currentTokenId;

  string private baseURI;
  bool private allowlistMintPriceSet = false;
  bool private publicMintPriceSet = false;

  uint256 public constant MAX_ALLOWLIST_TOKENS_PER_WALLET = 10;
  uint256 collectionSize = 3333;

  uint256 public allowlistMintPrice;
  uint256 public publicMintPrice; 

  bool public isPublicSaleActive;
  bool public isAllowlistSaleActive;
  bool public isClaimActive;
  bool public isCrossmintActive;

  address public allowlistSigner;
  address public claimSigner;

  address public crossmintAddress;
  
  mapping(bytes => uint256) public allowlistMintCounts;
  mapping(bytes => bool) public claimUsed;

  // ============ MODIFIERS ============

  modifier publicSaleActive() {
    require(isPublicSaleActive, "Public sale is not open");
    _;
  }

  modifier allowlistSaleActive() {
    require(isAllowlistSaleActive, "Allowlist sale is not open");
    _;
  }

  modifier claimActive() {
    require(isClaimActive, "Claim period is not open");
    _;
  }

  modifier crossmintActive() {
    require(isCrossmintActive, "Crossmint payment is not open");
    _;
  }

  modifier requiresAllowlistMintPriceSet() {
    require(allowlistMintPriceSet, "Allowlist mint price was never set");
    _;
  }

  modifier requiresPublicMintPriceSet() {
    require(publicMintPriceSet, "Public mint price was never set");
    _;
  }

  modifier isSenderCrossmintAddress(address _addr) {
    require(_addr == crossmintAddress, "Only Crossmint can mint with this function");
    _;
  }

  modifier canMintTokens(uint256 numberOfTokensToAdd) {
    require(
      currentTokenId.current() + numberOfTokensToAdd <= collectionSize,
      "Not enough tokens remaining to mint"
    );
    _;
  }

  modifier allowlistSignatureVerified(address _addr, bytes calldata _signature) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19Ethereum Signed Message:\n32",
        keccak256(abi.encode(_addr))
      )
    );
    require(
      allowlistSigner == digest.recover(_signature),
      "Unable to verify allowlist signature"
    );
    _;
  }

  modifier claimSignatureVerified(address _addr, bytes calldata _signature) {
    bytes32 digest = keccak256(
      abi.encodePacked(
        "\x19Ethereum Signed Message:\n32",
        keccak256(abi.encode(_addr))
      )
    );
    require(
      claimSigner == digest.recover(_signature),
      "Unable to verify claim signature"
    );
    _;
  }

  modifier hasNotUsedClaim(bytes memory signature) {
    require(
      !claimUsed[signature],
      "Claim signature has already been used"
    );
    _;
  }

  modifier canMintAllowlistTokens(bytes memory signature, uint256 numberOfTokensToAdd) {
    uint256 allowlistTokensAlreadyMinted = allowlistMintCounts[signature];
    require(
      allowlistTokensAlreadyMinted + numberOfTokensToAdd <= MAX_ALLOWLIST_TOKENS_PER_WALLET,
      "Max allowlist tokens already minted to this wallet"
    );
    _;
  }

  modifier isAccuratePayment(uint256 price, uint256 numberOfTokensToAdd) {
    require(
      price * numberOfTokensToAdd <= msg.value,
      "Incorrect amount of ETH sent; check price!"
    );
    _;
  }

  constructor() ERC721("Sawa Genesis", "DOVE") {}

  // ============ MINTING ============

  function mint()
    external
    payable
    nonReentrant
    requiresPublicMintPriceSet
    isAccuratePayment(publicMintPrice, 1)
    publicSaleActive
    canMintTokens(1)
  {   
    _safeMint(msg.sender, nextTokenId());
  }

  function allowlistMint(bytes calldata _signature)
    external
    payable
    nonReentrant
    requiresAllowlistMintPriceSet
    isAccuratePayment(allowlistMintPrice, 1)
    allowlistSaleActive
    canMintTokens(1)
    allowlistSignatureVerified(msg.sender, _signature)
    canMintAllowlistTokens(_signature, 1)
  {
     uint256 allowlistTokensAlreadyMinted = allowlistMintCounts[_signature];
     _safeMint(msg.sender, nextTokenId());
     allowlistMintCounts[_signature] = allowlistTokensAlreadyMinted + 1;
  }

  function claim(bytes calldata _signature)
    external
    payable
    nonReentrant
    claimActive
    canMintTokens(1)
    claimSignatureVerified(msg.sender, _signature)
    hasNotUsedClaim(_signature)
  {
     _safeMint(msg.sender, nextTokenId());
     claimUsed[_signature] = true;
  }

  function crossmint(address _to)
    external
    payable
    nonReentrant
    requiresPublicMintPriceSet
    isAccuratePayment(publicMintPrice, 1)
    crossmintActive
    publicSaleActive
    canMintTokens(1)
    isSenderCrossmintAddress(msg.sender)
  {
    _safeMint(_to, nextTokenId());
  }

  // ============ GETTERS ============

  function getBaseURI() external view returns (string memory) {
    return baseURI;
  }

  function getCurrentTokenId() external view returns (uint256) {
    return currentTokenId.current();
  }

  // ============ SETTERS ============

  function setBaseURI(string memory _baseURI) external onlyOwner {
    baseURI = _baseURI;
  }

  function setIsPublicSaleActive(bool _isPublicSaleActive) external onlyOwner { 
    isPublicSaleActive = _isPublicSaleActive;
  }

  function setIsAllowlistSaleActive(bool _isAllowlistSaleActive) external onlyOwner {
    isAllowlistSaleActive = _isAllowlistSaleActive;
  }

  function setIsClaimActive(bool _isClaimActive) external onlyOwner {
    isClaimActive = _isClaimActive;
  }

  function setIsCrossmintActive(bool _isCrossmintActive) external onlyOwner {
    isCrossmintActive = _isCrossmintActive;
  }

  function setAllowlistSigner(address _signer) external onlyOwner {
    allowlistSigner = _signer;
  }

  function setClaimSigner(address _signer) external onlyOwner {
    claimSigner = _signer;
  }

  function setCrossmintAddress(address _crossmintAddress) external onlyOwner {
    crossmintAddress = _crossmintAddress;
  }

  function setAllowlistMintPrice(uint256 _allowlistMintPrice) external onlyOwner {
    allowlistMintPrice = _allowlistMintPrice;
    allowlistMintPriceSet = true;
  }

  function setPublicMintPrice(uint256 _publicMintPrice) external onlyOwner {
    publicMintPrice = _publicMintPrice;
    publicMintPriceSet = true;
  }

  // ============ WITHDRAWL ============

  function withdraw() public onlyOwner nonReentrant {
    payable(msg.sender).transfer(address(this).balance);
  }

  function withdrawTokens(IERC20 token) public onlyOwner nonReentrant {
    uint amount = token.balanceOf(address(this));
    token.transfer(msg.sender, amount);
  }

  // ============ HELPERS ============

  function nextTokenId() private returns (uint256) {
    currentTokenId.increment();
    return currentTokenId.current();
  }

  // ============ OVERRIDES ============

  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC721, IERC165)
    returns (bool)
  {
    return
        interfaceId == type(IERC2981).interfaceId ||
        super.supportsInterface(interfaceId);
  }
  
  /**
   * @dev See {IERC721Metadata-tokenURI}.
   */
  function tokenURI(uint256 tokenId)
      public
      view
      virtual
      override
      returns (string memory)
  {
      require(_exists(tokenId), "Nonexistent token");

      return
          string(abi.encodePacked(baseURI, "/", tokenId.toString()));
  }

  /**
   * @dev See {IERC165-royaltyInfo}.
   */
  function royaltyInfo(uint256 tokenId, uint256 salePrice)
    external
    view
    override
    returns (address receiver, uint256 royaltyAmount)
  {
    require(_exists(tokenId), "Nonexistent token");

    return (address(this), SafeMath.div(SafeMath.mul(salePrice, 10), 100));
  }
}