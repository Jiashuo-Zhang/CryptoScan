/**

 *Submitted for verification at Etherscan.io on 2020-09-15

*/



pragma solidity =0.6.6;



//import '@swapx/v1-core/contracts/interfaces/ISwapXV1Factory.sol';



interface ISwapXV1Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, address pToken, uint);



    function feeTo() external view returns (address);



    function setter() external view returns (address);



    function miner() external view returns (address);



    function token2Pair(address token) external view returns (address pair);



    function pair2Token(address pair) external view returns (address pToken);



    function getPair(address tokenA, address tokenB) external view returns (address pair);



    function allPairs(uint) external view returns (address pair);



    function pairTokens(uint) external view returns (address pair);



    function allPairsLength() external view returns (uint);



    function createPair(address tokenA, address tokenB) external returns (address pair, address pToken);



    function setFeeTo(address) external;



    function setSetter(address) external;



    function setMiner(address) external;



}



//import '@swapx/lib/contracts/libraries/TransferHelper.sol';



// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false

library TransferHelper {

    function safeApprove(address token, address to, uint value) internal {

        // bytes4(keccak256(bytes('approve(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');

    }



    function safeTransfer(address token, address to, uint value) internal {

        // bytes4(keccak256(bytes('transfer(address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');

    }



    function safeTransferFrom(address token, address from, address to, uint value) internal {

        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));

        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');

    }



    function safeTransferETH(address to, uint value) internal {

        (bool success,) = to.call{value:value}(new bytes(0));

        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');

    }

}



//import '@swapx/lib/contracts/libraries/PairNamer.sol';



//import './SafeERC20Namer.sol';



//import './AddressStringUtil.sol';



library AddressStringUtil {

    // converts an address to the uppercase hex string, extracting only len bytes (up to 20, multiple of 2)

    function toAsciiString(address addr, uint len) pure internal returns (string memory) {

        require(len % 2 == 0 && len > 0 && len <= 40, "AddressStringUtil: INVALID_LEN");



        bytes memory s = new bytes(len);

        uint addrNum = uint(addr);

        for (uint i = 0; i < len / 2; i++) {

            // shift right and truncate all but the least significant byte to extract the byte at position 19-i

            uint8 b = uint8(addrNum >> (8 * (19 - i)));

            // first hex character is the most significant 4 bits

            uint8 hi = b >> 4;

            // second hex character is the least significant 4 bits

            uint8 lo = b - (hi << 4);

            s[2 * i] = char(hi);

            s[2 * i + 1] = char(lo);

        }

        return string(s);

    }



    // hi and lo are only 4 bits and between 0 and 16

    // this method converts those values to the unicode/ascii code point for the hex representation

    // uses upper case for the characters

    function char(uint8 b) pure private returns (byte c) {

        if (b < 10) {

            return byte(b + 0x30);

        } else {

            return byte(b + 0x37);

        }

    }

}





// produces token descriptors from inconsistent or absent ERC20 symbol implementations that can return string or bytes32

// this library will always produce a string symbol to represent the token

