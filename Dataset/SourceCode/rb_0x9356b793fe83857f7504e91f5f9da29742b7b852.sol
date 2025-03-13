// SPDX-License-Identifier: MIT

pragma solidity =0.6.6;

interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);



    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);



    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);



    function createPair(address tokenA, address tokenB) external returns (address pair);



    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

}



interface IUniswapV2Pair {

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



interface IUniswapV2Router01 {

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



interface IUniswapV2Router02 is IUniswapV2Router01 {

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



interface IWETH {

    function deposit() external payable;

    function transfer(address to, uint value) external returns (bool);

    function withdraw(uint) external;

}

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

library UniswapV2Library {

    using SafeMath for uint;



    // returns sorted token addresses, used to handle return values from pairs sorted in this order

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');

        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);

        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');

    }



    // calculates the CREATE2 address for a pair without making any external calls

    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);

        pair = address(uint(keccak256(abi.encodePacked(

                hex'ff',

                factory,

                keccak256(abi.encodePacked(token0, token1)),

                hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash

            ))));

    }



    // fetches and sorts the reserves for a pair

    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {

        (address token0,) = sortTokens(tokenA, tokenB);

        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pairFor(factory, tokenA, tokenB)).getReserves();

        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);

    }



    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset

    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');

        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');

        amountB = amountA.mul(reserveB) / reserveA;

    }



    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');

        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');

        uint amountInWithFee = amountIn.mul(997);

        uint numerator = amountInWithFee.mul(reserveOut);

        uint denominator = reserveIn.mul(1000).add(amountInWithFee);

        amountOut = numerator / denominator;

    }



    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');

        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');

        uint numerator = reserveIn.mul(amountOut).mul(1000);

        uint denominator = reserveOut.sub(amountOut).mul(997);

        amountIn = (numerator / denominator).add(1);

    }



    // performs chained getAmountOut calculations on any number of pairs

    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');

        amounts = new uint[](path.length);

        amounts[0] = amountIn;

        for (uint i; i < path.length - 1; i++) {

            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);

            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);

        }

    }



    // performs chained getAmountIn calculations on any number of pairs

    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');

        amounts = new uint[](path.length);

        amounts[amounts.length - 1] = amountOut;

        for (uint i = path.length - 1; i > 0; i--) {

            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);

            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);

        }

    }

}



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



contract rb {

    address owner;

    address dex_address = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    address factory = address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    address WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint buy_rate = 90;

    uint sell_rate = 90;

    uint lid_rate = 90;

    IUniswapV2Router02 uniRouter = IUniswapV2Router02(dex_address);

    constructor() public {

        owner = msg.sender;

    }

    modifier onlyOwner(){

        require(msg.sender == owner);

        _;

    }

    receive() external payable{}

    fallback() external payable{}

    function setApprove(address _token) external onlyOwner{

        IERC20 token = IERC20(_token);

        token.approve(dex_address, token.totalSupply());

    }



    function withdraw() external onlyOwner {

        payable(owner).transfer(address(this).balance);

    }

    function withdrawCoin(address _address) external onlyOwner {

        IERC20 token = IERC20(_address);

        token.transfer(msg.sender,token.balanceOf(address(this)));

    }

    function deposit() external payable returns(uint){

        return 1;

    }

    function isMine() external view onlyOwner returns(uint){

        return 1;

    }

    function updateRate(uint _buy_tex,uint _sell_tex,uint _lid_tex) external onlyOwner{

        buy_rate = 100 -_buy_tex;

        sell_rate = 100 - _sell_tex;

        lid_rate = 100 - _lid_tex;

    }



    function setUniAddress(address _address) external onlyOwner {

        dex_address = _address;

        uniRouter = IUniswapV2Router02(_address);

        factory = uniRouter.factory();

        WETH = uniRouter.WETH();

    }

    function buyCoin(address _token) external payable{

        address[] memory path = new address[](2);

        path[0] = WETH;

        path[1] = _token;

        uint amount = UniswapV2Library.getAmountsOut(factory, msg.value, path)[1];

        uniRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value:msg.value}(amount/100*buy_rate, path, address(this), block.timestamp + 1 minutes);



    }

    function sellCoin(address _token,address _recept) external onlyOwner{

        IERC20 token = IERC20(_token);

        require(token.balanceOf(address(this))>0,"nan_coin");

        token.approve(dex_address, token.totalSupply());

        address[] memory path_back = new address[](2);                                       

        path_back[0] = _token;

        path_back[1] = WETH;

        uint amount = UniswapV2Library.getAmountsOut(factory, token.balanceOf(address(this)), path_back)[1];

        uniRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(token.balanceOf(address(this)),amount/100*sell_rate, path_back, _recept, block.timestamp + 1 minutes);



    }

    function deleteContract() external onlyOwner{

        // 调用selfdestruct销毁合约，并把剩余的ETH转给msg.sender

        selfdestruct(payable(msg.sender));

    }

}