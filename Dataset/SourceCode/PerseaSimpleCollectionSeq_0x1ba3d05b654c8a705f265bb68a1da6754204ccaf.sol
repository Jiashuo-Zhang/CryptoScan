// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./ERC4906.sol";
import "./Splitter.sol";

contract PerseaSimpleCollectionSeq is
    ERC4906,
    ReentrancyGuard,
    Ownable,
    Splitter
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    string private _contractURIHash;
    string private _gatewayBaseURI;
    uint256 public totalSupply;
    uint256 public _price;

    mapping(uint256 => string) private _tokenHash;

    constructor(
        string memory _name ,
        string memory _symbol,
        string memory gatewayBaseURI,
        string memory contractURIHash,
        uint256 price,
        address[] memory _payees,
        uint256[] memory _percentages
    ) ERC4906(_name, _symbol) Splitter(_payees, _percentages) {
        _price = price;
        _contractURIHash = contractURIHash;
        _gatewayBaseURI = gatewayBaseURI;
    }

    function contractURI() public view onlyOwner returns (string memory) {
        return string(abi.encodePacked(_gatewayBaseURI, _contractURIHash));
    }

    function setContractURIHash(string memory contractURIHash) public onlyOwner {
        _contractURIHash = contractURIHash;
    }

    function setTokenURIHash(uint256 _tokenId, string memory newHash) public onlyOwner {
        _tokenHash[_tokenId] = newHash;
        emit MetadataUpdate(_tokenId);
    }

    function setTokenURIHashBatch(uint256[] memory tokenIds, string[] memory newHashes) public onlyOwner {
        require(tokenIds.length == newHashes.length, "Persea: Arrays length mismatch");
        uint256 from = tokenIds[0];
        uint256 to = 0;
        for(uint256 index = 0; index < tokenIds.length; index++) {
            _requireMinted(tokenIds[index]);
            _tokenHash[tokenIds[index]] = newHashes[index];
            from = tokenIds[index] < from ? tokenIds[index] : from;
            to = tokenIds[index] > to ? tokenIds[index] : to;
        }
        emit BatchMetadataUpdate(from, to);
    }

    function setAllTokensURIHash(string[] memory newHashes) public onlyOwner {
        require(totalSupply == newHashes.length, "Persea: Arrays length mismatch");
        for(uint256 index = 0; index < newHashes.length; index++) {
            _tokenHash[index + 1] = newHashes[index];
        }
        emit BatchMetadataUpdate(1, totalSupply);
    }

    function mint(address to, string memory uriHash) public onlyOwner {
        require(bytes(uriHash).length > 0, "Persea: URI is empty");
        uint256 tokenId = _mintOne(to);
        _tokenHash[tokenId] = uriHash;
    }

    function _safeMint(address to) internal returns(uint256){
        uint256 newItemId = _getCurrentId();
        _mint(to, newItemId);
        _addSupply();
        return newItemId;
    }

    function payableMint(string memory uriHash) public nonReentrant payable {
        require(bytes(uriHash).length > 0, "Persea: URI is empty");
        require(msg.value >= _price, "Persea: Balance not enough");
        payWithNativeToken();
        uint256 tokenId = _mintOne(_msgSender());
        _tokenHash[tokenId] = uriHash;
    }

    function payWithNativeToken() internal {
        address[] memory payees = getPayess();
        for (uint256 index = 0; index < payees.length; index++) {
            (bool sent, ) = payable(payees[index]).call{value: getShareAmount(payees[index], msg.value)}("");
            require(sent, "Persea : Failed to send Ethers");
        }
    }

    function _mintOne(address to) internal returns (uint256 newItemId) {
        newItemId = _safeMint(to);
        return newItemId;
    }

    function _addSupply() private {
        totalSupply++;
    }

    function _getCurrentId() internal returns (uint256){
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        return newItemId;
    }

    function getPrice() public view returns(uint256) {
        return _price;
    }

    function setPrice(uint256 _newPrice) public onlyOwner {
        _price = _newPrice;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        return string(abi.encodePacked(_gatewayBaseURI, _tokenHash[tokenId]));
    }
}