{{

  "language": "Solidity",

  "sources": {

    "/contracts/TicketsHelper.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0\r\n// solhint-disable-next-line\r\npragma solidity 0.8.12;\r\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\r\nimport \"./interface/IBapTickets.sol\";\r\n\r\n/// @title Bulls and Apes Project - Tickets Helper\r\n/// @author BAP Dev Team\r\n/// @notice Helper contract to interact with BAP Tickets contract\r\ncontract TicketsHelper is Ownable {\r\n    /// @notice Contract address for BAP Tickets\r\n    IBapTickets public bapTickets;\r\n\r\n    /// @notice signer address\r\n    address public secret;\r\n\r\n    /// @notice Mapping for addresses allowed to use this contract\r\n    mapping(address => bool) public isAuthorized;\r\n    /// @notice Mapping for used signatures\r\n    mapping(bytes => bool) public isSignatureUsed;\r\n    /// @notice Mapping for users, event id and amount of tickets purchased\r\n    mapping(address => mapping(uint256 => uint256)) public ticketsPurchased;\r\n\r\n    /// @notice Deploys the contract\r\n    /// @param _bapTickets BAP Tickets contract address\r\n\r\n    constructor(address _bapTickets, address _secret) {\r\n        bapTickets = IBapTickets(_bapTickets);\r\n        secret = _secret;\r\n\r\n        isAuthorized[msg.sender] = true;\r\n    }\r\n\r\n    modifier onlyAuthorized() {\r\n        require(isAuthorized[msg.sender], \"Not Authorized\");\r\n        _;\r\n    }\r\n\r\n    /// @notice fallback function\r\n    receive() external payable {}\r\n\r\n    /// @notice Call createEvent function on BAP Tickets contract\r\n    /// @param _maxSupply Maximum supply of tickets\r\n    function createEvent(uint256 _maxSupply) external onlyAuthorized {\r\n        bapTickets.createEvent(_maxSupply, 0, 0, 0, 0);\r\n    }\r\n\r\n    /// @notice Call airdrop function on BAP Tickets contract\r\n    /// @param eventId Event Id\r\n    /// @param account Address to send the tickets\r\n    /// @param amount Quantity of tickets to mint\r\n    function airdrop(\r\n        uint256 eventId,\r\n        address account,\r\n        uint256 amount\r\n    ) external onlyAuthorized {\r\n        bapTickets.airdrop(eventId, account, amount);\r\n    }\r\n\r\n    ///@notice Purchase tickets for an event\r\n    ///@param eventId Event Id\r\n    ///@param amount Quantity of tickets to purchase\r\n    ///@param price Price of the tickets\r\n    ///@param timeOut Time out for the purchase\r\n    ///@param maxPerWallet Maximum amount of tickets per wallet\r\n    ///@param recipient Address to receive the tickets\r\n    ///@param signature Signature to verify the purchase\r\n    function purchaseTickets(\r\n        uint256 eventId,\r\n        uint256 amount,\r\n        uint256 price,\r\n        uint256 timeOut,\r\n        uint256 maxPerWallet,\r\n        address recipient,\r\n        bytes memory signature\r\n    ) external payable {\r\n        require(\r\n            !isSignatureUsed[signature],\r\n            \"purchaseTickets: Signature already used\"\r\n        );\r\n        require(\r\n            ticketsPurchased[recipient][eventId] + amount <= maxPerWallet,\r\n            \"purchaseTickets: Max per wallet reached\"\r\n        );\r\n        require(block.timestamp <= timeOut, \"purchaseTickets: Time out\");\r\n        require(msg.value >= price, \"purchaseTickets: Invalid ETH amount\");\r\n        require(\r\n            _verifyHashSignature(\r\n                keccak256(\r\n                    abi.encode(eventId, amount, price, timeOut, maxPerWallet, recipient)\r\n                ),\r\n                signature\r\n            ),\r\n            \"purchaseTickets: Invalid signature\"\r\n        );\r\n\r\n        isSignatureUsed[signature] = true;\r\n\r\n        ticketsPurchased[recipient][eventId] += amount;\r\n\r\n        if(msg.value > price){\r\n            (bool success, ) = recipient.call{value: msg.value - price}(\"\");\r\n            require(success, \"purchaseTickets: Unable to send refund eth\");\r\n        }\r\n\r\n        bapTickets.airdrop(eventId, recipient, amount);\r\n    }\r\n\r\n    // Ownable\r\n\r\n    /// @notice authorise a new address to use this contract\r\n    /// @param operator Address to be set\r\n    /// @param status Can use this contract or not\r\n    /// @dev Only contract owner can call this function\r\n    function setAuthorized(address operator, bool status) external onlyOwner {\r\n        isAuthorized[operator] = status;\r\n    }\r\n\r\n    /// @notice Change the address for signer\r\n    /// @param _newAddress New address to be set\r\n    /// @dev Can only be called by the contract owner\r\n    function setSecret(address _newAddress) external onlyOwner {\r\n        secret = _newAddress;\r\n    }\r\n\r\n    /// @notice Transfer ownership from external contracts owned by this contract\r\n    /// @param _contract Address of the external contract\r\n    /// @param _newOwner New owner\r\n    /// @dev Only contract owner can call this function\r\n    function transferOwnershipExternalContract(\r\n        address _contract,\r\n        address _newOwner\r\n    ) external onlyOwner {\r\n        Ownable(_contract).transferOwnership(_newOwner);\r\n    }\r\n\r\n    /// @notice Change the address for Tickets Contract\r\n    /// @param _newAddress New address to be set\r\n    /// @dev Can only be called by the contract owner\r\n    function setTicketsContract(address _newAddress) external onlyOwner {\r\n        bapTickets = IBapTickets(_newAddress);\r\n    }    \r\n\r\n    /// @notice Call withdrawETH function on BAP Tickets contract\r\n    /// @param _address Address to send the ETH\r\n    /// @param amount Quantity of ETH to send\r\n    function withdrawETH(\r\n        address _address,\r\n        uint256 amount\r\n    ) external onlyOwner {\r\n        bapTickets.withdrawETH(_address, amount);\r\n    }\r\n\r\n    function withdrawRemainingETH(address _address, uint256 amount)\r\n        external\r\n        onlyOwner\r\n    {\r\n        require(amount <= address(this).balance, \"Insufficient funds\");\r\n        (bool success, ) = _address.call{value: amount}(\"\");\r\n\r\n        require(success, \"Unable to send eth\");\r\n    }\r\n\r\n    function _verifyHashSignature(\r\n        bytes32 freshHash,\r\n        bytes memory signature\r\n    ) internal view returns (bool) {\r\n        bytes32 hash = keccak256(\r\n            abi.encodePacked(\"\\x19Ethereum Signed Message:\\n32\", freshHash)\r\n        );\r\n\r\n        bytes32 r;\r\n        bytes32 s;\r\n        uint8 v;\r\n\r\n        if (signature.length != 65) {\r\n            return false;\r\n        }\r\n        assembly {\r\n            r := mload(add(signature, 32))\r\n            s := mload(add(signature, 64))\r\n            v := byte(0, mload(add(signature, 96)))\r\n        }\r\n\r\n        if (v < 27) {\r\n            v += 27;\r\n        }\r\n\r\n        address signer = address(0);\r\n        if (v == 27 || v == 28) {\r\n            // solium-disable-next-line arg-overflow\r\n            signer = ecrecover(hash, v, r, s);\r\n        }\r\n        return secret == signer;\r\n    }\r\n}\r\n"

    },

    "/contracts/interface/IBapTickets.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0\r\n// solhint-disable-next-line\r\npragma solidity 0.8.12;\r\n\r\ninterface IBapTickets {\r\n    function withdrawETH(address _address, uint256 amount) external;\r\n\r\n    function airdrop(uint256 eventId, address account, uint256 amount) external;\r\n\r\n    function createEvent(\r\n        uint256 _maxSupply,\r\n        uint8 _maxPerTx,\r\n        uint8 _maxPerWallet,\r\n        uint256 _ticketPrice,\r\n        uint8 _status // 0: sale close, 1: public sale - everybody can buy, no checks, 2: only gods owner - only god owners can buy (you're currently checking), 3: only signature - only users with a valid signature\r\n    ) external;\r\n}\r\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    }

  },

  "settings": {

    "remappings": [],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "evmVersion": "london",

    "libraries": {},

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

    }

  }

}}