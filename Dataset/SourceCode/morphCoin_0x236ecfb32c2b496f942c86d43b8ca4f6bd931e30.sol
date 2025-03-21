/**

 *Submitted for verification at Etherscan.io on 2021-01-16

*/



// SPDX-License-Identifier: CC-BY-NC-SA-2.5

//@code0x2



pragma solidity ^0.6.12;



abstract contract Context {

    function _msgSender() internal view virtual returns (address payable) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691

        return msg.data;

    }

}



interface IFeeManager {

    function queryFee(address sender, address receiver, uint256 amount) external returns(address, uint256);

}



interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external;

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external;

    function transferFrom(address sender, address recipient, uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



interface IERC20Standard {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

}



contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () internal {

        address msgSender = _msgSender();

        _owner = msgSender;

        emit OwnershipTransferred(address(0), msgSender);

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");

        _;

    }



    function renounceOwnership() public virtual onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    function transferOwnership(address newOwner) public virtual onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



contract Operator is Context, Ownable {

    address private _operator;

    mapping (address => bool) private privileged;



    event OperatorTransferred(

        address indexed previousOperator,

        address indexed newOperator

    );



    constructor() internal {

        _operator = _msgSender();

        emit OperatorTransferred(address(0), _operator);

    }



    function operator() public view returns (address) {

        return _operator;

    }



    function setPrivileged(address _usr, bool _isPrivileged) public onlyOwner {

        privileged[_usr] = _isPrivileged;

    }



    modifier onlyOperator() {

        require(msg.sender == _operator || privileged[msg.sender] == true, 'operator: caller does not have permission');

        _;

    }



    function isOperator() public view returns (bool) {

        return _msgSender() == _operator;

    }



    function transferOperator(address newOperator_) public onlyOwner {

        _transferOperator(newOperator_);

    }



    function _transferOperator(address newOperator_) internal {

        require(

            newOperator_ != address(0),

            'operator: zero address given for new operator'

        );

        emit OperatorTransferred(address(0), newOperator_);

        _operator = newOperator_;

    }

}



library SafeMath {



    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);

        uint256 c = a - b;



        return c;

    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");



        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");

    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");

    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}



library Babylonian {

    function sqrt(uint256 y) internal pure returns (uint256 z) {

        if (y > 3) {

            z = y;

            uint256 x = y / 2 + 1;

            while (x < z) {

                z = x;

                x = (y / x + x) / 2;

            }

        } else if (y != 0) {

            z = 1;

        }

        // else z = 0

    }

}



library FixedPoint {

    // range: [0, 2**112 - 1]

    // resolution: 1 / 2**112

    struct uq112x112 {

        uint224 _x;

    }



    // range: [0, 2**144 - 1]

    // resolution: 1 / 2**112

    struct uq144x112 {

        uint256 _x;

    }



    uint8 private constant RESOLUTION = 112;

    uint256 private constant Q112 = uint256(1) << RESOLUTION;

    uint256 private constant Q224 = Q112 << RESOLUTION;



    // encode a uint112 as a UQ112x112

    function encode(uint112 x) internal pure returns (uq112x112 memory) {

        return uq112x112(uint224(x) << RESOLUTION);

    }



    // encodes a uint144 as a UQ144x112

    function encode144(uint144 x) internal pure returns (uq144x112 memory) {

        return uq144x112(uint256(x) << RESOLUTION);

    }



    // divide a UQ112x112 by a uint112, returning a UQ112x112

    function div(uq112x112 memory self, uint112 x)

        internal

        pure

        returns (uq112x112 memory)

    {

        require(x != 0, 'FixedPoint: DIV_BY_ZERO');

        return uq112x112(self._x / uint224(x));

    }



    // multiply a UQ112x112 by a uint, returning a UQ144x112

    // reverts on overflow

    function mul(uq112x112 memory self, uint256 y)

        internal

        pure

        returns (uq144x112 memory)

    {

        uint256 z;

        require(

            y == 0 || (z = uint256(self._x) * y) / y == uint256(self._x),

            'FixedPoint: MULTIPLICATION_OVERFLOW'

        );

        return uq144x112(z);

    }



    // returns a UQ112x112 which represents the ratio of the numerator to the denominator

    // equivalent to encode(numerator).div(denominator)

    function fraction(uint112 numerator, uint112 denominator)

        internal

        pure

        returns (uq112x112 memory)

    {

        require(denominator > 0, 'FixedPoint: DIV_BY_ZERO');

        return uq112x112((uint224(numerator) << RESOLUTION) / denominator);

    }



    // decode a UQ112x112 into a uint112 by truncating after the radix point

    function decode(uq112x112 memory self) internal pure returns (uint112) {

        return uint112(self._x >> RESOLUTION);

    }



    // decode a UQ144x112 into a uint144 by truncating after the radix point

    function decode144(uq144x112 memory self) internal pure returns (uint144) {

        return uint144(self._x >> RESOLUTION);

    }



    // take the reciprocal of a UQ112x112

    function reciprocal(uq112x112 memory self)

        internal

        pure

        returns (uq112x112 memory)

    {

        require(self._x != 0, 'FixedPoint: ZERO_RECIPROCAL');

        return uq112x112(uint224(Q224 / self._x));

    }



    // square root of a UQ112x112

    function sqrt(uq112x112 memory self)

        internal

        pure

        returns (uq112x112 memory)

    {

        return uq112x112(uint224(Babylonian.sqrt(uint256(self._x)) << 56));

    }

}



