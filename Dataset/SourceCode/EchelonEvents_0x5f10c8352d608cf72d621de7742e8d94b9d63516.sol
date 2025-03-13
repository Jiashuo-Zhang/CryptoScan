pragma solidity 0.8.17;
// SPDX-License-Identifier: MIT

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import { ERC1155Burnable } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";

import { ERC1155URIStorage } from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";

import { IEchelonEvents } from "./interfaces/IEchelonEvents.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/*
 * @dev InvokeEchelonHandler: Another type of contract in the Echelon ecosystem that will be deployed after PRIME.
 *      Different InvokeEchelonHandler's will be deployed over time to facilitate expanding PRIME use cases.
 *      InvokeEchelonHandler.handleInvokeEchelon is called at the end of the invokeEchelon function (see below).
 *      handleInvokeEchelon enables additional functionality to execute after the movement of PRIME and/or ETH.
 *      A very similar concept is utilized in EchelonCache(1155) to enable Core Pack NFT holders to send NFTs + ETH
 *      and receive a different set of NFTs back, all within a single transaction (no approve necessary).
 * @param _from - The address of the caller of invokeEchelon
 * @param _ethDestination - The address to which ETH was collected to before calling handleInvokeEchelon
 * @param _primeDestination - The address to which PRIME was collected to before calling handleInvokeEchelon
 * @param _id - An id passed by the caller to represent any arbitrary and potentially off-chain event id
 * @param _ethValue - The amount of ETH that was sent to the invokeEchelon function (and was collected to _ethDestination)
 * @param _primeValue - The amount of PRIME that was sent to the invokeEchelon function (and was collected to _primeDestination)
 * @param _data - Catch-all param allowing callers to pass additional data
 */
abstract contract InvokeEchelonHandler {
    function handleInvokeEchelon(
        address _from,
        address _ethDestination,
        address _primeDestination,
        uint256 _id,
        uint256 _ethValue,
        uint256 _primeValue,
        bytes memory _data
    ) external virtual;
}

