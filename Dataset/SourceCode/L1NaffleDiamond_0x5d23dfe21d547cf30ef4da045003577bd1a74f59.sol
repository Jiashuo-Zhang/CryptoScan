// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@solidstate/contracts/access/access_control/AccessControlStorage.sol";
import "@solidstate/contracts/proxy/diamond/SolidStateDiamond.sol";
import "@solidstate/contracts/access/access_control/AccessControl.sol";
import "./L1NaffleBaseInternal.sol";

/**
    @title L1 Naffle Diamond
    @dev diamond implementation contract for L1 Naffle
    @notice inherits from SolidStateDiamond, AccessControl, L1NaffleBaseInternal
 */
contract L1NaffleDiamond is SolidStateDiamond, AccessControl, L1NaffleBaseInternal {
    constructor(
        address _admin,
        uint256 _minimumNaffleDuration,
        uint256 _minimumPaidTicketSpots,
        address _zksyncContractAddress,
        address _foundersKeyContractAddress,
        address _foundersKeyPlaceholderAddress,
        string memory _domainName
    ) SolidStateDiamond() {
        _grantRole(AccessControlStorage.DEFAULT_ADMIN_ROLE, _admin);
        _setMinimumNaffleDuration(_minimumNaffleDuration);
        _setMinimumPaidTicketSpots(_minimumPaidTicketSpots);
        _setFoundersKeyAddress(_foundersKeyContractAddress);
        _setFoundersKeyPlaceholderAddress(_foundersKeyPlaceholderAddress);
        _setZkSyncAddress(_zksyncContractAddress);

        _setSignatureSignerAddress(msg.sender);
        _setCollectionWhitelistSignature(keccak256(abi.encodePacked("CollectionWhitelist(address tokenAddress,uint256 expiresAt)")));
        _setDomainSignature(keccak256(abi.encodePacked("EIP712Domain(string name)")));
        _setDomainName(_domainName);
    }
}