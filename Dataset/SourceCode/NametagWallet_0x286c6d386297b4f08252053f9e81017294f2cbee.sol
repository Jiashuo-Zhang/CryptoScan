{{

  "language": "Solidity",

  "sources": {

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "contracts/INametag.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\ninterface INametag {\n    function getByName(string memory name) external view returns (uint256);\n    function ownerOf(uint256 tokenId) external view returns (address owner);\n    function getTokenName(uint256 tokenId) external view returns (string memory);\n}\n"

    },

    "contracts/NametagWallet.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"./INametag.sol\";\n\ncontract NametagWallet is Ownable {\n    event ContractAdded(address indexed nametagContract);\n    event ContractRemoved(address indexed nametagContract);\n    event NametagWalletChanged(address indexed owner, string indexed name, address wallet);\n    event ReverseNametagSet(address indexed owner, string indexed name);\n    event ReverseNametagRemoved(address indexed owner);\n\n    struct ReverseNametag {\n        address nametagContract;\n        uint256 tokenId;\n    }\n\n    bytes32 constant private TAIL = keccak256(\".tag\");\n\n    address[] public nametagContracts;\n    mapping(string => mapping(address => address)) internal nametagWallet;\n    mapping(address => ReverseNametag) internal reverseNametag;\n\n    constructor(address[] memory addresses) {\n        for (uint256 i = 0; i < addresses.length; ++i) {\n            addNametagContract(addresses[i]);\n        }\n    }\n\n    /**\n     * @dev Adds new contract for looking for nametag\n     */\n    function addNametagContract(address _contract) public onlyOwner {\n        nametagContracts.push(_contract);\n\n        emit ContractAdded(_contract);\n    }\n\n    /**\n     * @dev Removes the nametag contract\n     */\n    function removeNametagContract(address _contract) external onlyOwner {\n        uint256 last = nametagContracts.length - 1;\n        for (uint256 i = 0; i <= last; ++i) {\n            if (nametagContracts[i] != _contract) continue;\n            if (i != last) nametagContracts[i] = nametagContracts[last];\n            nametagContracts.pop();\n            emit ContractRemoved(_contract);\n            return;\n        }\n        revert(\"NametagWallet: Contract not found\");\n    }\n\n    /**\n     * @dev Sets wallet for the nametag for sender. Nametag must be present on a contract.\n     */\n    function setNametagWallet(string calldata nametag, address wallet) external {\n        require(wallet != address(0), \"NametagWallet: Zero wallet address\");\n\n        _setNametagWallet(nametag, wallet);\n    }\n\n    /**\n     * @dev Sets default wallet for the nametag for sender. Nametag must be present on a contract.\n     */\n    function clearNametagWallet(string calldata nametag) external {\n        _setNametagWallet(nametag, _msgSender());\n    }\n\n    /**\n     * @dev Sets reverse nametag for owner. Nametag must be present on a contract.\n     */\n    function setReverseNametag(string calldata nametag) external {\n        (address _contract, uint256 tokenId) = _resolveNametag(nametag);\n\n        require(_contract != address(0), \"NametagWallet: Nametag not found\");\n\n        address owner = INametag(_contract).ownerOf(tokenId);\n\n        require(owner == _msgSender(), \"NametagWallet: Not owner of nametag\");\n\n        reverseNametag[_msgSender()] = ReverseNametag(_contract, tokenId);\n\n        emit ReverseNametagSet(_msgSender(), nametag);\n    }\n\n    /**\n     * @dev Clears reverse nametag for owner.\n     */\n    function clearReverseNametag(string calldata nametag) external {\n        (address _contract, uint256 tokenId) = _resolveNametag(nametag);\n\n        require(_contract != address(0), \"NametagWallet: Nametag not found\");\n\n        address owner = INametag(_contract).ownerOf(tokenId);\n\n        require(owner == _msgSender(), \"NametagWallet: Not owner of nametag\");\n\n        delete reverseNametag[_msgSender()];\n\n        emit ReverseNametagRemoved(_msgSender());\n    }\n\n    /**\n     * @dev Returns the wallet address for the current owner of Nametag or just the owner's address\n     */\n    function getNametagWallet(string calldata nametag) external view returns (address wallet)  {\n        (address _contract, uint256 tokenId) = _resolveNametag(nametag);\n\n        if (_contract == address(0)) return address(0);\n\n        string memory name = INametag(_contract).getTokenName(tokenId);\n\n        address owner = INametag(_contract).ownerOf(tokenId);\n        wallet = nametagWallet[name][owner];\n\n        if (wallet == address(0)) wallet = owner;\n    }\n\n    function getNametagByWallet(address wallet) external view returns (string memory) {\n        ReverseNametag memory reverse = reverseNametag[wallet];\n        require(reverse.nametagContract != address(0), \"NametagWallet: Wallet not assigned\");\n\n        address owner = INametag(reverse.nametagContract).ownerOf(reverse.tokenId);\n\n        require(owner == wallet, \"NametagWallet: Wallet not assigned\");\n\n        return INametag(reverse.nametagContract).getTokenName(reverse.tokenId);\n    }\n\n    function _setNametagWallet(string calldata nametag, address wallet) private {\n        require(bytes(nametag).length > 0, \"NametagWallet: Nametag is empty\");\n        (address _contract,uint256 tokenId) = _resolveNametag(nametag);\n        require(_contract != address(0), \"NametagWallet: Nametag not found\");\n\n        string memory name = INametag(_contract).getTokenName(tokenId);\n\n        nametagWallet[name][_msgSender()] = wallet;\n\n        emit NametagWalletChanged(_msgSender(), name, wallet);\n    }\n\n    function _resolveNametag(string calldata nametag) internal view returns (address, uint256) {\n        string memory nametag2 = _getNametag(nametag);\n        for (uint256 i = 0; i < nametagContracts.length; ++i) {\n            address _contract = nametagContracts[i];\n            uint256 tokenId = INametag(_contract).getByName(nametag2);\n            if (tokenId != 0) {\n                return (_contract, tokenId);\n            }\n        }\n        return (address(0), 0);\n    }\n\n    function _getNametag(string calldata nametag) private pure returns (string memory) {\n        bytes calldata str = bytes(nametag);\n        if (str.length >= 7) {\n            bytes calldata a = str[str.length - 4 : str.length];\n            if (keccak256(a) == TAIL) {\n                return string(nametag[0 : str.length - 4]);\n            }\n        }\n\n        return string(nametag);\n    }\n}\n"

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