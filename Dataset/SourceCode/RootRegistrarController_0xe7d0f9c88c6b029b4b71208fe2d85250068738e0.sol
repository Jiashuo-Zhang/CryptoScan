//SPDX-License-Identifier: MIT

pragma solidity ~0.8.17;

import {BaseRegistrarImplementation} from "./BaseRegistrarImplementation.sol";

import {StringUtils} from "./StringUtils.sol";

import {Resolver} from "../resolvers/Resolver.sol";

import {ReverseRegistrar} from "../registry/ReverseRegistrar.sol";

import {IRootRegistrarController, IPriceOracle} from "./IRootRegistrarController.sol";



import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

import {PaymentSplitter} from "@openzeppelin/contracts/finance/PaymentSplitter.sol";

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import {INameWrapper} from "../wrapper/INameWrapper.sol";

import {ERC20Recoverable} from "../utils/ERC20Recoverable.sol";

import {IReservedDomains} from "./IReservedDomains.sol";



error CommitmentTooNew(bytes32 commitment);

error CommitmentTooOld(bytes32 commitment);

error NameNotAvailable(string name);

error DurationTooShort(uint256 duration);

error ResolverRequiredWhenDataSupplied();

error UnexpiredCommitmentExists(bytes32 commitment);

error InsufficientValue();

error Unauthorised(bytes32 node);

error MaxCommitmentAgeTooLow();

error MaxCommitmentAgeTooHigh();



/**

 * @dev A registrar controller for registering and renewing names at fixed cost.

 */

contract RootRegistrarController is

    IRootRegistrarController,

    IERC165,

    ERC20Recoverable,

    PaymentSplitter

