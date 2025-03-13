{{

  "language": "Solidity",

  "sources": {

    "src/Lootto.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\r\npragma solidity 0.8.19;\r\n\r\nimport {Owned} from \"solmate/auth/Owned.sol\";\r\nimport {IUniswapV2Router02} from \"v2-periphery/interfaces/IUniswapV2Router02.sol\";\r\n\r\n// PAIN LOOTTO\r\n// The Memecoin Misfortune Extravaganza!\r\n\r\n// twitter: https://twitter.com/loottoerc20\r\n// telegram: https://t.me/visitthedungeon\r\ncontract Lootto is Owned {\r\n    event Transfer(address indexed from, address indexed to, uint256 amount);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\r\n\r\n    event IsAddressExcludedChanged(address indexed user, bool value);\r\n\r\n    error MaxBuyExceeded(uint256 maxBuy, uint256 amount);\r\n    error TradingNotEnabled();\r\n    error PainAlreadyInflicted();\r\n\r\n    string public name;\r\n\r\n    string public symbol;\r\n\r\n    uint8 public immutable decimals;\r\n\r\n    uint256 public totalSupply;\r\n\r\n    mapping(address => uint256) public balanceOf;\r\n\r\n    mapping(address => mapping(address => uint256)) public allowance;\r\n\r\n    uint256 internal immutable INITIAL_CHAIN_ID;\r\n\r\n    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;\r\n\r\n    mapping(address => uint256) public nonces;\r\n\r\n    mapping(address => bool) public isAddressExcluded;\r\n    uint256 private constant EMOTIONAL_DAMAGE = 3000;\r\n    uint256 private constant EVERY_NTH_TRANSFER_TAXED = 5;\r\n    uint256 private constant HUNDRED_PERCENT = 10000;\r\n    address private immutable TREASURY;\r\n    IUniswapV2Router02 private immutable router;\r\n    address private immutable WETH;\r\n    uint216 private transferNumber;\r\n\r\n    uint256 private constant MAX_BUY = 1e26;\r\n    uint256 private constant MAX_BUY_DURATION = 10 minutes;\r\n    uint40 private MAX_BUY_END_TIME;\r\n\r\n    constructor(address treasury, address uniV2Router, address weth) Owned(msg.sender) {\r\n        name = \"PAIN LOOTTO\";\r\n        symbol = \"LOOTTO\";\r\n        decimals = 18;\r\n\r\n        INITIAL_CHAIN_ID = block.chainid;\r\n        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();\r\n\r\n        _mint(msg.sender, 1e28);\r\n\r\n        isAddressExcluded[msg.sender] = true;\r\n        isAddressExcluded[treasury] = true;\r\n        isAddressExcluded[address(this)] = true;\r\n\r\n        TREASURY = treasury;\r\n\r\n        router = IUniswapV2Router02(uniV2Router);\r\n        allowance[address(this)][uniV2Router] = type(uint256).max;\r\n\r\n        WETH = weth;\r\n    }\r\n\r\n    function approve(address spender, uint256 amount) public returns (bool) {\r\n        allowance[msg.sender][spender] = amount;\r\n\r\n        emit Approval(msg.sender, spender, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    function transfer(address to, uint256 amount) public returns (bool) {\r\n        balanceOf[msg.sender] -= amount;\r\n\r\n        if (!isAddressExcluded[msg.sender]) {\r\n            amount = _processEmotionalDamage(amount);\r\n\r\n            if (MAX_BUY_END_TIME == 0) revert TradingNotEnabled();\r\n        }\r\n\r\n        // Cannot overflow because the sum of all user\r\n        // balances can't exceed the max uint224 value.\r\n        // taxAmount is always less than amount\r\n        unchecked {\r\n            uint256 newAmount = amount + balanceOf[to];\r\n\r\n            if (!isAddressExcluded[to]) {\r\n                _revertOnMaxBuyExceeded(newAmount);\r\n            }\r\n\r\n            balanceOf[to] = newAmount;\r\n        }\r\n\r\n        emit Transfer(msg.sender, to, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(address from, address to, uint256 amount) public returns (bool) {\r\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\r\n\r\n        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;\r\n\r\n        balanceOf[from] -= amount;\r\n\r\n        if (!isAddressExcluded[from]) {\r\n            amount = _processEmotionalDamage(amount);\r\n        }\r\n\r\n        // Cannot overflow because the sum of all user\r\n        // balances can't exceed the max uint224 value.\r\n        // taxAmount is always less than amount\r\n        unchecked {\r\n            uint256 newAmount = amount + balanceOf[to];\r\n\r\n            if (!isAddressExcluded[to]) {\r\n                _revertOnMaxBuyExceeded(newAmount);\r\n\r\n                if (MAX_BUY_END_TIME == 0) revert TradingNotEnabled();\r\n            }\r\n\r\n            balanceOf[to] = newAmount;\r\n        }\r\n\r\n        emit Transfer(from, to, amount);\r\n\r\n        return true;\r\n    }\r\n\r\n    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)\r\n        public\r\n    {\r\n        require(deadline >= block.timestamp, \"PERMIT_DEADLINE_EXPIRED\");\r\n\r\n        // Unchecked because the only math done is incrementing\r\n        // the owner's nonce which cannot realistically overflow.\r\n        unchecked {\r\n            address recoveredAddress = ecrecover(\r\n                keccak256(\r\n                    abi.encodePacked(\r\n                        \"\\x19\\x01\",\r\n                        DOMAIN_SEPARATOR(),\r\n                        keccak256(\r\n                            abi.encode(\r\n                                keccak256(\r\n                                    \"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\"\r\n                                ),\r\n                                owner,\r\n                                spender,\r\n                                value,\r\n                                nonces[owner]++,\r\n                                deadline\r\n                            )\r\n                        )\r\n                    )\r\n                ),\r\n                v,\r\n                r,\r\n                s\r\n            );\r\n\r\n            require(recoveredAddress != address(0) && recoveredAddress == owner, \"INVALID_SIGNER\");\r\n\r\n            allowance[recoveredAddress][spender] = value;\r\n        }\r\n\r\n        emit Approval(owner, spender, value);\r\n    }\r\n\r\n    function DOMAIN_SEPARATOR() public view returns (bytes32) {\r\n        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();\r\n    }\r\n\r\n    function computeDomainSeparator() internal view returns (bytes32) {\r\n        return keccak256(\r\n            abi.encode(\r\n                keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"),\r\n                keccak256(bytes(name)),\r\n                keccak256(\"1\"),\r\n                block.chainid,\r\n                address(this)\r\n            )\r\n        );\r\n    }\r\n\r\n    function _mint(address to, uint256 amount) internal {\r\n        totalSupply += amount;\r\n\r\n        unchecked {\r\n            balanceOf[to] += amount;\r\n        }\r\n\r\n        emit Transfer(address(0), to, amount);\r\n    }\r\n\r\n    function _processEmotionalDamage(uint256 amount) internal returns (uint256) {\r\n        unchecked {\r\n            uint256 newTransferNumber = ++transferNumber;\r\n\r\n            if (newTransferNumber % 5 != 0) {\r\n                return amount;\r\n            }\r\n            // cant overflow because:\r\n            // block.timestamp <= minTaxOn\r\n            // all numbers are small enough for type(uint256).max\r\n            uint256 taxAmount = EMOTIONAL_DAMAGE * amount / HUNDRED_PERCENT;\r\n\r\n            if (taxAmount == 0) {\r\n                return amount;\r\n            }\r\n\r\n            uint256 newAmount = taxAmount + balanceOf[address(this)];\r\n            balanceOf[address(this)] = newAmount;\r\n\r\n            address[] memory path = new address[](2);\r\n            path[0] = address(this);\r\n            path[1] = WETH;\r\n\r\n            try router.swapExactTokensForETH(newAmount, 0, path, TREASURY, block.timestamp) {\r\n                // SWAP was successful.\r\n            } catch {\r\n                // Swap can fail if amount is too low, we dont want to handle it, next tax will sell everything together.\r\n            }\r\n\r\n            return (amount - taxAmount);\r\n        }\r\n    }\r\n\r\n    function _revertOnMaxBuyExceeded(uint256 newAmount) internal view {\r\n        if (block.timestamp > MAX_BUY_END_TIME) {\r\n            return;\r\n        }\r\n\r\n        if (newAmount > MAX_BUY) revert MaxBuyExceeded(MAX_BUY, newAmount);\r\n    }\r\n\r\n    function maxBuy() external view returns (uint256) {\r\n        if (block.timestamp > MAX_BUY_END_TIME) {\r\n            return type(uint256).max;\r\n        }\r\n\r\n        return MAX_BUY;\r\n    }\r\n\r\n    function setIsAddressExcluded(address user, bool value) external onlyOwner {\r\n        isAddressExcluded[user] = value;\r\n\r\n        emit IsAddressExcludedChanged(user, value);\r\n    }\r\n\r\n    function renounceOwnership() external {\r\n        transferOwnership(address(0));\r\n    }\r\n\r\n    function inflictPain() external onlyOwner {\r\n        if (MAX_BUY_END_TIME != 0) revert PainAlreadyInflicted();\r\n\r\n        MAX_BUY_END_TIME = uint40(block.timestamp + MAX_BUY_DURATION);\r\n    }\r\n\r\n    function isPainInflicted() external view returns (bool) {\r\n        return MAX_BUY_END_TIME != 0;\r\n    }\r\n}\r\n"

    },

    "lib/solmate/src/auth/Owned.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\r\npragma solidity >=0.8.0;\r\n\r\n/// @notice Simple single owner authorization mixin.\r\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)\r\nabstract contract Owned {\r\n    /*//////////////////////////////////////////////////////////////\r\n                                 EVENTS\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    event OwnershipTransferred(address indexed user, address indexed newOwner);\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                            OWNERSHIP STORAGE\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    address public owner;\r\n\r\n    modifier onlyOwner() virtual {\r\n        require(msg.sender == owner, \"UNAUTHORIZED\");\r\n\r\n        _;\r\n    }\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                               CONSTRUCTOR\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    constructor(address _owner) {\r\n        owner = _owner;\r\n\r\n        emit OwnershipTransferred(address(0), _owner);\r\n    }\r\n\r\n    /*//////////////////////////////////////////////////////////////\r\n                             OWNERSHIP LOGIC\r\n    //////////////////////////////////////////////////////////////*/\r\n\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        owner = newOwner;\r\n\r\n        emit OwnershipTransferred(msg.sender, newOwner);\r\n    }\r\n}\r\n"

    },

    "lib/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol": {

      "content": "pragma solidity >=0.6.2;\r\n\r\nimport './IUniswapV2Router01.sol';\r\n\r\ninterface IUniswapV2Router02 is IUniswapV2Router01 {\r\n    function removeLiquidityETHSupportingFeeOnTransferTokens(\r\n        address token,\r\n        uint liquidity,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountETH);\r\n    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(\r\n        address token,\r\n        uint liquidity,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline,\r\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\r\n    ) external returns (uint amountETH);\r\n\r\n    function swapExactTokensForTokensSupportingFeeOnTransferTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external;\r\n    function swapExactETHForTokensSupportingFeeOnTransferTokens(\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external payable;\r\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external;\r\n}\r\n"

    },

    "lib/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol": {

      "content": "pragma solidity >=0.6.2;\r\n\r\ninterface IUniswapV2Router01 {\r\n    function factory() external pure returns (address);\r\n    function WETH() external pure returns (address);\r\n\r\n    function addLiquidity(\r\n        address tokenA,\r\n        address tokenB,\r\n        uint amountADesired,\r\n        uint amountBDesired,\r\n        uint amountAMin,\r\n        uint amountBMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountA, uint amountB, uint liquidity);\r\n    function addLiquidityETH(\r\n        address token,\r\n        uint amountTokenDesired,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);\r\n    function removeLiquidity(\r\n        address tokenA,\r\n        address tokenB,\r\n        uint liquidity,\r\n        uint amountAMin,\r\n        uint amountBMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountA, uint amountB);\r\n    function removeLiquidityETH(\r\n        address token,\r\n        uint liquidity,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint amountToken, uint amountETH);\r\n    function removeLiquidityWithPermit(\r\n        address tokenA,\r\n        address tokenB,\r\n        uint liquidity,\r\n        uint amountAMin,\r\n        uint amountBMin,\r\n        address to,\r\n        uint deadline,\r\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\r\n    ) external returns (uint amountA, uint amountB);\r\n    function removeLiquidityETHWithPermit(\r\n        address token,\r\n        uint liquidity,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline,\r\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\r\n    ) external returns (uint amountToken, uint amountETH);\r\n    function swapExactTokensForTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint[] memory amounts);\r\n    function swapTokensForExactTokens(\r\n        uint amountOut,\r\n        uint amountInMax,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint[] memory amounts);\r\n    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)\r\n        external\r\n        payable\r\n        returns (uint[] memory amounts);\r\n    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)\r\n        external\r\n        returns (uint[] memory amounts);\r\n    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)\r\n        external\r\n        returns (uint[] memory amounts);\r\n    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)\r\n        external\r\n        payable\r\n        returns (uint[] memory amounts);\r\n\r\n    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);\r\n    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);\r\n    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);\r\n    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);\r\n    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);\r\n}\r\n"

    }

  },

  "settings": {

    "remappings": [

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",

      "forge-std/=lib/forge-std/src/",

      "openzeppelin-contracts/=lib/openzeppelin-contracts/",

      "openzeppelin/=lib/openzeppelin-contracts/contracts/",

      "solady/=lib/solady/",

      "solmate/=lib/solmate/src/",

      "v2-core/=lib/v2-core/contracts/",

      "v2-periphery/=lib/v2-periphery/contracts/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "useLiteralContent": false,

      "bytecodeHash": "ipfs",

      "appendCBOR": true

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

    "evmVersion": "paris",

    "libraries": {}

  }

}}