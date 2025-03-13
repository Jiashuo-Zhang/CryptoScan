/*----------------------------------------------------------*|
|*          ███    ██ ██ ███    ██ ███████  █████           *|
|*          ████   ██ ██ ████   ██ ██      ██   ██          *|
|*          ██ ██  ██ ██ ██ ██  ██ █████   ███████          *|
|*          ██  ██ ██ ██ ██  ██ ██ ██      ██   ██          *|
|*          ██   ████ ██ ██   ████ ██      ██   ██          *|
|*----------------------------------------------------------*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "./access/AccessControl.sol";

/**
 *
 * @title NinfaWhitelist                               *
 *                                                           *
 * @notice allowa lazy whitelist and access control          *
 *                                                           *
 * @custom:security-contact [email protected]                    *
 *
 */

// this contract will need to have the CURATOR_ROLE on the factory
// and to be the owner of the marketplace and auction contracts
contract NinfaWhitelist is AccessControl {

    address private feeAccount; // this is the address that will receive the fee

    bytes32 private DOMAIN_SEPARATOR;
    bytes32 private DOMAIN_TYPEHASH;
    bytes32 private WHITELIST_PERMIT_TYPEHASH;

    // keccak256("CURATOR_ROLE");
    bytes32 private constant CURATOR_ROLE = 0x850d585eb7f024ccee5e68e55f2c26cc72e1e6ee456acf62135757a5eb9d4a10;

    uint256 private flatFee;

    mapping(bytes => bool) private usedSignatures;

    mapping(address => bool) public isWhitelisted;

    struct WhitelistPermit {
        address collection;
        bool isWhitelisted;
        bytes32 collectionType;
        bytes32 salt;
    }

    event Whitelist(
        address collection, address indexed whitelister, bytes32 indexed collectionType, bool isWhitelisted
    );

    /**
     * @dev whoever has a valid signature can call the whitelistCollection
     * function, a flat fee could be payed of any
     * @param _permit contains information on what collection to whitelist and
     * if it should be whitelisted or not
     * @param _signature the signature of the curator
     */
    function whitelistCollection(WhitelistPermit calldata _permit, bytes memory _signature) external payable {
        require(msg.value >= flatFee);

        if (flatFee > 0) {
            _sendValue(feeAccount, flatFee);
        }

        address _signer = _recover(_permit, _signature);

        require(hasRole(CURATOR_ROLE, _signer) && !usedSignatures[_signature]);

        usedSignatures[_signature] = true;

        isWhitelisted[_permit.collection] = _permit.isWhitelisted;

        emit Whitelist(_permit.collection, msg.sender, _permit.collectionType, _permit.isWhitelisted);
    }

    /*----------------------------------------------------------*|
    |*  # RECOVER FUNCTIONS                                     *|
    |*----------------------------------------------------------*/

    function _recover(
        WhitelistPermit calldata _permit,
        bytes memory _signature
    )
        private
        view
        returns (address _signer)
    {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        WHITELIST_PERMIT_TYPEHASH,
                        _permit.collection,
                        _permit.isWhitelisted,
                        _permit.collectionType,
                        _permit.salt
                    )
                )
            )
        );

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_signature, 0x20))
            s := mload(add(_signature, 0x40))
            v := byte(0, mload(add(_signature, 0x60)))
        }

        _signer = ecrecover(digest, v, r, s);
        if (_signer == address(0)) revert();
    }

    /*----------------------------------------------------------*|
    |*  # OWNER FUNCTIONS                                       *|
    |*----------------------------------------------------------*/

    function setFlatFee(uint256 _flatFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        flatFee = _flatFee;
    }

    function setFeeAccount(address _feeAccount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        feeAccount = _feeAccount;
    }

    // this function is used to allow the curator to firectly whitelist a collection
    function whitelistCollection(address collection, bool isWhitelisted_) external onlyRole(CURATOR_ROLE) {
        isWhitelisted[collection] = isWhitelisted_;
    }

    function whitelistCollections(address[] memory collections, bool isWhitelisted_) external onlyRole(CURATOR_ROLE) {
        for (uint256 i = 0; i < collections.length; i++) {
            isWhitelisted[collections[i]] = isWhitelisted_;
        }
    }

    receive() external payable {
        revert();
    }

    /*----------------------------------------------------------*|
    |*  #  OTHER                                                *|
    |*----------------------------------------------------------*/

    function _sendValue(address _receiver, uint256 _amount) private {
        // solhint-disable-next-line avoid-low-level-calls
        (bool success,) = payable(_receiver).call{ value: _amount }("");
        require(success);
    }

    constructor(string memory _eip712DomainName) {
        DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");
        WHITELIST_PERMIT_TYPEHASH =
            keccak256("WhitelistPermit(address collection,bool isWhitelisted,bytes32 collectionType,bytes32 salt)");

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(_eip712DomainName)), // name
                block.chainid, // chainId
                address(this) // verifyingContract
            )
        );

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
}