interface IUniswapV2Pair {

    event Approval(

        address indexed owner,

        address indexed spender,

        uint256 value

    );

    event Transfer(address indexed from, address indexed to, uint256 value);



    function name() external pure returns (string memory);



    function symbol() external pure returns (string memory);



    function decimals() external pure returns (uint8);



    function totalSupply() external view returns (uint256);



    function balanceOf(address owner) external view returns (uint256);



    function allowance(address owner, address spender)

        external

        view

        returns (uint256);



    function approve(address spender, uint256 value) external returns (bool);



    function transfer(address to, uint256 value) external returns (bool);



    function transferFrom(

        address from,

        address to,

        uint256 value

    ) external returns (bool);



    function DOMAIN_SEPARATOR() external view returns (bytes32);



    function PERMIT_TYPEHASH() external pure returns (bytes32);



    function nonces(address owner) external view returns (uint256);



    function permit(

        address owner,

        address spender,

        uint256 value,

        uint256 deadline,

        uint8 v,

        bytes32 r,

        bytes32 s

    ) external;



    event Mint(address indexed sender, uint256 amount0, uint256 amount1);

    event Burn(

        address indexed sender,

        uint256 amount0,

        uint256 amount1,

        address indexed to

    );

    event Swap(

        address indexed sender,

        uint256 amount0In,

        uint256 amount1In,

        uint256 amount0Out,

        uint256 amount1Out,

        address indexed to

    );

    event Sync(uint112 reserve0, uint112 reserve1);



    function MINIMUM_LIQUIDITY() external pure returns (uint256);



    function factory() external view returns (address);



    function token0() external view returns (address);



    function token1() external view returns (address);



    function getReserves()

        external

        view

        returns (

            uint112 reserve0,

            uint112 reserve1,

            uint32 blockTimestampLast

        );



    function price0CumulativeLast() external view returns (uint256);



    function price1CumulativeLast() external view returns (uint256);



    function kLast() external view returns (uint256);



    function mint(address to) external returns (uint256 liquidity);



    function burn(address to)

        external

        returns (uint256 amount0, uint256 amount1);



    function swap(

        uint256 amount0Out,

        uint256 amount1Out,

        address to,

        bytes calldata data

    ) external;



    function skim(address to) external;



    function sync() external;



    function initialize(address, address) external;

}



