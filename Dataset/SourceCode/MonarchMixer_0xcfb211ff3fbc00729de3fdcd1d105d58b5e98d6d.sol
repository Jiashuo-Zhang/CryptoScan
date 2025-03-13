// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.17;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./ERC1155WithOperatorFilter.sol";

/**
 * @dev Monarch Mixer - Mintable ERC1155 NFT Contract
 *
 *      MonarchMixer <= ERC1155WithOperatorFilter
 *          <= ERC1155Rebased <= ERC1155Royalty
 *          <= ERC1155Supply <= ERC1155Metadata <= ERC1155
 */
contract MonarchMixer is ERC1155WithOperatorFilter {
    using ECDSA for bytes32;

    mapping(address => bool) private _signer;
    mapping(uint256 => uint256) private _deadline;
    mapping(uint256 => mapping(uint64 => bool)) private _sigIdClaimed;
    mapping(uint256 => mapping(address => bool)) private _accountClaimed;

    event Mint(address account, uint256 tokenId, uint256 proofId);
    event SetSigner(address indexed account, bool status);

    constructor(
        string memory name_,
        string memory symbol_,
        bytes memory uri_
    ) ERC1155Metadata(name_, symbol_) ERC1155(uri_) {}

    function isSigner(address account_) public view returns (bool) {
        return _signer[account_];
    }

    function getDeadline(uint256 tokenId_) public view returns (uint256) {
        return _deadline[tokenId_];
    }

    function isSigIdClaimed(
        uint256 tokenId_,
        uint64 sigId_
    ) public view returns (bool) {
        return _sigIdClaimed[tokenId_][sigId_];
    }

    function isAccountClaimed(
        uint256 tokenId_,
        address account_
    ) public view returns (bool) {
        return _accountClaimed[tokenId_][account_];
    }

    function recoverSigner(
        uint256 _tokenId,
        uint64 _sigId,
        bytes memory _signature
    ) public pure returns (address) {
        return _getEthSignedMsgHash(_tokenId, _sigId).recover(_signature);
    }

    function verifySig(
        uint256 _tokenId,
        uint64 _sigId,
        bytes memory _signature
    ) public view returns (bool) {
        return
            _signer[_getEthSignedMsgHash(_tokenId, _sigId).recover(_signature)];
    }

    function mint(
        uint256 tokenId_,
        uint64 sigId_,
        bytes memory signature_
    ) external {
        if (0 < _deadline[tokenId_]) {
            require(
                block.timestamp <= _deadline[tokenId_],
                "Mint: deadline missed"
            );
        }

        address account = _msgSender();

        require(
            !isAccountClaimed(tokenId_, account),
            string(
                abi.encodePacked(
                    Strings.toHexString(account),
                    " has already claimed TokenID #",
                    Strings.toString(tokenId_)
                )
            )
        );

        require(
            !isSigIdClaimed(tokenId_, sigId_),
            string(
                abi.encodePacked(
                    "#",
                    Strings.toString(sigId_),
                    "/",
                    Strings.toString(tokenId_),
                    " has already been used"
                )
            )
        );

        require(verifySig(tokenId_, sigId_, signature_), "Invalid signature");

        _sigIdClaimed[tokenId_][sigId_] = true;
        _accountClaimed[tokenId_][account] = true;
        _mint(account, tokenId_, 1, "");

        emit Mint(account, tokenId_, sigId_);
    }

    function setSigner(address account_) external onlyOwner {
        emit SetSigner(account_, true);
        _signer[account_] = true;
    }

    function revokeSigner(address account_) external onlyOwner {
        emit SetSigner(account_, false);
        delete _signer[account_];
    }

    function setDeadline(
        uint256 tokenId_,
        uint256 timestamp_
    ) external onlyOwner {
        if (0 < timestamp_) {
            _deadline[tokenId_] = timestamp_;
        } else {
            delete _deadline[tokenId_];
        }
    }

    function setTokenId(
        uint256 tokenId_,
        uint256 timestamp_,
        bytes memory baseUri_
    ) external onlyOwner {
        if (0 < timestamp_) {
            _deadline[tokenId_] = timestamp_;
        }

        _setURI(baseUri_);

        if (0 == supplyOf(tokenId_)) {
            _mint(owner(), tokenId_, 1, "");
        }
    }

    function _getEthSignedMsgHash(
        uint256 _tokenId,
        uint64 _sigId
    ) internal pure returns (bytes32) {
        return
            keccak256(abi.encodePacked(_tokenId, _sigId))
                .toEthSignedMessageHash();
    }
}