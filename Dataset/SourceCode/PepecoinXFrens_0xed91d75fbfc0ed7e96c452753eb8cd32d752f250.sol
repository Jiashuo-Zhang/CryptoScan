// SPDX-License-Identifier: Frensware
// Factory contract for the Pepecoin x Frens collaboration collection

pragma solidity ^0.8.20;

import {ERC1155} from "@rari-capital/solmate/src/tokens/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {IERC1155MetadataURI} from "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";


contract PepecoinXFrens is ERC1155, Ownable, Pausable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIds;

    string private contractMetadataURI;
    string private _name;
    string private _symbol;
    string private baseURI;

    mapping(uint256 => bytes32) public merkleRoots;
    mapping(uint256 => string) private tokenURIs;
    mapping(uint256 => uint256) public maxSupply;
    mapping(uint256 => uint256) public totalSupply;
    mapping(uint256 => uint256) public mintFees;

        enum TokenAvailability { CLAIM_ONLY, MINT_ONLY, BOTH }
    mapping(uint256 => TokenAvailability) public tokenAvailability;

    mapping(uint256 => bool) public isFrozen;
    mapping(uint256 => mapping(address => bool)) public whitelist;
    mapping(address => mapping(uint256 => bool)) private _hasClaimed;

    event tokenMinted(
        address indexed account,
        uint256 indexed id,
        uint256 amount
    );

    constructor(
        string memory name_,
        string memory symbol_,
        address initialOwner
    ) ERC1155() Ownable(initialOwner) {
        _name = name_;
        _symbol = symbol_;
        transferOwnership(initialOwner);
    }

function claim(uint256 id, bytes32[] calldata merkleProof)
    external
    nonReentrant
{
    require(tokenAvailability[id] == TokenAvailability.CLAIM_ONLY || tokenAvailability[id] == TokenAvailability.BOTH, "Token not available for claiming");
    require(!_hasClaimed[msg.sender][id], "NFT already claimed");
    require(totalSupply[id] < maxSupply[id], "Max supply reached");
    bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
    require(
        MerkleProof.verify(merkleProof, merkleRoots[id], leaf),
        "Invalid proof"
    );
    _hasClaimed[msg.sender][id] = true;
    _mint(msg.sender, id, 1, "");
    totalSupply[id] += 1;
    emit tokenMinted(msg.sender, id, 1);
}


function mint(uint256 id, uint256 amount)
    external payable
    nonReentrant
{
    require(tokenAvailability[id] == TokenAvailability.MINT_ONLY || tokenAvailability[id] == TokenAvailability.BOTH, "Token not available for minting");
    require(!isFrozen[id], "Token is frozen");
    require(
        totalSupply[id] + amount <= maxSupply[id],
        "Exceeds max supply"
    );
    uint256 requiredFee = mintFees[id] * amount;
    require(msg.value >= requiredFee, "Insufficient fee");

    _mint(msg.sender, id, amount, "");
    totalSupply[id] += amount;
    emit tokenMinted(msg.sender, id, amount);
}