library UniswapV2Library {

    using SafeMath for uint256;



    // returns sorted token addresses, used to handle return values from pairs sorted in this order

    function sortTokens(address tokenA, address tokenB)

        internal

        pure

        returns (address token0, address token1)

    {

        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');

        (token0, token1) = tokenA < tokenB

            ? (tokenA, tokenB)

            : (tokenB, tokenA);

        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');

    }



    // calculates the CREATE2 address for a pair without making any external calls

    function pairFor(

        address factory,

        address tokenA,

        address tokenB

    ) internal pure returns (address pair) {

        (address token0, address token1) = sortTokens(tokenA, tokenB);

        pair = address(

            uint256(

                keccak256(

                    abi.encodePacked(

                        hex'ff',

                        factory,

                        keccak256(abi.encodePacked(token0, token1)),

                        hex'96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f' // init code hash

                    )

                )

            )

        );

    }



    // fetches and sorts the reserves for a pair

    function getReserves(

        address factory,

        address tokenA,

        address tokenB

    ) internal view returns (uint256 reserveA, uint256 reserveB) {

        (address token0, ) = sortTokens(tokenA, tokenB);

        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(

            pairFor(factory, tokenA, tokenB)

        )

            .getReserves();

        (reserveA, reserveB) = tokenA == token0

            ? (reserve0, reserve1)

            : (reserve1, reserve0);

    }



    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset

    function quote(

        uint256 amountA,

        uint256 reserveA,

        uint256 reserveB

    ) internal pure returns (uint256 amountB) {

        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');

        require(

            reserveA > 0 && reserveB > 0,

            'UniswapV2Library: INSUFFICIENT_LIQUIDITY'

        );

        amountB = amountA.mul(reserveB) / reserveA;

    }



    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset

    function getAmountOut(

        uint256 amountIn,

        uint256 reserveIn,

        uint256 reserveOut

    ) internal pure returns (uint256 amountOut) {

        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');

        require(

            reserveIn > 0 && reserveOut > 0,

            'UniswapV2Library: INSUFFICIENT_LIQUIDITY'

        );

        uint256 amountInWithFee = amountIn.mul(997);

        uint256 numerator = amountInWithFee.mul(reserveOut);

        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);

        amountOut = numerator / denominator;

    }



    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset

    function getAmountIn(

        uint256 amountOut,

        uint256 reserveIn,

        uint256 reserveOut

    ) internal pure returns (uint256 amountIn) {

        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');

        require(

            reserveIn > 0 && reserveOut > 0,

            'UniswapV2Library: INSUFFICIENT_LIQUIDITY'

        );

        uint256 numerator = reserveIn.mul(amountOut).mul(1000);

        uint256 denominator = reserveOut.sub(amountOut).mul(997);

        amountIn = (numerator / denominator).add(1);

    }



    // performs chained getAmountOut calculations on any number of pairs

    function getAmountsOut(

        address factory,

        uint256 amountIn,

        address[] memory path

    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');

        amounts = new uint256[](path.length);

        amounts[0] = amountIn;

        for (uint256 i; i < path.length - 1; i++) {

            (uint256 reserveIn, uint256 reserveOut) = getReserves(

                factory,

                path[i],

                path[i + 1]

            );

            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);

        }

    }



    // performs chained getAmountIn calculations on any number of pairs

    function getAmountsIn(

        address factory,

        uint256 amountOut,

        address[] memory path

    ) internal view returns (uint256[] memory amounts) {

        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');

        amounts = new uint256[](path.length);

        amounts[amounts.length - 1] = amountOut;

        for (uint256 i = path.length - 1; i > 0; i--) {

            (uint256 reserveIn, uint256 reserveOut) = getReserves(

                factory,

                path[i - 1],

                path[i]

            );

            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);

        }

    }

}



library UniswapV2OracleLibrary {

    using FixedPoint for *;



    // helper function that returns the current block timestamp within the range of uint32, i.e. [0, 2**32 - 1]

    function currentBlockTimestamp() internal view returns (uint32) {

        return uint32(block.timestamp % 2**32);

    }



    // produces the cumulative price using counterfactuals to save gas and avoid a call to sync.

    function currentCumulativePrices(address pair)

        internal

        view

        returns (

            uint256 price0Cumulative,

            uint256 price1Cumulative,

            uint32 blockTimestamp

        )

    {

        blockTimestamp = currentBlockTimestamp();

        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();

        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();



        // if time has elapsed since the last update on the pair, mock the accumulated price values

        (

            uint112 reserve0,

            uint112 reserve1,

            uint32 blockTimestampLast

        ) = IUniswapV2Pair(pair).getReserves();

        if (blockTimestampLast != blockTimestamp) {

            // subtraction overflow is desired

            uint32 timeElapsed = blockTimestamp - blockTimestampLast;

            // addition overflow is desired

            // counterfactual

            price0Cumulative +=

                uint256(FixedPoint.fraction(reserve1, reserve0)._x) *

                timeElapsed;

            // counterfactual

            price1Cumulative +=

                uint256(FixedPoint.fraction(reserve0, reserve1)._x) *

                timeElapsed;

        }

    }

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



interface IUniswapRouter is IUniswapV2Router01 {

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



interface IUniswapV2Factory {

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);



    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function migrator() external view returns (address);



    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);



    function createPair(address tokenA, address tokenB) external returns (address pair);



    function setFeeTo(address) external;

    function setFeeToSetter(address) external;

    function setMigrator(address) external;

}



library Address {

    function isContract(address account) internal view returns (bool) {

        // This method relies in extcodesize, which returns 0 for contracts in

        // construction, since the code is only stored at the end of the

        // constructor execution.



        uint256 size;

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

        return size > 0;

    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");



        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value

        (bool success, ) = recipient.call{ value: amount }("");

        require(success, "Address: unable to send value, recipient may have reverted");

    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");

    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);

    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");

    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");

        return _functionCallWithValue(target, data, value, errorMessage);

    }



    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");



        // solhint-disable-next-line avoid-low-level-calls

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);

        if (success) {

            return returndata;

        } else {

            // Look for revert reason and bubble it up if present

            if (returndata.length > 0) {

                // The easiest way to bubble the revert reason is using memory via assembly



                // solhint-disable-next-line no-inline-assembly

                assembly {

                    let returndata_size := mload(returndata)

                    revert(add(32, returndata), returndata_size)

                }

            } else {

                revert(errorMessage);

            }

        }

    }

}



