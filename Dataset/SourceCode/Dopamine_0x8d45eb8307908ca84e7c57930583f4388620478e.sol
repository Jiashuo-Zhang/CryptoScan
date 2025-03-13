/** 
DOPAMINE (DOPA) 
Revanchist dynastic epochal levels of fuck you wealth. Bet more.
Twitter:  https://twitter.com/getdopamine
Website:  https://getdopamine.xyz
**/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Dopamine is ERC20, Ownable {
	uint256 public constant maxSupply = 1_000_000_000_000 * 10 ** 18; // 1t
	uint256 public constant operationalSupply = 750_000_000_000 * 10 ** 18; // 750b 
	uint256 public constant mintAmount = 18_000_000 * 10 ** 18; // 18m
	uint256 public constant maxMintCount = 8;
	uint256 public constant batchMintFee = 5; // in percent
	uint256 public constant tradingFee  = 2; // in percent
	uint256 public seed;
	uint256 public tradingEnabledTime;
	uint256 public constant highTaxDuration = 2 minutes; // anti-bot first 2 mins
	uint256 public constant highTaxRate = 20;
	address payable public marketingWallet;
	bool public tradingEnabled;
	bool public mintingEnabled;
	mapping(address => uint256) public mintCounts;
	mapping(address => bool) private blocklist;
	mapping(address => bool) private isExcludedFromFee;

	constructor() ERC20("Dopamine", "DOPA") {
		isExcludedFromFee[msg.sender] = true;
		marketingWallet = payable(msg.sender);
		_mint((address(this)), maxSupply);
		_transfer(address(this), msg.sender, operationalSupply);
	}

	struct Round {
		address owner; // address of the current round owner
		uint256 countdown; // e.g. 300 = 5 minutes 
		uint256 prizePool; // e.g. 100 * 10 ** 18 = 100 DOPA
		uint256 takeoverCost; // e.g. 100 * 10 ** 18 = 100 DOPA
		uint256 takeoverCostIncrease; // e.g. 5 = 5% increase each takeover
		uint256 lastTakeoverTime; // timestamp of the last takeover
		uint256 sidepot; // e.g. 100 * 10 ** 18 = 100 DOPA
		uint256 sidepotSpinCost; // e.g. 10 * 10 ** 18 = 10 DOPA
	}

	Round public currentRound;

	// Events
	event RoundStarted(
		uint256 countdown,
		uint256 prizePool,
		uint256 takeoverCostIncrease
	);
	event Takeover(address indexed user, uint256 amount);
	event Received(address user, uint amount);
	event PrizePoolClaimed(address indexed claimer, uint256 amount);
	event SidepotSpin(address indexed user, uint256 result);
	event SidepotWin(address indexed user, uint256 amount);

	// Modifiers
	modifier onlyWhenRoundHasEnded() {
		require(
			block.timestamp >= currentRound.lastTakeoverTime + currentRound.countdown,
			"Dopamine: Round not finished"
		);
		_;	
	}

	// Once turned on can never be turned off
	function enableTrading() external onlyOwner {
		tradingEnabled = true;
		tradingEnabledTime = block.timestamp;
	}

	// Once turned on can never be turned off
	function enableMinting() external onlyOwner {
		mintingEnabled = true;
	}

	function setMarketingWallet(address _marketingWallet) external onlyOwner {
		marketingWallet = payable(_marketingWallet);
	}

	function manageBlocklist(address user, bool blockUser) external onlyOwner {
		blocklist[user] = blockUser;
	}

	function manageExcludedFromFee(address user, bool exclude) external onlyOwner {
		isExcludedFromFee[user] = exclude;
	}

	// Game code
	function startNewRound(
		uint256 _countdown,
		uint256 _prizePool,
		uint256 _takeoverCost,
		uint256 _takeoverCostIncrease,
		uint256 _sidepot,
		uint256 _sidepotSpinCost
	) external onlyOwner onlyWhenRoundHasEnded {
		require(
			IERC20(address(this)).transferFrom(msg.sender, address(this), _prizePool + _sidepot),
			"Dopamine: Transfer failed"
		);
		require(_prizePool > 0, "Dopamine: Prize pool must be greater than 0");
		require(_countdown > 0, "Dopamine: Countdown must be greater than 0");
		require(_takeoverCost > 0, "Dopamine: Takeover cost must be greater than 0");
		require(_takeoverCostIncrease > 0 && _takeoverCostIncrease <= 25, "Dopamine: Takeover cost increase must be greater than 0 and less than or equal to 25");
		require(_sidepot > 0, "Dopamine: Sidepot must be greater than 0");
		require(_sidepotSpinCost > 0, "Dopamine: Sidepot spin cost must be greater than 0");

		currentRound = Round(
			address(0),
			_countdown,
			_prizePool,
			_takeoverCost,
			_takeoverCostIncrease,
			block.timestamp,
			_sidepot,
			_sidepotSpinCost
		);
		emit RoundStarted(
			_countdown,
			_prizePool,
			_takeoverCostIncrease
		);
	}

	function claimPrizePool() external onlyWhenRoundHasEnded  {
		require(
			msg.sender == currentRound.owner,
			"Dopamine: Only the winner can claim the prize pool");
		require(
			currentRound.prizePool > 0,
			"Dopamine: Prizepool has already been claimed"
		);
		_transfer(address(this), msg.sender, currentRound.prizePool);
		currentRound.prizePool = 0;
		emit PrizePoolClaimed(msg.sender, currentRound.prizePool);
	}

	function takeover() external {
		require(
			currentRound.takeoverCost > 0,
			"Dopamine: Round has not started"
		);
		require(
			IERC20(address(this)).transferFrom(msg.sender, address(this), currentRound.takeoverCost),
			"Dopamine: Transfer failed"
		);
		require(
			msg.sender != currentRound.owner,
			"Dopamine: You already own this round"
		);

		uint256 addToSidepot = (currentRound.takeoverCost * 40) / 100;
		uint256 burnAmount = (currentRound.takeoverCost * 20) / 100;
		uint256 addToPrizePool = currentRound.takeoverCost - addToSidepot - burnAmount;

		currentRound.owner = msg.sender;
		currentRound.prizePool += addToPrizePool; 
		currentRound.takeoverCost = 
			(currentRound.takeoverCost * (100 + currentRound.takeoverCostIncrease)) / 100;
		currentRound.lastTakeoverTime = block.timestamp;
		currentRound.sidepot += addToSidepot;

		_burn(address(this), burnAmount);	
		emit Takeover(msg.sender, currentRound.takeoverCost);
	}

	function sidepotSpin() external returns (bool) {
		require(
			currentRound.sidepot > 0,
			"Dopamine: Sidepot is empty"
		);
		require(
			IERC20(address(this)).transferFrom(msg.sender, address(this), currentRound.sidepotSpinCost),
			"Dopamine: Transfer failed"
		);
		currentRound.sidepot += currentRound.sidepotSpinCost;
		uint256 roll = sidepotCheck(100, msg.sender);
		if (roll == 42) {
			_transfer(address(this), msg.sender, currentRound.sidepot);
			currentRound.sidepot = 0;
			emit SidepotWin(msg.sender, currentRound.sidepot);
			return true;
		}
		emit SidepotSpin(msg.sender, roll);
		return false;
	}	
	
	function sidepotCheck(uint max, address _a) private returns (uint) {
		seed++;
		return uint(keccak256(abi.encodePacked(blockhash(block.number - 1), _a, seed))) % max;
	}

	function mint() external {
		require(mintingEnabled, "Dopamine: Minting is not enabled");
		require(msg.sender == tx.origin, "Dopamine: Cannot mint from contract");
		require(
			balanceOf(address(this)) - currentRound.prizePool >= mintAmount,
			"Dopamine: Not enough DOPA left to mint"
		);
		require(
			mintCounts[msg.sender] < 8,
			"Dopamine: Max mint count reached"
		);
		mintCounts[msg.sender] += 1;
		_transfer(address(this), msg.sender, mintAmount);
	}

	function batchMint() external {
		require(mintingEnabled, "Dopamine: Minting is not enabled");
		require(msg.sender == tx.origin, "Dopamine: Cannot mint from contract");
		require(
			balanceOf(address(this)) - currentRound.prizePool >= mintAmount * maxMintCount,
			"Dopamine: Not enough DOPA left to mint"
		);
		require(
			mintCounts[msg.sender] < 8,
			"Dopamine: Max mint count reached"
		);
		uint256 totalAmount = mintAmount * (maxMintCount - mintCounts[msg.sender]); // 144m
		uint256 tax = (totalAmount * batchMintFee) / 100; // 7.2m
		uint256 afterTaxAmount = totalAmount - tax; // 136.8m
		mintCounts[msg.sender] = 8;
		_transfer(address(this), msg.sender, afterTaxAmount);
		_transfer(address(this), address(marketingWallet), tax);
	}

	function _transfer(address from, address to, uint256 amount) internal virtual override {
		require(from != address(0), "Dopamine: Transfer from the zero address");
		require(to != address(0), "Dopamine: Transfer to the zero address");
		require(amount > 0, "Dopamine: Transfer amount must be greater than zero");
		if (
			isExcludedFromFee[from] || 
			isExcludedFromFee[to] || 
			tradingEnabled == false || 
			from == address(this) || 
			to == address(this)) {
			super._transfer(from, to, amount);
		} else {
			uint256 tradingFeeRate;
			if (block.timestamp < tradingEnabledTime + highTaxDuration) {
				// protect public from snipers in first few minutes
				tradingFeeRate = highTaxRate;
			} else {
				tradingFeeRate = tradingFee;
			}
			uint256 fee = (amount * tradingFeeRate) / 100;
			uint256 afterFeeAmount = amount - fee;
			super._transfer(from, to, afterFeeAmount);
			super._transfer(from, address(marketingWallet), fee);
		}
	}

	function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
		super._beforeTokenTransfer(from, to, amount);
		if (!tradingEnabled) {
			require(from == owner() || to == owner() || from == address(this) || to == address(this), "Dopamine: Trading is not enabled");
		}
		require(!blocklist[from] && !blocklist[to], "Dopamine: Address is blocklisted");
	}

	function burn(uint256 amount) external {
		_burn(msg.sender, amount);
	}

	fallback() external payable {
		emit Received(msg.sender, msg.value);
	}

	receive() external payable {
		emit Received(msg.sender, msg.value);
	}

	function withdraw() external onlyOwner {
		uint balance = address(this).balance;
		payable(msg.sender).transfer(balance);
	}

}