{

    using StringUtils for *;

    using Address for address;



    uint256 public constant MIN_REGISTRATION_DURATION = 28 days;

    bytes32 private constant ROOT_NODE = 0;

    uint64 private constant MAX_EXPIRY = type(uint64).max;

    uint256 public immutable START;

    BaseRegistrarImplementation immutable base;

    IPriceOracle public immutable prices;

    uint256 public immutable minCommitmentAge;

    uint256 public immutable maxCommitmentAge;

    ReverseRegistrar public immutable reverseRegistrar;

    INameWrapper public immutable nameWrapper;

    IReservedDomains public immutable reservedDomains;

    IERC721 public immutable BAYC;



    mapping(bytes32 => uint256) public commitments;



    event NameRegistered(

        string name,

        bytes32 indexed label,

        address indexed owner,

        uint256 baseCost,

        uint256 premium,

        uint256 expires

    );

    event NameRenewed(

        string name,

        bytes32 indexed label,

        uint256 cost,

        uint256 expires

    );



    constructor(

        BaseRegistrarImplementation _base,

        IPriceOracle _prices,

        uint256 _minCommitmentAge,

        uint256 _maxCommitmentAge,

        ReverseRegistrar _reverseRegistrar,

        INameWrapper _nameWrapper,

        IReservedDomains _reservedDomains,

        IERC721 _BAYC,

        address[] memory _payees,

        uint256[] memory _shares

    ) PaymentSplitter(_payees, _shares) {

        if (_maxCommitmentAge <= _minCommitmentAge) {

            revert MaxCommitmentAgeTooLow();

        }



        if (_maxCommitmentAge > block.timestamp) {

            revert MaxCommitmentAgeTooHigh();

        }



        base = _base;

        prices = _prices;

        minCommitmentAge = _minCommitmentAge;

        maxCommitmentAge = _maxCommitmentAge;

        reverseRegistrar = _reverseRegistrar;

        nameWrapper = _nameWrapper;

        reservedDomains = _reservedDomains;

        BAYC = _BAYC;



        START = block.timestamp;

    }



    function rentPrice(string memory name, uint256 duration)

        public

        view

        override

        returns (IPriceOracle.Price memory price)

    {

        bytes32 label = keccak256(bytes(name));

        price = prices.price(

            name, 

            base.nameExpires(uint256(label)), 

            duration, 

            reservedDomains.isSpecial(label)

        );

    }



    function valid(string memory name) public pure returns (bool) {

        uint256 len = name.strlen();

        return len >= 1 && len <= 63;

    }



    function available(string memory name) public view override returns (bool) {

        bytes32 label = keccak256(bytes(name));

        return valid(name) && base.available(uint256(label));

    }



    function availableNFT(uint256 id, address _address) public view override returns (bool) {

        if(id < 1000 || block.timestamp - START > 60 days){

            return false;

        }

        

        try BAYC.ownerOf(id) returns (address owner){

            if (owner == _address){

                string memory name = Strings.toString(id);

                bytes32 label = keccak256(bytes(name));

                return valid(name) && base.available(uint256(label));

            }

            return false;

        } catch {

            return false;

        }

    }



    function makeCommitment(

        string memory name,

        address owner,

        uint256 duration,

        bytes32 secret,

        address resolver,

        bytes[] calldata data,

        bool reverseRecord,

        uint32 fuses,

        uint64 wrapperExpiry

    ) public pure override returns (bytes32) {

        bytes32 label = keccak256(bytes(name));

        if (data.length > 0 && resolver == address(0)) {

            revert ResolverRequiredWhenDataSupplied();

        }

        return

            keccak256(

                abi.encode(

                    label,

                    owner,

                    duration,

                    resolver,

                    data,

                    secret,

                    reverseRecord,

                    fuses,

                    wrapperExpiry

                )

            );

    }



    function commit(bytes32 commitment) public override {

        if (commitments[commitment] + maxCommitmentAge >= block.timestamp) {

            revert UnexpiredCommitmentExists(commitment);

        }

        commitments[commitment] = block.timestamp;

    }



    function register(

        string calldata name,

        address owner,

        uint256 duration,

        bytes32 secret,

        address resolver,

        bytes[] calldata data,

        bool reverseRecord,

        uint32 fuses,

        uint64 wrapperExpiry

    ) external payable override {

        IPriceOracle.Price memory price = rentPrice(name, duration);

        if (msg.value < price.base + price.premium) {

            revert InsufficientValue();

        }



        if (!available(name)) {

            revert NameNotAvailable(name);

        }



        _consumeCommitment(

            makeCommitment(

                name,

                owner,

                duration,

                secret,

                resolver,

                data,

                reverseRecord,

                fuses,

                wrapperExpiry

            )

        );

        

        if (duration < MIN_REGISTRATION_DURATION) {

            revert DurationTooShort(duration);

        }



        uint256 expires = nameWrapper.registerAndWrap(

            name,

            owner,

            duration,

            resolver,

            fuses,

            wrapperExpiry

        );



        if (data.length > 0) {

            _setRecords(resolver, keccak256(bytes(name)), data);

        }



        if (reverseRecord) {

            _setReverseRecord(name, resolver, msg.sender);

        }



        emit NameRegistered(

            name,

            keccak256(bytes(name)),

            owner,

            price.base,

            price.premium,

            expires

        );



        if (msg.value > (price.base + price.premium)) {

            payable(msg.sender).transfer(

                msg.value - (price.base + price.premium)

            );

        }

    }



    function registerNFT(

        uint256 id,

        address owner,

        bytes32 secret,

        address resolver,

        bytes[] calldata data,

        bool reverseRecord,

        uint32 fuses,

        uint64 wrapperExpiry

    ) external override {

        string memory name = Strings.toString(id);

        if (!availableNFT(id, msg.sender)) {

            revert NameNotAvailable(name);

        }



        _consumeCommitment(

            makeCommitment(

                name,

                owner,

                365 days,

                secret,

                resolver,

                data,

                reverseRecord,

                fuses,

                wrapperExpiry

            )

        );



        uint256 expires = nameWrapper.registerAndWrap(

            name,

            owner,

            365 days,

            resolver,

            fuses,

            wrapperExpiry

        );



        if (data.length > 0) {

            _setRecords(resolver, keccak256(bytes(name)), data);

        }



        if (reverseRecord) {

            _setReverseRecord(name, resolver, msg.sender);

        }



        emit NameRegistered(

            name,

            keccak256(bytes(name)),

            owner,

            0,

            0,

            expires

        );

    }



    function renew(string calldata name, uint256 duration)

        external

        payable

        override

    {

        _renew(name, duration, 0, 0);

    }



    function renewWithFuses(

        string calldata name,

        uint256 duration,

        uint32 fuses,

        uint64 wrapperExpiry

    ) external payable {

        bytes32 labelhash = keccak256(bytes(name));

        bytes32 nodehash = keccak256(abi.encodePacked(ROOT_NODE, labelhash));

        if (!nameWrapper.isTokenOwnerOrApproved(nodehash, msg.sender)) {

            revert Unauthorised(nodehash);

        }

        _renew(name, duration, fuses, wrapperExpiry);

    }



    function _renew(

        string calldata name,

        uint256 duration,

        uint32 fuses,

        uint64 wrapperExpiry

    ) internal {

        bytes32 labelhash = keccak256(bytes(name));

        uint256 tokenId = uint256(labelhash);

        IPriceOracle.Price memory price = rentPrice(name, duration);

        if (msg.value < price.base) {

            revert InsufficientValue();

        }

        uint256 expires;

        expires = nameWrapper.renew(tokenId, duration, fuses, wrapperExpiry);



        if (msg.value > price.base) {

            payable(msg.sender).transfer(msg.value - price.base);

        }



        emit NameRenewed(name, labelhash, msg.value, expires);

    }



    function supportsInterface(bytes4 interfaceID)

        external

        pure

        returns (bool)

    {

        return

            interfaceID == type(IERC165).interfaceId ||

            interfaceID == type(IRootRegistrarController).interfaceId;

    }



    /* Internal functions */



    function _consumeCommitment(

        bytes32 commitment

    ) internal {

        // Require an old enough commitment.

        if (commitments[commitment] + minCommitmentAge > block.timestamp) {

            revert CommitmentTooNew(commitment);

        }



        // If the commitment is too old stop

        if (commitments[commitment] + maxCommitmentAge <= block.timestamp) {

            revert CommitmentTooOld(commitment);

        }



        delete (commitments[commitment]);

    }



    function _setRecords(

        address resolverAddress,

        bytes32 label,

        bytes[] calldata data

    ) internal {

        bytes32 nodehash = keccak256(abi.encodePacked(ROOT_NODE, label));

        Resolver resolver = Resolver(resolverAddress);

        resolver.multicallWithNodeCheck(nodehash, data);

    }



    function _setReverseRecord(

        string memory name,

        address resolver,

        address owner

    ) internal {

        reverseRegistrar.setNameForAddr(

            msg.sender,

            owner,

            resolver,

            name

        );

    }

}