contract EchelonEvents is
    ERC1155Burnable,
    ERC1155URIStorage,
    Ownable,
    InvokeEchelonHandler,
    IEchelonEvents
{
    /// @notice The contract URI.
    string public contractURI;

    /// @notice Address of PRIME contract.
    address public PRIME = 0xb23d80f5FefcDDaa212212F028021B41DEd428CF;

    /// @notice Mapping of addresses to a mapping of tokenIds to amount claimed.
    mapping(address => mapping(uint256 => uint256)) public claimed;

    /// @notice Mapping of tokenIds to mintable.
    mapping(uint256 => bool) public isMintable;

    /// @notice Mapping of tokenIds to the merkle roots for allowlists.
    mapping(uint256 => bytes32) public merkleRoots;

    /// @notice Mapping of tokenIds to mint prices.
    mapping(uint256 => uint256) public prices;

    /// @notice Mapping of tokenIds to default max allocations.
    mapping(uint256 => uint256) public defaultMaxAllocations;

    /// @notice Indicates if invoke is disabled.
    bool public disabled;

    /// @notice A descriptive name for a collection of NFTs in this contract.
    string public name;

    /// @notice An abbreviated name for NFTs in this contract.
    string public symbol;

    constructor(string memory _uri) ERC1155(_uri) {
        name = "EchelonEvents";
        symbol = "ECHEV";
    }

    /************************************ Owner Functions ************************************/

    /**
     *  @notice Sets contract URI.
     * @param _uri New metadata contractURI.
     */
    function setContractURI(string calldata _uri) external onlyOwner {
        contractURI = _uri;
        emit ContractUriSet(_uri);
    }

    /**
     *  @notice Sets invoke to enabled/disabled.
     * @param _disabled New state of the invoke.
     */
    function setDisabled(bool _disabled) external onlyOwner {
        disabled = _disabled;
        emit IsDisabledSet(_disabled);
    }

    /**
     * @notice Sets default max allocation when specific merkle tree is not used.
     * @param _tokenId The tokenId.
     * @param _allocation New max allocation.
     */
    function setMaxAllocation(
        uint256 _tokenId,
        uint256 _allocation
    ) external onlyOwner {
        defaultMaxAllocations[_tokenId] = _allocation;
        emit MaxAllocationSet(_tokenId, _allocation);
    }

    /**
     *   @notice Sets merkle root.
     * @param _merkleRoot New merkle root.
     */
    function setMerkleRoot(
        uint256 _tokenId,
        bytes32 _merkleRoot
    ) external onlyOwner {
        merkleRoots[_tokenId] = _merkleRoot;
        emit MerkleRootSet(_tokenId, _merkleRoot);
    }

    /**
     * @notice Sets tokenId to enable/disable minting.
     * @param _tokenId The tokenId to set.
     * @param _mintable New state of the mintable.
     */
    function setMintable(uint256 _tokenId, bool _mintable) external onlyOwner {
        isMintable[_tokenId] = _mintable;
        emit IsMintableSet(_tokenId, _mintable);
    }

    /**
     * @notice Sets PRIME price.
     * @param _tokenId The tokenId.
     * @param _price New PRIME price.
     */
    function setPrice(uint256 _tokenId, uint256 _price) external onlyOwner {
        prices[_tokenId] = _price;
        emit PriceSet(_tokenId, _price);
    }

    /**
     * @notice Updated PRIME contract address.
     * @param _prime New PRIME contract address.
     */
    function setPrime(address _prime) external onlyOwner {
        PRIME = _prime;
        emit PrimeAddressSet(_prime);
    }

    /**
     * @notice Set the URI for a specific token.
     * @param _tokenId The token ID for which to set the URI.
     * @param _uri The URI to set.
     */
    function setTokenURI(
        uint256 _tokenId,
        string calldata _uri
    ) external onlyOwner {
        _setURI(_tokenId, _uri);
        emit TokenUriSet(_tokenId, _uri);
    }

    /**
     * @notice Allows owner to create `amount` tokens of token type `id`, and assign them to `to`.
     *
     *  @param _to The address minted to
     *  @param _id The tokenId to mint
     *  @param _amount The amount of tokens to mint
     *  @param _data Additional data with no specified format
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function specialMint(
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) external onlyOwner {
        claimed[_to][_id] += _amount;
        _mint(_to, _id, _amount, _data);
    }

    /************************************ Public Functions ************************************/

    /**
     * @notice Function invoked by the prime token contract to purchase terminals
     * @param _from The address of the original msg.sender
     * @param _primeValue The amount of prime that was sent from the prime token contract
     * @param _data Catch-all param to allow the caller to pass additional data to the handler, includes tokenIds and amounts
     */
    function handleInvokeEchelon(
        address _from,
        address,
        address,
        uint256,
        uint256,
        uint256 _primeValue,
        bytes memory _data
    ) external override {
        if (msg.sender != PRIME) revert InvalidCaller(msg.sender);
        if (disabled) revert ContractDisabled();

        // Decode data for merkle proof mint
        (
            uint256 tokenId,
            uint256 amount,
            uint256 maxAmount,
            bytes32[] memory proof
        ) = abi.decode(_data, (uint256, uint256, uint256, bytes32[]));

        if (!isMintable[tokenId]) revert MintInactive();
        if (_primeValue != prices[tokenId] * amount) revert InsufficientPrime();
        mint(_from, tokenId, amount, maxAmount, proof, "");
    }

    /**
     * @notice Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     *  @param _to The address minted to
     *  @param _id The tokenId to mint
     *  @param _amount The amount of tokens to mint
     *  @param _maxAmount The max amount of tokens allowed to be minted, must be verified in leaf
     *  @param _proof The merkle proof to verify
     *  @param _data Additional data with no specified format
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     * - caller must provide a valid merkle proof.
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function mint(
        address _to,
        uint256 _id,
        uint256 _amount,
        uint256 _maxAmount,
        bytes32[] memory _proof,
        bytes memory _data
    ) internal virtual {
        bytes32 leaf = keccak256(abi.encodePacked(_to, _maxAmount));

        // Bypass verification if merkle root is empty
        if (merkleRoots[_id] != bytes32(0)) {
            // Verify merkle proof
            if (!MerkleProof.verify(_proof, merkleRoots[_id], leaf))
                revert InvalidMerkleProof();
            // Verify not exceeding allocation
            if (claimed[_to][_id] + _amount > _maxAmount)
                revert AllocationExceeded();
        } else {
            // Verify not exceeding default allocation when not using merkle root
            if (claimed[_to][_id] + _amount > defaultMaxAllocations[_id])
                revert AllocationExceeded();
        }
        claimed[_to][_id] += _amount;
        _mint(_to, _id, _amount, _data);
    }

    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(
        uint256 _tokenId
    )
        public
        view
        virtual
        override(ERC1155, ERC1155URIStorage)
        returns (string memory)
    {
        return super.uri(_tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 _interfaceId
    ) public view virtual override(ERC1155) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }
}