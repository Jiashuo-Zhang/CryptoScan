{{

  "language": "Solidity",

  "sources": {

    "contracts/deploy/DesynChainlinkOracle.sol": {

      "content": "pragma solidity 0.6.12;\n\nimport \"../base/Num.sol\";\nimport \"../interfaces/IERC20.sol\";\nimport \"../interfaces/AggregatorV2V3Interface.sol\";\nimport \"../interfaces/IUniswapOracle.sol\";\n\nlibrary SafeMath {\n    function add(uint a, uint b) internal pure returns (uint) {\n        uint c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n\n        return c;\n    }\n\n    function sub(uint a, uint b) internal pure returns (uint) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n\n    function sub(\n        uint a,\n        uint b,\n        string memory errorMessage\n    ) internal pure returns (uint) {\n        require(b <= a, errorMessage);\n        uint c = a - b;\n\n        return c;\n    }\n\n    function mul(uint a, uint b) internal pure returns (uint) {\n        if (a == 0) {\n            return 0;\n        }\n\n        uint c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n\n        return c;\n    }\n\n    function div(uint a, uint b) internal pure returns (uint) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n\n    function div(\n        uint a,\n        uint b,\n        string memory errorMessage\n    ) internal pure returns (uint) {\n        require(b > 0, errorMessage);\n        uint c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn't hold\n\n        return c;\n    }\n\n    function mod(uint a, uint b) internal pure returns (uint) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n\n    function mod(\n        uint a,\n        uint b,\n        string memory errorMessage\n    ) internal pure returns (uint) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n\n    function abs(uint a, uint b) internal pure returns(uint result, bool isFirstBigger) {\n        if(a > b){\n            result = a - b;\n            isFirstBigger = true;\n        } else {\n            result = b - a;\n            isFirstBigger = false;\n        }\n    }\n}\n\ncontract DesynChainlinkOracle is Num {\n    address public admin;\n    using SafeMath for uint;\n    IUniswapOracle public twapOracle;\n    mapping(address => uint) internal prices;\n    mapping(bytes32 => AggregatorV2V3Interface) internal feeds;\n    event PricePosted(address asset, uint previousPriceMantissa, uint requestedPriceMantissa, uint newPriceMantissa);\n    event NewAdmin(address oldAdmin, address newAdmin);\n    event FeedSet(address feed, string symbol);\n\n    constructor(address twapOracle_) public {\n        admin = msg.sender;\n        twapOracle = IUniswapOracle(twapOracle_);\n    }\n\n    function getPrice(address tokenAddress) public returns (uint price) {\n        IERC20 token = IERC20(tokenAddress);\n        AggregatorV2V3Interface feed = getFeed(token.symbol());\n        if (prices[address(token)] != 0) {\n            price = prices[address(token)];\n        } else if (address(feed) != address(0)) {\n            price = getChainlinkPrice(feed);\n        } else {\n            try twapOracle.update(address(token)) {} catch {}\n            price = getUniswapPrice(tokenAddress);\n        }\n\n        (uint decimalDelta, bool isUnderFlow18) = uint(18).abs(uint(token.decimals()));\n\n        if(isUnderFlow18){\n            return price.mul(10**decimalDelta);\n        }\n\n        if(!isUnderFlow18){\n            return price.div(10**decimalDelta);\n        }\n    }\n\n    function getAllPrice(address[] calldata poolTokens, uint[] calldata actualAmountsOut) external returns (uint fundAll) {\n        require(poolTokens.length == actualAmountsOut.length, \"Invalid Length\");\n        \n        for (uint i = 0; i < poolTokens.length; i++) {\n            address t = poolTokens[i];\n            uint tokenAmountOut = actualAmountsOut[i];\n            fundAll = badd(fundAll, bmul(getPrice(t), tokenAmountOut));\n        }\n    }\n\n    function getChainlinkPrice(AggregatorV2V3Interface feed) internal view returns (uint) {\n        // Chainlink USD-denominated feeds store answers at 8 decimals\n        uint decimalDelta = bsub(uint(18), feed.decimals());\n        // Ensure that we don't multiply the result by 0\n        if (decimalDelta > 0) {\n            return uint(feed.latestAnswer()).mul(10**decimalDelta);\n        } else {\n            return uint(feed.latestAnswer());\n        }\n    }\n\n    function getUniswapPrice(address tokenAddress) internal view returns (uint) {\n        IERC20 token = IERC20(tokenAddress);\n        uint price = twapOracle.consult(tokenAddress, 1e18);\n        return price;\n    }\n\n    function setDirectPrice(address asset, uint price) external onlyAdmin {\n        emit PricePosted(asset, prices[asset], price, price);\n        prices[asset] = price;\n    }\n\n    function setFeed(string calldata symbol, address feed) external onlyAdmin {\n        require(feed != address(0) && feed != address(this), \"invalid feed address\");\n        emit FeedSet(feed, symbol);\n        feeds[keccak256(abi.encodePacked(symbol))] = AggregatorV2V3Interface(feed);\n    }\n\n    function getFeed(string memory symbol) public view returns (AggregatorV2V3Interface) {\n        return feeds[keccak256(abi.encodePacked(symbol))];\n    }\n\n    function assetPrices(address asset) external view returns (uint) {\n        return prices[asset];\n    }\n\n    function compareStrings(string memory a, string memory b) internal pure returns (bool) {\n        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));\n    }\n\n    function setAdmin(address newAdmin) external onlyAdmin {\n        require(newAdmin != address(0),\"ERR_ZERO_ADDRESS\");\n        address oldAdmin = admin;\n        admin = newAdmin;\n\n        emit NewAdmin(oldAdmin, newAdmin);\n    }\n\n    modifier onlyAdmin() {\n        require(msg.sender == admin, \"only admin may call\");\n        _;\n    }\n}\n"

    },

    "contracts/base/Num.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity 0.6.12;\n\nimport \"./Const.sol\";\n\n// Core contract; can't be changed. So disable solhint (reminder for v2)\n\n/* solhint-disable private-vars-leading-underscore */\n\ncontract Num is Const {\n    function btoi(uint a) internal pure returns (uint) {\n        return a / BONE;\n    }\n\n    function bfloor(uint a) internal pure returns (uint) {\n        return btoi(a) * BONE;\n    }\n\n    function badd(uint a, uint b) internal pure returns (uint) {\n        uint c = a + b;\n        require(c >= a, \"ERR_ADD_OVERFLOW\");\n        return c;\n    }\n\n    function bsub(uint a, uint b) internal pure returns (uint) {\n        (uint c, bool flag) = bsubSign(a, b);\n        require(!flag, \"ERR_SUB_UNDERFLOW\");\n        return c;\n    }\n\n    function bsubSign(uint a, uint b) internal pure returns (uint, bool) {\n        if (a >= b) {\n            return (a - b, false);\n        } else {\n            return (b - a, true);\n        }\n    }\n\n    function bmul(uint a, uint b) internal pure returns (uint) {\n        uint c0 = a * b;\n        require(a == 0 || c0 / a == b, \"ERR_MUL_OVERFLOW\");\n        uint c1 = c0 + (BONE / 2);\n        require(c1 >= c0, \"ERR_MUL_OVERFLOW\");\n        uint c2 = c1 / BONE;\n        return c2;\n    }\n\n    function bdiv(uint a, uint b) internal pure returns (uint) {\n        require(b != 0, \"ERR_DIV_ZERO\");\n        uint c0 = a * BONE;\n        require(a == 0 || c0 / a == BONE, \"ERR_DIV_INTERNAL\"); // bmul overflow\n        uint c1 = c0 + (b / 2);\n        require(c1 >= c0, \"ERR_DIV_INTERNAL\"); //  badd require\n        uint c2 = c1 / b;\n        return c2;\n    }\n\n    // DSMath.wpow\n    function bpowi(uint a, uint n) internal pure returns (uint) {\n        uint z = n % 2 != 0 ? a : BONE;\n\n        for (n /= 2; n != 0; n /= 2) {\n            a = bmul(a, a);\n\n            if (n % 2 != 0) {\n                z = bmul(z, a);\n            }\n        }\n        return z;\n    }\n\n    // Compute b^(e.w) by splitting it into (b^e)*(b^0.w).\n    // Use `bpowi` for `b^e` and `bpowK` for k iterations\n    // of approximation of b^0.w\n    function bpow(uint base, uint exp) internal pure returns (uint) {\n        require(base >= MIN_BPOW_BASE, \"ERR_BPOW_BASE_TOO_LOW\");\n        require(base <= MAX_BPOW_BASE, \"ERR_BPOW_BASE_TOO_HIGH\");\n\n        uint whole = bfloor(exp);\n        uint remain = bsub(exp, whole);\n\n        uint wholePow = bpowi(base, btoi(whole));\n\n        if (remain == 0) {\n            return wholePow;\n        }\n\n        uint partialResult = bpowApprox(base, remain, BPOW_PRECISION);\n        return bmul(wholePow, partialResult);\n    }\n\n    function bpowApprox(\n        uint base,\n        uint exp,\n        uint precision\n    ) internal pure returns (uint) {\n        // term 0:\n        uint a = exp;\n        (uint x, bool xneg) = bsubSign(base, BONE);\n        uint term = BONE;\n        uint sum = term;\n        bool negative = false;\n\n        // term(k) = numer / denom\n        //         = (product(a - i - 1, i=1-->k) * x^k) / (k!)\n        // each iteration, multiply previous term by (a-(k-1)) * x / k\n        // continue until term is less than precision\n        for (uint i = 1; term >= precision; i++) {\n            uint bigK = i * BONE;\n            (uint c, bool cneg) = bsubSign(a, bsub(bigK, BONE));\n            term = bmul(term, bmul(c, x));\n            term = bdiv(term, bigK);\n            if (term == 0) break;\n\n            if (xneg) negative = !negative;\n            if (cneg) negative = !negative;\n            if (negative) {\n                sum = bsub(sum, term);\n            } else {\n                sum = badd(sum, term);\n            }\n        }\n\n        return sum;\n    }\n}\n"

    },

    "contracts/interfaces/IERC20.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity 0.6.12;\n\n// Interface declarations\n\n/* solhint-disable func-order */\n\ninterface IERC20 {\n    // Emitted when the allowance of a spender for an owner is set by a call to approve.\n    // Value is the new allowance\n    event Approval(address indexed owner, address indexed spender, uint value);\n\n    // Emitted when value tokens are moved from one account (from) to another (to).\n    // Note that value may be zero\n    event Transfer(address indexed from, address indexed to, uint value);\n\n    // Returns the amount of tokens in existence\n    function totalSupply() external view returns (uint);\n\n    // Returns the amount of tokens owned by account\n    function balanceOf(address account) external view returns (uint);\n\n    // Returns the decimals of tokens\n    function decimals() external view returns (uint8);\n\n    function symbol() external view returns (string memory);\n\n    // Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner\n    // through transferFrom. This is zero by default\n    // This value changes when approve or transferFrom are called\n    function allowance(address owner, address spender) external view returns (uint);\n\n    // Sets amount as the allowance of spender over the caller’s tokens\n    // Returns a boolean value indicating whether the operation succeeded\n    // Emits an Approval event.\n    function approve(address spender, uint amount) external returns (bool);\n\n    // Moves amount tokens from the caller’s account to recipient\n    // Returns a boolean value indicating whether the operation succeeded\n    // Emits a Transfer event.\n    function transfer(address recipient, uint amount) external returns (bool);\n\n    // Moves amount tokens from sender to recipient using the allowance mechanism\n    // Amount is then deducted from the caller’s allowance\n    // Returns a boolean value indicating whether the operation succeeded\n    // Emits a Transfer event\n    function transferFrom(\n        address sender,\n        address recipient,\n        uint amount\n    ) external returns (bool);\n}\n"

    },

    "contracts/interfaces/AggregatorV2V3Interface.sol": {

      "content": "pragma solidity 0.6.12;\n\n/**\n * @title The V2 & V3 Aggregator Interface\n * @notice Solidity V0.5 does not allow interfaces to inherit from other\n * interfaces so this contract is a combination of v0.5 AggregatorInterface.sol\n * and v0.5 AggregatorV3Interface.sol.\n */\ninterface AggregatorV2V3Interface {\n    //\n    // V2 Interface:\n    //\n    function latestAnswer() external view returns (int);\n\n    function latestTimestamp() external view returns (uint);\n\n    function latestRound() external view returns (uint);\n\n    function getAnswer(uint roundId) external view returns (int);\n\n    function getTimestamp(uint roundId) external view returns (uint);\n\n    event AnswerUpdated(int indexed current, uint indexed roundId, uint timestamp);\n    event NewRound(uint indexed roundId, address indexed startedBy, uint startedAt);\n\n    //\n    // V3 Interface:\n    //\n    function decimals() external view returns (uint8);\n\n    function description() external view returns (string memory);\n\n    function version() external view returns (uint);\n\n    // getRoundData and latestRoundData should both raise \"No data present\"\n    // if they do not have data to report, instead of returning unset values\n    // which could be misinterpreted as actual reported values.\n    function getRoundData(uint80 _roundId)\n        external\n        view\n        returns (\n            uint80 roundId,\n            int answer,\n            uint startedAt,\n            uint updatedAt,\n            uint80 answeredInRound\n        );\n\n    function latestRoundData()\n        external\n        view\n        returns (\n            uint80 roundId,\n            int answer,\n            uint startedAt,\n            uint updatedAt,\n            uint80 answeredInRound\n        );\n}\n"

    },

    "contracts/interfaces/IUniswapOracle.sol": {

      "content": "pragma solidity 0.6.12;\n\ninterface IUniswapOracle {\n    function update(address token) external;\n\n    function consult(address token, uint amountIn) external view returns (uint amountOut);\n}\n"

    },

    "contracts/base/Const.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity 0.6.12;\n\nimport \"./Color.sol\";\n\ncontract Const is BBronze {\n    uint public constant BONE = 10**18;\n\n    uint public constant MIN_BOUND_TOKENS = 1;\n    uint public constant MAX_BOUND_TOKENS = 16;\n\n    uint public constant MIN_FEE = BONE / 10**6;\n    uint public constant MAX_FEE = BONE / 10;\n    uint public constant EXIT_FEE = 0;\n\n    uint public constant MIN_WEIGHT = BONE;\n    uint public constant MAX_WEIGHT = BONE * 50;\n    uint public constant MAX_TOTAL_WEIGHT = BONE * 50;\n    uint public constant MIN_BALANCE = 0;\n\n    uint public constant INIT_POOL_SUPPLY = BONE * 100;\n\n    uint public constant MIN_BPOW_BASE = 1 wei;\n    uint public constant MAX_BPOW_BASE = (2 * BONE) - 1 wei;\n    uint public constant BPOW_PRECISION = BONE / 10**10;\n\n    uint public constant MAX_IN_RATIO = BONE / 2;\n    uint public constant MAX_OUT_RATIO = (BONE / 3) + 1 wei;\n}\n"

    },

    "contracts/base/Color.sol": {

      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\npragma solidity 0.6.12;\n\n// abstract contract BColor {\n//     function getColor()\n//         external view virtual\n//         returns (bytes32);\n// }\n\ncontract BBronze {\n    function getColor() external pure returns (bytes32) {\n        return bytes32(\"BRONZE\");\n    }\n}\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 20

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

    "metadata": {

      "useLiteralContent": true

    },

    "libraries": {}

  }

}}