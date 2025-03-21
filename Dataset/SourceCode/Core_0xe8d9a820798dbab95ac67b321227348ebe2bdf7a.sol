{{

  "language": "Solidity",

  "sources": {

    "@solidstate/contracts/access/ownable/IOwnable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC173 } from '../../interfaces/IERC173.sol';\n\ninterface IOwnable is IERC173 {}\n"

    },

    "@solidstate/contracts/access/ownable/IOwnableInternal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC173Internal } from '../../interfaces/IERC173Internal.sol';\n\ninterface IOwnableInternal is IERC173Internal {\n    error Ownable__NotOwner();\n    error Ownable__NotTransitiveOwner();\n}\n"

    },

    "@solidstate/contracts/access/ownable/ISafeOwnable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IOwnable } from './IOwnable.sol';\n\ninterface ISafeOwnable is IOwnable {\n    /**\n     * @notice get the nominated owner who has permission to call acceptOwnership\n     */\n    function nomineeOwner() external view returns (address);\n\n    /**\n     * @notice accept transfer of contract ownership\n     */\n    function acceptOwnership() external;\n}\n"

    },

    "@solidstate/contracts/access/ownable/ISafeOwnableInternal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IOwnableInternal } from './IOwnableInternal.sol';\n\ninterface ISafeOwnableInternal is IOwnableInternal {\n    error SafeOwnable__NotNomineeOwner();\n}\n"

    },

    "@solidstate/contracts/access/ownable/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC173 } from '../../interfaces/IERC173.sol';\nimport { IOwnable } from './IOwnable.sol';\nimport { OwnableInternal } from './OwnableInternal.sol';\n\n/**\n * @title Ownership access control based on ERC173\n */\nabstract contract Ownable is IOwnable, OwnableInternal {\n    /**\n     * @inheritdoc IERC173\n     */\n    function owner() public view virtual returns (address) {\n        return _owner();\n    }\n\n    /**\n     * @inheritdoc IERC173\n     */\n    function transferOwnership(address account) public virtual onlyOwner {\n        _transferOwnership(account);\n    }\n}\n"

    },

    "@solidstate/contracts/access/ownable/OwnableInternal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC173 } from '../../interfaces/IERC173.sol';\nimport { AddressUtils } from '../../utils/AddressUtils.sol';\nimport { IOwnableInternal } from './IOwnableInternal.sol';\nimport { OwnableStorage } from './OwnableStorage.sol';\n\nabstract contract OwnableInternal is IOwnableInternal {\n    using AddressUtils for address;\n\n    modifier onlyOwner() {\n        if (msg.sender != _owner()) revert Ownable__NotOwner();\n        _;\n    }\n\n    modifier onlyTransitiveOwner() {\n        if (msg.sender != _transitiveOwner())\n            revert Ownable__NotTransitiveOwner();\n        _;\n    }\n\n    function _owner() internal view virtual returns (address) {\n        return OwnableStorage.layout().owner;\n    }\n\n    function _transitiveOwner() internal view virtual returns (address owner) {\n        owner = _owner();\n\n        while (owner.isContract()) {\n            try IERC173(owner).owner() returns (address transitiveOwner) {\n                owner = transitiveOwner;\n            } catch {\n                break;\n            }\n        }\n    }\n\n    function _transferOwnership(address account) internal virtual {\n        _setOwner(account);\n    }\n\n    function _setOwner(address account) internal virtual {\n        OwnableStorage.Layout storage l = OwnableStorage.layout();\n        emit OwnershipTransferred(l.owner, account);\n        l.owner = account;\n    }\n}\n"

    },

    "@solidstate/contracts/access/ownable/OwnableStorage.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nlibrary OwnableStorage {\n    struct Layout {\n        address owner;\n    }\n\n    bytes32 internal constant STORAGE_SLOT =\n        keccak256('solidstate.contracts.storage.Ownable');\n\n    function layout() internal pure returns (Layout storage l) {\n        bytes32 slot = STORAGE_SLOT;\n        assembly {\n            l.slot := slot\n        }\n    }\n}\n"

    },

    "@solidstate/contracts/access/ownable/SafeOwnable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { Ownable } from './Ownable.sol';\nimport { ISafeOwnable } from './ISafeOwnable.sol';\nimport { OwnableInternal } from './OwnableInternal.sol';\nimport { SafeOwnableInternal } from './SafeOwnableInternal.sol';\n\n/**\n * @title Ownership access control based on ERC173 with ownership transfer safety check\n */\nabstract contract SafeOwnable is ISafeOwnable, Ownable, SafeOwnableInternal {\n    /**\n     * @inheritdoc ISafeOwnable\n     */\n    function nomineeOwner() public view virtual returns (address) {\n        return _nomineeOwner();\n    }\n\n    /**\n     * @inheritdoc ISafeOwnable\n     */\n    function acceptOwnership() public virtual onlyNomineeOwner {\n        _acceptOwnership();\n    }\n\n    function _transferOwnership(\n        address account\n    ) internal virtual override(OwnableInternal, SafeOwnableInternal) {\n        super._transferOwnership(account);\n    }\n}\n"

    },

    "@solidstate/contracts/access/ownable/SafeOwnableInternal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { ISafeOwnableInternal } from './ISafeOwnableInternal.sol';\nimport { OwnableInternal } from './OwnableInternal.sol';\nimport { SafeOwnableStorage } from './SafeOwnableStorage.sol';\n\nabstract contract SafeOwnableInternal is ISafeOwnableInternal, OwnableInternal {\n    modifier onlyNomineeOwner() {\n        if (msg.sender != _nomineeOwner())\n            revert SafeOwnable__NotNomineeOwner();\n        _;\n    }\n\n    /**\n     * @notice get the nominated owner who has permission to call acceptOwnership\n     */\n    function _nomineeOwner() internal view virtual returns (address) {\n        return SafeOwnableStorage.layout().nomineeOwner;\n    }\n\n    /**\n     * @notice accept transfer of contract ownership\n     */\n    function _acceptOwnership() internal virtual {\n        _setOwner(msg.sender);\n        delete SafeOwnableStorage.layout().nomineeOwner;\n    }\n\n    /**\n     * @notice set nominee owner, granting permission to call acceptOwnership\n     */\n    function _transferOwnership(address account) internal virtual override {\n        SafeOwnableStorage.layout().nomineeOwner = account;\n    }\n}\n"

    },

    "@solidstate/contracts/access/ownable/SafeOwnableStorage.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nlibrary SafeOwnableStorage {\n    struct Layout {\n        address nomineeOwner;\n    }\n\n    bytes32 internal constant STORAGE_SLOT =\n        keccak256('solidstate.contracts.storage.SafeOwnable');\n\n    function layout() internal pure returns (Layout storage l) {\n        bytes32 slot = STORAGE_SLOT;\n        assembly {\n            l.slot := slot\n        }\n    }\n}\n"

    },

    "@solidstate/contracts/interfaces/IERC165.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC165Internal } from './IERC165Internal.sol';\n\n/**\n * @title ERC165 interface registration interface\n * @dev see https://eips.ethereum.org/EIPS/eip-165\n */\ninterface IERC165 is IERC165Internal {\n    /**\n     * @notice query whether contract has registered support for given interface\n     * @param interfaceId interface id\n     * @return bool whether interface is supported\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"

    },

    "@solidstate/contracts/interfaces/IERC165Internal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC165Internal } from './IERC165Internal.sol';\n\n/**\n * @title ERC165 interface registration interface\n */\ninterface IERC165Internal {\n\n}\n"

    },

    "@solidstate/contracts/interfaces/IERC173.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC173Internal } from './IERC173Internal.sol';\n\n/**\n * @title Contract ownership standard interface\n * @dev see https://eips.ethereum.org/EIPS/eip-173\n */\ninterface IERC173 is IERC173Internal {\n    /**\n     * @notice get the ERC173 contract owner\n     * @return conrtact owner\n     */\n    function owner() external view returns (address);\n\n    /**\n     * @notice transfer contract ownership to new account\n     * @param account address of new owner\n     */\n    function transferOwnership(address account) external;\n}\n"

    },

    "@solidstate/contracts/interfaces/IERC173Internal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\n/**\n * @title Partial ERC173 interface needed by internal functions\n */\ninterface IERC173Internal {\n    event OwnershipTransferred(\n        address indexed previousOwner,\n        address indexed newOwner\n    );\n}\n"

    },

    "@solidstate/contracts/introspection/ERC165/base/ERC165Base.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC165 } from '../../../interfaces/IERC165.sol';\nimport { IERC165Base } from './IERC165Base.sol';\nimport { ERC165BaseInternal } from './ERC165BaseInternal.sol';\nimport { ERC165BaseStorage } from './ERC165BaseStorage.sol';\n\n/**\n * @title ERC165 implementation\n */\nabstract contract ERC165Base is IERC165Base, ERC165BaseInternal {\n    /**\n     * @inheritdoc IERC165\n     */\n    function supportsInterface(bytes4 interfaceId) public view returns (bool) {\n        return _supportsInterface(interfaceId);\n    }\n}\n"

    },

    "@solidstate/contracts/introspection/ERC165/base/ERC165BaseInternal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IERC165BaseInternal } from './IERC165BaseInternal.sol';\nimport { ERC165BaseStorage } from './ERC165BaseStorage.sol';\n\n/**\n * @title ERC165 implementation\n */\nabstract contract ERC165BaseInternal is IERC165BaseInternal {\n    /**\n     * @notice indicates whether an interface is already supported based on the interfaceId\n     * @param interfaceId id of interface to check\n     * @return bool indicating whether interface is supported\n     */\n    function _supportsInterface(\n        bytes4 interfaceId\n    ) internal view returns (bool) {\n        return ERC165BaseStorage.layout().supportedInterfaces[interfaceId];\n    }\n\n    /**\n     * @notice sets status of interface support\n     * @param interfaceId id of interface to set status for\n     * @param status boolean indicating whether interface will be set as supported\n     */\n    function _setSupportsInterface(bytes4 interfaceId, bool status) internal {\n        if (interfaceId == 0xffffffff) revert ERC165Base__InvalidInterfaceId();\n        ERC165BaseStorage.layout().supportedInterfaces[interfaceId] = status;\n    }\n}\n"

    },

    "@solidstate/contracts/introspection/ERC165/base/ERC165BaseStorage.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nlibrary ERC165BaseStorage {\n    struct Layout {\n        mapping(bytes4 => bool) supportedInterfaces;\n    }\n\n    bytes32 internal constant STORAGE_SLOT =\n        keccak256('solidstate.contracts.storage.ERC165Base');\n\n    function layout() internal pure returns (Layout storage l) {\n        bytes32 slot = STORAGE_SLOT;\n        assembly {\n            l.slot := slot\n        }\n    }\n}\n"

    },

    "@solidstate/contracts/introspection/ERC165/base/IERC165Base.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport { IERC165 } from '../../../interfaces/IERC165.sol';\nimport { IERC165BaseInternal } from './IERC165BaseInternal.sol';\n\ninterface IERC165Base is IERC165, IERC165BaseInternal {}\n"

    },

    "@solidstate/contracts/introspection/ERC165/base/IERC165BaseInternal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport { IERC165Internal } from '../../../interfaces/IERC165Internal.sol';\n\ninterface IERC165BaseInternal is IERC165Internal {\n    error ERC165Base__InvalidInterfaceId();\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/base/DiamondBase.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { Proxy } from '../../Proxy.sol';\nimport { IDiamondBase } from './IDiamondBase.sol';\nimport { DiamondBaseStorage } from './DiamondBaseStorage.sol';\n\n/**\n * @title EIP-2535 \"Diamond\" proxy base contract\n * @dev see https://eips.ethereum.org/EIPS/eip-2535\n */\nabstract contract DiamondBase is IDiamondBase, Proxy {\n    /**\n     * @inheritdoc Proxy\n     */\n    function _getImplementation()\n        internal\n        view\n        virtual\n        override\n        returns (address implementation)\n    {\n        // inline storage layout retrieval uses less gas\n        DiamondBaseStorage.Layout storage l;\n        bytes32 slot = DiamondBaseStorage.STORAGE_SLOT;\n        assembly {\n            l.slot := slot\n        }\n\n        implementation = address(bytes20(l.facets[msg.sig]));\n    }\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/base/DiamondBaseStorage.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\n/**\n * @dev derived from https://github.com/mudgen/diamond-2 (MIT license)\n */\nlibrary DiamondBaseStorage {\n    struct Layout {\n        // function selector => (facet address, selector slot position)\n        mapping(bytes4 => bytes32) facets;\n        // total number of selectors registered\n        uint16 selectorCount;\n        // array of selector slots with 8 selectors per slot\n        mapping(uint256 => bytes32) selectorSlots;\n        address fallbackAddress;\n    }\n\n    bytes32 internal constant STORAGE_SLOT =\n        keccak256('solidstate.contracts.storage.DiamondBase');\n\n    function layout() internal pure returns (Layout storage l) {\n        bytes32 slot = STORAGE_SLOT;\n        assembly {\n            l.slot := slot\n        }\n    }\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/base/IDiamondBase.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IProxy } from '../../IProxy.sol';\n\ninterface IDiamondBase is IProxy {}\n"

    },

    "@solidstate/contracts/proxy/diamond/fallback/DiamondFallback.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { OwnableInternal } from '../../../access/ownable/OwnableInternal.sol';\nimport { DiamondBase } from '../base/DiamondBase.sol';\nimport { DiamondBaseStorage } from '../base/DiamondBaseStorage.sol';\nimport { IDiamondFallback } from './IDiamondFallback.sol';\n\n// TODO: DiamondFallback interface\n\n/**\n * @title Fallback feature for EIP-2535 \"Diamond\" proxy\n */\nabstract contract DiamondFallback is\n    IDiamondFallback,\n    OwnableInternal,\n    DiamondBase\n{\n    /**\n     * @inheritdoc IDiamondFallback\n     */\n    function getFallbackAddress()\n        external\n        view\n        returns (address fallbackAddress)\n    {\n        fallbackAddress = _getFallbackAddress();\n    }\n\n    /**\n     * @inheritdoc IDiamondFallback\n     */\n    function setFallbackAddress(address fallbackAddress) external onlyOwner {\n        _setFallbackAddress(fallbackAddress);\n    }\n\n    /**\n     * @inheritdoc DiamondBase\n     * @notice query custom fallback address is no implementation is found\n     */\n    function _getImplementation()\n        internal\n        view\n        virtual\n        override\n        returns (address implementation)\n    {\n        implementation = super._getImplementation();\n\n        if (implementation == address(0)) {\n            implementation = _getFallbackAddress();\n        }\n    }\n\n    /**\n     * @notice query the address of the fallback implementation\n     * @return fallbackAddress address of fallback implementation\n     */\n    function _getFallbackAddress()\n        internal\n        view\n        virtual\n        returns (address fallbackAddress)\n    {\n        fallbackAddress = DiamondBaseStorage.layout().fallbackAddress;\n    }\n\n    /**\n     * @notice set the address of the fallback implementation\n     * @param fallbackAddress address of fallback implementation\n     */\n    function _setFallbackAddress(address fallbackAddress) internal virtual {\n        DiamondBaseStorage.layout().fallbackAddress = fallbackAddress;\n    }\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/fallback/IDiamondFallback.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IDiamondBase } from '../base/IDiamondBase.sol';\n\ninterface IDiamondFallback is IDiamondBase {\n    /**\n     * @notice query the address of the fallback implementation\n     * @return fallbackAddress address of fallback implementation\n     */\n    function getFallbackAddress()\n        external\n        view\n        returns (address fallbackAddress);\n\n    /**\n     * @notice set the address of the fallback implementation\n     * @param fallbackAddress address of fallback implementation\n     */\n    function setFallbackAddress(address fallbackAddress) external;\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/ISolidStateDiamond.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { ISafeOwnable } from '../../access/ownable/ISafeOwnable.sol';\nimport { IERC165 } from '../../interfaces/IERC165.sol';\nimport { IDiamondBase } from './base/IDiamondBase.sol';\nimport { IDiamondFallback } from './fallback/IDiamondFallback.sol';\nimport { IDiamondReadable } from './readable/IDiamondReadable.sol';\nimport { IDiamondWritable } from './writable/IDiamondWritable.sol';\n\ninterface ISolidStateDiamond is\n    IDiamondBase,\n    IDiamondFallback,\n    IDiamondReadable,\n    IDiamondWritable,\n    ISafeOwnable,\n    IERC165\n{\n    receive() external payable;\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/readable/DiamondReadable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { DiamondBaseStorage } from '../base/DiamondBaseStorage.sol';\nimport { IDiamondReadable } from './IDiamondReadable.sol';\n\n/**\n * @title EIP-2535 \"Diamond\" proxy introspection contract\n * @dev derived from https://github.com/mudgen/diamond-2 (MIT license)\n */\nabstract contract DiamondReadable is IDiamondReadable {\n    /**\n     * @inheritdoc IDiamondReadable\n     */\n    function facets() external view returns (Facet[] memory diamondFacets) {\n        DiamondBaseStorage.Layout storage l = DiamondBaseStorage.layout();\n\n        diamondFacets = new Facet[](l.selectorCount);\n\n        uint8[] memory numFacetSelectors = new uint8[](l.selectorCount);\n        uint256 numFacets;\n        uint256 selectorIndex;\n\n        // loop through function selectors\n        for (uint256 slotIndex; selectorIndex < l.selectorCount; slotIndex++) {\n            bytes32 slot = l.selectorSlots[slotIndex];\n\n            for (\n                uint256 selectorSlotIndex;\n                selectorSlotIndex < 8;\n                selectorSlotIndex++\n            ) {\n                selectorIndex++;\n\n                if (selectorIndex > l.selectorCount) {\n                    break;\n                }\n\n                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));\n                address facet = address(bytes20(l.facets[selector]));\n\n                bool continueLoop;\n\n                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {\n                    if (diamondFacets[facetIndex].target == facet) {\n                        diamondFacets[facetIndex].selectors[\n                            numFacetSelectors[facetIndex]\n                        ] = selector;\n                        // probably will never have more than 256 functions from one facet contract\n                        require(numFacetSelectors[facetIndex] < 255);\n                        numFacetSelectors[facetIndex]++;\n                        continueLoop = true;\n                        break;\n                    }\n                }\n\n                if (continueLoop) {\n                    continue;\n                }\n\n                diamondFacets[numFacets].target = facet;\n                diamondFacets[numFacets].selectors = new bytes4[](\n                    l.selectorCount\n                );\n                diamondFacets[numFacets].selectors[0] = selector;\n                numFacetSelectors[numFacets] = 1;\n                numFacets++;\n            }\n        }\n\n        for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {\n            uint256 numSelectors = numFacetSelectors[facetIndex];\n            bytes4[] memory selectors = diamondFacets[facetIndex].selectors;\n\n            // setting the number of selectors\n            assembly {\n                mstore(selectors, numSelectors)\n            }\n        }\n\n        // setting the number of facets\n        assembly {\n            mstore(diamondFacets, numFacets)\n        }\n    }\n\n    /**\n     * @inheritdoc IDiamondReadable\n     */\n    function facetFunctionSelectors(\n        address facet\n    ) external view returns (bytes4[] memory selectors) {\n        DiamondBaseStorage.Layout storage l = DiamondBaseStorage.layout();\n\n        selectors = new bytes4[](l.selectorCount);\n\n        uint256 numSelectors;\n        uint256 selectorIndex;\n\n        // loop through function selectors\n        for (uint256 slotIndex; selectorIndex < l.selectorCount; slotIndex++) {\n            bytes32 slot = l.selectorSlots[slotIndex];\n\n            for (\n                uint256 selectorSlotIndex;\n                selectorSlotIndex < 8;\n                selectorSlotIndex++\n            ) {\n                selectorIndex++;\n\n                if (selectorIndex > l.selectorCount) {\n                    break;\n                }\n\n                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));\n\n                if (facet == address(bytes20(l.facets[selector]))) {\n                    selectors[numSelectors] = selector;\n                    numSelectors++;\n                }\n            }\n        }\n\n        // set the number of selectors in the array\n        assembly {\n            mstore(selectors, numSelectors)\n        }\n    }\n\n    /**\n     * @inheritdoc IDiamondReadable\n     */\n    function facetAddresses()\n        external\n        view\n        returns (address[] memory addresses)\n    {\n        DiamondBaseStorage.Layout storage l = DiamondBaseStorage.layout();\n\n        addresses = new address[](l.selectorCount);\n        uint256 numFacets;\n        uint256 selectorIndex;\n\n        for (uint256 slotIndex; selectorIndex < l.selectorCount; slotIndex++) {\n            bytes32 slot = l.selectorSlots[slotIndex];\n\n            for (\n                uint256 selectorSlotIndex;\n                selectorSlotIndex < 8;\n                selectorSlotIndex++\n            ) {\n                selectorIndex++;\n\n                if (selectorIndex > l.selectorCount) {\n                    break;\n                }\n\n                bytes4 selector = bytes4(slot << (selectorSlotIndex << 5));\n                address facet = address(bytes20(l.facets[selector]));\n\n                bool continueLoop;\n\n                for (uint256 facetIndex; facetIndex < numFacets; facetIndex++) {\n                    if (facet == addresses[facetIndex]) {\n                        continueLoop = true;\n                        break;\n                    }\n                }\n\n                if (continueLoop) {\n                    continue;\n                }\n\n                addresses[numFacets] = facet;\n                numFacets++;\n            }\n        }\n\n        // set the number of facet addresses in the array\n        assembly {\n            mstore(addresses, numFacets)\n        }\n    }\n\n    /**\n     * @inheritdoc IDiamondReadable\n     */\n    function facetAddress(\n        bytes4 selector\n    ) external view returns (address facet) {\n        facet = address(bytes20(DiamondBaseStorage.layout().facets[selector]));\n    }\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/readable/IDiamondReadable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\n/**\n * @title Diamond proxy introspection interface\n * @dev see https://eips.ethereum.org/EIPS/eip-2535\n */\ninterface IDiamondReadable {\n    struct Facet {\n        address target;\n        bytes4[] selectors;\n    }\n\n    /**\n     * @notice get all facets and their selectors\n     * @return diamondFacets array of structured facet data\n     */\n    function facets() external view returns (Facet[] memory diamondFacets);\n\n    /**\n     * @notice get all selectors for given facet address\n     * @param facet address of facet to query\n     * @return selectors array of function selectors\n     */\n    function facetFunctionSelectors(\n        address facet\n    ) external view returns (bytes4[] memory selectors);\n\n    /**\n     * @notice get addresses of all facets used by diamond\n     * @return addresses array of facet addresses\n     */\n    function facetAddresses()\n        external\n        view\n        returns (address[] memory addresses);\n\n    /**\n     * @notice get the address of the facet associated with given selector\n     * @param selector function selector to query\n     * @return facet facet address (zero address if not found)\n     */\n    function facetAddress(\n        bytes4 selector\n    ) external view returns (address facet);\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/SolidStateDiamond.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IOwnable, Ownable, OwnableInternal } from '../../access/ownable/Ownable.sol';\nimport { ISafeOwnable, SafeOwnable } from '../../access/ownable/SafeOwnable.sol';\nimport { IERC165 } from '../../interfaces/IERC165.sol';\nimport { IERC173 } from '../../interfaces/IERC173.sol';\nimport { ERC165Base, ERC165BaseStorage } from '../../introspection/ERC165/base/ERC165Base.sol';\nimport { DiamondBase } from './base/DiamondBase.sol';\nimport { DiamondFallback, IDiamondFallback } from './fallback/DiamondFallback.sol';\nimport { DiamondReadable, IDiamondReadable } from './readable/DiamondReadable.sol';\nimport { DiamondWritable, IDiamondWritable } from './writable/DiamondWritable.sol';\nimport { ISolidStateDiamond } from './ISolidStateDiamond.sol';\n\n/**\n * @title SolidState \"Diamond\" proxy reference implementation\n */\nabstract contract SolidStateDiamond is\n    ISolidStateDiamond,\n    DiamondBase,\n    DiamondFallback,\n    DiamondReadable,\n    DiamondWritable,\n    SafeOwnable,\n    ERC165Base\n{\n    constructor() {\n        bytes4[] memory selectors = new bytes4[](12);\n        uint256 selectorIndex;\n\n        // register DiamondFallback\n\n        selectors[selectorIndex++] = IDiamondFallback\n            .getFallbackAddress\n            .selector;\n        selectors[selectorIndex++] = IDiamondFallback\n            .setFallbackAddress\n            .selector;\n\n        _setSupportsInterface(type(IDiamondFallback).interfaceId, true);\n\n        // register DiamondWritable\n\n        selectors[selectorIndex++] = IDiamondWritable.diamondCut.selector;\n\n        _setSupportsInterface(type(IDiamondWritable).interfaceId, true);\n\n        // register DiamondReadable\n\n        selectors[selectorIndex++] = IDiamondReadable.facets.selector;\n        selectors[selectorIndex++] = IDiamondReadable\n            .facetFunctionSelectors\n            .selector;\n        selectors[selectorIndex++] = IDiamondReadable.facetAddresses.selector;\n        selectors[selectorIndex++] = IDiamondReadable.facetAddress.selector;\n\n        _setSupportsInterface(type(IDiamondReadable).interfaceId, true);\n\n        // register ERC165\n\n        selectors[selectorIndex++] = IERC165.supportsInterface.selector;\n\n        _setSupportsInterface(type(IERC165).interfaceId, true);\n\n        // register SafeOwnable\n\n        selectors[selectorIndex++] = Ownable.owner.selector;\n        selectors[selectorIndex++] = SafeOwnable.nomineeOwner.selector;\n        selectors[selectorIndex++] = Ownable.transferOwnership.selector;\n        selectors[selectorIndex++] = SafeOwnable.acceptOwnership.selector;\n\n        _setSupportsInterface(type(IERC173).interfaceId, true);\n\n        // diamond cut\n\n        FacetCut[] memory facetCuts = new FacetCut[](1);\n\n        facetCuts[0] = FacetCut({\n            target: address(this),\n            action: FacetCutAction.ADD,\n            selectors: selectors\n        });\n\n        _diamondCut(facetCuts, address(0), '');\n\n        // set owner\n\n        _setOwner(msg.sender);\n    }\n\n    receive() external payable {}\n\n    function _transferOwnership(\n        address account\n    ) internal virtual override(OwnableInternal, SafeOwnable) {\n        super._transferOwnership(account);\n    }\n\n    /**\n     * @inheritdoc DiamondFallback\n     */\n    function _getImplementation()\n        internal\n        view\n        override(DiamondBase, DiamondFallback)\n        returns (address implementation)\n    {\n        implementation = super._getImplementation();\n    }\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/writable/DiamondWritable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { OwnableInternal } from '../../../access/ownable/OwnableInternal.sol';\nimport { IDiamondWritable } from './IDiamondWritable.sol';\nimport { DiamondWritableInternal } from './DiamondWritableInternal.sol';\n\n/**\n * @title EIP-2535 \"Diamond\" proxy update contract\n */\nabstract contract DiamondWritable is\n    IDiamondWritable,\n    DiamondWritableInternal,\n    OwnableInternal\n{\n    /**\n     * @inheritdoc IDiamondWritable\n     */\n    function diamondCut(\n        FacetCut[] calldata facetCuts,\n        address target,\n        bytes calldata data\n    ) external onlyOwner {\n        _diamondCut(facetCuts, target, data);\n    }\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/writable/DiamondWritableInternal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport { AddressUtils } from '../../../utils/AddressUtils.sol';\nimport { DiamondBaseStorage } from '../base/DiamondBaseStorage.sol';\nimport { IDiamondWritableInternal } from './IDiamondWritableInternal.sol';\n\nabstract contract DiamondWritableInternal is IDiamondWritableInternal {\n    using AddressUtils for address;\n\n    bytes32 private constant CLEAR_ADDRESS_MASK =\n        bytes32(uint256(0xffffffffffffffffffffffff));\n    bytes32 private constant CLEAR_SELECTOR_MASK =\n        bytes32(uint256(0xffffffff << 224));\n\n    /**\n     * @notice update functions callable on Diamond proxy\n     * @param facetCuts array of structured Diamond facet update data\n     * @param target optional recipient of initialization delegatecall\n     * @param data optional initialization call data\n     */\n    function _diamondCut(\n        FacetCut[] memory facetCuts,\n        address target,\n        bytes memory data\n    ) internal {\n        DiamondBaseStorage.Layout storage l = DiamondBaseStorage.layout();\n\n        unchecked {\n            uint256 originalSelectorCount = l.selectorCount;\n            uint256 selectorCount = originalSelectorCount;\n            bytes32 selectorSlot;\n\n            // Check if last selector slot is not full\n            if (selectorCount & 7 > 0) {\n                // get last selectorSlot\n                selectorSlot = l.selectorSlots[selectorCount >> 3];\n            }\n\n            for (uint256 i; i < facetCuts.length; i++) {\n                FacetCut memory facetCut = facetCuts[i];\n                FacetCutAction action = facetCut.action;\n\n                if (facetCut.selectors.length == 0)\n                    revert DiamondWritable__SelectorNotSpecified();\n\n                if (action == FacetCutAction.ADD) {\n                    (selectorCount, selectorSlot) = _addFacetSelectors(\n                        l,\n                        selectorCount,\n                        selectorSlot,\n                        facetCut\n                    );\n                } else if (action == FacetCutAction.REPLACE) {\n                    _replaceFacetSelectors(l, facetCut);\n                } else if (action == FacetCutAction.REMOVE) {\n                    (selectorCount, selectorSlot) = _removeFacetSelectors(\n                        l,\n                        selectorCount,\n                        selectorSlot,\n                        facetCut\n                    );\n                }\n            }\n\n            if (selectorCount != originalSelectorCount) {\n                l.selectorCount = uint16(selectorCount);\n            }\n\n            // If last selector slot is not full\n            if (selectorCount & 7 > 0) {\n                l.selectorSlots[selectorCount >> 3] = selectorSlot;\n            }\n\n            emit DiamondCut(facetCuts, target, data);\n            _initialize(target, data);\n        }\n    }\n\n    function _addFacetSelectors(\n        DiamondBaseStorage.Layout storage l,\n        uint256 selectorCount,\n        bytes32 selectorSlot,\n        FacetCut memory facetCut\n    ) internal returns (uint256, bytes32) {\n        unchecked {\n            if (\n                facetCut.target != address(this) &&\n                !facetCut.target.isContract()\n            ) revert DiamondWritable__TargetHasNoCode();\n\n            for (uint256 i; i < facetCut.selectors.length; i++) {\n                bytes4 selector = facetCut.selectors[i];\n                bytes32 oldFacet = l.facets[selector];\n\n                if (address(bytes20(oldFacet)) != address(0))\n                    revert DiamondWritable__SelectorAlreadyAdded();\n\n                // add facet for selector\n                l.facets[selector] =\n                    bytes20(facetCut.target) |\n                    bytes32(selectorCount);\n                uint256 selectorInSlotPosition = (selectorCount & 7) << 5;\n\n                // clear selector position in slot and add selector\n                selectorSlot =\n                    (selectorSlot &\n                        ~(CLEAR_SELECTOR_MASK >> selectorInSlotPosition)) |\n                    (bytes32(selector) >> selectorInSlotPosition);\n\n                // if slot is full then write it to storage\n                if (selectorInSlotPosition == 224) {\n                    l.selectorSlots[selectorCount >> 3] = selectorSlot;\n                    selectorSlot = 0;\n                }\n\n                selectorCount++;\n            }\n\n            return (selectorCount, selectorSlot);\n        }\n    }\n\n    function _removeFacetSelectors(\n        DiamondBaseStorage.Layout storage l,\n        uint256 selectorCount,\n        bytes32 selectorSlot,\n        FacetCut memory facetCut\n    ) internal returns (uint256, bytes32) {\n        unchecked {\n            if (facetCut.target != address(0))\n                revert DiamondWritable__RemoveTargetNotZeroAddress();\n\n            uint256 selectorSlotCount = selectorCount >> 3;\n            uint256 selectorInSlotIndex = selectorCount & 7;\n\n            for (uint256 i; i < facetCut.selectors.length; i++) {\n                bytes4 selector = facetCut.selectors[i];\n                bytes32 oldFacet = l.facets[selector];\n\n                if (address(bytes20(oldFacet)) == address(0))\n                    revert DiamondWritable__SelectorNotFound();\n\n                if (address(bytes20(oldFacet)) == address(this))\n                    revert DiamondWritable__SelectorIsImmutable();\n\n                if (selectorSlot == 0) {\n                    selectorSlotCount--;\n                    selectorSlot = l.selectorSlots[selectorSlotCount];\n                    selectorInSlotIndex = 7;\n                } else {\n                    selectorInSlotIndex--;\n                }\n\n                bytes4 lastSelector;\n                uint256 oldSelectorsSlotCount;\n                uint256 oldSelectorInSlotPosition;\n\n                // adding a block here prevents stack too deep error\n                {\n                    // replace selector with last selector in l.facets\n                    lastSelector = bytes4(\n                        selectorSlot << (selectorInSlotIndex << 5)\n                    );\n\n                    if (lastSelector != selector) {\n                        // update last selector slot position info\n                        l.facets[lastSelector] =\n                            (oldFacet & CLEAR_ADDRESS_MASK) |\n                            bytes20(l.facets[lastSelector]);\n                    }\n\n                    delete l.facets[selector];\n                    uint256 oldSelectorCount = uint16(uint256(oldFacet));\n                    oldSelectorsSlotCount = oldSelectorCount >> 3;\n                    oldSelectorInSlotPosition = (oldSelectorCount & 7) << 5;\n                }\n\n                if (oldSelectorsSlotCount != selectorSlotCount) {\n                    bytes32 oldSelectorSlot = l.selectorSlots[\n                        oldSelectorsSlotCount\n                    ];\n\n                    // clears the selector we are deleting and puts the last selector in its place.\n                    oldSelectorSlot =\n                        (oldSelectorSlot &\n                            ~(CLEAR_SELECTOR_MASK >>\n                                oldSelectorInSlotPosition)) |\n                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);\n\n                    // update storage with the modified slot\n                    l.selectorSlots[oldSelectorsSlotCount] = oldSelectorSlot;\n                } else {\n                    // clears the selector we are deleting and puts the last selector in its place.\n                    selectorSlot =\n                        (selectorSlot &\n                            ~(CLEAR_SELECTOR_MASK >>\n                                oldSelectorInSlotPosition)) |\n                        (bytes32(lastSelector) >> oldSelectorInSlotPosition);\n                }\n\n                if (selectorInSlotIndex == 0) {\n                    delete l.selectorSlots[selectorSlotCount];\n                    selectorSlot = 0;\n                }\n            }\n\n            selectorCount = (selectorSlotCount << 3) | selectorInSlotIndex;\n\n            return (selectorCount, selectorSlot);\n        }\n    }\n\n    function _replaceFacetSelectors(\n        DiamondBaseStorage.Layout storage l,\n        FacetCut memory facetCut\n    ) internal {\n        unchecked {\n            if (!facetCut.target.isContract())\n                revert DiamondWritable__TargetHasNoCode();\n\n            for (uint256 i; i < facetCut.selectors.length; i++) {\n                bytes4 selector = facetCut.selectors[i];\n                bytes32 oldFacet = l.facets[selector];\n                address oldFacetAddress = address(bytes20(oldFacet));\n\n                if (oldFacetAddress == address(0))\n                    revert DiamondWritable__SelectorNotFound();\n                if (oldFacetAddress == address(this))\n                    revert DiamondWritable__SelectorIsImmutable();\n                if (oldFacetAddress == facetCut.target)\n                    revert DiamondWritable__ReplaceTargetIsIdentical();\n\n                // replace old facet address\n                l.facets[selector] =\n                    (oldFacet & CLEAR_ADDRESS_MASK) |\n                    bytes20(facetCut.target);\n            }\n        }\n    }\n\n    function _initialize(address target, bytes memory data) private {\n        if ((target == address(0)) != (data.length == 0))\n            revert DiamondWritable__InvalidInitializationParameters();\n\n        if (target != address(0)) {\n            if (target != address(this)) {\n                if (!target.isContract())\n                    revert DiamondWritable__TargetHasNoCode();\n            }\n\n            (bool success, ) = target.delegatecall(data);\n\n            if (!success) {\n                assembly {\n                    returndatacopy(0, 0, returndatasize())\n                    revert(0, returndatasize())\n                }\n            }\n        }\n    }\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/writable/IDiamondWritable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { IDiamondWritableInternal } from './IDiamondWritableInternal.sol';\n\n/**\n * @title Diamond proxy upgrade interface\n * @dev see https://eips.ethereum.org/EIPS/eip-2535\n */\ninterface IDiamondWritable is IDiamondWritableInternal {\n    /**\n     * @notice update diamond facets and optionally execute arbitrary initialization function\n     * @param facetCuts array of structured Diamond facet update data\n     * @param target optional target of initialization delegatecall\n     * @param data optional initialization function call data\n     */\n    function diamondCut(\n        FacetCut[] calldata facetCuts,\n        address target,\n        bytes calldata data\n    ) external;\n}\n"

    },

    "@solidstate/contracts/proxy/diamond/writable/IDiamondWritableInternal.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\ninterface IDiamondWritableInternal {\n    enum FacetCutAction {\n        ADD,\n        REPLACE,\n        REMOVE\n    }\n\n    event DiamondCut(FacetCut[] facetCuts, address target, bytes data);\n\n    error DiamondWritable__InvalidInitializationParameters();\n    error DiamondWritable__RemoveTargetNotZeroAddress();\n    error DiamondWritable__ReplaceTargetIsIdentical();\n    error DiamondWritable__SelectorAlreadyAdded();\n    error DiamondWritable__SelectorIsImmutable();\n    error DiamondWritable__SelectorNotFound();\n    error DiamondWritable__SelectorNotSpecified();\n    error DiamondWritable__TargetHasNoCode();\n\n    struct FacetCut {\n        address target;\n        FacetCutAction action;\n        bytes4[] selectors;\n    }\n}\n"

    },

    "@solidstate/contracts/proxy/IProxy.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\ninterface IProxy {\n    error Proxy__ImplementationIsNotContract();\n\n    fallback() external payable;\n}\n"

    },

    "@solidstate/contracts/proxy/Proxy.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { AddressUtils } from '../utils/AddressUtils.sol';\nimport { IProxy } from './IProxy.sol';\n\n/**\n * @title Base proxy contract\n */\nabstract contract Proxy is IProxy {\n    using AddressUtils for address;\n\n    /**\n     * @notice delegate all calls to implementation contract\n     * @dev reverts if implementation address contains no code, for compatibility with metamorphic contracts\n     * @dev memory location in use by assembly may be unsafe in other contexts\n     */\n    fallback() external payable virtual {\n        address implementation = _getImplementation();\n\n        if (!implementation.isContract())\n            revert Proxy__ImplementationIsNotContract();\n\n        assembly {\n            calldatacopy(0, 0, calldatasize())\n            let result := delegatecall(\n                gas(),\n                implementation,\n                0,\n                calldatasize(),\n                0,\n                0\n            )\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            case 0 {\n                revert(0, returndatasize())\n            }\n            default {\n                return(0, returndatasize())\n            }\n        }\n    }\n\n    /**\n     * @notice get logic implementation address\n     * @return implementation address\n     */\n    function _getImplementation() internal virtual returns (address);\n}\n"

    },

    "@solidstate/contracts/utils/AddressUtils.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { UintUtils } from './UintUtils.sol';\n\nlibrary AddressUtils {\n    using UintUtils for uint256;\n\n    error AddressUtils__InsufficientBalance();\n    error AddressUtils__NotContract();\n    error AddressUtils__SendValueFailed();\n\n    function toString(address account) internal pure returns (string memory) {\n        return uint256(uint160(account)).toHexString(20);\n    }\n\n    function isContract(address account) internal view returns (bool) {\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    function sendValue(address payable account, uint256 amount) internal {\n        (bool success, ) = account.call{ value: amount }('');\n        if (!success) revert AddressUtils__SendValueFailed();\n    }\n\n    function functionCall(\n        address target,\n        bytes memory data\n    ) internal returns (bytes memory) {\n        return\n            functionCall(target, data, 'AddressUtils: failed low-level call');\n    }\n\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory error\n    ) internal returns (bytes memory) {\n        return _functionCallWithValue(target, data, 0, error);\n    }\n\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return\n            functionCallWithValue(\n                target,\n                data,\n                value,\n                'AddressUtils: failed low-level call with value'\n            );\n    }\n\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory error\n    ) internal returns (bytes memory) {\n        if (value > address(this).balance)\n            revert AddressUtils__InsufficientBalance();\n        return _functionCallWithValue(target, data, value, error);\n    }\n\n    /**\n     * @notice execute arbitrary external call with limited gas usage and amount of copied return data\n     * @dev derived from https://github.com/nomad-xyz/ExcessivelySafeCall (MIT License)\n     * @param target recipient of call\n     * @param gasAmount gas allowance for call\n     * @param value native token value to include in call\n     * @param maxCopy maximum number of bytes to copy from return data\n     * @param data encoded call data\n     * @return success whether call is successful\n     * @return returnData copied return data\n     */\n    function excessivelySafeCall(\n        address target,\n        uint256 gasAmount,\n        uint256 value,\n        uint16 maxCopy,\n        bytes memory data\n    ) internal returns (bool success, bytes memory returnData) {\n        returnData = new bytes(maxCopy);\n\n        assembly {\n            // execute external call via assembly to avoid automatic copying of return data\n            success := call(\n                gasAmount,\n                target,\n                value,\n                add(data, 0x20),\n                mload(data),\n                0,\n                0\n            )\n\n            // determine whether to limit amount of data to copy\n            let toCopy := returndatasize()\n\n            if gt(toCopy, maxCopy) {\n                toCopy := maxCopy\n            }\n\n            // store the length of the copied bytes\n            mstore(returnData, toCopy)\n\n            // copy the bytes from returndata[0:toCopy]\n            returndatacopy(add(returnData, 0x20), 0, toCopy)\n        }\n    }\n\n    function _functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory error\n    ) private returns (bytes memory) {\n        if (!isContract(target)) revert AddressUtils__NotContract();\n\n        (bool success, bytes memory returnData) = target.call{ value: value }(\n            data\n        );\n\n        if (success) {\n            return returnData;\n        } else if (returnData.length > 0) {\n            assembly {\n                let returnData_size := mload(returnData)\n                revert(add(32, returnData), returnData_size)\n            }\n        } else {\n            revert(error);\n        }\n    }\n}\n"

    },

    "@solidstate/contracts/utils/UintUtils.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\n/**\n * @title utility functions for uint256 operations\n * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)\n */\nlibrary UintUtils {\n    error UintUtils__InsufficientHexLength();\n\n    bytes16 private constant HEX_SYMBOLS = '0123456789abcdef';\n\n    function add(uint256 a, int256 b) internal pure returns (uint256) {\n        return b < 0 ? sub(a, -b) : a + uint256(b);\n    }\n\n    function sub(uint256 a, int256 b) internal pure returns (uint256) {\n        return b < 0 ? add(a, -b) : a - uint256(b);\n    }\n\n    function toString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return '0';\n        }\n\n        uint256 temp = value;\n        uint256 digits;\n\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n\n        bytes memory buffer = new bytes(digits);\n\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n\n        return string(buffer);\n    }\n\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return '0x00';\n        }\n\n        uint256 length = 0;\n\n        for (uint256 temp = value; temp != 0; temp >>= 8) {\n            unchecked {\n                length++;\n            }\n        }\n\n        return toHexString(value, length);\n    }\n\n    function toHexString(\n        uint256 value,\n        uint256 length\n    ) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = '0';\n        buffer[1] = 'x';\n\n        unchecked {\n            for (uint256 i = 2 * length + 1; i > 1; --i) {\n                buffer[i] = HEX_SYMBOLS[value & 0xf];\n                value >>= 4;\n            }\n        }\n\n        if (value != 0) revert UintUtils__InsufficientHexLength();\n\n        return string(buffer);\n    }\n}\n"

    },

    "contracts/core/Core.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity ^0.8.0;\n\nimport { SolidStateDiamond } from '@solidstate/contracts/proxy/diamond/SolidStateDiamond.sol';\n\n/**\n * @notice Insrt Finance platform core contract\n */\ncontract Core is SolidStateDiamond {\n\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "viaIR": true,

    "outputSelection": {

      "*": {

        "*": [

          "evm.bytecode",

          "evm.deployedBytecode",

          "devdoc",

          "userdoc",

          "metadata",

          "abi"

        ]

      }

    },

    "libraries": {}

  }

}}