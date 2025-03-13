import "../ChopBotGame.sol";

contract TelegramChopBotGame is Ownable {
    address public revenueWallet;
    ChopBotGame public immutable bettingToken;
    uint256 public immutable minimumBet;

    uint256 public immutable revenueBps;

    uint256 public immutable burnBps;

    mapping(int64 => Game) public games;

    int64[] public activeTgGroups;

    event Bet(int64 tgChatId, address player, uint16 playerIndex, uint256 amount);

    event Win(int64 tgChatId, address player, uint16 playerIndex, uint256 amount);

    event Loss(int64 tgChatId, address player, uint16 playerIndex, uint256 amount);

    event Revenue(int64 tgChatId, uint256 amount);

    event Burn(int64 tgChatId, uint256 amount);

    constructor(address payable _bettingToken, uint256 _minimumBet, uint256 _revenueBps, uint256 _burnBps, address _revenueWallet) {
        revenueWallet = _revenueWallet;
        revenueBps = _revenueBps;
        burnBps = _burnBps;
        bettingToken = ChopBotGame(_bettingToken);
        minimumBet = _minimumBet;
    }

    struct Game {
        uint256 revolverSize;
        uint256 minBet;

        bytes32 hashedBulletChamberIndex;

        address[] players;
        uint256[] bets;

        bool inProgress;
        uint16 loser;
    }

    /**
     * @dev Check if there is a game in progress for a Telegram group.
     * @param _tgChatId Telegram group to check
     * @return true if there is a game in progress, otherwise false
     */
    function isGameInProgress(int64 _tgChatId) public view returns (bool) {
        return games[_tgChatId].inProgress;
    }

    /**
     * @dev Remove a Telegram chat ID from the array.
     * @param _tgChatId Telegram chat ID to remove
     */
    function removeTgId(int64 _tgChatId) internal {
        for (uint256 i = 0; i < activeTgGroups.length; i++) {
            if (activeTgGroups[i] == _tgChatId) {
                activeTgGroups[i] = activeTgGroups[activeTgGroups.length - 1];
                activeTgGroups.pop();
            }
        }
    }

    /**
     * @dev Create a new game. Transfer funds into escrow.
     * @param _tgChatId Telegram group of this game
     * @param _revolverSize number of chambers in the revolver
     * @param _minBet minimum bet to play
     * @param _hashedBulletChamberIndex which chamber the bullet is in
     * @param _players participating players
     * @param _bets each player's bet
     * @return The updated list of bets.
     */
    function newGame(
        int64 _tgChatId, uint256 _revolverSize, uint256 _minBet, bytes32 _hashedBulletChamberIndex,
        address[] memory _players, uint256[] memory _bets) public onlyOwner returns (uint256[] memory
    ) {
        require(_revolverSize >= 2, "Revolver size too small");
        require(_players.length <= _revolverSize, "Too many players for this size revolver");
        require(_minBet >= minimumBet, "Minimum bet too small");
        require(_players.length == _bets.length, "Players/bets length mismatch");
        require(_players.length > 1, "Not enough players");
        require(!isGameInProgress(_tgChatId), "There is already a game in progress");

        uint256 betTotal = 0;
        for (uint16 i = 0; i < _bets.length; i++) {
            require(_bets[i] >= _minBet, "Bet is smaller than the minimum");
            betTotal += _bets[i];
        }

        for (uint16 i = 0; i < _bets.length; i++) {
            betTotal -= _bets[i];
            if (_bets[i] > betTotal) {
                _bets[i] = betTotal;
            }
            betTotal += _bets[i];

            require(bettingToken.allowance(_players[i], address(this)) >= _bets[i], "Not enough allowance");
            bool isSent = bettingToken.transferFrom(_players[i], address(this), _bets[i]);
            require(isSent, "Funds transfer failed");

            emit Bet(_tgChatId, _players[i], i, _bets[i]);
        }

        Game memory g;
        g.revolverSize = _revolverSize;
        g.minBet = _minBet;
        g.hashedBulletChamberIndex = _hashedBulletChamberIndex;
        g.players = _players;
        g.bets = _bets;
        g.inProgress = true;

        games[_tgChatId] = g;
        activeTgGroups.push(_tgChatId);

        return _bets;
    }

    /**
     * @dev Declare a loser of the game and pay out the winnings.
     * @param _tgChatId Telegram group of this game
     * @param _loser index of the loser
     *
     * Challenges to the fairness of the game can be met by revealing the string embedded during game creation.
     */
    function endGame(int64 _tgChatId, uint16 _loser) public onlyOwner {
        require(_loser != type(uint16).max, "Loser index shouldn't be the sentinel value");
        require(isGameInProgress(_tgChatId), "No game in progress for this Telegram chat ID");

        Game storage g = games[_tgChatId];

        require(_loser < g.players.length, "Loser index out of range");
        require(g.players.length > 1, "Not enough players");

        g.loser = _loser;
        g.inProgress = false;
        removeTgId(_tgChatId);

        address[] memory winners = new address[](g.players.length - 1);
        uint16[] memory winnersPlayerIndex = new uint16[](g.players.length - 1);

        uint256 winningBetTotal = 0;

        {
            uint16 numWinners = 0;
            for (uint16 i = 0; i < g.players.length; i++) {
                if (i != _loser) {
                    winners[numWinners] = g.players[i];
                    winnersPlayerIndex[numWinners] = i;
                    winningBetTotal += g.bets[i];
                    numWinners++;
                }
            }
        }

        uint256 totalPaidWinnings = 0;
        require(burnBps + revenueBps < 10_1000, "Total fees must be < 100%");

        uint256 burnShare = g.bets[_loser] * burnBps / 10_000;
        uint256 approxRevenueShare = g.bets[_loser] * revenueBps / 10_000;

        bool isSent;
        {
            uint256 totalWinnings = g.bets[_loser] - burnShare - approxRevenueShare;

            for (uint16 i = 0; i < winners.length; i++) {
                uint256 winnings = totalWinnings * g.bets[winnersPlayerIndex[i]] / winningBetTotal;

                isSent = bettingToken.transfer(winners[i], g.bets[winnersPlayerIndex[i]] + winnings);
                require(isSent, "Funds transfer failed");

                emit Win(_tgChatId, winners[i], winnersPlayerIndex[i], winnings);

                totalPaidWinnings += winnings;
            }
        }

        bettingToken.burn(burnShare);
        emit Burn(_tgChatId, burnShare);

        uint256 realRevenueShare = g.bets[_loser] - totalPaidWinnings - burnShare;
        isSent = bettingToken.transfer(revenueWallet, realRevenueShare);
        require(isSent, "Revenue transfer failed");
        emit Revenue(_tgChatId, realRevenueShare);

        require((totalPaidWinnings + burnShare + realRevenueShare) == g.bets[_loser], "Calculated winnings do not add up");
    }

    /**
     * @dev Abort a game and refund the bets. Use in emergencies
     *      e.g. bot crash.
     * @param _tgChatId Telegram group of this game
     */
    function abortGame(int64 _tgChatId) public onlyOwner {
        require(isGameInProgress(_tgChatId), "No game in progress for this Telegram chat ID");
        Game storage g = games[_tgChatId];

        for (uint16 i = 0; i < g.players.length; i++) {
            bool isSent = bettingToken.transfer(g.players[i], g.bets[i]);
            require(isSent, "Funds transfer failed");
        }

        g.inProgress = false;
        removeTgId(_tgChatId);
    }

    /**
     * @dev Abort all in progress games.
     */
    function abortAllGames() public onlyOwner {
        // abortGame modifies activeTgGroups with each call, so
        // iterate over a copy
        int64[] memory _activeTgGroups = activeTgGroups;
        for (uint256 i = 0; i < _activeTgGroups.length; i++) {
            abortGame(_activeTgGroups[i]);
        }
    }
}