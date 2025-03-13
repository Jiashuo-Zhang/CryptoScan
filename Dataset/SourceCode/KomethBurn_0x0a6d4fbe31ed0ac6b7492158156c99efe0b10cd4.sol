/**
SPDX-License-Identifier: MIT
*/

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

interface IKometh {
    function burn(uint256 _tokenId) external;

    function mintTo(
        address[] calldata _to,
        uint256[] calldata _amount
    ) external;

    function ownerOf(uint256 _tokenId) external view returns (address);
}

/// @author yuru@Gaspack twitter.com/0xYuru
/// @custom:coauthor Radisa twitter.com/pr0ph0z
/// @dev aa0cdefd28cd450477ec80c28ecf3574 0x8fd31bb99658cb203b8c9034baf3f836c2bc2422fd30380fa30b8eade122618d3ca64095830cac2c0e84bc22910eef206eb43d54f71069f8d9e66cf8e4dcabec1c
contract KomethBurn is EIP712, ReentrancyGuard, Ownable {
    using ECDSA for bytes32;

    bytes32 public constant MINTER_TYPEHASH =
        keccak256(
            "KomethBurn(address burnContract,address mintContract,uint256[] tokenIds,uint256 quantity,address recipient)"
        );

    address public signer;

    event Burned(
        address burnContract,
        address mintContract,
        uint256[] burnedTokenIds,
        address minter
    );

    modifier notContract() {
        require(!_isContract(_msgSender()), "NOT_ALLOWED_CONTRACT");
        require(_msgSender() == tx.origin, "NOT_ALLOWED_PROXY");
        _;
    }

    constructor(address _signer) EIP712("KomethBurn", "1.0.0") {
        signer = _signer;
    }

    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }

    /// @notice Burn and mint NFT
    function burn(
        address _burnContract,
        address _mintContract,
        uint256[] calldata _tokenIds,
        uint256 _quantity,
        bytes calldata _signature
    ) external nonReentrant notContract {
        require(
            signer ==
                _verify(
                    _burnContract,
                    _mintContract,
                    _tokenIds,
                    _quantity,
                    msg.sender,
                    _signature
                ),
            "INVALID_SIGNATURE"
        );
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            require(
                IKometh(_burnContract).ownerOf(_tokenIds[i]) == msg.sender,
                "INVALID_OWNER"
            );
            IKometh(_burnContract).burn(_tokenIds[i]);
        }
        address[] memory mintAddresses = new address[](1);
        mintAddresses[0] = msg.sender;
        uint256[] memory mintQuantities = new uint256[](1);
        mintQuantities[0] = _quantity;

        IKometh(_mintContract).mintTo(mintAddresses, mintQuantities);

        emit Burned(_burnContract, _mintContract, _tokenIds, msg.sender);
    }

    function _verify(
        address _burnContract,
        address _mintContract,
        uint256[] calldata _tokenIds,
        uint256 _quantity,
        address _recipient,
        bytes calldata _sign
    ) internal view returns (address) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    MINTER_TYPEHASH,
                    _burnContract,
                    _mintContract,
                    keccak256(abi.encodePacked(_tokenIds)),
                    _quantity,
                    _recipient
                )
            )
        );
        return ECDSA.recover(digest, _sign);
    }

    /// @notice Set signer for whitelist/redeem NFT.
    /// @param _signer address of signer
    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }
}