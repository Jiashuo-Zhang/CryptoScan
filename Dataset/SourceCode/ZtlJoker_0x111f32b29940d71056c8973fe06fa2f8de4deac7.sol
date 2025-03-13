// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./opensea/IProxyRegistry.sol";
import "./opensea/IERC4906.sol";
import "./IZtlDevilsTreasury.sol";

/**
 * @title Zeitls Joker token contract.
 */
contract ZtlJoker is Ownable, ERC721Enumerable, IERC4906 {
    using ECDSA for bytes32;

    /// @dev This event emits when multiple Devil's pieces are combined into a single large piece.
    event PiecesFusion(uint256 fusionId, uint256[] pieces);

    /// @notice Address which private key signed the permission for a piece mint.
    address public signer;

    /// @notice Contract for holding funds from purchases. 
    IZtlDevilsTreasury public treasury;

    /// @notice OpenSea's Proxy Registry.
    IProxyRegistry public immutable proxyRegistry;

    /// @notice Piece metadata uri.
    string public uri;

    constructor(
        address owner,
        address _signer,
        IZtlDevilsTreasury _treasury, 
        IProxyRegistry _proxyRegistry, 
        string memory _uri
    ) ERC721("The Joker", "JOKER") {
        _transferOwnership(owner);
        signer = _signer;
        proxyRegistry = _proxyRegistry;
        treasury = _treasury;
        uri = _uri;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(IERC165, ERC721Enumerable) returns (bool) {
        return interfaceId == type(IERC4906).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @notice Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator) public view override(IERC721, ERC721) returns (bool) {
        // Whitelist OpenSea proxy contract for easy trading.
        if (address(proxyRegistry) != address(0x0) && proxyRegistry.proxies(owner) == operator) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }

    /**
     * @notice Purchase Devils pieces with permission.
     * @dev Used signature where each piece included with a price. 
     * @param pieces id of pieces. 
     * @param prices price per piece according to index. 
     * @param deadline the time util price is effective.
     * @param signature off-chain signed permission.  
     */
    function purchase(uint256[] calldata pieces, uint256[] calldata prices, uint256 deadline, bytes calldata signature) public payable {
        require(pieces.length == prices.length, "Invalid arrays size");
        require(block.timestamp <= deadline, "Price offer expired");

        bytes32 msgHash;
        uint256 totalAmount;

        for (uint i = 0; i < pieces.length; i++) {
            require(!_exists(pieces[i]), "Piece already exist");
            totalAmount += prices[i];
            msgHash = keccak256(bytes.concat(msgHash, abi.encodePacked(pieces[i], prices[i], deadline)));
        }

        require(msg.value >= totalAmount, "Insufficient funds");
        require(_verifySignature(msgHash.toEthSignedMessageHash(), signature), "Invalid signature provided");

        for (uint i = 0; i < pieces.length; i++) {
            _safeMint(_msgSender(), pieces[i]);
        }

        treasury.keep{ value: totalAmount }();
    }

    /**
     * @notice Combine multiple Devil's pieces into one large piece.
     * Every piece token will be destroyed and create a new one with lowest token id number
     * @param pieces token ids for fusion. 
     */
    function fusion(uint256[] calldata pieces) external {
        uint256 fusionId = pieces[0];

        for (uint256 i = 0; i < pieces.length; i++) {
            require(ownerOf(pieces[i]) == _msgSender(), "Wrong piece owner");
            _burn(pieces[i]);
            fusionId = fusionId < pieces[i] ? fusionId : pieces[i]; 
        }

        _safeMint(_msgSender(), fusionId);

        emit PiecesFusion(fusionId, pieces);
        emit MetadataUpdate(fusionId);
    }

    /**
     * @notice Updates Key token metadata source.
     */
    function setURI(string calldata _uri) external onlyOwner {
        uri = _uri;
    }

    /**
     * @notice Updates signer address. 
     */
    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    /**
    * @dev Verify provided signature, it must be signed by the contract signer. 
    */
    function _verifySignature(bytes32 msgHash, bytes calldata signature) internal view returns (bool) {
        address recovered = msgHash.recover(signature);
        return recovered == signer;
    }

    function _baseURI() internal view override returns (string memory) {
        return uri;
    }
}