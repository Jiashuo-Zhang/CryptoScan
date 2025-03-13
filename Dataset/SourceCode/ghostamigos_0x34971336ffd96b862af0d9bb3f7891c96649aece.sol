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

contract ghostamigos is INft, Ownable, ERC721A {
    using ECDSA for bytes32;
    uint256 public ghostSupply = 5555;
    uint256 public ghostPrice = 0.003 ether;
    uint256 public maxFree = 1555;
    uint64 public WALLET_MAX = 100;
    uint256 public maxFreeGhost = 1;
    string private _baseTokenURI = "ipfs://bafybeienpldglnqt6nqexx5izqybd3m7umtwv74hxvy6qc4uexgm23bbga/";
    string private baseExtension = ".json";
    bool public pausedSale = false;
    event Minted(address indexed receiver, uint256 quantity);
    mapping(address => uint256) private _freeGhostCount;

    constructor(address _vault) ERC721A("GhostAmigos", "GAmigos") {
        _mintERC2309(_vault, 50);
    }


    /// @notice Function used during the public mint
    function mint(uint64 quantity) external payable {
    require(!pausedSale, "Not ready to ghost");
    uint256 price = ghostPrice;
    uint256 freeMintCount = _freeGhostCount[msg.sender];
    if(quantity<=(maxFreeGhost-freeMintCount)){
        require((_totalMinted()+ quantity) <= maxFree, "Too Many FreeMint");
        price=0;
        _freeGhostCount[msg.sender] += quantity;
        }
    require(msg.value >= (price*quantity), "hey dude, you have to pay for ghosts!");
    require((_numberMinted(msg.sender) - _getAux(msg.sender)) + quantity <= WALLET_MAX, "Ghost limit exceeded");
    require((_totalMinted()+ quantity) <= ghostSupply, "Too Many Ghosts");

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
    /// @param newGhostPrice Newly intended `ghostPrice` value.
    function setGhostRound(uint256 _maxFreeGhost, uint64 newMaxWallet, uint256 newGhostPrice, uint256 newMaxFree) external onlyOwner {
      maxFreeGhost = _maxFreeGhost;
      WALLET_MAX = newMaxWallet;
      ghostPrice = newGhostPrice;
      maxFree = newMaxFree;
    }



    function setGhostState(bool _state) external onlyOwner {
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