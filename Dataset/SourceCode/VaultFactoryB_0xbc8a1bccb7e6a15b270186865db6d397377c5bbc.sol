// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.7.6;

import {ERC721} from "./ERC721.sol";

import {IVaultFactory} from "./IVaultFactory.sol";
import {IInstanceRegistry} from "./InstanceRegistry.sol";
import {ProxyFactory} from "./ProxyFactory.sol";

import {IUniversalVaultB} from "./VaultB.sol";

/// @title VaultFactoryB
contract VaultFactoryB is IInstanceRegistry, ERC721, IVaultFactory {
    address private immutable _template;
    mapping(address => address) private _ownerVault;

    constructor(address template) ERC721("Vault v1", "VAULT-V1") {
        require(template != address(0), "VaultFactory: invalid template");
        _template = template;
    }

    /* registry functions */

    function isInstance(address instance) external view override returns (bool validity) {
        return ERC721._exists(uint256(instance));
    }

    function instanceCount() external view override returns (uint256 count) {
        return ERC721.totalSupply();
    }

    function instanceAt(uint256 index) external view override returns (address instance) {
        return address(ERC721.tokenByIndex(index));
    }

    /* factory functions */

    // function create(bytes calldata) external override returns (address vault) {
    //     return create();
    // }

    // function create2(bytes calldata, bytes32 salt) external override returns (address vault) {
    //     return create2(salt);
    // }

    function create() public override returns (address vault) {
        // create clone and initialize
        vault = ProxyFactory._create(
            _template,
            abi.encodeWithSelector(IUniversalVaultB.initialize.selector)
        );

        // mint nft to caller
        ERC721._safeMint(msg.sender, uint256(vault));
        _ownerVault[msg.sender] = vault;

        // emit event
        emit InstanceAdded(vault);

        // explicit return
        return vault;
    }

    function createFor(address beneficiary) public override returns (address vault) {
        // create clone and initialize
        vault = ProxyFactory._create(
            _template,
            abi.encodeWithSelector(IUniversalVaultB.initialize.selector)
        );

        // mint nft to caller
        ERC721._safeMint(beneficiary, uint256(vault));
        _ownerVault[beneficiary] = vault;

        // emit event
        emit InstanceAdded(vault);

        // explicit return
        return vault;
    }

    function create2(bytes32 salt) public override returns (address vault) {
        // create clone and initialize
        vault = ProxyFactory._create2(
            _template,
            abi.encodeWithSelector(IUniversalVaultB.initialize.selector),
            salt
        );

        // mint nft to caller
        ERC721._safeMint(msg.sender, uint256(vault));
        _ownerVault[msg.sender] = vault;

        // emit event
        emit InstanceAdded(vault);

        // explicit return
        return vault;
    }

    /* getter functions */

    function getTemplate() external view returns (address template) {
        return _template;
    }

    function getOwnerVault(address owner) external view override returns (address) {
        return _ownerVault[owner];
    }
}