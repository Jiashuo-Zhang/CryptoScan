// SPDX-License-Identifier: MIT
//
//          [email protected]@@                                                                  
//               ,@@@@@@@&,                  #@@%                                  
//                    @@@@@@@@@@@@@@.          @@@@@@@@@                           
//                        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                      
//                            @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   
//                                @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.                 
//                                    @@@@@@@    &@@@@@@@@@@@@@@@@@                
//                                        @@@/        &@@@@@@@@@@@@@,              
//                                            @            @@@@@@@@@@@             
//                                                             /@@@@@@@#           
//                                                                  @@@@@          
//                                                                      *@&   
//         RTFKT Studios (https://twitter.com/RTFKT)
//         NFC-NFT Linking Contract (made by @CardilloSamuel)

pragma solidity 0.8.17;

import '@solidstate/contracts/proxy/diamond/SolidStateDiamond.sol';

contract FuncDiamond is SolidStateDiamond {
    
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IOwnable, Ownable, OwnableInternal, OwnableStorage } from '../../access/ownable/Ownable.sol';
import { ISafeOwnable, SafeOwnable } from '../../access/ownable/SafeOwnable.sol';
import { IERC173 } from '../../interfaces/IERC173.sol';
import { ERC165, IERC165, ERC165Storage } from '../../introspection/ERC165.sol';
import { DiamondBase, DiamondBaseStorage } from './base/DiamondBase.sol';
import { DiamondReadable, IDiamondReadable } from './readable/DiamondReadable.sol';
import { DiamondWritable, IDiamondWritable } from './writable/DiamondWritable.sol';
import { ISolidStateDiamond } from './ISolidStateDiamond.sol';

/**
 * @title SolidState "Diamond" proxy reference implementation
 */
