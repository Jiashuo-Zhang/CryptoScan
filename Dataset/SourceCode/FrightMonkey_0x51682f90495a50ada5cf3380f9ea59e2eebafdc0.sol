// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title FrightMonkey NFT Collection
/// @author Bitduke
/// @notice ERC721 NFT collection

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FrightMonkey is ERC721A, Ownable {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 10000;
    address immutable public deployer;
    string public contractURI;
    string public baseURI;

    uint256 private _flag;
    string private _defTokenURI = "https://ipfs.io/ipfs/QmSuJkvkqACL9mreQqzWcNoWJv87owarWAUKxYh2tWTBQS";
    string private _baseTokenURI = "";

    mapping(address => bool) private _hasMinted;

    event NewMint(address indexed msgSender, uint256 indexed mintQuantity);
    event ContractURIChanged(address sender, string newContractURI);

    constructor(
        string memory name, 
        string memory symbol,
        string memory _contractBaseURI, 
        string memory _contractURI
    ) ERC721A(name, symbol) {
        baseURI = _contractBaseURI;
        contractURI = _contractURI;
        deployer = msg.sender;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A)
    returns (bool) {
      return super.supportsInterface(interfaceId);
    }

    function transferOut(address _to) public onlyOwner {
        uint256 balance = address(this).balance;
        payable(_to).transfer(balance);
    }

    function changeTokenURIFlag(uint256 flag) external onlyOwner {
        _flag = flag;
    }

    function changeDefURI(string calldata _tokenURI) external onlyOwner {
        _defTokenURI = _tokenURI;
    }

    function changeURI(string calldata _tokenURI) external onlyOwner {
        _baseTokenURI = _tokenURI;
    }

    /// @notice Update contractURI/NFT metadata
    /// @param _newContractURI New collection metadata
    function setContractURI(string calldata _newContractURI) public onlyOwner {
        contractURI = _newContractURI;
        emit ContractURIChanged(msg.sender, _newContractURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }
    
    function _DefURI() internal view virtual returns (string memory) {
        return _DefURI();
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (_flag == 0) {
            return _defTokenURI;
        } else {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
            return string(abi.encodePacked(_baseTokenURI, Strings.toString(tokenId)));
        }
    }

    function mint(uint256 quantity) public payable {
        require(totalSupply() + quantity <= MAX_SUPPLY, "ERC721: Exceeds maximum supply");
        _safeMint(msg.sender,quantity);
        emit NewMint(msg.sender, quantity);
    }

}