library SafeERC20Namer {

    function bytes32ToString(bytes32 x) pure private returns (string memory) {

        bytes memory bytesString = new bytes(32);

        uint charCount = 0;

        for (uint j = 0; j < 32; j++) {

            byte char = x[j];

            if (char != 0) {

                bytesString[charCount] = char;

                charCount++;

            }

        }

        bytes memory bytesStringTrimmed = new bytes(charCount);

        for (uint j = 0; j < charCount; j++) {

            bytesStringTrimmed[j] = bytesString[j];

        }

        return string(bytesStringTrimmed);

    }



    // assumes the data is in position 2

    function parseStringData(bytes memory b) pure private returns (string memory) {

        uint charCount = 0;

        // first parse the charCount out of the data

        for (uint i = 32; i < 64; i++) {

            charCount <<= 8;

            charCount += uint8(b[i]);

        }



        bytes memory bytesStringTrimmed = new bytes(charCount);

        for (uint i = 0; i < charCount; i++) {

            bytesStringTrimmed[i] = b[i + 64];

        }



        return string(bytesStringTrimmed);

    }



    // uses a heuristic to produce a token name from the address

    // the heuristic returns the full hex of the address string in upper case

    function addressToName(address token) pure private returns (string memory) {

        return AddressStringUtil.toAsciiString(token, 40);

    }



    // uses a heuristic to produce a token symbol from the address

    // the heuristic returns the first 6 hex of the address string in upper case

    function addressToSymbol(address token) pure private returns (string memory) {

        return AddressStringUtil.toAsciiString(token, 6);

    }



    // calls an external view token contract method that returns a symbol or name, and parses the output into a string

    function callAndParseStringReturn(address token, bytes4 selector) view private returns (string memory) {

        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSelector(selector));

        // if not implemented, or returns empty data, return empty string

        if (!success || data.length == 0) {

            return "";

        }

        // bytes32 data always has length 32

        if (data.length == 32) {

            bytes32 decoded = abi.decode(data, (bytes32));

            return bytes32ToString(decoded);

        } else if (data.length > 64) {

            return abi.decode(data, (string));

        }

        return "";

    }



    // attempts to extract the token symbol. if it does not implement symbol, returns a symbol derived from the address

    function tokenSymbol(address token) internal view returns (string memory) {

        // 0x95d89b41 = bytes4(keccak256("symbol()"))

        string memory symbol = callAndParseStringReturn(token, 0x95d89b41);

        if (bytes(symbol).length == 0) {

            // fallback to 6 uppercase hex of address

            return addressToSymbol(token);

        }

        return symbol;

    }



    // attempts to extract the token name. if it does not implement name, returns a name derived from the address

    function tokenName(address token) internal view returns (string memory) {

        // 0x06fdde03 = bytes4(keccak256("name()"))

        string memory name = callAndParseStringReturn(token, 0x06fdde03);

        if (bytes(name).length == 0) {

            // fallback to full hex of address

            return addressToName(token);

        }

        return name;

    }

}





// produces names for pairs of tokens

library PairNamer {

    string private constant TOKEN_SYMBOL_PREFIX = '🔀';

    string private constant TOKEN_SEPARATOR = ':';



    // produces a pair descriptor in the format of `${prefix}${name0}:${name1}${suffix}`

    function pairName(address token0, address token1, string memory prefix, string memory suffix) internal view returns (string memory) {

        return string(

            abi.encodePacked(

                prefix,

                SafeERC20Namer.tokenName(token0),

                TOKEN_SEPARATOR,

                SafeERC20Namer.tokenName(token1),

                suffix

            )

        );

    }



    // produces a pair symbol in the format of `🔀${symbol0}:${symbol1}${suffix}`

    function pairSymbol(address token0, address token1, string memory suffix) internal view returns (string memory) {

        return string(

            abi.encodePacked(

                TOKEN_SYMBOL_PREFIX,

                SafeERC20Namer.tokenSymbol(token0),

                TOKEN_SEPARATOR,

                SafeERC20Namer.tokenSymbol(token1),

                suffix

            )

        );

    }



    // produces a pair symbol in the format of `🔀${symbol0}:${symbol1}${suffix}`

    function pairPtSymbol(address token0, address token1, string memory suffix) internal view returns (string memory) {

        return string(

            abi.encodePacked(

                SafeERC20Namer.tokenSymbol(token0),

                SafeERC20Namer.tokenSymbol(token1),

                suffix

            )

        );

    }

}



//import './interfaces/IERC20.sol';



interface IERC20 {

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);



    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);



    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

}





//import './interfaces/ISwapXV1Router02.sol';



//import './ISwapXV1Router01.sol';



interface ISwapXV1Router01 {

    function factory() external pure returns (address);

    function WETH() external pure returns (address);



    function addLiquidity(

        address tokenA,

        address tokenB,

        uint amountADesired,

        uint amountBDesired,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(

        address token,

        uint amountTokenDesired,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(

        uint amountOut,

        uint amountInMax,

        address[] calldata path,

        address to,

        uint deadline

    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        returns (uint[] memory amounts);

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)

        external

        payable

        returns (uint[] memory amounts);



    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}





interface ISwapXV1Router02 is ISwapXV1Router01 {

    function removeLiquidityETHSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external returns (uint amountETH);



    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external;

}



//import './libraries/SwapXV1Library.sol';



// import '@swapx/v1-core/contracts/interfaces/ISwapXV1Pair.sol';



interface ISwapXV1Pair {

    event Approval(address indexed owner, address indexed spender, uint value);

    event Transfer(address indexed from, address indexed to, uint value);



    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);



    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);



    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);



    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;



    event Mint(address indexed sender, uint amount0, uint amount1);

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);

    event Swap(

        address indexed sender,

        uint amount0In,

        uint amount1In,

        uint amount0Out,

        uint amount1Out,

        address indexed to

    );

    event Sync(uint112 reserve0, uint112 reserve1);



    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);



    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;



    function initialize(address, address) external;

}