abstract contract SolidStateDiamond is
    ISolidStateDiamond,
    DiamondBase,
    DiamondReadable,
    DiamondWritable,
    SafeOwnable,
    ERC165
{
    using DiamondBaseStorage for DiamondBaseStorage.Layout;
    using ERC165Storage for ERC165Storage.Layout;
    using OwnableStorage for OwnableStorage.Layout;

    constructor() {
        ERC165Storage.Layout storage erc165 = ERC165Storage.layout();
        bytes4[] memory selectors = new bytes4[](12);

        // register DiamondWritable

        selectors[0] = IDiamondWritable.diamondCut.selector;

        erc165.setSupportedInterface(type(IDiamondWritable).interfaceId, true);

        // register DiamondReadable

        selectors[1] = IDiamondReadable.facets.selector;
        selectors[2] = IDiamondReadable.facetFunctionSelectors.selector;
        selectors[3] = IDiamondReadable.facetAddresses.selector;
        selectors[4] = IDiamondReadable.facetAddress.selector;

        erc165.setSupportedInterface(type(IDiamondReadable).interfaceId, true);

        // register ERC165

        selectors[5] = IERC165.supportsInterface.selector;

        erc165.setSupportedInterface(type(IERC165).interfaceId, true);

        // register SafeOwnable

        selectors[6] = Ownable.owner.selector;
        selectors[7] = SafeOwnable.nomineeOwner.selector;
        selectors[8] = Ownable.transferOwnership.selector;
        selectors[9] = SafeOwnable.acceptOwnership.selector;

        erc165.setSupportedInterface(type(IERC173).interfaceId, true);

        // register Diamond

        selectors[10] = SolidStateDiamond.getFallbackAddress.selector;
        selectors[11] = SolidStateDiamond.setFallbackAddress.selector;

        // diamond cut

        FacetCut[] memory facetCuts = new FacetCut[](1);

        facetCuts[0] = FacetCut({
            target: address(this),
            action: FacetCutAction.ADD,
            selectors: selectors
        });

        _diamondCut(facetCuts, address(0), '');

        // set owner

        OwnableStorage.layout().setOwner(msg.sender);
    }

    receive() external payable {}

    /**
     * @inheritdoc ISolidStateDiamond
     */
    function getFallbackAddress() external view returns (address) {
        return DiamondBaseStorage.layout().fallbackAddress;
    }

    /**
     * @inheritdoc ISolidStateDiamond
     */
    function setFallbackAddress(address fallbackAddress) external onlyOwner {
        DiamondBaseStorage.layout().fallbackAddress = fallbackAddress;
    }

    function _transferOwnership(address account)
        internal
        virtual
        override(OwnableInternal, SafeOwnable)
    {
        super._transferOwnership(account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { ISafeOwnable } from '../../access/ownable/ISafeOwnable.sol';
import { IERC165 } from '../../interfaces/IERC165.sol';
import { IDiamondBase } from './base/IDiamondBase.sol';
import { IDiamondReadable } from './readable/IDiamondReadable.sol';
import { IDiamondWritable } from './writable/IDiamondWritable.sol';

interface ISolidStateDiamond is
    IDiamondBase,
    IDiamondReadable,
    IDiamondWritable,
    ISafeOwnable,
    IERC165
{
    receive() external payable;

    /**
     * @notice get the address of the fallback contract
     * @return fallback address
     */
    function getFallbackAddress() external view returns (address);

    /**
     * @notice set the address of the fallback contract
     * @param fallbackAddress fallback address
     */
    function setFallbackAddress(address fallbackAddress) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { OwnableInternal } from '../../../access/ownable/OwnableInternal.sol';
import { DiamondBaseStorage } from '../base/DiamondBaseStorage.sol';
import { IDiamondWritable } from './IDiamondWritable.sol';
import { DiamondWritableInternal } from './DiamondWritableInternal.sol';

/**
 * @title EIP-2535 "Diamond" proxy update contract
 */
abstract contract DiamondWritable is
    IDiamondWritable,
    DiamondWritableInternal,
    OwnableInternal
{
    using DiamondBaseStorage for DiamondBaseStorage.Layout;

    /**
     * @inheritdoc IDiamondWritable
     */
    function diamondCut(
        FacetCut[] calldata facetCuts,
        address target,
        bytes calldata data
    ) external onlyOwner {
        _diamondCut(facetCuts, target, data);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { DiamondBaseStorage } from '../base/DiamondBaseStorage.sol';
import { IDiamondReadable } from './IDiamondReadable.sol';

/**
 * @title EIP-2535 "Diamond" proxy introspection contract
 * @dev derived from https://github.com/mudgen/diamond-2 (MIT license)
 */
abstract contract DiamondReadable is IDiamondReadable {
    /**
     * @inheritdoc IDiamondReadable
     */
    function facets() external view returns (Facet[] memory diamondFacets) {
        DiamondBaseStorage.Layout storage l = DiamondBaseStorage.layout();

        diamondFacets = new Facet[](l.selectorCount);

        uint8[] memory numFacetSelectors = new uint8[](l.selectorCount);
        uint256 numFacets;
        uint256 selectorIndex;

        // loop through function selectors
        for (uint256 slotIndex; selectorIndex < l.selectorCount; slotIndex++) {
            bytes32 slot = l.selectorSlots[slotIndex];

            for (
                uint256 selectorSlotIndex;
                selectorSlotIndex < 8;
                selectorSlotIndex++
            ) {
                selectorIndex++;

                if (selectorIndex > l.selectorCount) {
                    break;
                }

                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facet = address(bytes20(l.facets[selector]));

                bool continueLoop;

                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
                    if (diamondFacets[facetIndex].target == facet) {
                        diamondFacets[facetIndex].selectors[
                            numFacetSelectors[facetIndex]
                        ] = selector;
                        // probably will never have more than 256 functions from one facet contract
                        require(numFacetSelectors[facetIndex] < 255);
                        numFacetSelectors[facetIndex]++;
                        continueLoop = true;
                        break;
                    }
                }

                if (continueLoop) {
                    continue;
                }

                diamondFacets[numFacets].target = facet;
                diamondFacets[numFacets].selectors = new bytes4[](
                    l.selectorCount
                );
                diamondFacets[numFacets].selectors[0] = selector;
                numFacetSelectors[numFacets] = 1;
                numFacets++;
            }
        }

        for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
            uint256 numSelectors = numFacetSelectors[facetIndex];
            bytes4[] memory selectors = diamondFacets[facetIndex].selectors;

            // setting the number of selectors
            assembly {
                mstore(selectors, numSelectors)
            }
        }

        // setting the number of facets
        assembly {
            mstore(diamondFacets, numFacets)
        }
    }

    /**
     * @inheritdoc IDiamondReadable
     */
    function facetFunctionSelectors(address facet)
        external
        view
        returns (bytes4[] memory selectors)
    {
        DiamondBaseStorage.Layout storage l = DiamondBaseStorage.layout();

        selectors = new bytes4[](l.selectorCount);

        uint256 numSelectors;
        uint256 selectorIndex;

        // loop through function selectors
        for (uint256 slotIndex; selectorIndex < l.selectorCount; slotIndex++) {
            bytes32 slot = l.selectorSlots[slotIndex];

            for (
                uint256 selectorSlotIndex;
                selectorSlotIndex < 8;
                selectorSlotIndex++
            ) {
                selectorIndex++;

                if (selectorIndex > l.selectorCount) {
                    break;
                }

                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));

                if (facet == address(bytes20(l.facets[selector]))) {
                    selectors[numSelectors] = selector;
                    numSelectors++;
                }
            }
        }

        // set the number of selectors in the array
        assembly {
            mstore(selectors, numSelectors)
        }
    }

    /**
     * @inheritdoc IDiamondReadable
     */
    function facetAddresses()
        external
        view
        returns (address[] memory addresses)
    {
        DiamondBaseStorage.Layout storage l = DiamondBaseStorage.layout();

        addresses = new address[](l.selectorCount);
        uint256 numFacets;
        uint256 selectorIndex;

        for (uint256 slotIndex; selectorIndex < l.selectorCount; slotIndex++) {
            bytes32 slot = l.selectorSlots[slotIndex];

            for (
                uint256 selectorSlotIndex;
                selectorSlotIndex < 8;
                selectorSlotIndex++
            ) {
                selectorIndex++;

                if (selectorIndex > l.selectorCount) {
                    break;
                }

                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));
                address facet = address(bytes20(l.facets[selector]));

                bool continueLoop;

                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {
                    if (facet == addresses[facetIndex]) {
                        continueLoop = true;
                        break;
                    }
                }

                if (continueLoop) {
                    continue;
                }

                addresses[numFacets] = facet;
                numFacets++;
            }
        }

        // set the number of facet addresses in the array
        assembly {
            mstore(addresses, numFacets)
        }
    }

    /**
     * @inheritdoc IDiamondReadable
     */
    function facetAddress(bytes4 selector)
        external
        view
        returns (address facet)
    {
        facet = address(bytes20(DiamondBaseStorage.layout().facets[selector]));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { Proxy } from '../../Proxy.sol';
import { IDiamondBase } from './IDiamondBase.sol';
import { DiamondBaseStorage } from './DiamondBaseStorage.sol';

/**
 * @title EIP-2535 "Diamond" proxy base contract
 * @dev see https://eips.ethereum.org/EIPS/eip-2535
 */
abstract contract DiamondBase is IDiamondBase, Proxy {
    /**
     * @inheritdoc Proxy
     */
    function _getImplementation() internal view override returns (address) {
        // inline storage layout retrieval uses less gas
        DiamondBaseStorage.Layout storage l;
        bytes32 slot = DiamondBaseStorage.STORAGE_SLOT;
        assembly {
            l.slot := slot
        }

        address implementation = address(bytes20(l.facets[msg.sig]));

        if (implementation == address(0)) {
            implementation = l.fallbackAddress;
            if (implementation == address(0))
                revert DiamondBase__NoFacetForSignature();
        }

        return implementation;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC165 } from '../interfaces/IERC165.sol';
import { ERC165Storage } from './ERC165Storage.sol';

/**
 * @title ERC165 implementation
 */
abstract contract ERC165 is IERC165 {
    using ERC165Storage for ERC165Storage.Layout;

    /**
     * @inheritdoc IERC165
     */
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {
        return ERC165Storage.layout().isSupportedInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173Internal } from './IERC173Internal.sol';

/**
 * @title Contract ownership standard interface
 * @dev see https://eips.ethereum.org/EIPS/eip-173
 */
interface IERC173 is IERC173Internal {
    /**
     * @notice get the ERC173 contract owner
     * @return conrtact owner
     */
    function owner() external view returns (address);

    /**
     * @notice transfer contract ownership to new account
     * @param account address of new owner
     */
    function transferOwnership(address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { Ownable, OwnableStorage } from './Ownable.sol';
import { ISafeOwnable } from './ISafeOwnable.sol';
import { OwnableInternal } from './OwnableInternal.sol';
import { SafeOwnableInternal } from './SafeOwnableInternal.sol';

/**
 * @title Ownership access control based on ERC173 with ownership transfer safety check
 */
abstract contract SafeOwnable is ISafeOwnable, Ownable, SafeOwnableInternal {
    /**
     * @inheritdoc ISafeOwnable
     */
    function nomineeOwner() public view virtual returns (address) {
        return _nomineeOwner();
    }

    /**
     * @inheritdoc ISafeOwnable
     */
    function acceptOwnership() public virtual onlyNomineeOwner {
        _acceptOwnership();
    }

    function _transferOwnership(address account)
        internal
        virtual
        override(OwnableInternal, SafeOwnableInternal)
    {
        super._transferOwnership(account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173 } from '../../interfaces/IERC173.sol';
import { IOwnable } from './IOwnable.sol';
import { OwnableInternal } from './OwnableInternal.sol';
import { OwnableStorage } from './OwnableStorage.sol';

/**
 * @title Ownership access control based on ERC173
 */
abstract contract Ownable is IOwnable, OwnableInternal {
    using OwnableStorage for OwnableStorage.Layout;

    /**
     * @inheritdoc IERC173
     */
    function owner() public view virtual returns (address) {
        return _owner();
    }

    /**
     * @inheritdoc IERC173
     */
    function transferOwnership(address account) public virtual onlyOwner {
        _transferOwnership(account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { AddressUtils } from '../../../utils/AddressUtils.sol';
import { DiamondBaseStorage } from '../base/DiamondBaseStorage.sol';
import { IDiamondWritableInternal } from './IDiamondWritableInternal.sol';

abstract contract DiamondWritableInternal is IDiamondWritableInternal {
    using AddressUtils for address;

    bytes32 private constant CLEAR_ADDRESS_MASK =
        bytes32(uint256(0xffffffffffffffffffffffff));
    bytes32 private constant CLEAR_SELECTOR_MASK =
        bytes32(uint256(0xffffffff << 224));

    /**
     * @notice update functions callable on Diamond proxy
     * @param facetCuts array of structured Diamond facet update data
     * @param target optional recipient of initialization delegatecall
     * @param data optional initialization call data
     */
    function _diamondCut(
        FacetCut[] memory facetCuts,
        address target,
        bytes memory data
    ) internal {
        DiamondBaseStorage.Layout storage l = DiamondBaseStorage.layout();

        unchecked {
            uint256 originalSelectorCount = l.selectorCount;
            uint256 selectorCount = originalSelectorCount;
            bytes32 selectorSlot;

            // Check if last selector slot is not full
            if (selectorCount & 7 > 0) {
                // get last selectorSlot
                selectorSlot = l.selectorSlots[selectorCount >> 3];
            }

            for (uint256 i; i < facetCuts.length; i++) {
                FacetCut memory facetCut = facetCuts[i];
                FacetCutAction action = facetCut.action;

                if (facetCut.selectors.length == 0)
                    revert DiamondWritable__SelectorNotSpecified();

                if (action == FacetCutAction.ADD) {
                    (selectorCount, selectorSlot) = _addFacetSelectors(
                        l,
                        selectorCount,
                        selectorSlot,
                        facetCut
                    );
                } else if (action == FacetCutAction.REPLACE) {
                    _replaceFacetSelectors(l, facetCut);
                } else if (action == FacetCutAction.REMOVE) {
                    (selectorCount, selectorSlot) = _removeFacetSelectors(
                        l,
                        selectorCount,
                        selectorSlot,
                        facetCut
                    );
                }
            }

            if (selectorCount != originalSelectorCount) {
                l.selectorCount = uint16(selectorCount);
            }

            // If last selector slot is not full
            if (selectorCount & 7 > 0) {
                l.selectorSlots[selectorCount >> 3] = selectorSlot;
            }

            emit DiamondCut(facetCuts, target, data);
            _initialize(target, data);
        }
    }

    function _addFacetSelectors(
        DiamondBaseStorage.Layout storage l,
        uint256 selectorCount,
        bytes32 selectorSlot,
        FacetCut memory facetCut
    ) internal returns (uint256, bytes32) {
        unchecked {
            if (
                facetCut.target != address(this) &&
                !facetCut.target.isContract()
            ) revert DiamondWritable__TargetHasNoCode();

            for (uint256 i; i < facetCut.selectors.length; i++) {
                bytes4 selector = facetCut.selectors[i];
                bytes32 oldFacet = l.facets[selector];

                if (address(bytes20(oldFacet)) != address(0))
                    revert DiamondWritable__SelectorAlreadyAdded();

                // add facet for selector
                l.facets[selector] =
                    bytes20(facetCut.target) |
                    bytes32(selectorCount);
                uint256 selectorInSlotPosition = (selectorCount & 7) << 5;

                // clear selector position in slot and add selector
                selectorSlot =
                    (selectorSlot &
                        ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) |
                    (bytes32(selector) >> selectorInSlotPosition);

                // if slot is full then write it to storage
                if (selectorInSlotPosition == 224) {
                    l.selectorSlots[selectorCount >> 3] = selectorSlot;
                    selectorSlot = 0;
                }

                selectorCount++;
            }

            return (selectorCount, selectorSlot);
        }
    }

    function _removeFacetSelectors(
        DiamondBaseStorage.Layout storage l,
        uint256 selectorCount,
        bytes32 selectorSlot,
        FacetCut memory facetCut
    ) internal returns (uint256, bytes32) {
        unchecked {
            if (facetCut.target != address(0))
                revert DiamondWritable__RemoveTargetNotZeroAddress();

            uint256 selectorSlotCount = selectorCount >> 3;
            uint256 selectorInSlotIndex = selectorCount & 7;

            for (uint256 i; i < facetCut.selectors.length; i++) {
                bytes4 selector = facetCut.selectors[i];
                bytes32 oldFacet = l.facets[selector];

                if (address(bytes20(oldFacet)) == address(0))
                    revert DiamondWritable__SelectorNotFound();

                if (address(bytes20(oldFacet)) == address(this))
                    revert DiamondWritable__SelectorIsImmutable();

                if (selectorSlot == 0) {
                    selectorSlotCount--;
                    selectorSlot = l.selectorSlots[selectorSlotCount];
                    selectorInSlotIndex = 7;
                } else {
                    selectorInSlotIndex--;
                }

                bytes4 lastSelector;
                uint256 oldSelectorsSlotCount;
                uint256 oldSelectorInSlotPosition;

                // adding a block here prevents stack too deep error
                {
                    // replace selector with last selector in l.facets
                    lastSelector = bytes4(
                        selectorSlot << (selectorInSlotIndex << 5)
                    );

                    if (lastSelector != selector) {
                        // update last selector slot position info
                        l.facets[lastSelector] =
                            (oldFacet & CLEAR_ADDRESS_MASK) |
                            bytes20(l.facets[lastSelector]);
                    }

                    delete l.facets[selector];
                    uint256 oldSelectorCount = uint16(uint256(oldFacet));
                    oldSelectorsSlotCount = oldSelectorCount >> 3;
                    oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;
                }

                if (oldSelectorsSlotCount != selectorSlotCount) {
                    bytes32 oldSelectorSlot = l.selectorSlots[
                        oldSelectorsSlotCount
                    ];

                    // clears the selector we are deleting and puts the last selector in its place.
                    oldSelectorSlot =
                        (oldSelectorSlot &
                            ~(CLEAR_SELECTOR_MASK >>
                                oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);

                    // update storage with the modified slot
                    l.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;
                } else {
                    // clears the selector we are deleting and puts the last selector in its place.
                    selectorSlot =
                        (selectorSlot &
                            ~(CLEAR_SELECTOR_MASK >>
                                oldSelectorInSlotPosition)) |
                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);
                }

                if (selectorInSlotIndex == 0) {
                    delete l.selectorSlots[selectorSlotCount];
                    selectorSlot = 0;
                }
            }

            selectorCount = (selectorSlotCount << 3) | selectorInSlotIndex;

            return (selectorCount, selectorSlot);
        }
    }

    function _replaceFacetSelectors(
        DiamondBaseStorage.Layout storage l,
        FacetCut memory facetCut
    ) internal {
        unchecked {
            if (!facetCut.target.isContract())
                revert DiamondWritable__TargetHasNoCode();

            for (uint256 i; i < facetCut.selectors.length; i++) {
                bytes4 selector = facetCut.selectors[i];
                bytes32 oldFacet = l.facets[selector];
                address oldFacetAddress = address(bytes20(oldFacet));

                if (oldFacetAddress == address(0))
                    revert DiamondWritable__SelectorNotFound();
                if (oldFacetAddress == address(this))
                    revert DiamondWritable__SelectorIsImmutable();
                if (oldFacetAddress == facetCut.target)
                    revert DiamondWritable__ReplaceTargetIsIdentical();

                // replace old facet address
                l.facets[selector] =
                    (oldFacet & CLEAR_ADDRESS_MASK) |
                    bytes20(facetCut.target);
            }
        }
    }

    function _initialize(address target, bytes memory data) private {
        if ((target == address(0)) != (data.length == 0))
            revert DiamondWritable__InvalidInitializationParameters();

        if (target != address(0)) {
            if (target != address(this)) {
                if (!target.isContract())
                    revert DiamondWritable__TargetHasNoCode();
            }

            (bool success, ) = target.delegatecall(data);

            if (!success) {
                assembly {
                    returndatacopy(0, 0, returndatasize())
                    revert(0, returndatasize())
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IDiamondWritableInternal } from './IDiamondWritableInternal.sol';

/**
 * @title Diamond proxy upgrade interface
 * @dev see https://eips.ethereum.org/EIPS/eip-2535
 */
interface IDiamondWritable is IDiamondWritableInternal {
    /**
     * @notice update diamond facets and optionally execute arbitrary initialization function
     * @param facetCuts array of structured Diamond facet update data
     * @param target optional target of initialization delegatecall
     * @param data optional initialization function call data
     */
    function diamondCut(
        FacetCut[] calldata facetCuts,
        address target,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @dev derived from https://github.com/mudgen/diamond-2 (MIT license)
 */
library DiamondBaseStorage {
    struct Layout {
        // function selector => (facet address, selector slot position)
        mapping(bytes4 => bytes32) facets;
        // total number of selectors registered
        uint16 selectorCount;
        // array of selector slots with 8 selectors per slot
        mapping(uint256 => bytes32) selectorSlots;
        address fallbackAddress;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.DiamondBase');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173 } from '../../interfaces/IERC173.sol';
import { AddressUtils } from '../../utils/AddressUtils.sol';
import { IOwnableInternal } from './IOwnableInternal.sol';
import { OwnableStorage } from './OwnableStorage.sol';

abstract contract OwnableInternal is IOwnableInternal {
    using AddressUtils for address;
    using OwnableStorage for OwnableStorage.Layout;

    modifier onlyOwner() {
        if (msg.sender != _owner()) revert Ownable__NotOwner();
        _;
    }

    modifier onlyTransitiveOwner() {
        if (msg.sender != _transitiveOwner())
            revert Ownable__NotTransitiveOwner();
        _;
    }

    function _owner() internal view virtual returns (address) {
        return OwnableStorage.layout().owner;
    }

    function _transitiveOwner() internal view virtual returns (address) {
        address owner = _owner();

        while (owner.isContract()) {
            try IERC173(owner).owner() returns (address transitiveOwner) {
                owner = transitiveOwner;
            } catch {
                return owner;
            }
        }

        return owner;
    }

    function _transferOwnership(address account) internal virtual {
        OwnableStorage.layout().setOwner(account);
        emit OwnershipTransferred(msg.sender, account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Diamond proxy introspection interface
 * @dev see https://eips.ethereum.org/EIPS/eip-2535
 */
interface IDiamondReadable {
    struct Facet {
        address target;
        bytes4[] selectors;
    }

    /**
     * @notice get all facets and their selectors
     * @return diamondFacets array of structured facet data
     */
    function facets() external view returns (Facet[] memory diamondFacets);

    /**
     * @notice get all selectors for given facet address
     * @param facet address of facet to query
     * @return selectors array of function selectors
     */
    function facetFunctionSelectors(address facet)
        external
        view
        returns (bytes4[] memory selectors);

    /**
     * @notice get addresses of all facets used by diamond
     * @return addresses array of facet addresses
     */
    function facetAddresses()
        external
        view
        returns (address[] memory addresses);

    /**
     * @notice get the address of the facet associated with given selector
     * @param selector function selector to query
     * @return facet facet address (zero address if not found)
     */
    function facetAddress(bytes4 selector)
        external
        view
        returns (address facet);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IProxy } from '../../IProxy.sol';

interface IDiamondBase is IProxy {
    error DiamondBase__NoFacetForSignature();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { AddressUtils } from '../utils/AddressUtils.sol';
import { IProxy } from './IProxy.sol';

/**
 * @title Base proxy contract
 */
abstract contract Proxy is IProxy {
    using AddressUtils for address;

    /**
     * @notice delegate all calls to implementation contract
     * @dev reverts if implementation address contains no code, for compatibility with metamorphic contracts
     * @dev memory location in use by assembly may be unsafe in other contexts
     */
    fallback() external payable virtual {
        address implementation = _getImplementation();

        if (!implementation.isContract())
            revert Proxy__ImplementationIsNotContract();

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )
            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    /**
     * @notice get logic implementation address
     * @return implementation address
     */
    function _getImplementation() internal virtual returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title ERC165 interface registration interface
 * @dev see https://eips.ethereum.org/EIPS/eip-165
 */
interface IERC165 {
    /**
     * @notice query whether contract has registered support for given interface
     * @param interfaceId interface id
     * @return bool whether interface is supported
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IOwnable } from './IOwnable.sol';

interface ISafeOwnable is IOwnable {
    /**
     * @notice get the nominated owner who has permission to call acceptOwnership
     */
    function nomineeOwner() external view returns (address);

    /**
     * @notice accept transfer of contract ownership
     */
    function acceptOwnership() external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library ERC165Storage {
    error ERC165Storage__InvalidInterfaceId();

    struct Layout {
        mapping(bytes4 => bool) supportedInterfaces;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.ERC165');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function isSupportedInterface(Layout storage l, bytes4 interfaceId)
        internal
        view
        returns (bool)
    {
        return l.supportedInterfaces[interfaceId];
    }

    function setSupportedInterface(
        Layout storage l,
        bytes4 interfaceId,
        bool status
    ) internal {
        if (interfaceId == 0xffffffff)
            revert ERC165Storage__InvalidInterfaceId();
        l.supportedInterfaces[interfaceId] = status;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Partial ERC173 interface needed by internal functions
 */
interface IERC173Internal {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { ISafeOwnableInternal } from './ISafeOwnableInternal.sol';
import { OwnableInternal } from './OwnableInternal.sol';
import { OwnableStorage } from './OwnableStorage.sol';
import { SafeOwnableStorage } from './SafeOwnableStorage.sol';

abstract contract SafeOwnableInternal is ISafeOwnableInternal, OwnableInternal {
    using OwnableStorage for OwnableStorage.Layout;
    using SafeOwnableStorage for SafeOwnableStorage.Layout;

    modifier onlyNomineeOwner() {
        if (msg.sender != _nomineeOwner())
            revert SafeOwnable__NotNomineeOwner();
        _;
    }

    /**
     * @notice get the nominated owner who has permission to call acceptOwnership
     */
    function _nomineeOwner() internal view virtual returns (address) {
        return SafeOwnableStorage.layout().nomineeOwner;
    }

    /**
     * @notice accept transfer of contract ownership
     */
    function _acceptOwnership() internal virtual {
        OwnableStorage.Layout storage l = OwnableStorage.layout();
        emit OwnershipTransferred(l.owner, msg.sender);
        l.setOwner(msg.sender);
        SafeOwnableStorage.layout().setNomineeOwner(address(0));
    }

    /**
     * @notice set nominee owner, granting permission to call acceptOwnership
     */
    function _transferOwnership(address account) internal virtual override {
        SafeOwnableStorage.layout().setNomineeOwner(account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library OwnableStorage {
    struct Layout {
        address owner;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.Ownable');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function setOwner(Layout storage l, address owner) internal {
        l.owner = owner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173 } from '../../interfaces/IERC173.sol';

interface IOwnable is IERC173 {}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface IDiamondWritableInternal {
    enum FacetCutAction {
        ADD,
        REPLACE,
        REMOVE
    }

    event DiamondCut(FacetCut[] facetCuts, address target, bytes data);

    error DiamondWritable__InvalidInitializationParameters();
    error DiamondWritable__RemoveTargetNotZeroAddress();
    error DiamondWritable__ReplaceTargetIsIdentical();
    error DiamondWritable__SelectorAlreadyAdded();
    error DiamondWritable__SelectorIsImmutable();
    error DiamondWritable__SelectorNotFound();
    error DiamondWritable__SelectorNotSpecified();
    error DiamondWritable__TargetHasNoCode();

    struct FacetCut {
        address target;
        FacetCutAction action;
        bytes4[] selectors;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { UintUtils } from './UintUtils.sol';

library AddressUtils {
    using UintUtils for uint256;

    error AddressUtils__InsufficientBalance();
    error AddressUtils__NotContract();
    error AddressUtils__SendValueFailed();

    function toString(address account) internal pure returns (string memory) {
        return uint256(uint160(account)).toHexString(20);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable account, uint256 amount) internal {
        (bool success, ) = account.call{ value: amount }('');
        if (!success) revert AddressUtils__SendValueFailed();
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCall(target, data, 'AddressUtils: failed low-level call');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory error
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, error);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                'AddressUtils: failed low-level call with value'
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory error
    ) internal returns (bytes memory) {
        if (value > address(this).balance)
            revert AddressUtils__InsufficientBalance();
        return _functionCallWithValue(target, data, value, error);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory error
    ) private returns (bytes memory) {
        if (!isContract(target)) revert AddressUtils__NotContract();

        (bool success, bytes memory returnData) = target.call{ value: value }(
            data
        );

        if (success) {
            return returnData;
        } else if (returnData.length > 0) {
            assembly {
                let returnData_size := mload(returnData)
                revert(add(32, returnData), returnData_size)
            }
        } else {
            revert(error);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface IProxy {
    error Proxy__ImplementationIsNotContract();

    fallback() external payable;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library SafeOwnableStorage {
    struct Layout {
        address nomineeOwner;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.SafeOwnable');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function setNomineeOwner(Layout storage l, address nomineeOwner) internal {
        l.nomineeOwner = nomineeOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IOwnableInternal } from './IOwnableInternal.sol';

interface ISafeOwnableInternal is IOwnableInternal {
    error SafeOwnable__NotNomineeOwner();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173Internal } from '../../interfaces/IERC173Internal.sol';

interface IOwnableInternal is IERC173Internal {
    error Ownable__NotOwner();
    error Ownable__NotTransitiveOwner();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title utility functions for uint256 operations
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)
 */
library UintUtils {
    error UintUtils__InsufficientHexLength();

    bytes16 private constant HEX_SYMBOLS = '0123456789abcdef';

    function add(uint256 a, int256 b) internal pure returns (uint256) {
        return b < 0 ? sub(a, -b) : a + uint256(b);
    }

    function sub(uint256 a, int256 b) internal pure returns (uint256) {
        return b < 0 ? add(a, -b) : a - uint256(b);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0';
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0x00';
        }

        uint256 length = 0;

        for (uint256 temp = value; temp != 0; temp >>= 8) {
            unchecked {
                length++;
            }
        }

        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';

        unchecked {
            for (uint256 i = 2 * length + 1; i > 1; --i) {
                buffer[i] = HEX_SYMBOLS[value & 0xf];
                value >>= 4;
            }
        }

        if (value != 0) revert UintUtils__InsufficientHexLength();

        return string(buffer);
    }
}