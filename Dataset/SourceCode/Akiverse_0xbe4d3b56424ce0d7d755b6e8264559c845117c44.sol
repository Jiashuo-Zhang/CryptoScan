// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;



import "./ERC721Template.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";



/// @title Akiverse Official PFP Contract

contract Akiverse is ERC721Template {

    using ECDSA for bytes32;

    /// @notice Flag to authenticate free mint

    uint8 public constant FREE_MINT_FLAG = 10;

    /// @notice Phase 1 mint price

    uint256 public whitelistMintPrice;

    /// @notice Phase 2 mint price

    uint256 public whitelist2MintPrice;

    /// @notice Current mint limit

    uint256 public currentLimit;

    /// @notice Mapping used to track who has already minted for free mint

    mapping(address => bool) public hasMinted;



    constructor(

        string memory _name,

        string memory _symbol,

        string memory _baseURI,

        uint16 maxSupply_,

        address withdrawAddress,

        address _whitelistSignerAddress,

        uint256 _whitelistMintPrice,

        uint256 _whitelist2MintPrice,

        uint256 _publicMintPrice,

        uint256 _currentLimit

    )

        ERC721Template(

            _name,

            _symbol,

            _baseURI,

            maxSupply_,

            withdrawAddress,

            _whitelistSignerAddress,

            _publicMintPrice

        )

    {

        // Set all required variables

        currentLimit = _currentLimit;

        whitelistMintPrice = _whitelistMintPrice;

        whitelist2MintPrice = _whitelist2MintPrice;

    }



    /**

     * @dev Throws if minting exceeds current limit

     * @param _amount Mint amount

     */

    modifier noExceedCurrentLimit(uint256 _amount) {

        require(

            totalSupply() + _amount <= currentLimit,

            "Exceeded currentLimit!"

        );

        _;

    }



    /**

     * @dev Throws if the input stage does not match the current stage

     * @param _stage Input stage

     */

    modifier onlyStage(uint8 _stage) {

        require(stage == _stage, "Wrong stage!");

        _;

    }



    /**

     * @dev Whitelist Mint Phase 1

     * @param _amount Amount to mint

     * @param nonce Nonce to prevent replay attacks

     * @param signature Signature from backend signed by signer address if user is whitelisted

     */

    function whitelistMint(

        uint256 _amount,

        bytes calldata nonce,

        bytes calldata signature

    ) external payable noExceedCurrentLimit(_amount) onlyStage(1) {

        _mintWithSignature(_amount, nonce, signature, whitelistMintPrice);

    }



    /**

     * @dev Whitelist Mint Phase 2

     * @param _amount Amount to mint

     * @param nonce Nonce to prevent replay attacks

     * @param signature Signature from backend signed by signer address if user is whitelisted

     */

    function whitelistMint2(

        uint256 _amount,

        bytes calldata nonce,

        bytes calldata signature

    ) external payable noExceedCurrentLimit(_amount) onlyStage(3) {

        _mintWithSignature(_amount, nonce, signature, whitelist2MintPrice);

    }



    /**

     * @dev Free Mint

     * @param _amount Amount to mint

     * @param nonce Nonce to prevent replay attacks

     * @param signature Signature from backend signed by signer address if user is whitelisted

     */

    function freeMint(

        uint256 _amount,

        bytes calldata nonce,

        bytes calldata signature

    ) external {

        require(

            _authenticate(msg.sender, nonce, signature, _amount),

            "Invalid Signature for free mint!"

        );

        require(currentLimit <= MAX_SUPPLY, "Max supply reached!");

        if (totalSupply() >= currentLimit) {

            revert("No more free mint");

        }

        if (totalSupply() + _amount >= currentLimit) {

            _amount = currentLimit - totalSupply();

        }

        require(stage >= 1 || stage <= 5, "Free mint not open");

        require(!hasMinted[msg.sender], "No more free mint");

        hasMinted[msg.sender] = true;



        _mintWithRandomness(_amount);

    }



    /**

     * @dev Function to authenticate free mint

     * @param sender Address to check free mint eligibility

     * @param nonce Nonce to prevent replay attacks

     * @param signature Signature from backend signed by signer address if user is whitelisted

     */

    function _authenticate(

        address sender,

        bytes calldata nonce,

        bytes calldata signature,

        uint256 amount

    ) private view returns (bool) {

        bytes32 _hash = keccak256(

            abi.encodePacked(sender, nonce, FREE_MINT_FLAG, amount)

        );

        return

            whitelistSignerAddress ==

            ECDSA.toEthSignedMessageHash(_hash).recover(signature);

    }



    /**

     * @dev Public Mint

     * @param _amount Amount to mint

     */

    function publicMint(

        uint256 _amount

    ) external payable noExceedCurrentLimit(_amount) onlyStage(5) {

        _publicMint(_amount);

    }



    /**

     * @dev Allow users to free mint again

     * @param _addresses Addresses to reset

     */

    function resetFreeMint(address[] calldata _addresses) external onlyOwner {

        for (uint256 i; i < _addresses.length; ) {

            hasMinted[_addresses[i]] = false;

            unchecked {

                ++i;

            }

        }

    }



    /**

     * @dev Set phase 1 mint price

     * @param _whitelistMintPrice Phase 1 mint price

     */

    function setWhitelistMintPrice(

        uint256 _whitelistMintPrice

    ) external onlyOwner {

        whitelistMintPrice = _whitelistMintPrice;

    }



    /**

     * @dev Set phase 2 mint price

     * @param _whitelist2MintPrice Phase 2 mint price

     */

    function setWhitelistMintPrice2(

        uint256 _whitelist2MintPrice

    ) external onlyOwner {

        whitelist2MintPrice = _whitelist2MintPrice;

    }



    /**

     * @dev Set current limit

     * @param _currentLimit Current minting limit

     */

    function setCurrentLimit(uint256 _currentLimit) external onlyOwner {

        require(_currentLimit <= MAX_SUPPLY, "above max supply");

        currentLimit = _currentLimit;

    }

}