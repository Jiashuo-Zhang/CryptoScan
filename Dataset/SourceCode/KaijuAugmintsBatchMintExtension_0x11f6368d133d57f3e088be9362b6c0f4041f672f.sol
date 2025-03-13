{{

  "language": "Solidity",

  "sources": {

    "contracts/KaijuAugmintsBatchMintExtension.sol": {

      "content": "// SPDX-License-Identifier: Unlicense\n\npragma solidity ^0.8.0;\n\nimport \"@openzeppelin/contracts/access/IAccessControl.sol\";\n\ninterface IKaijuAugmints is IAccessControl {\n    function mint(address to, uint256 id, uint256 amount) external;\n    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata amounts) external;\n}\n\nerror KaijuAugmintsBatchMintExtension_NotAllowed();\n\n/**\n                        .             :++-\n                       *##-          +####*          -##+\n                       *####-      :%######%.      -%###*\n                       *######:   =##########=   .######*\n                       *#######*-#############*-*#######*\n                       *################################*\n                       *################################*\n                       *################################*\n                       *################################*\n                       *################################*\n                       :*******************************+.\n\n                .:.\n               *###%*=:\n              .##########+-.\n              +###############=:\n              %##################%+\n             =######################\n             -######################++++++++++++++++++=-:\n              =###########################################*:\n               =#############################################.\n  +####%#*+=-:. -#############################################:\n  %############################################################=\n  %##############################################################\n  %##############################################################%=----::.\n  %#######################################################################%:\n  %##########################################+:    :+%#######################:\n  *########################################*          *#######################\n   -%######################################            %######################\n     -%###################################%            #######################\n       =###################################-          :#######################\n     ....+##################################*.      .+########################\n  +###########################################%*++*%##########################\n  %#########################################################################*.\n  %#######################################################################+\n  ########################################################################-\n  *#######################################################################-\n  .######################################################################%.\n     :+#################################################################-\n         :=#####################################################:.....\n             :--:.:##############################################+\n   ::             +###############################################%-\n  ####%+-.        %##################################################.\n  %#######%*-.   :###################################################%\n  %###########%*=*####################################################=\n  %####################################################################\n  %####################################################################+\n  %#####################################################################.\n  %#####################################################################%\n  %######################################################################-\n  .+*********************************************************************.\n * @title Kaiju Augmints Batch Mint Extension\n * @author Augminted Labs, LLC\n * @notice Additional functions used for mass minting/airdropping Kaiju Augmints more efficiently\n */\ncontract KaijuAugmintsBatchMintExtension {\n    bytes32 public constant MINTER_ROLE = keccak256(\"MINTER_ROLE\");\n\n    IKaijuAugmints public immutable AUGMINTS;\n\n    constructor(IKaijuAugmints augmints) {\n        AUGMINTS = augmints;\n    }\n\n    /**\n     * @notice Modifier that requires the sender to have the `MINTER_ROLE` role\n     */\n    modifier onlyMinter() {\n        if (!AUGMINTS.hasRole(MINTER_ROLE, msg.sender)) revert KaijuAugmintsBatchMintExtension_NotAllowed();\n        _;\n    }\n\n    /**\n     * @notice Mass mint tokens to specified addresses\n     * @param receivers Addresses receiving the minted tokens\n     * @param ids Token identifiers to mint\n     * @param amounts Amounts of the tokens to mint\n     */\n    function multiMint(\n        address[] calldata receivers,\n        uint256[] calldata ids,\n        uint256[] calldata amounts\n    )\n        public\n        onlyMinter\n    {\n        uint256 length = receivers.length;\n        for (uint i; i < length;) {\n            AUGMINTS.mint(receivers[i], ids[i], amounts[i]);\n            unchecked { ++i; }\n        }\n    }\n\n    /**\n     * @notice Mass mint batches of tokens to specified addresses\n     * @param receivers Addresses receiving the minted tokens\n     * @param idsBatches Batches of token identifiers to mint\n     * @param amountsBatches Batches of amounts of the tokens to mint\n     */\n    function multiMintBatch(\n        address[] calldata receivers,\n        uint256[][] calldata idsBatches,\n        uint256[][] calldata amountsBatches\n    )\n        public\n        onlyMinter\n    {\n        uint256 length = receivers.length;\n        for (uint i; i < length;) {\n            AUGMINTS.mintBatch(receivers[i], idsBatches[i], amountsBatches[i]);\n            unchecked { ++i; }\n        }\n    }\n}"

    },

    "@openzeppelin/contracts/access/IAccessControl.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev External interface of AccessControl declared to support ERC165 detection.\n */\ninterface IAccessControl {\n    /**\n     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`\n     *\n     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite\n     * {RoleAdminChanged} not being emitted signaling this.\n     *\n     * _Available since v3.1._\n     */\n    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);\n\n    /**\n     * @dev Emitted when `account` is granted `role`.\n     *\n     * `sender` is the account that originated the contract call, an admin role\n     * bearer except when using {AccessControl-_setupRole}.\n     */\n    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Emitted when `account` is revoked `role`.\n     *\n     * `sender` is the account that originated the contract call:\n     *   - if using `revokeRole`, it is the admin role bearer\n     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)\n     */\n    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);\n\n    /**\n     * @dev Returns `true` if `account` has been granted `role`.\n     */\n    function hasRole(bytes32 role, address account) external view returns (bool);\n\n    /**\n     * @dev Returns the admin role that controls `role`. See {grantRole} and\n     * {revokeRole}.\n     *\n     * To change a role's admin, use {AccessControl-_setRoleAdmin}.\n     */\n    function getRoleAdmin(bytes32 role) external view returns (bytes32);\n\n    /**\n     * @dev Grants `role` to `account`.\n     *\n     * If `account` had not been already granted `role`, emits a {RoleGranted}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function grantRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from `account`.\n     *\n     * If `account` had been granted `role`, emits a {RoleRevoked} event.\n     *\n     * Requirements:\n     *\n     * - the caller must have ``role``'s admin role.\n     */\n    function revokeRole(bytes32 role, address account) external;\n\n    /**\n     * @dev Revokes `role` from the calling account.\n     *\n     * Roles are often managed via {grantRole} and {revokeRole}: this function's\n     * purpose is to provide a mechanism for accounts to lose their privileges\n     * if they are compromised (such as when a trusted device is misplaced).\n     *\n     * If the calling account had been granted `role`, emits a {RoleRevoked}\n     * event.\n     *\n     * Requirements:\n     *\n     * - the caller must be `account`.\n     */\n    function renounceRole(bytes32 role, address account) external;\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": false,

      "runs": 200

    },

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