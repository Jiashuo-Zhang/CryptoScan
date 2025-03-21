{{

  "language": "Solidity",

  "sources": {

    "2007KiaSedona.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\r\npragma solidity >=0.8.0;\r\n\r\n/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.\r\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)\r\n/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)\r\n/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.\r\nabstract contract ERC20 {\r\n    /*//////////////////////////////////////////////////////////////\r\n                                 EVENTS\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 amount);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                            METADATA STORAGE\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    string public name;\r\n\r\n    string public symbol;\r\n\r\n    uint8 public immutable decimals;\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                              ERC20 STORAGE\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    uint256 public totalSupply;\r\n\r\n    mapping(address => uint256) public balanceOf;\r\n\r\n    mapping(address => mapping(address => uint256)) public allowance;\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                            EIP-2612 STORAGE\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    uint256 internal immutable INITIAL_CHAIN_ID;\r\n\r\n    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;\r\n\r\n    mapping(address => uint256) public nonces;\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                               CONSTRUCTOR\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    constructor(\r\n        string memory _name,\r\n        string memory _symbol,\r\n        uint8 _decimals\r\n    ) {\r\n        name = _name;\r\n        symbol = _symbol;\r\n        decimals = _decimals;\r\n\r\n        INITIAL_CHAIN_ID = block.chainid;\r\n        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();\r\n    }\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                               ERC20 LOGIC\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    function approve(address spender, uint256 amount) public virtual returns (bool) {\r\n        allowance[msg.sender][spender] = amount;\r\n\r\n        emit Approval(msg.sender, spender, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    function transfer(address to, uint256 amount) public virtual returns (bool) {\r\n        balanceOf[msg.sender] -= amount;\r\n\r\n        // Cannot overflow because the sum of all user\r\n        // balances can't exceed the max uint256 value.\r\n        unchecked {\r\n            balanceOf[to] += amount;\r\n        }\r\n\r\n        emit Transfer(msg.sender, to, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) public virtual returns (bool) {\r\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\r\n\r\n        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;\r\n\r\n        balanceOf[from] -= amount;\r\n\r\n        // Cannot overflow because the sum of all user\r\n        // balances can't exceed the max uint256 value.\r\n        unchecked {\r\n            balanceOf[to] += amount;\r\n        }\r\n\r\n        emit Transfer(from, to, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                             EIP-2612 LOGIC\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    function permit(\r\n        address owner,\r\n        address spender,\r\n        uint256 value,\r\n        uint256 deadline,\r\n        uint8 v,\r\n        bytes32 r,\r\n        bytes32 s\r\n    ) public virtual {\r\n        require(deadline >= block.timestamp, \"PERMIT_DEADLINE_EXPIRED\");\r\n\r\n        // Unchecked because the only math done is incrementing\r\n        // the owner's nonce which cannot realistically overflow.\r\n        unchecked {\r\n            address recoveredAddress = ecrecover(\r\n                keccak256(\r\n                    abi.encodePacked(\r\n                        \"\\x19\\x01\",\r\n                        DOMAIN_SEPARATOR(),\r\n                        keccak256(\r\n                            abi.encode(\r\n                                keccak256(\r\n                                    \"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\"\r\n                                ),\r\n                                owner,\r\n                                spender,\r\n                                value,\r\n                                nonces[owner]++,\r\n                                deadline\r\n                            )\r\n                        )\r\n                    )\r\n                ),\r\n                v,\r\n                r,\r\n                s\r\n            );\r\n\r\n            require(recoveredAddress != address(0) && recoveredAddress == owner, \"INVALID_SIGNER\");\r\n\r\n            allowance[recoveredAddress][spender] = value;\r\n        }\r\n\r\n        emit Approval(owner, spender, value);\r\n    }\r\n\r\n    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {\r\n        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();\r\n    }\r\n\r\n    function computeDomainSeparator() internal view virtual returns (bytes32) {\r\n        return\r\n            keccak256(\r\n                abi.encode(\r\n                    keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"),\r\n                    keccak256(bytes(name)),\r\n                    keccak256(\"1\"),\r\n                    block.chainid,\r\n                    address(this)\r\n                )\r\n            );\r\n    }\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                        INTERNAL MINT/BURN LOGIC\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    function _mint(address to, uint256 amount) internal virtual {\r\n        totalSupply += amount;\r\n\r\n        // Cannot overflow because the sum of all user\r\n        // balances can't exceed the max uint256 value.\r\n        unchecked {\r\n            balanceOf[to] += amount;\r\n        }\r\n\r\n        emit Transfer(address(0), to, amount);\r\n    }\r\n\r\n    function _burn(address from, uint256 amount) internal virtual {\r\n        balanceOf[from] -= amount;\r\n\r\n        // Cannot underflow because a user's balance\r\n        // will never be larger than the total supply.\r\n        unchecked {\r\n            totalSupply -= amount;\r\n        }\r\n\r\n        emit Transfer(from, address(0), amount);\r\n    }\r\n}\r\n\r\npragma solidity 0.8.19;\r\n\r\ncontract TwoThousandSevenKiaSedona is ERC20(\"2007 Kia Sedona\", \"2007KiaSedona\", 18) {\r\n\r\n    constructor() {\r\n        _mint(msg.sender, 200700000 * 1e18);\r\n    }\r\n\r\n}\r\n\r\n"

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

    }

  }

}}