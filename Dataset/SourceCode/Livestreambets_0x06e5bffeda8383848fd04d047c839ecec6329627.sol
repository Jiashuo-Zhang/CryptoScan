// SPDX-License-Identifier: MIT

/*
  [Website]         https://www.livestreambets.gg
  [Twitter/X]       https://twitter.com/livestreambets
  [Telegram]        https://t.me/livestreambetsgg
*/

pragma solidity ^0.8.19;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Livestreambets is Ownable, Pausable, ReentrancyGuard {
    enum GameStatus {
        EntriesClosed,
        EntriesOpen,
        Expired, // Terminal state
        WinnerDeclared, // Terminal state
        Cancelled // Terminal state
    }

    struct Position {
        uint256 amount;
        bool hasWithdrawn;
    }

    struct Game {
        uint256 expiresAt;
        uint256 options;
        uint256 minPositionSize; // individual position minimum size
        uint256 maxAmountPerOption; // maximum total amount that can be bet on a single option across all account positions
        uint256 winner;
        bool entriesOpen;
        bool winnerDeclared;
        bool cancelled;
        bool rakeRecorded;
    }

    // Game management
    uint256 public defaultExpirationPeriod;
    uint256 public maxOptions;
    uint256 public defaultMinPositionSize;
    uint256 public defaultMaxAmountPerOption;
    address public gameManager;
    Game[] public games;

    // Rake management
    uint256 public earnedRakeAmount;
    uint256 public claimedRakeAmount;
    address payable public rakeRecipient;

    // SEE: positionKeyHash
    mapping(bytes32 => Position) public positions;

    // SEE: gameOptionKeyHash
    mapping(bytes32 => uint256) public totalOfAllPositionsForGameOption;

    error NotAllowed();
    error InvalidGameStatus();
    error PositionSizeTooSmall();
    error MaxAmountForOptionExceeded();
    error WithdrawalFailed();

    error InvalidGameConfiguration();
    error InvalidGame();
    error InvalidGameOption();

    error EmptyPosition();
    error InvalidAmount();
    error GameNotFinished();

    event WinnerDeclared(uint256 gameId, uint256 winningOptionId);
    event AddedToPosition(
        uint256 gameId,
        uint256 optionId,
        address account,
        uint256 originalPositionSize,
        uint256 amountAddedToPosition
    );
    event GameCreated(uint256 indexed gameId);
    event UserWithdrawal(
        uint256 gameId,
        uint256 optionId,
        address account,
        uint256 amount
    );
    event BulkUserWithdrawal(uint256 gameId, address account, uint256 amount);
    event RakeWithdrawn(uint256 amount);
    event StatusChange(
        uint256 gameId,
        GameStatus oldStatus,
        GameStatus newStatus
    );
    event OwnerDeposit(uint256 amount);
    event OwnerWithdrawal(uint256 amount);

    modifier checkGameId(uint256 gameId_) {
        if (gameId_ >= games.length) {
            revert InvalidGame();
        }
        _;
    }

    modifier onlyOwnerOrGameManager() {
        require(
            msg.sender == owner() || msg.sender == gameManager,
            "Caller is neither the owner nor game manager"
        );
        _;
    }

    constructor(address payable rakeRecipient_, address gameManager_) {
        setDefaultExpirationPeriod(3 days);
        setMaxOptions(10);
        setDefaultMinPositionSize(0.1 ether);
        setDefaultMaxAmountPerOption(1 ether);
        setRakeRecipient(rakeRecipient_);
        setGameManager(gameManager_);
    }

    function positionKeyHash(
        uint256 gameId_,
        address account_,
        uint256 optionId_
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(gameId_, account_, optionId_));
    }

    function gameOptionKeyHash(
        uint256 gameId_,
        uint256 optionId_
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(gameId_, optionId_));
    }

    function gameCount() public view returns (uint256) {
        return games.length;
    }

    function gameStatus(
        uint256 gameId_
    ) public view checkGameId(gameId_) returns (GameStatus) {
        Game storage game = games[gameId_];
        return _gameStatus(game);
    }

    // Check terminal states first, then check non-terminal states.
    function _gameStatus(Game storage game) internal view returns (GameStatus) {
        // Terminal state (manual).
        if (game.winnerDeclared) {
            return GameStatus.WinnerDeclared;
        }

        // Terminal state (manual).
        if (game.cancelled) {
            return GameStatus.Cancelled;
        }

        // Terminal state (automatic).
        if (block.timestamp > game.expiresAt) {
            return GameStatus.Expired;
        }

        // Non-terminal state (manual).
        if (game.entriesOpen) {
            return GameStatus.EntriesOpen;
        }

        // Non-terminal state (manual).
        return GameStatus.EntriesClosed;
    }

    //////////  Game management functions  //////////

    function createGameWithDefaults(
        uint256 options_
    ) external onlyOwnerOrGameManager {
        createGame(
            defaultExpirationPeriod,
            options_,
            defaultMinPositionSize,
            defaultMaxAmountPerOption
        );
    }

    function createGame(
        uint256 expirationPeriod_,
        uint256 options_,
        uint256 minPositionSize_,
        uint256 maxAmountPerOption_
    ) public onlyOwnerOrGameManager {
        // A race must have at least 2 options and at most maxOptions.
        if (options_ < 2 || options_ > maxOptions) {
            revert InvalidGameConfiguration();
        }

        // Create the game and push it onto the games array.
        games.push(
            Game(
                block.timestamp + expirationPeriod_, // uint256 expiresAt
                options_, // uint256 options
                minPositionSize_, // uint256 minPositionSize;
                maxAmountPerOption_, // uint256 maxAmountPerOption
                0, // uint256 winner
                false, // bool entriesOpen
                false, // bool winnerDeclared
                false, // bool cancelled
                false // bool rakeRecorded
            )
        );

        // Emit event.
        emit GameCreated(games.length - 1);
    }

    function openEntries(
        uint256 gameId_
    ) external onlyOwnerOrGameManager checkGameId(gameId_) {
        Game storage game = games[gameId_];

        // Game must be in EntriesClosed state.
        GameStatus gameStatus__ = _gameStatus(game);
        if (gameStatus__ != GameStatus.EntriesClosed) {
            revert InvalidGameStatus();
        }

        // Open the game for betting.
        game.entriesOpen = true;

        // Emit event.
        emit StatusChange(gameId_, gameStatus__, GameStatus.EntriesOpen);
    }

    function closeEntries(
        uint256 gameId_
    ) external onlyOwnerOrGameManager checkGameId(gameId_) {
        Game storage game = games[gameId_];

        // Game must be in EntriesOpen state.
        GameStatus gameStatus__ = _gameStatus(game);
        if (gameStatus__ != GameStatus.EntriesOpen) {
            revert InvalidGameStatus();
        }

        // Open the game for betting.
        game.entriesOpen = false;

        // Emit event.
        emit StatusChange(gameId_, gameStatus__, GameStatus.EntriesClosed);
    }

    function cancelGame(
        uint256 gameId_
    ) external onlyOwnerOrGameManager checkGameId(gameId_) {
        Game storage game = games[gameId_];
        GameStatus gameStatus__ = _gameStatus(game);

        // Game must be in a cancellable state (either EntriesOpen or EntriesClosed).
        if (
            gameStatus__ != GameStatus.EntriesOpen &&
            gameStatus__ != GameStatus.EntriesClosed
        ) {
            revert InvalidGameStatus();
        }

        // Cancel the game.
        game.cancelled = true;

        // Emit event.
        emit StatusChange(gameId_, gameStatus__, GameStatus.Cancelled);
    }

    function declareWinner(
        uint256 gameId_,
        uint256 winningOptionId_
    ) external onlyOwnerOrGameManager checkGameId(gameId_) {
        Game storage game = games[gameId_];
        GameStatus gameStatus__ = _gameStatus(game);

        // Game must be in EntriesClosed state.
        if (gameStatus__ != GameStatus.EntriesClosed) {
            revert InvalidGameStatus();
        }

        // Check that the winner is within the possible range of options.
        if (winningOptionId_ >= game.options) {
            revert InvalidGameOption();
        }

        // Save the winner.
        game.winnerDeclared = true;
        game.winner = winningOptionId_;

        // Emit events.
        emit WinnerDeclared(gameId_, winningOptionId_);
        emit StatusChange(gameId_, gameStatus__, GameStatus.EntriesOpen);
    }

    function withdrawRake(uint256 amount_) public onlyOwner nonReentrant {
        // Check that the amount is available to claim.
        if (amount_ > claimableRakeAmount()) {
            revert InvalidAmount();
        }

        // Record the amount claimed.
        claimedRakeAmount += amount_;

        // Pay out earnings to account using .call().
        (bool success, ) = rakeRecipient.call{value: amount_}("");

        // Revert if unsuccessful.
        if (!success) {
            revert WithdrawalFailed();
        }

        // Emit event
        emit RakeWithdrawn(amount_);
    }

    function withdrawAllAvailableRake() external onlyOwner {
        withdrawRake(claimableRakeAmount());
    }

    function claimableRakeAmount() public view returns (uint256) {
        return earnedRakeAmount - claimedRakeAmount;
    }

    // Convenience external view function to get the total of all positions for a game.
    function totalsOfAllPositionsForAllGameOptions(
        uint256 gameId_
    ) external view checkGameId(gameId_) returns (uint256[] memory) {
        Game storage game = games[gameId_];
        uint256[] memory totals = new uint256[](game.options);

        for (uint256 i = 0; i < game.options; i++) {
            totals[i] = totalOfAllPositionsForGameOption[
                gameOptionKeyHash(gameId_, i)
            ];
        }

        return totals;
    }

    function totalLockedInGame(
        uint256 gameId_
    ) external view checkGameId(gameId_) returns (uint256) {
        Game storage game = games[gameId_];
        uint256 total = 0;

        for (uint256 i = 0; i < game.options; i++) {
            total += totalOfAllPositionsForGameOption[
                gameOptionKeyHash(gameId_, i)
            ];
        }

        return total;
    }

    // Convenience external view function to get all of a user's positions for a game.
    function positionsForGameForAccount(
        uint256 gameId_,
        address account_
    ) external view checkGameId(gameId_) returns (Position[] memory) {
        Game storage game = games[gameId_];
        Position[] memory positions__ = new Position[](game.options);

        for (uint256 i = 0; i < game.options; i++) {
            positions__[i] = positions[positionKeyHash(gameId_, account_, i)];
        }

        return positions__;
    }

    // Convenience external view function to get a user's total committed to a game.
    function totalCommittedToGameForAccount(
        uint256 gameId_,
        address account_
    ) external view checkGameId(gameId_) returns (uint256) {
        Game storage game = games[gameId_];
        uint256 total = 0;

        for (uint256 i = 0; i < game.options; i++) {
            total += positions[positionKeyHash(gameId_, account_, i)].amount;
        }

        return total;
    }

    // Compute losing positions to allow them to be withdrawn by the owner, and record the amount in earnedRakeAmount.
    function recordRake(
        uint256 gameId_
    ) external onlyOwner checkGameId(gameId_) {
        Game storage game = games[gameId_];
        GameStatus gameStatus__ = _gameStatus(game);

        // Ensure that the winner has been declared, so we can add up the losing positions.
        if (gameStatus__ != GameStatus.WinnerDeclared) {
            revert InvalidGameStatus();
        }

        // Ensure that the rake has not already been computed for this game.
        if (game.rakeRecorded) {
            revert NotAllowed();
        }

        // Compute the total amount of rake available to be claimed.
        for (uint256 i = 0; i < game.options; i++) {
            // Skip the winning option.
            if (i == game.winner) {
                continue;
            }

            // Get the total of all losing positions.
            // Add the amount to the total claimable rake for the owner.
            earnedRakeAmount += totalOfAllPositionsForGameOption[
                gameOptionKeyHash(gameId_, i)
            ];
        }
        // Record that the rake was calculated for this game.
        game.rakeRecorded = true;
    }

    // Handle the 3 terminal states (Expired, Cancelled, and WinnerSelected), and allow users to withdraw their positions and winnings where eligible.
    function withdrawAllPositionsAndWinningsFromGame(
        uint256 gameId_
    ) external checkGameId(gameId_) whenNotPaused nonReentrant {
        Game storage game = games[gameId_];
        GameStatus gameStatus__ = _gameStatus(game);

        if (gameStatus__ == GameStatus.WinnerDeclared) {
            // If a winner has been selected, only allow winners to withdraw their winnings.
            _processWithdrawalForWinnerDeclaredState(gameId_, game.winner);
        } else if (
            gameStatus__ == GameStatus.Expired ||
            gameStatus__ == GameStatus.Cancelled
        ) {
            // If the game is Expired or Cancelled, allow all users to withdraw all their positions.
            _processFullWithdrawalForAllOfUsersPositions(gameId_, game.options);
        } else {
            revert InvalidGameStatus();
        }
    }

    // Used in cases where we want the user to be able to withdraw all the money they have committed to the game (Expired and Cancelled states).
    function _processFullWithdrawalForAllOfUsersPositions(
        uint256 gameId_,
        uint256 gameOptions_
    ) internal {
        uint256 totalAmountForWithdrawal = 0;

        for (uint256 i = 0; i < gameOptions_; i++) {
            Position storage position = positions[
                positionKeyHash(gameId_, msg.sender, i)
            ];

            // Check if the account has already withdrawn their winnings.
            if (position.hasWithdrawn) {
                continue;
            }

            // Check if the account holds the position.
            if (position.amount == 0) {
                continue;
            }

            // Record that the account has withdrawn their position.
            position.hasWithdrawn = true;

            // Add the amount to the total amount for withdrawal.
            totalAmountForWithdrawal += position.amount;
        }

        // Check that the total amount for withdrawal is greater than 0.
        if (totalAmountForWithdrawal == 0) {
            revert EmptyPosition();
        }

        // Bulk payout to account.
        (bool success, ) = msg.sender.call{value: totalAmountForWithdrawal}("");

        // Revert if unsuccessful.
        if (!success) {
            revert WithdrawalFailed();
        }

        // Emit event
        emit BulkUserWithdrawal(gameId_, msg.sender, totalAmountForWithdrawal);
    }

    // Used in cases where there is a winner declared (WinnerDeclared state only), and we want users who held that position to be able to withdraw their winnings.
    function _processWithdrawalForWinnerDeclaredState(
        uint256 gameId_,
        uint256 winningGameOptionId_
    ) internal {
        // Get the account's winning position.
        Position storage position = positions[
            positionKeyHash(gameId_, msg.sender, winningGameOptionId_)
        ];

        // Check if the account has already withdrawn their winnings.
        if (position.hasWithdrawn) {
            revert WithdrawalFailed();
        }

        // Check if the account holds the position.
        if (position.amount == 0) {
            revert EmptyPosition();
        }

        // Calculate the winnings using 2:1 odds. This final value includes the original position amount and the winnings.
        uint256 totalEligibleForWithdrawal = position.amount * 2;

        position.hasWithdrawn = true;

        // Pay out earnings to account.
        (bool success, ) = msg.sender.call{value: totalEligibleForWithdrawal}(
            ""
        );

        // Revert if unsuccessful.
        if (!success) {
            revert WithdrawalFailed();
        }

        // Emit event
        emit UserWithdrawal(
            gameId_,
            winningGameOptionId_,
            msg.sender,
            totalEligibleForWithdrawal
        );
    }

    function addToPosition(
        uint256 gameId_,
        uint256 optionId_
    ) external payable checkGameId(gameId_) nonReentrant whenNotPaused {
        Game storage game = games[gameId_];
        GameStatus gameStatus__ = _gameStatus(game);

        // Check that the game is open for betting.
        if (gameStatus__ != GameStatus.EntriesOpen) {
            revert InvalidGameStatus();
        }

        // Check that the option is within the possible range of options.
        if (optionId_ >= game.options) {
            revert InvalidGameOption();
        }

        // Retrieve the user's current position.
        Position storage position = positions[
            positionKeyHash(gameId_, msg.sender, optionId_)
        ];

        // Check that the total amount for the position is at least the minBetSize
        uint256 newPositionSize = position.amount + msg.value;

        if (newPositionSize < game.minPositionSize) {
            revert PositionSizeTooSmall();
        }

        // Check that the total sum of positions on the option does not exceed maxAmountPerOption.
        bytes32 gameOptionKey = gameOptionKeyHash(gameId_, optionId_);

        uint256 newTotalAmountCommitted = totalOfAllPositionsForGameOption[
            gameOptionKey
        ] + msg.value;

        if (newTotalAmountCommitted > game.maxAmountPerOption) {
            revert MaxAmountForOptionExceeded();
        }

        // Save the new position.
        totalOfAllPositionsForGameOption[
            gameOptionKey
        ] = newTotalAmountCommitted;
        position.amount = newPositionSize;

        // Emit event.
        emit AddedToPosition(
            gameId_,
            optionId_,
            msg.sender,
            position.amount, // account's original position size
            msg.value // amount added to account's position
        );
    }

    //////////  Admin config functions  //////////

    function setDefaultExpirationPeriod(
        uint256 defaultExpirationPeriod_
    ) public onlyOwner {
        defaultExpirationPeriod = defaultExpirationPeriod_;
    }

    function setDefaultMinPositionSize(
        uint256 defaultMinPositionSize_
    ) public onlyOwner {
        defaultMinPositionSize = defaultMinPositionSize_;
    }

    function setDefaultMaxAmountPerOption(
        uint256 defaultMaxAmountPerOption_
    ) public onlyOwner {
        defaultMaxAmountPerOption = defaultMaxAmountPerOption_;
    }

    function setMaxOptions(uint256 maxOptions_) public onlyOwner {
        maxOptions = maxOptions_;
    }

    function setRakeRecipient(address payable rakeRecipient_) public onlyOwner {
        rakeRecipient = rakeRecipient_;
    }

    function setGameManager(address gameManager_) public onlyOwner {
        gameManager = gameManager_;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    //////////  Admin balance management functions  //////////

    function ownerDeposit() external payable onlyOwner {
        if (msg.value == 0) {
            revert InvalidAmount();
        }

        // Emit event.
        emit OwnerDeposit(msg.value);
    }

    function ownerWithdrawal(uint256 amount_) external onlyOwner {
        // Check that the amount is available to claim.
        if (amount_ > address(this).balance || amount_ == 0) {
            revert InvalidAmount();
        }

        // Pay out earnings to account using .call().
        (bool success, ) = msg.sender.call{value: amount_}("");

        // Revert if unsuccessful.
        if (!success) {
            revert WithdrawalFailed();
        }

        // Emit event
        emit OwnerWithdrawal(amount_);
    }

    //////////  Fallback functions  //////////

    fallback() external {
        revert NotAllowed();
    }

    receive() external payable {
        revert NotAllowed();
    }
}