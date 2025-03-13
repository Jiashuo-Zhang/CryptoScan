// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./WhaleToken.sol";
import "./RewardsVesting.sol";

// errors
    
    // emitted when the deposit is not the right amount
    error IncorrectDepositAmount();

    // emitted when the deposit timelock has not passed
    error DepositTimelockNotPassed();

    // emitted when the user deposits twice in the same block
    error DepositCooldown();

    // emitted when the user is already the claimer
    error AlreadyClaimer();

    // emitted when the claimer is not the sender
    error NotClaimer();

    // emitted when the claim time has not passed
    error ClaimTimeNotPassed();
    
 
contract WhaleGame {

// events

    // emitted when a user deposits
    event Deposited(address indexed user, uint256 indexed amount);

    // emitted when a user claims
    event Claim(uint256 indexed round, uint256 indexed amount, address indexed user, address vestingContract);

// deps

    // the $WHALE token
    WhaleToken public whaleToken;

// constants

    // initial deposit cost (in wei) for each round
    uint256 public constant INITIAL_DEPOSIT_COST = 5e16 wei;

    // fee charged for each deposit that goes to back the token (in percents)
    uint256 public constant FEE_RATE = 50;

    // incremental rate of growth for deposits (in tenths of percents)
    uint256 public constant GROWTH_RATE = 33; // 3.3%

    // the minimum amount of time elapsed between each deposit
    uint256 public constant BUFFER_PERIOD = 15 seconds;

    // the amount of time a user has to wait in between deposits
    uint256 public constant DEPOSIT_TIMELOCK = 12 hours;

    // the amount of time a user has to wait in before claiming
    uint256 public constant CLAIM_TIMELOCK = 1 days;

    // the decay factor on the token emissions between rounds (in percents)
    uint256 public constant DECAY_FACTOR = 85;

    // the lowest multiplier for WHALE token rewards — initial rewards are 10x this amount
    uint256 public constant MIN_TOKEN_MULTIPLIER = 1e17;

    // base number of tokens minted before mutliplier is applied
    uint256 public constant BASE_TOKENS_MINTED = 100_000;

// states

    // the current token reward multiplier
    uint256 public tokenMultiplier = 1e18; // this value decays per round until 1e17

    // the current game round
    uint256 public round;

    // the eligible claimer
    address public claimer;

    // the current deposit cost
    uint256 public depositCost;

    // the current claim time
    uint256 public claimTime;

    // the timestamp of the most recent deposit, used to create a time buffers between deposits
    uint256 public lastDepositTimestamp;

    // an arbitrary message broadcasted by the most recent depositor
    string public graffiti;

// mappings

    // deposit timelock for users
    mapping(address => uint256) public userDepositTimelock;

    // rewards vesting contract for each round
    mapping(uint256 => RewardsVesting) public vestingContractForRound;




// functions

    constructor () {
        // deploy the whale token
        whaleToken = new WhaleToken();

        // initialize the game state
        _resetGame();
    }

    function deposit(string memory graffiti_) external payable {

    // input validations
        
        // 1. check that the deposit is the right amount
        if (msg.value != depositCost) revert IncorrectDepositAmount();

        // 2. check that the current time is not before the next deposit timestamp of the msg.sender
        if (userDepositTimelock[msg.sender] != 0 && block.timestamp < userDepositTimelock[msg.sender]) revert DepositTimelockNotPassed();

        // 3. check that the current block is not the same as the previous deposit block with a 15 second time buffer
        if (block.timestamp < lastDepositTimestamp + BUFFER_PERIOD) revert DepositCooldown();

        // 4. check that the msg.sender is not already the first claimer
        if (msg.sender == claimer) revert AlreadyClaimer();

    
    // state updates

        // 1. set the next deposit timestamp of the msg.sender to 12 hours from now
        userDepositTimelock[msg.sender] = block.timestamp + DEPOSIT_TIMELOCK;

        // 2. set the last deposit timestamp to the current time
        lastDepositTimestamp = block.timestamp;

        // 3. set the claimer to the message sender
        claimer = payable(msg.sender);

        // 4. set the claim time to 1 day from now
        claimTime = block.timestamp + CLAIM_TIMELOCK;

        // 5. calculate the fee to send to the token contract
        uint256 fee = depositCost * FEE_RATE / 100;

        // 6. then increment the deposit cost by growth rate (3.3%)
        depositCost = depositCost * (1000 + GROWTH_RATE) / 1000;

        // 7. set the new message to display on the bulletin
        graffiti = graffiti_;


    // external interactions       

        // mint the multiplier adjusted token reward for this round to the depositor
        whaleToken.mint(msg.sender, BASE_TOKENS_MINTED * tokenMultiplier);

        // send fee to the token contract
        SafeTransferLib.safeTransferETH(address(whaleToken), fee);

        // emit the deposit event
        emit Deposited(msg.sender, msg.value);
    }


    function claim() external {
    
    // input validations

        // check that the claimer is the sender
        if (msg.sender != claimer) revert NotClaimer();

        // require that the claim time has passed
        if (block.timestamp < claimTime) revert ClaimTimeNotPassed();

    // state updates

        // decay the token reward multiplier by decay 85%
        tokenMultiplier = (tokenMultiplier * DECAY_FACTOR / 100); 

        // set up the Rewards Vesting contract
        RewardsVesting vestingContract = new RewardsVesting(this, round, payable(msg.sender));
        vestingContractForRound[round] = vestingContract;

        // reset the game
        _resetGame();

    // external interactions

        // send the balance to the Vesting contract 
        SafeTransferLib.safeTransferETH(address(vestingContract), address(this).balance);

        // unlock fee redemptions on the token after round 10
        if (round == 11) {
            whaleToken.unlockRedemptions();
        }

        // emit the claim event ()
        emit Claim(round - 1, address(this).balance, msg.sender, address(vestingContract));
    }   


    function _resetGame() internal {
        // set the claimer to the zero address
        claimer = payable(address(0));

        // set the deposit cost to .1 ether
        depositCost = INITIAL_DEPOSIT_COST;

        // set the new last deposit timestamp to the current time
        lastDepositTimestamp = block.timestamp;

        // set the claim time to the latest possible time
        claimTime = type(uint256).max;

        // wipe the message
        graffiti = "";

        // increment the round
        round++;
    }

}