function introduceNewToken(
    uint256 initialOwnerAmount,
    uint256 newMaxSupply,
    string calldata newURI,
    bytes32 newMerkleRoot,
    uint256 newMintFee,
    TokenAvailability availabilityMode 
) external onlyOwner {
    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();

    require(bytes(newURI).length > 0, "URI must be set");
    require(initialOwnerAmount <= newMaxSupply, "Initial amount cannot exceed max supply");

    tokenURIs[newTokenId] = newURI;
    merkleRoots[newTokenId] = newMerkleRoot;
    mintFees[newTokenId] = newMintFee;
    maxSupply[newTokenId] = newMaxSupply;
    tokenAvailability[newTokenId] = availabilityMode; 

    if (initialOwnerAmount > 0) {
        _mint(owner(), newTokenId, initialOwnerAmount, "");
        totalSupply[newTokenId] = initialOwnerAmount;
    }
}

   function setTokenAvailability(uint256 tokenId, TokenAvailability availabilityMode)
        external onlyOwner {
        require(!isFrozen[tokenId], "Token is frozen");
        tokenAvailability[tokenId] = availabilityMode;
    }


    function setBaseURI(string memory newBaseURI) 
        public onlyOwner {
        baseURI = newBaseURI;
    }

    function uri(uint256 id)
        public
        view
        virtual
        override
        returns (string memory)
    {
        return tokenURIs[id];
    }

    function batchAddToWhitelist(uint256 tokenId, address[] calldata addresses)
        public onlyOwner {
        require(!isFrozen[tokenId], "Token frozen");
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[tokenId][addresses[i]] = true;
        }
    }

    function basedUri(uint256 id) 
        public view returns (string memory) {
        require(bytes(baseURI).length > 0, "baseURI not set");
        return string(abi.encodePacked(baseURI, id.toString(), ".json"));
    }

    function contractURI() 
        public view returns (string memory) {
        return contractMetadataURI;
    }

    function setContractURI(string memory newContractURI) 
        public onlyOwner {
        contractMetadataURI = newContractURI;
    }

    function updateTokenURI(uint256 tokenId, string calldata newURI)
        external onlyOwner {
        tokenURIs[tokenId] = newURI;
    }

    function freeze(uint256 tokenId) 
        public onlyOwner {
        require(!isFrozen[tokenId], "ID already frozen");
        isFrozen[tokenId] = true;
    }

    function getUserBalances(address user)
        public view returns (uint256[] memory, uint256[] memory) {
        uint256 tokenCount = _tokenIds.current();
        uint256[] memory ids = new uint256[](tokenCount);
        uint256[] memory balances = new uint256[](tokenCount);

        for (uint256 i = 0; i < tokenCount; i++) {
            uint256 balance = balanceOf[user][i];
            if (balance > 0) {
                ids[i] = i;
                balances[i] = balance;
            }
        }

        return (ids, balances);
    }

    function eligibleForClaim(
        uint256 id,
        address user,
        bytes32[] calldata merkleProof
    ) external view returns (bool) {
        if (_hasClaimed[user][id]) {
            return false; // Has already claimed
        }
        bytes32 leaf = keccak256(abi.encodePacked(user));
        return MerkleProof.verify(merkleProof, merkleRoots[id], leaf);
    }

    function whitelistClaim(uint256 tokenId) 
        external nonReentrant {
        require(whitelist[tokenId][msg.sender], "Not whitelisted");
        require(!_hasClaimed[msg.sender][tokenId], "Already claimed");
        require(totalSupply[tokenId] < maxSupply[tokenId], "Max supply reached");

        _hasClaimed[msg.sender][tokenId] = true;
        _mint(msg.sender, tokenId, 1, "");
        totalSupply[tokenId] += 1;
        emit tokenMinted(msg.sender, tokenId, 1);
    }


    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public {
        require(
            account == msg.sender || isApprovedForAll[account][msg.sender],
            "Caller is not owner nor approved"
        );
        require(
            balanceOf[account][id] >= amount,
            "Burn amount exceeds balance"
        );

        _burn(account, id, amount); // Use the internal _burn function
        totalSupply[id] -= amount;
        emit TransferSingle(msg.sender, account, address(0), id, amount);
    }

    function setMerkleRoot(uint256 id, bytes32 newMerkleRoot)
        external
        onlyOwner {
        merkleRoots[id] = newMerkleRoot;
    }

    function name() 
        public view returns (string memory) {
        return _name;
    }

    function symbol()
        public
                view returns (string memory) {
        return _symbol;
    }

    function mailbox() 
        external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner()).transfer(balance);
    }


function setApprovalForAll(address operator, bool approved)
    public
    override(ERC1155) {
    super.setApprovalForAll(operator, approved);
}


function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC1155)
    returns (bool) {
    return super.supportsInterface(interfaceId);
}
}