// import "@swapx/v1-core/contracts/interfaces/ISwapXV1Factory.sol";





//import "./SafeMath.sol";



// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)



library SafeMath {

    function add(uint x, uint y) internal pure returns (uint z) {

        require((z = x + y) >= x, 'ds-math-add-overflow');

    }



    function sub(uint x, uint y) internal pure returns (uint z) {

        require((z = x - y) <= x, 'ds-math-sub-underflow');

    }



    function mul(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');

    }

}



library SwapXV1Library {

    using SafeMath for uint;



    // returns sorted token addresses, used to handle return values from pairs sorted in this order

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'SwapXV1Library: IDENTICAL_ADDRESSES');

        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        require(token0 != address(0), 'SwapXV1Library: ZERO_ADDRESS');

    }



    // calculates the CREATE2 address for a pair without making any external calls

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);

        pair = address(uint(keccak256(abi.encodePacked(

                hex'ff',

                factory,

                keccak256(abi.encodePacked(token0, token1)),

                hex'8a838d3f197b37a44c61957f48e39c7c4102bc1c5496802ad8473865bb6eb733' // init code hash

            ))));

    }



    // fetches and sorts the reserves for a pair

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);

        (uint reserve0, uint reserve1,) = ISwapXV1Pair(pairFor(factory, tokenA, tokenB)).getReserves();

        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);

    }



    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'SwapXV1Library: INSUFFICIENT_AMOUNT');

        require(reserveA > 0 && reserveB > 0, 'SwapXV1Library: INSUFFICIENT_LIQUIDITY');

        amountB = amountA.mul(reserveB) / reserveA;

    }



    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'SwapXV1Library: INSUFFICIENT_INPUT_AMOUNT');

        require(reserveIn > 0 && reserveOut > 0, 'SwapXV1Library: INSUFFICIENT_LIQUIDITY');

        uint amountInWithFee = amountIn.mul(997);

        uint numerator = amountInWithFee.mul(reserveOut);

        uint denominator = reserveIn.mul(1000).add(amountInWithFee);

        amountOut = numerator / denominator;

    }



    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'SwapXV1Library: INSUFFICIENT_OUTPUT_AMOUNT');

        require(reserveIn > 0 && reserveOut > 0, 'SwapXV1Library: INSUFFICIENT_LIQUIDITY');

        uint numerator = reserveIn.mul(amountOut).mul(1000);

        uint denominator = reserveOut.sub(amountOut).mul(997);

        amountIn = (numerator / denominator).add(1);

    }



    // performs chained getAmountOut calculations on any number of pairs

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'SwapXV1Library: INVALID_PATH');

        amounts = new uint[](path.length);

        amounts[0] = amountIn;

        for (uint i; i < path.length - 1; i++) {

            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);

            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);

        }

    }



    // performs chained getAmountIn calculations on any number of pairs

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'SwapXV1Library: INVALID_PATH');

        amounts = new uint[](path.length);

        amounts[amounts.length - 1] = amountOut;

        for (uint i = path.length - 1; i > 0; i--) {

            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);

            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);

        }

    }

}





//import './interfaces/IWETH.sol';



interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}



