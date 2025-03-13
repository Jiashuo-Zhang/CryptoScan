// SPDX-License-Identifier: GPL-3.0



pragma solidity ^0.8.19;



import "erc721a/contracts/ERC721A.sol";

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import { ERC2981 } from "@openzeppelin/contracts/token/common/ERC2981.sol";



//- Errors

error InvalidSignature();

error SaleNotStarted();

error InsufficientPayment();

error SupplyExceeded();

error PhaseSupplyExceeded();

error InvalidMintAmount();

error FreeClaimExceeded();

error InvalidNewSupply();

error WithdrawFailed();

error URIForNonExistentToken();



/** 

 * @title SyncUpAvatar

 * @author @Texoid__

 */

contract SyncUpAvatar is ERC721A, ERC2981, Ownable {

    using ECDSA for bytes32;



    //- If mint is enabled

    bool public mintEnabled = false;



    //- The cost, per NFT, in ETH

    uint256 public price = 0.022 ether;



    //- Maximum supply

    uint256 public maxSupply = 10000;



    //- Supply limit at the current phase

    uint256 public mintPhaseLimit = 2222;



    //- Max free claim amount

    uint256 public freeClaimLimit = 1;



    //- Max amount mintable per transaction

    uint256 public perTxLimit = 3;



    //- Address that signs messages for minting

    address public mintSigner;



    //- base token URI

    string private _baseTokenURI;



    constructor(string memory name, string memory symbol, string memory baseTokenURI, address _signer, address _royaltyReceiver) ERC721A (name, symbol) {



        //- Setting the base token URI

        _baseTokenURI = baseTokenURI;



        //- Setting the mint signer

        mintSigner = _signer;



        //- Setting 5% royalty

        _setDefaultRoyalty(_royaltyReceiver, 500);

        

    } 



    /**|=========================| MINT LOGIC |=========================|**/

    function publicMint(address to, uint256 amount, bytes calldata signature) external payable {



        if (!mintEnabled) revert SaleNotStarted();

        if (msg.value < price * amount) revert InsufficientPayment();

        if (_totalMinted() + amount > mintPhaseLimit) revert PhaseSupplyExceeded();



        //- Are they attempting to mint an imvalid amount

        if (amount < 1 || amount > perTxLimit) revert InvalidMintAmount();



        //- Validate signature

        bytes32 hashVal = keccak256(abi.encodePacked(to, amount, mintEnabled));

        bytes32 signedHash = hashVal.toEthSignedMessageHash();

        if (signedHash.recover(signature) != mintSigner) revert InvalidSignature();



        //- Mint tokens

        _mint(to, amount);

    }



    function freeClaim(address to, uint8 amount, string calldata code, bytes calldata signature) external payable {



        if (!mintEnabled) revert SaleNotStarted();

        if (_totalMinted() + amount > mintPhaseLimit) revert PhaseSupplyExceeded();



        //- Validate the signature

        bytes32 hashVal = keccak256(abi.encodePacked(to, amount, code));

        bytes32 signedHash = hashVal.toEthSignedMessageHash();

        if (signedHash.recover(signature) != mintSigner) revert InvalidSignature();



        //- Ensuring the user will has a free claim available

        uint64 claimCount = _getAux(to) + amount;

        if(claimCount > freeClaimLimit) revert FreeClaimExceeded();

        

        //- Update the claim count

        _setAux(to, claimCount);



        //- Mint the token

        _mint(to, amount);



    }



    function ownerMint(address to, uint256 amount) external payable onlyOwner {

        if(_totalMinted() + amount > maxSupply) revert SupplyExceeded();

        _mint(to, amount);

    }



    function freeClaimCount(address user) external view returns (uint64) {

        return _getAux(user);

    }



    function totalMintCount(address user) external view returns (uint256) {

        return _numberMinted(user);

    }



    //- overriding the start token ID so the first token is 1 not 0

    function _startTokenId() internal override view virtual returns (uint256) {

        return 1;

    }



    /**|=========================| MINT SETTINGS |=========================|**/

    function toggleMint() external onlyOwner {

        mintEnabled = !mintEnabled;

    }



    function setPrice(uint256 _price) external onlyOwner {

        price = _price;

    }



    //- Allows us to decrese the total max supply

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {

        if(_maxSupply >= maxSupply) revert InvalidNewSupply();

        maxSupply = _maxSupply;

    }



    //- Allows us to release more supply in the current phase, within collection sypply limits

    function setMintPhaseLimit(uint256 _mintPhaseLimit) external onlyOwner {

        if(_mintPhaseLimit > maxSupply) revert SupplyExceeded();

        mintPhaseLimit = _mintPhaseLimit;

    }



    function setPerTransactionLimit(uint256 _perTxLimit) external onlyOwner {

        perTxLimit = _perTxLimit;

    }



    function setMintSigner(address _signer) external onlyOwner {

        mintSigner = _signer;

    }



    function setFreeClaimLimit(uint256 _amount) external onlyOwner {

        freeClaimLimit = _amount;

    }



    function withdrawFunds(address receiver) external onlyOwner {

        (bool sent,) = receiver.call{value: address(this).balance}("");

        if (!sent) revert WithdrawFailed();

    }



    /**|=========================| METADATA |=========================|**/

    function setBaseURI(string calldata newBaseURI) external onlyOwner {

        _baseTokenURI = newBaseURI;

    }



    function _baseURI() internal view override returns (string memory) {

        return _baseTokenURI;

    }



    function tokenURI(uint256 tokenID) public view override returns (string memory) {

        if(!_exists(tokenID)) revert URIForNonExistentToken();



        string memory baseURI = _baseURI();

        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenID), ".json")) : "";

    }



    /**|=========================| ERC165 |=========================|**/

    function supportsInterface(bytes4 interfaceId) public view override(ERC721A, ERC2981) returns (bool) {

        // Supports the following `interfaceId`s:

        // - IERC165: 0x01ffc9a7

        // - IERC721: 0x80ac58cd

        // - IERC721Metadata: 0x5b5e139f

        // - IERC2981: 0x2a55205a

        return ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);

    }



    /**|=========================| ERC2891 |=========================|**/

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {

        _setDefaultRoyalty(receiver, feeNumerator);

    }



}