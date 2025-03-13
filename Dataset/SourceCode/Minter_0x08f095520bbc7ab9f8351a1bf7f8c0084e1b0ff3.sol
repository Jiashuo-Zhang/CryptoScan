// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/INishikigoi.sol";

contract Minter is Ownable, IERC721Receiver, ReentrancyGuard {

    INishikigoi public nishikigoiNFTContract;
    address public cushionAddress;
    address private agentAddress;

    uint256 public constant PUBLIC_PRICE = 0.03 ether;    
    uint256 public constant ALLOWLIST_PRICE = 0.025 ether;    
    uint256 public constant HOLDER_PRICE = 0.01 ether;

    uint256 public constant PRICE = 0.03 ether;
    
    bool public isPublicSaleActive;
    bool public isAllowlistSaleActive;
    bool public isHolderSaleActive;

    bytes32 public allowlistMerkleRoot;
    bytes32 public holderMerkleRoot;

    /// @dev Holder Address => Minted token amount
    mapping (address => uint256) public holderMinted;

    /// @dev TokenId => Seed
    mapping (uint256 => bytes32) private tokenIdToSeed;

    enum Artist { Okazz, Raf, Ykxotkx }

    event Minted(uint256 indexed _tokenId, Artist indexed _artist, bytes32 indexed _seed);

    constructor(
        address _cushionAddress,
        address _targetAddress
    ) {
        nishikigoiNFTContract = INishikigoi(_targetAddress);
        cushionAddress = _cushionAddress;
    }

    function publicMint(
        uint256[] memory _tokenIdList
    ) external payable nonReentrant {
        require(isPublicSaleActive, "Minter: Public sale is not active");
        require(_isValidTokenIdList(_tokenIdList), "Minter: Invalid token id list");
        require(msg.value == PUBLIC_PRICE * _tokenIdList.length, "Minter: Incorrect payment amount");

        _mintNFT(msg.sender, _tokenIdList);
    }

    function publicMintByAgent(
        uint256[] memory _tokenIdList,
        address _recipient
    ) external payable onlyAgent nonReentrant {
        require(isPublicSaleActive, "Minter: Public sale is not active");
        require(_isValidTokenIdList(_tokenIdList), "Minter: Invalid token id list");
        require(msg.value == PUBLIC_PRICE * _tokenIdList.length, "Minter: Incorrect payment amount");

        _mintNFT(_recipient, _tokenIdList);
    }

    function allowlistMint(
        bytes32[] calldata _merkleProof,
        uint256[] memory _tokenIdList
    ) external payable nonReentrant {
        require(isAllowlistSaleActive, "Minter: Allowlist sale is not active");
        require(_isValidTokenIdList(_tokenIdList), "Minter: Invalid token id list");
        require(MerkleProof.verify(_merkleProof, allowlistMerkleRoot,  keccak256(abi.encodePacked(msg.sender))), "Minter: Invalid Merkle Proof");
        require(msg.value == ALLOWLIST_PRICE * _tokenIdList.length, "Minter: Incorrect payment amount");

        _mintNFT(msg.sender, _tokenIdList);
    }

    function allowlistMintByAgent(
        bytes32[] calldata _merkleProof,
        uint256[] memory _tokenIdList,
        address _recipient
    ) external payable onlyAgent nonReentrant {
        require(isAllowlistSaleActive, "Minter: Allowlist sale is not active");
        require(_isValidTokenIdList(_tokenIdList), "Minter: Invalid token id list");
        require(MerkleProof.verify(_merkleProof, allowlistMerkleRoot,  keccak256(abi.encodePacked(_recipient))), "Minter: Invalid Merkle Proof");
        require(msg.value == ALLOWLIST_PRICE * _tokenIdList.length, "Minter: Incorrect payment amount");

        _mintNFT(_recipient, _tokenIdList);
    }

    function holderMint(
        bytes32[] calldata _merkleProof,
        uint256 _quantity,
        uint256[] memory _tokenIdList
    ) external payable nonReentrant {
        require(isHolderSaleActive, "Minter: Holder sale is not active");
        require(holderMinted[msg.sender] + _tokenIdList.length <= _quantity, "Minter: Exceeds the number of mints allowed");
        require(_isValidTokenIdList(_tokenIdList), "Minter: Invalid token id list");
        require(MerkleProof.verify(_merkleProof, holderMerkleRoot,  keccak256(abi.encodePacked(msg.sender, _quantity))), "Minter: Invalid Merkle Proof");
        require(msg.value == HOLDER_PRICE * _tokenIdList.length, "Minter: Incorrect payment amount");
        
        _mintNFT(msg.sender, _tokenIdList);

        holderMinted[msg.sender] += _tokenIdList.length;
    }

    function holderMintByAgent(
        bytes32[] calldata _merkleProof,
        uint256 _quantity,
        uint256[] memory _tokenIdList,
        address _recipient
    ) external payable onlyAgent nonReentrant {
        require(isHolderSaleActive, "Minter: Holder sale is not active");
        require(holderMinted[_recipient] + _tokenIdList.length <= _quantity, "Minter: Exceeds the number of mints allowed");
        require(_isValidTokenIdList(_tokenIdList), "Minter: Invalid token id list");
        require(MerkleProof.verify(_merkleProof, holderMerkleRoot,  keccak256(abi.encodePacked(_recipient, _quantity))), "Minter: Invalid Merkle Proof");
        require(msg.value == HOLDER_PRICE * _tokenIdList.length, "Minter: Incorrect payment amount");
        
        _mintNFT(_recipient, _tokenIdList);

        holderMinted[_recipient] += _tokenIdList.length;
    }

    function ownerMintByMintForPromotion(address _to, uint256 _quantity) external onlyOwner {
        nishikigoiNFTContract.mintForPromotion(_to, _quantity);
    }

    function ownerMint(address _to, uint256[] memory _tokenIdList) external onlyOwner {
        _overrideBuyBundle(_to, _tokenIdList);
    }

    modifier onlyAgent() {
        require(msg.sender == agentAddress, "Minter: Invalid agent address");
        _;
    }

    function _changeSaleState(bool _state) internal {
        nishikigoiNFTContract.updateSaleStatus(_state);
    }

    function _overrideBuyBundle(address _to, uint256[] memory _tokenIdList) internal {
        _changeSaleState(true);
        nishikigoiNFTContract.buyBundle{value: PRICE * _tokenIdList.length}(_tokenIdList);
        _changeSaleState(false);

        for (uint256 i = 0; i < _tokenIdList.length; i++) {
            _transfer(_to, _tokenIdList[i]);
            emit Minted(_tokenIdList[i], getArtistFor3rdSale(_tokenIdList[i]), tokenIdToSeed[_tokenIdList[i]]);
        }
    }

    function _transfer(address _to, uint256 tokenId) internal {
        nishikigoiNFTContract.safeTransferFrom(address(this), cushionAddress, tokenId);        
        nishikigoiNFTContract.safeTransferFrom(cushionAddress, _to, tokenId);        
    }

    function _generateSeed(address _addr, uint256[] memory _tokenIdList) internal {
        for (uint256 i = 0; i < _tokenIdList.length; i++) {
            tokenIdToSeed[_tokenIdList[i]] = keccak256(abi.encodePacked(_tokenIdList[i], block.number, blockhash(block.number - 1), _addr));
        }
    }

    function _mintNFT(address _addr, uint256[] memory _tokenIdList) internal {
        _generateSeed(_addr, _tokenIdList);
        _overrideBuyBundle(_addr, _tokenIdList);
    }

    function _isValidTokenIdList(
        uint256[] memory _tokenIdList
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < _tokenIdList.length; i++) {
            if (_tokenIdList[i] >= 8666) {
                return false;
            }            
        }
        return true;
    }

    function overrideTransferOwnership(address _to) public onlyOwner {
        require(!Address.isContract(_to), "Minter: Cannot transfer ownership to a contract");
        bool anySaleActive = isHolderSaleActive || isAllowlistSaleActive || isPublicSaleActive;
        require(!anySaleActive, "Minter: Sale is active");
        nishikigoiNFTContract.transferOwnership(_to);
    }

    function setIsHolderSaleActive(bool _state) external onlyOwner {
        isHolderSaleActive = _state;
    }

    function setIsAllowlistSaleActive(bool _state) external onlyOwner {
        isAllowlistSaleActive = _state;
    }

    function setIsPublicSaleActive(bool _state) external onlyOwner {
        isPublicSaleActive = _state;
    }

    function setMerkleRoot(
        bytes32 _holderMerkleRoot,
        bytes32 _allowlistMerkleRoot
    ) external onlyOwner {
        holderMerkleRoot = _holderMerkleRoot;
        allowlistMerkleRoot = _allowlistMerkleRoot;
    }

    function setBaseURI(string memory _newBaseURI) external onlyOwner {
        nishikigoiNFTContract.updateBaseURI(_newBaseURI);
    }

    function setAgentAddress(address _agentAddress) external onlyOwner {
        agentAddress = _agentAddress;
    }

    function setCushionAddress(address _cushionAddress) external onlyOwner {
        cushionAddress = _cushionAddress;
    }
    
    function getSeed(uint256 tokenId) external view returns (bytes32) {
        return tokenIdToSeed[tokenId];
    }

    function getArtistFor3rdSale(uint256 tokenId) public pure returns (Artist) {        
        if (tokenId <= 1937) {
            /// @dev 0
            return Artist.Okazz;
        } else if (tokenId <= 3854) {
            /// @dev 1
            return Artist.Raf;
        } else {
            /// @dev 2
            return Artist.Ykxotkx;
        }
    }
    
    function withdraw(address payable _receiptAddress) external onlyOwner {
        require(_receiptAddress != address(0), "Minter: Invalid receipt address");

        _receiptAddress.transfer(address(this).balance);        
        nishikigoiNFTContract.withdrawETH();
    }

    function withdrawOfNishikigoi() external onlyOwner {
        nishikigoiNFTContract.withdrawETH();
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    receive() external payable {}

}