contract SwapXV1Router02 is ISwapXV1Router02 {

    using SafeMath for uint;



    address public immutable override factory;

    address public immutable override WETH;



    modifier ensure(uint deadline) {

        require(deadline >= block.timestamp, 'SwapXV1Router: EXPIRED');

        _;

    }



    constructor(address _factory, address _WETH) public {

        factory = _factory;

        WETH = _WETH;

    }



    receive() external payable {

        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract

    }



    // **** ADD LIQUIDITY ****

    function _addLiquidity(

        address tokenA,

        address tokenB,

        uint amountADesired,

        uint amountBDesired,

        uint amountAMin,

        uint amountBMin

    ) internal virtual returns (uint amountA, uint amountB) {

        // create the pair if it doesn't exist yet

        if (ISwapXV1Factory(factory).getPair(tokenA, tokenB) == address(0)) {

            ISwapXV1Factory(factory).createPair(tokenA, tokenB);

        }

        (uint reserveA, uint reserveB) = SwapXV1Library.getReserves(factory, tokenA, tokenB);

        if (reserveA == 0 && reserveB == 0) {

            (amountA, amountB) = (amountADesired, amountBDesired);

        } else {

            uint amountBOptimal = SwapXV1Library.quote(amountADesired, reserveA, reserveB);

            if (amountBOptimal <= amountBDesired) {

                require(amountBOptimal >= amountBMin, 'SwapXV1Router: INSUFFICIENT_B_AMOUNT');

                (amountA, amountB) = (amountADesired, amountBOptimal);

            } else {

                uint amountAOptimal = SwapXV1Library.quote(amountBDesired, reserveB, reserveA);

                assert(amountAOptimal <= amountADesired);

                require(amountAOptimal >= amountAMin, 'SwapXV1Router: INSUFFICIENT_A_AMOUNT');

                (amountA, amountB) = (amountAOptimal, amountBDesired);

            }

        }

    }

    function addLiquidity(

        address tokenA,

        address tokenB,

        uint amountADesired,

        uint amountBDesired,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {

        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);

        address pair = SwapXV1Library.pairFor(factory, tokenA, tokenB);

        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);

        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);

        liquidity = ISwapXV1Pair(pair).mint(to);

    }

    function addLiquidityETH(

        address token,

        uint amountTokenDesired,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) external virtual override payable ensure(deadline) returns (uint amountToken, uint amountETH, uint liquidity) {

        (amountToken, amountETH) = _addLiquidity(

            token,

            WETH,

            amountTokenDesired,

            msg.value,

            amountTokenMin,

            amountETHMin

        );

        address pair = SwapXV1Library.pairFor(factory, token, WETH);

        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);

        IWETH(WETH).deposit{value: amountETH}();

        assert(IWETH(WETH).transfer(pair, amountETH));

        liquidity = ISwapXV1Pair(pair).mint(to);

        // refund dust eth, if any

        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);

    }



    // **** REMOVE LIQUIDITY ****

    function removeLiquidity(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline

    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {

        address pair = SwapXV1Library.pairFor(factory, tokenA, tokenB);

        ISwapXV1Pair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair

        (uint amount0, uint amount1) = ISwapXV1Pair(pair).burn(to);

        (address token0,) = SwapXV1Library.sortTokens(tokenA, tokenB);

        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);

        require(amountA >= amountAMin, 'SwapXV1Router: INSUFFICIENT_A_AMOUNT');

        require(amountB >= amountBMin, 'SwapXV1Router: INSUFFICIENT_B_AMOUNT');

    }

    function removeLiquidityETH(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {

        (amountToken, amountETH) = removeLiquidity(

            token,

            WETH,

            liquidity,

            amountTokenMin,

            amountETHMin,

            address(this),

            deadline

        );

        TransferHelper.safeTransfer(token, to, amountToken);

        IWETH(WETH).withdraw(amountETH);

        TransferHelper.safeTransferETH(to, amountETH);

    }

    function removeLiquidityWithPermit(

        address tokenA,

        address tokenB,

        uint liquidity,

        uint amountAMin,

        uint amountBMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external virtual override returns (uint amountA, uint amountB) {

        address pair = SwapXV1Library.pairFor(factory, tokenA, tokenB);

        uint value = approveMax ? uint(-1) : liquidity;

        ISwapXV1Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);

        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);

    }

    function removeLiquidityETHWithPermit(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external virtual override returns (uint amountToken, uint amountETH) {

        address pair = SwapXV1Library.pairFor(factory, token, WETH);

        uint value = approveMax ? uint(-1) : liquidity;

        ISwapXV1Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);

        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);

    }



    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****

    function removeLiquidityETHSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline

    ) public virtual override ensure(deadline) returns (uint amountETH) {

        (, amountETH) = removeLiquidity(

            token,

            WETH,

            liquidity,

            amountTokenMin,

            amountETHMin,

            address(this),

            deadline

        );

        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));

        IWETH(WETH).withdraw(amountETH);

        TransferHelper.safeTransferETH(to, amountETH);

    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(

        address token,

        uint liquidity,

        uint amountTokenMin,

        uint amountETHMin,

        address to,

        uint deadline,

        bool approveMax, uint8 v, bytes32 r, bytes32 s

    ) external virtual override returns (uint amountETH) {

        address pair = SwapXV1Library.pairFor(factory, token, WETH);

        uint value = approveMax ? uint(-1) : liquidity;

        ISwapXV1Pair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);

        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(

            token, liquidity, amountTokenMin, amountETHMin, to, deadline

        );

    }



    // **** SWAP ****

    // requires the initial amount to have already been sent to the first pair

    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {

        for (uint i; i < path.length - 1; i++) {

            (address input, address output) = (path[i], path[i + 1]);

            (address token0,) = SwapXV1Library.sortTokens(input, output);

            uint amountOut = amounts[i + 1];

            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));

            address to = i < path.length - 2 ? SwapXV1Library.pairFor(factory, output, path[i + 2]) : _to;

            ISwapXV1Pair(SwapXV1Library.pairFor(factory, input, output)).swap(

                amount0Out, amount1Out, to, new bytes(0)

            );

        }

    }

    function swapExactTokensForTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {

        amounts = SwapXV1Library.getAmountsOut(factory, amountIn, path);

        require(amounts[amounts.length - 1] >= amountOutMin, 'SwapXV1Router: INSUFFICIENT_OUTPUT_AMOUNT');

        TransferHelper.safeTransferFrom(

            path[0], msg.sender, SwapXV1Library.pairFor(factory, path[0], path[1]), amounts[0]

        );

        _swap(amounts, path, to);

    }

    function swapTokensForExactTokens(

        uint amountOut,

        uint amountInMax,

        address[] calldata path,

        address to,

        uint deadline

    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {

        amounts = SwapXV1Library.getAmountsIn(factory, amountOut, path);

        require(amounts[0] <= amountInMax, 'SwapXV1Router: EXCESSIVE_INPUT_AMOUNT');

        TransferHelper.safeTransferFrom(

            path[0], msg.sender, SwapXV1Library.pairFor(factory, path[0], path[1]), amounts[0]

        );

        _swap(amounts, path, to);

    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        virtual

        override

        payable

        ensure(deadline)

        returns (uint[] memory amounts)

    {

        require(path[0] == WETH, 'SwapXV1Router: INVALID_PATH');

        amounts = SwapXV1Library.getAmountsOut(factory, msg.value, path);

        require(amounts[amounts.length - 1] >= amountOutMin, 'SwapXV1Router: INSUFFICIENT_OUTPUT_AMOUNT');

        IWETH(WETH).deposit{value: amounts[0]}();

        assert(IWETH(WETH).transfer(SwapXV1Library.pairFor(factory, path[0], path[1]), amounts[0]));

        _swap(amounts, path, to);

    }

    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)

        external

        virtual

        override

        ensure(deadline)

        returns (uint[] memory amounts)

    {

        require(path[path.length - 1] == WETH, 'SwapXV1Router: INVALID_PATH');

        amounts = SwapXV1Library.getAmountsIn(factory, amountOut, path);

        require(amounts[0] <= amountInMax, 'SwapXV1Router: EXCESSIVE_INPUT_AMOUNT');

        TransferHelper.safeTransferFrom(

            path[0], msg.sender, SwapXV1Library.pairFor(factory, path[0], path[1]), amounts[0]

        );

        _swap(amounts, path, address(this));

        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

    }

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)

        external

        virtual

        override

        ensure(deadline)

        returns (uint[] memory amounts)

    {

        require(path[path.length - 1] == WETH, 'SwapXV1Router: INVALID_PATH');

        amounts = SwapXV1Library.getAmountsOut(factory, amountIn, path);

        require(amounts[amounts.length - 1] >= amountOutMin, 'SwapXV1Router: INSUFFICIENT_OUTPUT_AMOUNT');

        TransferHelper.safeTransferFrom(

            path[0], msg.sender, SwapXV1Library.pairFor(factory, path[0], path[1]), amounts[0]

        );

        _swap(amounts, path, address(this));

        IWETH(WETH).withdraw(amounts[amounts.length - 1]);

        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);

    }

    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)

        external

        virtual

        override

        payable

        ensure(deadline)

        returns (uint[] memory amounts)

    {

        require(path[0] == WETH, 'SwapXV1Router: INVALID_PATH');

        amounts = SwapXV1Library.getAmountsIn(factory, amountOut, path);

        require(amounts[0] <= msg.value, 'SwapXV1Router: EXCESSIVE_INPUT_AMOUNT');

        IWETH(WETH).deposit{value: amounts[0]}();

        assert(IWETH(WETH).transfer(SwapXV1Library.pairFor(factory, path[0], path[1]), amounts[0]));

        _swap(amounts, path, to);

        // refund dust eth, if any

        if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);

    }



    // **** SWAP (supporting fee-on-transfer tokens) ****

    // requires the initial amount to have already been sent to the first pair

    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {

        for (uint i; i < path.length - 1; i++) {

            (address input, address output) = (path[i], path[i + 1]);

            (address token0,) = SwapXV1Library.sortTokens(input, output);

            ISwapXV1Pair pair = ISwapXV1Pair(SwapXV1Library.pairFor(factory, input, output));

            uint amountInput;

            uint amountOutput;

            { // scope to avoid stack too deep errors

            (uint reserve0, uint reserve1,) = pair.getReserves();

            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);

            amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);

            amountOutput = SwapXV1Library.getAmountOut(amountInput, reserveInput, reserveOutput);

            }

            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));

            address to = i < path.length - 2 ? SwapXV1Library.pairFor(factory, output, path[i + 2]) : _to;

            pair.swap(amount0Out, amount1Out, to, new bytes(0));

        }

    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    ) external virtual override ensure(deadline) {

        TransferHelper.safeTransferFrom(

            path[0], msg.sender, SwapXV1Library.pairFor(factory, path[0], path[1]), amountIn

        );

        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);

        _swapSupportingFeeOnTransferTokens(path, to);

        require(

            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,

            'SwapXV1Router: INSUFFICIENT_OUTPUT_AMOUNT'

        );

    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    )

        external

        virtual

        override

        payable

        ensure(deadline)

    {

        require(path[0] == WETH, 'SwapXV1Router: INVALID_PATH');

        uint amountIn = msg.value;

        IWETH(WETH).deposit{value: amountIn}();

        assert(IWETH(WETH).transfer(SwapXV1Library.pairFor(factory, path[0], path[1]), amountIn));

        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);

        _swapSupportingFeeOnTransferTokens(path, to);

        require(

            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,

            'SwapXV1Router: INSUFFICIENT_OUTPUT_AMOUNT'

        );

    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(

        uint amountIn,

        uint amountOutMin,

        address[] calldata path,

        address to,

        uint deadline

    )

        external

        virtual

        override

        ensure(deadline)

    {

        require(path[path.length - 1] == WETH, 'SwapXV1Router: INVALID_PATH');

        TransferHelper.safeTransferFrom(

            path[0], msg.sender, SwapXV1Library.pairFor(factory, path[0], path[1]), amountIn

        );

        _swapSupportingFeeOnTransferTokens(path, address(this));

        uint amountOut = IERC20(WETH).balanceOf(address(this));

        require(amountOut >= amountOutMin, 'SwapXV1Router: INSUFFICIENT_OUTPUT_AMOUNT');

        IWETH(WETH).withdraw(amountOut);

        TransferHelper.safeTransferETH(to, amountOut);

    }



    // **** LIBRARY FUNCTIONS ****

    function quote(uint amountA, uint reserveA, uint reserveB) public pure virtual override returns (uint amountB) {

        return SwapXV1Library.quote(amountA, reserveA, reserveB);

    }



    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)

        public

        pure

        virtual

        override

        returns (uint amountOut)

    {

        return SwapXV1Library.getAmountOut(amountIn, reserveIn, reserveOut);

    }



    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)

        public

        pure

        virtual

        override

        returns (uint amountIn)

    {

        return SwapXV1Library.getAmountIn(amountOut, reserveIn, reserveOut);

    }



    function getAmountsOut(uint amountIn, address[] memory path)

        public

        view

        virtual

        override

        returns (uint[] memory amounts)

    {

        return SwapXV1Library.getAmountsOut(factory, amountIn, path);

    }



    function getAmountsIn(uint amountOut, address[] memory path)

        public

        view

        virtual

        override

        returns (uint[] memory amounts)

    {

        return SwapXV1Library.getAmountsIn(factory, amountOut, path);

    }

}