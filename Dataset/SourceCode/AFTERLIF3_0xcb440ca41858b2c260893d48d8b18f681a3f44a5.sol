// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract AFTERLIF3 is ERC721, Ownable {
  using Strings for uint256;

  string public constant BASE_EXTENSION = ".json";
  uint256 public constant MAX_SUPPLY = 8888;
  uint256 public constant COST = 0.088 ether;

  string public baseURI;
  uint256 public maxMintAmount = 2;
  bool public paused = true;
  bool public onlyAllowedList = true;
  mapping(address => bool) public allowedListClaimed;

  uint256 internal _currentId;
  bytes32 internal merkleRootHash;

  event NFTMinted(address sender);

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
  }

  // modifiers
  modifier stateCompliance() {
    require(!paused, "the contract is paused");
    _;
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0, "need to mint at least 1 NFT");

    if (msg.sender != owner()) {
      require(
        _mintAmount <= maxMintAmount,
        "max mint amount per session exceeded"
      );
    }

    require(_currentId + _mintAmount <= MAX_SUPPLY, "max NFT limit exceeded");
    _;
  }

  modifier mintPriceCompliance(uint256 _mintAmount) {
    require(msg.value == COST * _mintAmount, "insufficient funds");
    _;
  }

  modifier allowedListCompliance(
    uint256 _mintAmount,
    bytes32[] calldata proof
  ) {
    require(!allowedListClaimed[msg.sender], "mint allocation already claimed");
    require(
      _validateTxn(proof, msg.sender),
      "invalid proof, transaction not valid"
    );
    _;
  }

  // external
  function mint(uint256 _mintAmount)
    external
    payable
    stateCompliance
    mintCompliance(_mintAmount)
    mintPriceCompliance(_mintAmount)
  {
    require(!onlyAllowedList, "minting is resctricted to the allowed list"); //allowed
    _mintQty(_mintAmount, msg.sender);
  }

  function allowedListMint(uint256 _mintAmount, bytes32[] calldata proof)
    external
    payable
    stateCompliance
    mintCompliance(_mintAmount)
    mintPriceCompliance(_mintAmount)
    allowedListCompliance(_mintAmount, proof)
  {
    allowedListClaimed[msg.sender] = true;
    _mintQty(_mintAmount, msg.sender);
  }

  function totalSupply() external view returns (uint256) {
    return _currentId;
  }

  // public
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return
      bytes(currentBaseURI).length > 0
        ? string(
          abi.encodePacked(currentBaseURI, tokenId.toString(), BASE_EXTENSION)
        )
        : "";
  }

  // internal
  function _mintQty(uint256 _mintAmount, address _receiver) internal {
    _currentId += _mintAmount;
    for (uint256 i = 1; i <= _mintAmount; ++i) {
      _safeMint(_receiver, _currentId);
    }
    emit NFTMinted(_receiver);
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function _validateTxn(bytes32[] memory proof, address _user)
    internal
    view
    returns (bool)
  {
    return _merkleVerify(proof, _hashLeaf(_user));
  }

  function _merkleVerify(bytes32[] memory proof, bytes32 hashedLeaf)
    internal
    view
    returns (bool)
  {
    return MerkleProof.processProof(proof, hashedLeaf) == merkleRootHash;
  }

  function _hashLeaf(address _user) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(_user));
  }

  /**
   *  Owner
   */
  function setClaimedStateForAddress(bool _state, address _address)
    external
    onlyOwner
  {
    allowedListClaimed[_address] = _state;
  }

  function mintOnBehalf(uint256 _mintAmount, address _receiver)
    external
    mintCompliance(_mintAmount)
    onlyOwner
  {
    _mintQty(_mintAmount, _receiver);
  }

  function setMerkleRoot(bytes32 _newRoot) external onlyOwner {
    merkleRootHash = _newRoot;
  }

  function setMaxMintAmount(uint256 _newmaxMintAmount) external onlyOwner {
    maxMintAmount = _newmaxMintAmount;
  }

  function setPaused(bool _state) external onlyOwner {
    paused = _state;
  }

  function setOnlyAllowedList(bool _state) external onlyOwner {
    onlyAllowedList = _state;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function withdraw() external onlyOwner {
    (bool os, ) = (owner()).call{value: address(this).balance}("");
    require(os);
  }
}