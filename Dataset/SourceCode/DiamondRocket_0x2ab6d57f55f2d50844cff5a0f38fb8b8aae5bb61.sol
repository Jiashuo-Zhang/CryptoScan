// SPDX-License-Identifier: MIT
/*                                                                       ! 
                                                                         ! 
                                                                         ^
              ____  _                                 __                / \
             / __ \(_)___ _____ ___  ____  ____  ____/ /               /___\ 
            / / / / / __ `/ __ `__ \/ __ \/ __ \/ __  /               |=   =|
           / /_/ / / /_/ / / / / / / /_/ / / / / /_/ /                |     |
          /_____/_/\__,_/_/ /_/ /_/\____/_/ /_/\__,_/                 |     |                                                 
                                                                      |     |
                                                                      |     |
                 ____             __        __                        |     |
                / __ \____  _____/ /_____  / /_                       |     |
               / /_/ / __ \/ ___/ //_/ _ \/ __/                       |##!##| 
              / _, _/ /_/ / /__/ ,< /  __/ /_                        /|##!##|\       
             /_/ |_|\____/\___/_/|_|\___/\__/                      /  |##!##|  \       
                                                                  |  / ^ | ^ \  |       
                                                                  | /  ( | )  \ |
                                                                  |/   ( | )   \|
                                                                      ((   ))         
                                                                     ((  :  ))                                                
                                                                     ((  :  ))                
                                                                     ((  :  ))      
                                                                      ((   ))                                               
Website: https://diamondrocketeth.com/                                 (( ))
                                                                        ( )
Telegram: https://t.me/diamondrocketeth                                  .
                                                                   .     '     ,
Twitter: https://twitter.com/DiamondRock3t                           _________
                                                                  _ /_|_____|_\ _
                                                                    '. \   / .'
                                                                      '.\ /.'
                                                                        '.'                   */                                                                                                                                                                                   
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "interfaces/IUniswapV2Router02.sol";
import "interfaces/IUniswapV2Pair.sol";
import "interfaces/IUniswapV2Factory.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DiamondRocket is IERC20, Ownable {
    string public name = "Diamond Rocket";
    string public symbol = "DIAMOND";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    uint256 public maxTax;
    uint256 public baseTax;

    uint256 maxWallet;
    bool public tradingEnabled = false;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) isExcludedFromTax;
    mapping(address => uint256) lastTimeReceived;

    address[] holders;
    address payable[] public latestWinners;
    uint256 public totalJackpotValue;

    address payable public jackpotFeeWallet = payable(0x5a0D3cb7ac52A17b36E26E369aFF095a1E54350b);
    address payable public buyBackFeeWallet = payable(0xA433b923040Da5DE7a43B10d3849CFee2922fF6B);

    IUniswapV2Pair public uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address payable treasury = payable(address(this));

    constructor() {
        totalSupply = 100_000_000e18;
        _balances[msg.sender] = totalSupply;

        maxWallet = totalSupply * 3 / 100;

        uniswapV2Pair = IUniswapV2Pair(
            IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH())
        );

        maxTax = 2400;
        baseTax = 1200;

        isExcludedFromTax[msg.sender] = true;
        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[address(uniswapV2Pair)] = true;
        isExcludedFromTax[address(uniswapV2Router)] = true;
    }

    function openTrading() public onlyOwner {
        tradingEnabled = true;
    }

    bool inSwap = false;

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    receive() external payable {}

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uint256 forBuyBack = tokenAmount / 3;
        uint256 forJackpot = tokenAmount - forBuyBack;
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            forBuyBack, 0, path, buyBackFeeWallet, block.timestamp
        );
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            forJackpot, 0, path, treasury, block.timestamp
        );
    }

    function burnFrom(address account, uint256 amount) private {
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _spendAllowance(sender, _msgSender(), amount);
        _transfer(sender, recipient, amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(tradingEnabled || (isExcludedFromTax[sender] && isExcludedFromTax[recipient]), "Can't trade yet");

        if (sender == address(uniswapV2Pair) && !isExcludedFromTax[recipient]) {
            require(amount + _balances[recipient] <= maxWallet, "Transfer amount exceeds the maxWallet");
        }
        if (recipient == address(uniswapV2Pair) && !isExcludedFromTax[sender]) {
            uint256 tax = (amount * viewTax(sender)) / 10000;
            uint256 toBurn;
            uint256 toEth;
            amount -= tax;

            if (viewTax(sender) > baseTax) {
                toBurn = (amount * (viewTax(sender) - baseTax)) / 10000;
                toEth = tax - toBurn;
            } else {
                toBurn = 0;
                toEth = tax;
            }
            _balances[address(this)] += toEth;
            _balances[address(0x000000000000000000000000000000000000dEaD)] += toBurn;
            _balances[sender] -= tax;
        }

        uint256 contractTokenBalance = _balances[address(this)];
        bool canSwap = contractTokenBalance > 0;
        if (canSwap && !inSwap && sender != address(uniswapV2Pair) && !isExcludedFromTax[sender]) {

            swapTokensForEth(contractTokenBalance);
        }

        if (isAlreadyHolder[recipient] == false && !isExcludedFromTax[recipient]) {
            holders.push(recipient);
            isAlreadyHolder[recipient] = true;
        }

        lastTimeReceived[recipient] = block.timestamp;

        _balances[sender] -= amount;
        _balances[recipient] += amount;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function viewTax(address _user) public view returns (uint256) {
        if (lastTimeReceived[_user] + 86400 > block.timestamp) {
            return calculateTax(_user);
        } else {
            return baseTax;
        }
    }

    function calculateTax(address _user) public view returns (uint256) {
        if (maxTax == 0) {
            return baseTax;
        } else {
            uint256 secondsLeft = (lastTimeReceived[_user] + 86400) - block.timestamp;
            //additional time to create transition between additional and base tax
            uint256 secs = (baseTax * 1e36 / ((maxTax * 1e18) / 86400)) / 1e18;
            uint256 tax = ((maxTax) * 1e18) / (86400 + secs) * (secondsLeft + secs);
            return tax / 1e18;
        }
    }

    function viewHolders() public view returns (address[] memory) {
        return holders;
    }

    function viewLatestWinners() public view returns (address payable[] memory) {
        return latestWinners;
    }

    mapping(address => bool) public isAlreadyHolder;

    function LuckyDraw(uint256 numberOfWinners, uint256 perGiveaway) external onlyOwner {
        require(holders.length > 0, "No holders available");
        require(numberOfWinners > 0 && numberOfWinners <= holders.length, "Invalid number of winners");

        uint256[] memory probabilities = new uint256[](holders.length);
        uint256 totalProbability = 0;

        // Calculate the probability for each eligible holder based on their token holdings
        for (uint256 i = 0; i < holders.length; i++) {
            address holder = holders[i];
            if (!isExcludedFromTax[holder]) {
                probabilities[i] = _balances[holder];
                totalProbability = totalProbability + probabilities[i];
            }
        }
        address payable[] memory winners = new address payable[](numberOfWinners);
        uint256 balance = address(this).balance * perGiveaway / 100;
        uint256 remainingBalance = balance;
        uint256 seed = balance * totalProbability; //Seed is random since the total balance of non excluded wallets and the final total eth value before transaction are random enough
        totalJackpotValue = totalJackpotValue + balance;

        for (uint256 i = 0; i < numberOfWinners; i++) {
            uint256 winningNumber =
                uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, seed, i))) % totalProbability;
            uint256 cumulativeProbability = 0;

            for (uint256 j = 0; j < holders.length; j++) {
                address holder = holders[j];

                if (!isExcludedFromTax[holder]) {
                    cumulativeProbability += probabilities[j];

                    if (winningNumber < cumulativeProbability) {
                        winners[i] = payable(holder);
                        uint256 share = remainingBalance / 2;
                        (bool success,) = winners[i].call{value: share, gas: 100000}("Winners get their jackpots");
                        if (!success) {
                            (bool succes,) = payable(jackpotFeeWallet).call{value: share, gas: 100000}(
                                "This is just a protection. If you see you wallet in the Winning list but did not receive it. Check if it is send to jackpotFeeWallet. Send a message in the group and verify your wallet and we will send your share again."
                            );
                        }
                        remainingBalance -= share;
                        break;
                    }
                }
            }
        }
        (bool success,) = winners[0].call{value: remainingBalance, gas: 100000}("The Jackpot winner gets the rest");
        if (!success) {
            (bool succes,) = payable(jackpotFeeWallet).call{value: remainingBalance, gas: 100000}(
                "This is just a protection. If you see you wallet in the Winning list but did not receive it. Check if it is send to jackpotFeeWallet. Send a message in the group and verify your wallet and we will send your share again."
            );
        }

        latestWinners = winners;
    }
}