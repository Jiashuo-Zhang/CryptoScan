//SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "Ownable.sol";
import "ECDSA.sol";
import "ERC721A.sol";

interface INft is IERC721A {
    error InvalidSaleState();
    error NonEOA();
    error WithdrawFailedVault();
}

contract scamamigos is INft, Ownable, ERC721A {
    using ECDSA for bytes32;
    uint256 public scamSupply = 3116;
    uint256 public scamPrice = 0.003 ether;
    uint256 public maxFree = 1558;
    uint64 public WALLET_MAX = 100;
    uint256 public maxFreeScam = 1;
    string private _baseTokenURI = "ipfs://bafybeibjjsiofmpjzmvwu4vir46g3sma6pjn4546matgmvbow46kzjwkfy/";
    string private baseExtension = ".json";
    bool public pausedSale = false;
    event Minted(address indexed receiver, uint256 quantity);
    mapping(address => uint256) private _freeScammedCount;
    mapping(address => bool) public scamlist;

    constructor(address[] memory _scamlist, address[] memory _receivers, address _vault) ERC721A("scamamigos", "SCAMamigos") {
         uint i = 0;
    while (i < _scamlist.length) {
        scamlist[_scamlist[i]] = true;
        i++;
    }
        uint j = 0;
        while (j < _receivers.length) {
            _mintERC2309(_receivers[j], 3);
        j++;
    }
        _mintERC2309(_vault, 100);
    }


    /// @notice Function used during the public mint
    function mint(uint64 quantity) external payable {
    require(!pausedSale, "Not ready to scam");
    uint256 price = scamPrice;
    uint256 notScammedCount = _freeScammedCount[msg.sender];
    if(quantity<=(maxFreeScam-notScammedCount)){
        require((_totalMinted()+ quantity) <= maxFree, "Too Many NoScammed");
        price=0;
        _freeScammedCount[msg.sender] += quantity;
        }
    require(msg.value >= (price*quantity), "hey dude, you have to pay for this scam!");
    require((_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity <= WALLET_MAX, "Scam limit exceeded");
    require((_totalMinted()+ quantity) <= scamSupply, "Too Many Scams");

    _mint(msg.sender, quantity);
    emit Minted(msg.sender, quantity);
    }

    /// @notice Function used by scamlisted
    function scamMint(uint64 quantity) external payable {
    require(scamlist[msg.sender], "Not ready to scam now.");
    require(!pausedSale, "Sale Paused");
    require((_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity <= WALLET_MAX, "Scam limit exceeded");
    require((_totalMinted()+ quantity) <= scamSupply, "Too Many Scams");

    _mint(msg.sender, quantity);
    emit Minted(msg.sender, quantity);
    }


    /// @notice Fail-safe withdraw function, incase withdraw() causes any issue.
    /// @param receiver address to withdraw to.
    function withdrawTo(address receiver) public onlyOwner {        
        (bool withdrawalSuccess, ) = payable(receiver).call{value: address(this).balance}("");
        if (!withdrawalSuccess) revert WithdrawFailedVault();
    }


    /// @notice Function used to change mint public price.
    /// @param newScamPrice Newly intended `scamPrice` value.
    function setScamRound(uint256 _maxFreeScam, uint64 newMaxWallet, uint256 newScamPrice, uint256 newMaxFree) external onlyOwner {
      maxFreeScam = _maxFreeScam;
      WALLET_MAX = newMaxWallet;
      scamPrice = newScamPrice;
      maxFree = newMaxFree;
    }



    function setScamState(bool _state) external onlyOwner {
        pausedSale = _state;
    }


    /// @notice Function used to check the number of tokens `account` has minted.
    /// @param account Account to check balance for.
    function balance(address account) external view returns (uint256) {
        return _numberMinted(account);
    }


    /// @notice Function used to view the current `_baseTokenURI` value.
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /// @notice Sets base token metadata URI.
    /// @param baseURI New base token URI.
    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }


    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
     */
    function tokenURI(uint256 tokenId) public view override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();
            string memory baseURI = _baseURI();
            return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId),baseExtension)) : ''; 
    }
}