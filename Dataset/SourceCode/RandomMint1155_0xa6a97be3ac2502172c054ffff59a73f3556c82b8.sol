// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC1155Mintable} from "./../interfaces/IERC1155Mintable.sol";
import {Payable} from "./../libraries/Payable.sol";
import {SignatureProtected} from "./../libraries/SignatureProtected.sol";
import {TimeProtected} from "./../libraries/TimeProtected.sol";
import {RandomGenerator} from "./../libraries/RandomGenerator.sol";
import {AccessProtected} from "./../libraries/AccessProtected.sol";

// @author: NFT Studios

contract RandomMint1155 is Payable, SignatureProtected, TimeProtected, RandomGenerator, AccessProtected {
    IERC1155Mintable public erc1155Contract;

    uint16[] private availableTokensPerType;

    constructor(
        uint16[] memory _availableTokensPerType,
        address _signerAddress,
        address _erc1155Address
    ) SignatureProtected(_signerAddress) {
        erc1155Contract = IERC1155Mintable(_erc1155Address);
        availableTokensPerType = _availableTokensPerType;
    }

    function setAvailableTokens(uint16[] memory _availableTokensPerType) external onlyOwner {
        availableTokensPerType = _availableTokensPerType;
    }

    function mint(
        uint256 _amount,
        uint256 _maxPerTransaction,
        uint256 _pricePerToken,
        uint256 _fromTimestamp,
        uint256 _toTimestamp,
        bytes calldata _signature
    ) external payable onlyUser {
        validateSignature(
            abi.encodePacked(_maxPerTransaction, _pricePerToken, _fromTimestamp, _toTimestamp),
            _signature
        );

        isMintOpen(_fromTimestamp, _toTimestamp);

        require(_amount <= _maxPerTransaction, "The amount to mint can not be greater than the maximum allowed per TX");

        uint256 availableTokens = getAvailableTokens();

        if (_amount > availableTokens) {
            _amount = availableTokens;
        }

        checkSentEther(_amount * _pricePerToken);

        require(_amount > 0, "No tokens left to be minted");

        uint256[] memory ids = new uint256[](_amount);
        uint256[] memory amounts = new uint256[](_amount);

        for (uint256 i; i < _amount; i++) {
            uint256 random = getRandomNumber(availableTokens, i);
            ids[i] = getTokenTypeByIndex(random);
            amounts[i] = 1;
            availableTokensPerType[ids[i]]--;
            availableTokens--;
        }

        erc1155Contract.mint(msg.sender, ids, amounts);
    }

    function getAvailableTokens() public view returns (uint256 total) {
        for (uint256 i; i < availableTokensPerType.length; i++) {
            total += availableTokensPerType[i];
        }
    }

    function getTokenTypeByIndex(uint256 index) private view returns (uint256) {
        uint256 counter;
        for (uint256 tokenType; tokenType < availableTokensPerType.length; tokenType++) {
            counter += availableTokensPerType[tokenType];
            if (counter > index) {
                return tokenType;
            }
        }

        revert("Can not find a type for the given index");
    }
}