interface IOptimizer {

    function allocateSeigniorage(uint256 amount) external;

    function allocateFee(uint256 amount) external;

}



contract LimitedERC20 is Context, IERC20Standard {

    using SafeMath for uint256;

    using Address for address;

    address public feeManager;



    mapping (address => uint256) private _balances;



    mapping (address => mapping (address => uint256)) private _allowances;



    uint256 private _totalSupply;



    string private _name;

    string private _symbol;

    uint8 private _decimals;



    uint256 internal burnShare = 75;



    constructor (string memory name, string memory symbol, address _feeManager) public {

        _name = name;

        _symbol = symbol;

        _decimals = 18;

        feeManager = _feeManager;

    }



    function name() public view returns (string memory) {

        return _name;

    }



    function symbol() public view returns (string memory) {

        return _symbol;

    }



    function decimals() public view returns (uint8) {

        return _decimals;

    }



    function totalSupply() public view override returns (uint256) {

        return _totalSupply;

    }



    function balanceOf(address account) public view override returns (uint256) {

        return _balances[account];

    }



    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);

        return true;

    }



    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];

    }



    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);

        return true;

    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));

        return true;

    }



    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));

        return true;

    }



    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));

        return true;

    }



    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");



        (address feeReceiver, uint256 feeAmount) = IFeeManager(feeManager).queryFee(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, 'ERC20: transfer amount exceeds balance');



        if(feeAmount > 0) {

            uint256 burnAmount = feeAmount.mul(burnShare).div(100);

            _balances[feeReceiver] = _balances[feeReceiver].add(feeAmount.sub(burnAmount));

            IOptimizer(feeReceiver).allocateFee(feeAmount.sub(burnAmount));

            emit Transfer(sender, feeReceiver, feeAmount.sub(burnAmount));

            _burn(sender, burnAmount);

        }



        amount = amount.sub(feeAmount);

        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);

    }



    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");



        _totalSupply = _totalSupply.add(amount);

        _balances[account] = _balances[account].add(amount);

        emit Transfer(address(0), account, amount);

    }



    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");



        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");

        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, address(0), amount);

    }



    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");

        require(spender != address(0), "ERC20: approve to the zero address");



        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);

    }



    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;

    }



    function _setFeeManager(address _fmg) internal {

        feeManager = _fmg;

    }



    function _setBurnShare(uint256 _toBurn) internal {

        burnShare = _toBurn;

    }

}



abstract contract ERC20Burnable is Context, LimitedERC20 {

    /**

     * @dev Destroys `amount` tokens from the caller.

     *

     * See {ERC20-_burn}.

     */

    function burn(uint256 amount) public virtual {

        _burn(_msgSender(), amount);

    }



    /**

     * @dev Destroys `amount` tokens from `account`, deducting from the caller's

     * allowance.

     *

     * See {ERC20-_burn} and {ERC20-allowance}.

     *

     * Requirements:

     *

     * - the caller must have allowance for ``accounts``'s tokens of at least

     * `amount`.

     */

    function burnFrom(address account, uint256 amount) public virtual {

        _burn(account, amount);

    }

}



contract morphCoin is ERC20Burnable, Operator {



    constructor(address _feeManager) public LimitedERC20('Morph Coin', 'MORC', _feeManager) {

    }



    function mint(address recipient_, uint256 amount_)

        public

        onlyOperator

        returns (bool)

    {

        uint256 balanceBefore = balanceOf(recipient_);

        _mint(recipient_, amount_);

        uint256 balanceAfter = balanceOf(recipient_);



        return balanceAfter > balanceBefore;

    }



    function burn(uint256 amount) public override onlyOperator {

        super.burn(amount);

    }



    function burnFrom(address account, uint256 amount)

        public

        override

        onlyOperator

    {

        super.burnFrom(account, amount);

    }



    function setFeeManager(address _feeManager) public onlyOwner {

        _setFeeManager(_feeManager);

    }



    function setBurnShare(uint256 _toBurn) public onlyOwner {

        _setBurnShare(_toBurn);

    }



    // Fallback rescue



    receive() external payable{

        payable(owner()).transfer(msg.value);

    }



    function rescueToken(IERC20 _token) public {

        _token.transfer(owner(), _token.balanceOf(address(this)));

    }

}