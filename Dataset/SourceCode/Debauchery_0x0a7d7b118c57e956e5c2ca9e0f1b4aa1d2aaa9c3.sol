// https://debauchery.io
// https://x.com/EthExcess
// https://t.me/DebaucheryExcess
//
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/FixedPoint96.sol';
import '@uniswap/v3-core/contracts/libraries/FullMath.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import './interfaces/IERC20Metadata.sol';

contract Debauchery is ERC20, Ownable {
  uint8 constant PLAYERS_PER_GAME = 10;
  uint8 constant PERCENTAGE_WIN = 90; // 90%
  address constant V3MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
  address constant V3FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
  address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
  address _creator;
  uint256 _activity;

  bool public gameEnabled = true;
  uint256 public gameCostUSDX96 = 100 * FixedPoint96.Q96; // $100
  uint256 public currentGame;
  // game number => selected wallets (1-PLAYERS_PER_GAME) => player
  mapping(uint256 => mapping(address => address)) public gamePlayers;
  // game number => token cost per game, set when first player selects a game wallet for consistency
  mapping(uint256 => uint256) public gameCostTokens;
  // game number => winning wallet (1-PLAYERS_PER_GAME)
  mapping(uint256 => address) public gameResults;
  uint256 _currentGamePlayers;
  uint256[] _pendingGameOutcomes;

  event ProcessWinner(
    uint256 indexed _game,
    address indexed _winningSelection,
    address _winner,
    uint256 _amountWon
  );
  event GameWalletSelected(
    uint256 indexed _game,
    address indexed gameWallet,
    address indexed userWallet,
    uint256 _cost
  );

  constructor() ERC20('Debauchery', 'EXCESS') {
    _creator = _msgSender();
    _activity = block.timestamp;
    _mint(_creator, 10_000_000_000 * 10 ** 18);
  }

  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    _activity = block.timestamp;

    if (gameEnabled) {
      if (_isGameWallet(to)) {
        if (_currentGamePlayers == 0) {
          currentGame++;
          _currentGamePlayers++;
          gamePlayers[currentGame][to] = from;
          gameCostTokens[currentGame] = _getGameCostTokens();
          to = address(0);
          amount = gameCostTokens[currentGame];
          emit GameWalletSelected(currentGame, to, from, amount);
        } else if (gamePlayers[currentGame][to] == address(0)) {
          _currentGamePlayers++;
          gamePlayers[currentGame][to] = from;
          to = address(0);
          amount = gameCostTokens[currentGame];
          emit GameWalletSelected(currentGame, to, from, amount);
          if (_currentGamePlayers == PLAYERS_PER_GAME) {
            _pendingGameOutcomes.push(currentGame);
            _currentGamePlayers = 0;
          }
        } else {
          // already an entry, noop transfer
          amount = 0;
        }
      } else if (
        _pendingGameOutcomes.length > 0 && _isProcessableTxn(from, to, amount)
      ) {
        _processGameResult();
      }
    }

    if (to == address(0)) {
      _burn(from, amount);
    } else {
      super._transfer(from, to, amount);
    }
  }

  function _processGameResult() internal {
    uint256 _game = _pendingGameOutcomes[0];
    _pendingGameOutcomes[0] = _pendingGameOutcomes[
      _pendingGameOutcomes.length - 1
    ];
    _pendingGameOutcomes.pop();
    uint256 _resultRaw = uint256(
      keccak256(
        abi.encodePacked(
          block.difficulty,
          block.timestamp,
          _game,
          gameCostTokens[_game],
          _tokenPriceUSDX96(),
          balanceOf(address(_getMainV3Pool())),
          IERC20(USDC).balanceOf(address(_getWETHUSDCV3Pool()))
        )
      )
    );
    uint256 _resultFinal = (_resultRaw % PLAYERS_PER_GAME) + 1;
    address _winner = gamePlayers[_game][address(_resultFinal)];
    uint256 _winAmount = (gameCostTokens[_game] *
      PLAYERS_PER_GAME *
      PERCENTAGE_WIN) / 100;
    gameResults[_game] = address(_resultFinal);
    _mint(_winner, _winAmount);
    emit ProcessWinner(_game, address(_resultFinal), _winner, _winAmount);
  }

  // allows game processing if it's a buy/sell transaction against the main pool
  // of greater than or equal to 2x an entry for a game
  function _isProcessableTxn(
    address _sender,
    address _recipient,
    uint256 _amount
  ) internal view returns (bool) {
    IUniswapV3Pool _mainTokenPool = _getMainV3Pool();
    if (
      _sender == address(_mainTokenPool) ||
      _recipient == address(_mainTokenPool)
    ) {
      return
        (_tokenPriceUSDX96() * _amount) / 10 ** decimals() >=
        2 * gameCostUSDX96;
    }
    return false;
  }

  function _getMainV3Pool() internal view returns (IUniswapV3Pool) {
    return _getV3Pool(address(this), WETH, 10000);
  }

  function _getWETHUSDCV3Pool() internal pure returns (IUniswapV3Pool) {
    return _getV3Pool(WETH, USDC, 500);
  }

  function _isGameWallet(address _wallet) internal pure returns (bool) {
    return _wallet > address(0) && _wallet <= address(PLAYERS_PER_GAME);
  }

  function _getGameCostTokens() internal view returns (uint256) {
    return (gameCostUSDX96 * 10 ** decimals()) / _tokenPriceUSDX96();
  }

  function _tokenPriceUSDX96() internal view returns (uint256) {
    IUniswapV3Pool _wethUSDCPool = _getWETHUSDCV3Pool();
    IUniswapV3Pool _tokenPool = _getMainV3Pool();
    uint256 _usdcWETHPriceX96 = _poolRatioPriceX96(_wethUSDCPool, USDC);
    uint256 _wethTokenPriceX96 = _poolRatioPriceX96(_tokenPool, WETH);
    return (_usdcWETHPriceX96 * _wethTokenPriceX96) / FixedPoint96.Q96;
  }

  function _getV3Pool(
    address _token0,
    address _token1,
    uint24 _fee
  ) internal pure returns (IUniswapV3Pool) {
    (address _t0, address _t1) = _tokensOrdered(_token0, _token1);
    PoolAddress.PoolKey memory _key = PoolAddress.PoolKey({
      token0: _t0,
      token1: _t1,
      fee: _fee
    });
    address pool = PoolAddress.computeAddress(V3FACTORY, _key);
    return IUniswapV3Pool(pool);
  }

  function _poolSqrtPriceX96(address _pool) internal view returns (uint160) {
    uint32 _twapInterval = 5 minutes;
    IUniswapV3Pool _v3Pool = IUniswapV3Pool(_pool);
    uint32[] memory _secAgo = new uint32[](2);
    _secAgo[0] = _twapInterval;
    _secAgo[1] = 0;
    (int56[] memory _tickCums, ) = _v3Pool.observe(_secAgo);
    return
      TickMath.getSqrtRatioAtTick(
        int24((_tickCums[1] - _tickCums[0]) / _twapInterval)
      );
  }

  function _priceX96FromSqrtPriceX96(
    uint160 _sqrtPriceX96
  ) internal pure returns (uint256) {
    return FullMath.mulDiv(_sqrtPriceX96, _sqrtPriceX96, FixedPoint96.Q96);
  }

  function _tokensOrdered(
    address _token0,
    address _token1
  ) internal pure returns (address, address) {
    return _token0 < _token1 ? (_token0, _token1) : (_token1, _token0);
  }

  function _poolRatioPriceX96(
    IUniswapV3Pool _pool,
    address _numerator
  ) internal view returns (uint256) {
    address _t1 = _pool.token1();
    uint8 _decimals0 = IERC20Metadata(_pool.token0()).decimals();
    uint8 _decimals1 = IERC20Metadata(_t1).decimals();
    uint160 _sqrtPriceX96 = _poolSqrtPriceX96(address(_pool));
    uint256 _priceX96 = _priceX96FromSqrtPriceX96(_sqrtPriceX96);
    uint256 _ratiodPriceX96 = _t1 == _numerator
      ? _priceX96
      : FixedPoint96.Q96 ** 2 / _priceX96;
    return
      _t1 == _numerator
        ? (_ratiodPriceX96 * 10 ** _decimals0) / 10 ** _decimals1
        : (_ratiodPriceX96 * 10 ** _decimals1) / 10 ** _decimals0;
  }

  function getGameCostTokens() external view returns (uint256) {
    return _getGameCostTokens();
  }

  function safeTokenPriceUSDX96() external view returns (uint256) {
    return _tokenPriceUSDX96();
  }

  function collectFees(uint256 _tokenId) external {
    INonfungiblePositionManager(V3MANAGER).collect(
      INonfungiblePositionManager.CollectParams({
        tokenId: _tokenId,
        recipient: _creator,
        amount0Max: type(uint128).max,
        amount1Max: type(uint128).max
      })
    );
  }

  // send to creator ONLY after 60 minutes of no token transfers (inactivity)
  function withdrawLP(uint256 _tokenId) external {
    require(block.timestamp > _activity + 60 minutes);
    INonfungiblePositionManager(V3MANAGER).transferFrom(
      address(this),
      _creator,
      _tokenId
    );
  }

  function setGameCostUSDX96(uint256 _newPriceX96) external onlyOwner {
    require(_newPriceX96 > 0);
    gameCostUSDX96 = _newPriceX96;
  }

  function setGameEnabled(bool _is) external onlyOwner {
    require(gameEnabled != _is);
    gameEnabled = _is;
  }
}