// SPDX-License-Identifier: MIT
//                                                                       %%
//             .@@@@@@@@@         @@@@@@     @@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@
//            @@@@@@@@@@@(       @@@@@@@    .@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@
//          @@@@@@@@@@@@@@      @@@@@@@           @@@@@@@       (@@@@@@     @@@@@@
//         @@@@@@@ @@@@@@@     @@@@@@@           @@@@@@@         @@@@@@@@@@@
//       @@@@@@@   @@@@@@@     @@@@@@            @@@@@@           @@@@@@@@@@@@@@
//      @@@@@@@@@@@@@@@@@@    @@@@@@@           @@@@@@@               #@@@@@@@@@@
//    @@@@@@@@@@@@@@@@@@@@   @@@@@@@           @@@@@@@        @@@@@@@     @@@@@@#
//   @@@@@@@@@@@@@@@@@@@@@   @@@@@@@@@@@@@@@@ @@@@@@@         @@@@@@@@@@@@@@@@@
// @@@@@@@         *@@@@@@  @@@@@@@@@@@@@@@@  @@@@@@            .@@@@@@@@@@@@

pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./interfaces/IDelegationRegistry.sol";

interface IAltsByAdidas is IERC721 {
    function walletOfOwner(
        address __owner,
        uint256 _startingIndex,
        uint256 _endingIndex
    ) external view returns (uint256[] memory);
}

interface IAdidasBluePass is IERC721 {
    function burnByOperator(uint256[] memory tokenIds) external;
}

/**
 * @title UniversalKey
 * @notice This contract enables ALTS by adidas holders to purchase Universal Keys
 * @dev This contract should be used with the ALTS by adidas ERC721 contract and optionally the Apecoin ERC20 token.
 */
contract UniversalKey is Ownable {
    using SafeERC20 for IERC20;
    struct Purchase {
        bool purchased;
        address owner;
    }
    /**
     * @notice ALTS by adidas ERC721 contract
     */
    IERC721 public erc721;
    /**
     * @notice Blue Pass ERC721 contract
     */
    IAdidasBluePass public bluePass;
    /**
     * @notice Apecoin ERC20 contract
     */
    IERC20 public apeCoin;
    /**
     * @notice Wallet to receive funds
     */
    address payable public receiver;
    /**
     * @notice The total limit of keys available for purchase.
     */
    uint256 public totalKeyLimit;
    /**
     * @notice The total number of Universal Keys purchased.
     */
    uint256 public totalKeysPurchased;
    /**
     *  @notice Get the maximum number of ALTS permitted in each team
     */
    uint256[8] public teamLimits;
    /**
     * @notice Exchange rate (# of APE per 1 ETH)
     */
    uint256 public ethApeExchangeRate;
    /**
     * @notice Snapshot prices
     */
    uint256[4] public snapshotPrices;
    /**
     * @notice Status of team selection
     */
    bool public teamSelectionEnabled;
    /**
     * @notice Status of Universal Key purchases
     */
    bool public purchasesEnabled;
    /**
     * @notice Status of team selection early access
     */
    bool public earlyAccessEnabled;

    mapping(uint256 => uint8) private tokenTeam;
    mapping(uint8 => uint256) private teamMemberCounts;
    mapping(uint256 => Purchase) private tokenPurchases;
    mapping(address => uint256[]) private userPurchasedTokens;
    /**
     * @notice Discounted purchases remaining for relevant snapshot groups
     */
    mapping(address => mapping(uint8 => bool)) public discountUsed;
    /**
     * @notice Token IDs with Universal Keys that are permitted for early access team selection
     */
    mapping(uint256 => bool) public earlyAccessTokens;
    /**
     * @notice Merkle roots for snapshots
     */
    mapping(uint8 => bytes32) public merkleRoots;

    IDelegationRegistry public immutable dc;

    constructor(
        address _erc721,
        address _bluePass,
        address _apeCoin,
        address payable _receiver,
        uint256[8] memory _teamLimits,
        uint256 _totalKeyLimit,
        uint256[4] memory _snapshotPrices,
        uint256 _ethApeExchangeRate,
        address _delegateCash,
        bytes32 _snapshot1Merkle,
        bytes32 _snapshot2Merkle,
        bytes32 _snapshot3Merkle
    ) {
        erc721 = IERC721(_erc721);
        bluePass = IAdidasBluePass(_bluePass);
        apeCoin = IERC20(_apeCoin);
        dc = IDelegationRegistry(_delegateCash);
        receiver = _receiver;
        totalKeyLimit = _totalKeyLimit;
        ethApeExchangeRate = _ethApeExchangeRate;
        snapshotPrices = _snapshotPrices;

        setMerkleRoot(0, _snapshot1Merkle);
        setMerkleRoot(1, _snapshot2Merkle);
        setMerkleRoot(2, _snapshot3Merkle);

        for (uint8 i = 0; i < 8; i++) {
            teamLimits[i] = _teamLimits[i];
        }
    }

    /**
     * @notice Enables ALTS by adidas holders to burn a Blue Pass for a Universal Key
     * @dev Purchases one key at zero price for a burned Blue Pass
     * @param tokenId Blue Pass token ID
     * @param altTokenId The ALTS by adidas ALT token ID to purchase a key for
     */
    function burnForKey(uint256 tokenId, uint256 altTokenId) public {
        require(
            purchasesEnabled || owner() == msg.sender,
            "Purchases are disabled"
        );
        require(
            totalKeysPurchased + 1 <= totalKeyLimit,
            "Total token limit exceeded"
        );
        require(
            bluePass.ownerOf(tokenId) == msg.sender,
            "User must own a Blue Pass"
        );
        require(
            erc721.ownerOf(altTokenId) == msg.sender,
            "User must own the ALTS token ID"
        );
        require(
            !tokenPurchases[altTokenId].purchased,
            "Key already purchased for ALT"
        );

        // Burn the Blue Pass
        uint256[] memory passToBurn = new uint256[](1);
        passToBurn[0] = tokenId;
        bluePass.burnByOperator(passToBurn);

        // Ensure successful Blue Pass burn before purchase

        tokenPurchases[altTokenId] = Purchase(true, msg.sender);
        userPurchasedTokens[msg.sender].push(altTokenId);

        totalKeysPurchased += 1;

        uint256[] memory singleTokenId = new uint256[](1);
        singleTokenId[0] = altTokenId;
    }

    /**
     * @notice Enables ALTS by adidas holders to purchase Universal Keys
     * @dev Purchases keys for the provided ALTS token IDs and handles payment
     * @param tokenIds The ALTS by adidas ALTS token IDs to purchase keys for
     * @param useApe Whether to pay with Apecoin
     */
    function purchaseKeys(
        uint256[] calldata tokenIds,
        bool useApe,
        address _vault,
        uint8[] calldata snapshotIds,
        bytes32[][] calldata proofs
    ) public payable {
        address requester = msg.sender;

        require(
            snapshotIds.length == proofs.length,
            "Snapshots/proofs length mismatch"
        );
        require(
            purchasesEnabled || owner() == msg.sender,
            "Purchases are disabled"
        );
        require(
            totalKeysPurchased + tokenIds.length <= totalKeyLimit,
            "Total token limit exceeded"
        );

        if (_vault != address(0)) {
            bool isDelegateValid = dc.checkDelegateForContract(
                msg.sender,
                _vault,
                address(erc721)
            );
            require(isDelegateValid, "invalid delegate-vault pairing");
            requester = _vault;
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(
                erc721.ownerOf(tokenIds[i]) == requester,
                "User must own the token ID"
            );
            require(
                !tokenPurchases[tokenIds[i]].purchased,
                "Token ID already purchased"
            );
        }

        uint256 price = 0;
        uint256 remainingKeys = tokenIds.length;
        bool[4] memory inSnapshot;

        for (uint256 i = 0; i < snapshotIds.length; i++) {
            inSnapshot[snapshotIds[i]] = isSnapshot(
                snapshotIds[i],
                requester,
                proofs[i]
            );
        }

        if (inSnapshot[0] && !discountUsed[requester][0]) {
            price += snapshotPrices[0];
            remainingKeys--;
            discountUsed[requester][0] = true;
        }
        if (remainingKeys > 0 && inSnapshot[1] && !discountUsed[requester][1]) {
            price += snapshotPrices[1];
            remainingKeys--;
            discountUsed[requester][1] = true;
        }
        if (remainingKeys > 0) {
            uint256 nextLowestPrice = inSnapshot[2]
                ? snapshotPrices[2]
                : snapshotPrices[3];
            price += nextLowestPrice * remainingKeys;
        }

        if (useApe) {
            require(msg.value == 0, "Should not send ETH with APE");
            uint256 apePrice = getApePrice(price);
            SafeERC20.safeTransferFrom(apeCoin, msg.sender, receiver, apePrice);
        } else {
            require(msg.value == price, "Insufficient payment");
            (bool sent, ) = receiver.call{value: price}("");
            require(sent, "Failed to send Ether");
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            tokenPurchases[tokenIds[i]] = Purchase(true, requester);
            userPurchasedTokens[requester].push(tokenIds[i]);
        }

        unchecked {
            totalKeysPurchased += tokenIds.length;
        }
    }

    /**
     * @notice Admin function to assign keys to ALTS
     * @param tokenIds The ALTS token IDs
     */
    function grantKeys(uint256[] calldata tokenIds) public onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            address wallet = erc721.ownerOf(tokenId);

            require(
                !tokenPurchases[tokenId].purchased,
                "Token ID already has key"
            );

            tokenPurchases[tokenId] = Purchase(true, wallet);
            userPurchasedTokens[wallet].push(tokenId);

            totalKeysPurchased++;
        }
    }

    /**
     * @notice Admin function to update the wallet address to receive funds from purchases
     * @dev Only callable by the contract owner
     * @param newReceiver The new receiver wallet address
     */
    function updateReceiver(address payable newReceiver) public onlyOwner {
        receiver = newReceiver;
    }

    /**
     * @notice Get owned ALTS by adidas tokens for the given wallet
     * @param wallet The wallet to check for owned ALTS
     * @return tokenIds An array of token IDs of owned ALTS
     */
    function getOwnedAlts(
        address wallet
    ) public view returns (uint256[] memory tokenIds) {
        IAltsByAdidas source = IAltsByAdidas(address(erc721));
        tokenIds = source.walletOfOwner(wallet, 1, 30000);
        return tokenIds;
    }

    /**
     * @notice Check if the given ALTS token IDs are purchased and get their respective owner wallet addresses
     * @param tokenIds The token IDs to check
     * @return purchased An array of booleans representing the purchase status
     * @return walletAddresses An array of wallet addresses of the owners
     */
    function isTokenIdPurchased(
        uint256[] memory tokenIds
    )
        public
        view
        returns (bool[] memory purchased, address[] memory walletAddresses)
    {
        purchased = new bool[](tokenIds.length);
        walletAddresses = new address[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            purchased[i] = tokenPurchases[tokenId].purchased;
            if (purchased[i]) {
                walletAddresses[i] = erc721.ownerOf(tokenId);
            }
        }
    }

    /**
     * @notice Get the purchased keys for the given user
     * @param user The user to check for purchased keys
     * @return An array of purchased keys (token IDs)
     */
    function getPurchasedKeys(
        address user
    ) public view returns (uint256[] memory) {
        return userPurchasedTokens[user];
    }

    /**
     * @notice Admin function to update the snapshot prices for all groups
     * @param prices An array of updated snapshot prices
     */
    function updateSnapshotPrices(uint256[4] memory prices) public onlyOwner {
        snapshotPrices = prices;
    }

    /**
     * @notice Set the APE to ETH exchange rate
     * @param rate The multiple of APE per ETH value
     */
    function setEthApeExchangeRate(uint256 rate) public onlyOwner {
        ethApeExchangeRate = rate;
    }

    /**
     * @notice Get the APE price for the given ETH price
     * @param ethPrice The ETH price to calculate APE price for
     * @return The calculated APE price
     */
    function getApePrice(uint256 ethPrice) public view returns (uint256) {
        return ethPrice * ethApeExchangeRate;
    }

    /**
     * @notice Get the payable amount for the given wallet and ALTS token IDs
     * @param wallet The wallet to check
     * @param tokenIds The ALTS token IDs to check
     * @param useApe Whether to use Ape token for payment
     * @return price The calculated payable amount
     */
    function getAmountPayable(
        address wallet,
        uint8[] calldata snapshotIds,
        uint256[] calldata tokenIds,
        bool useApe
    ) public view returns (uint256) {
        uint256 price = 0;
        uint256 remainingKeys = tokenIds.length;
        bool[4] memory inSnapshot;

        for (uint256 i = 0; i < snapshotIds.length; i++) {
            uint8 snapshotId = snapshotIds[i];
            inSnapshot[snapshotId] = true;
        }

        if (inSnapshot[0] && !discountUsed[wallet][0]) {
            price += snapshotPrices[0];
            remainingKeys--;
        }

        if (remainingKeys > 0 && inSnapshot[1] && !discountUsed[wallet][1]) {
            price += snapshotPrices[1];
            remainingKeys--;
        }

        if (remainingKeys > 0) {
            uint256 nextLowestPrice = inSnapshot[2]
                ? snapshotPrices[2]
                : snapshotPrices[3];
            price += nextLowestPrice * remainingKeys;
        }

        if (useApe) {
            return getApePrice(price);
        } else {
            return price;
        }
    }

    /**
     * @notice Admin function to set the total key limit
     * @param limit The limit to set for total keys
     */
    function setTotalKeyLimit(uint256 limit) public onlyOwner {
        totalKeyLimit = limit;
    }

    /**
     * @notice Admin function to update the team limits for all teams
     * @param limits An array of updated team limits
     */
    function updateTeamLimits(uint256[8] memory limits) public onlyOwner {
        for (uint8 i = 0; i < 8; i++) {
            teamLimits[i] = limits[i];
        }
    }

    /**
     * @notice Select teams for the given ALTS token IDs for which Universal Keys have been purchased
     * @param tokenIds The ALTS token IDs to select teams for
     * @param teams The selected teams for each ALTS token ID
     */
    function selectTeam(
        uint256[] memory tokenIds,
        uint8[] memory teams,
        address _vault
    ) public {
        require(
            tokenIds.length == teams.length,
            "TokenIds/teams length mismatch"
        );

        // Check if the user has early access for all tokens
        bool hasEarlyAccess = true;
        if (earlyAccessEnabled) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (!earlyAccessTokens[tokenIds[i]]) {
                    hasEarlyAccess = false;
                    break;
                }
            }
        }

        require(
            teamSelectionEnabled || owner() == msg.sender || hasEarlyAccess,
            "No team selection / early access"
        );

        address requester = msg.sender;
        if (_vault != address(0)) {
            bool isDelegateValid = dc.checkDelegateForContract(
                msg.sender,
                _vault,
                address(erc721)
            );
            require(isDelegateValid, "invalid delegate-vault pairing");
            requester = _vault;
        }

        uint256[8] memory teamSelections;

        for (uint256 i = 0; i < teams.length; i++) {
            uint8 team = teams[i];
            require(1 <= team && team <= 8, "Invalid team number");

            uint256 tokenId = tokenIds[i];
            require(
                erc721.ownerOf(tokenId) == requester,
                "User must own the token ID"
            );
            require(
                tokenPurchases[tokenId].purchased &&
                    tokenPurchases[tokenId].owner == requester,
                "No key found for token ID"
            );
            require(tokenTeam[tokenId] == 0, "Token ID already has a team");

            /// Check if the team is, or would become, oversubscribed
            teamSelections[team - 1]++;
            require(
                teamMemberCounts[team] + teamSelections[team - 1] <=
                    teamLimits[team - 1],
                "Not enough spaces in this team"
            );

            tokenTeam[tokenId] = team;
        }
        for (uint8 i = 0; i < 8; i++) {
            teamMemberCounts[i + 1] += teamSelections[i];
        }
    }

    /**
     * @notice Admin function to update team selections for ALTS token IDs
     * @param tokenIds The token IDs to update team selections for
     * @param teams The updated team selections for each token ID
     */
    function updateTeamSelections(
        uint256[] memory tokenIds,
        uint8[] memory teams
    ) public onlyOwner {
        require(
            tokenIds.length == teams.length,
            "TokenIds/teams length mismatch"
        );
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint8 team = teams[i];
            uint256 tokenId = tokenIds[i];
            tokenTeam[tokenId] = team;
            teamMemberCounts[team]++;
        }
    }

    /**
     * @notice Get the team selections for the given ALTS token IDs
     * @param tokenIds The token IDs to check for teams
     * @return An array of selected teams (indexed by ALT token ID)
     */
    function getTeam(
        uint256[] memory tokenIds
    ) public view returns (uint8[] memory) {
        uint8[] memory teamsSelected = new uint8[](tokenIds.length);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            teamsSelected[i] = tokenTeam[tokenIds[i]];
        }
        return teamsSelected;
    }

    /**
     * @notice Get all ALTS token IDs associated with a specified team
     * @param team The team number to get the token IDs for
     * @return An array of token IDs that belong to the specified team
     */
    function getTokenIdsByTeam(
        uint8 team
    ) public view returns (uint256[] memory) {
        require(1 <= team && team <= 8, "Invalid team number");

        uint256[] memory tokenIds = new uint256[](teamMemberCounts[team]);
        uint256 index = 0;

        for (uint256 tokenId = 1; tokenId <= totalKeyLimit; tokenId++) {
            if (tokenTeam[tokenId] == team) {
                tokenIds[index] = tokenId;
                index++;
            }
        }
        return tokenIds;
    }

    /**
     * @notice Get the total number of ALTS in each team
     * @return An array containing the number of ALTS in each team
     */
    function getTeamTotals() public view returns (uint256[8] memory) {
        uint256[8] memory currentTeamMembers;

        for (uint8 i = 0; i < 8; i++) {
            currentTeamMembers[i] = teamMemberCounts[i + 1];
        }
        return currentTeamMembers;
    }

    /**
     * @notice Get the total number of keys distributed among all teams
     * @return The total number of keys in all teams
     */
    function totalKeysInTeams() public view returns (uint256) {
        uint256 total = 0;
        for (uint8 i = 1; i <= 8; i++) {
            total += teamMemberCounts[i];
        }
        return total;
    }

    /**
     * @notice Admin function to set ALTS with early access to select team (golden keys)
     * @param tokenIds The ALTS token IDs to set
     */
    function setEarlyAccessTokens(uint256[] memory tokenIds) public onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            earlyAccessTokens[tokenIds[i]] = true;
        }
    }

    /**
     * @notice Admin function to enable team selection for early access token holders
     * @param enabled Bool to enable/disable early access
     */
    function setEarlyAccessEnabled(bool enabled) public onlyOwner {
        earlyAccessEnabled = enabled;
    }

    /**
     * @notice Admin function to enable or disable the ability to select a team
     * @param enabled A boolean representing whether team selection should be enabled or disabled
     */
    function setTeamSelectionEnabled(bool enabled) public onlyOwner {
        teamSelectionEnabled = enabled;
    }

    /**
     * @notice Admin function to enable or disable the ability to make key purchases
     * @param enabled A boolean for the status of key purchases
     */
    function setPurchasesEnabled(bool enabled) public onlyOwner {
        purchasesEnabled = enabled;
    }

    /**
     * @notice Admin function to reset discounted purchase availability for multiple wallets
     * @param users Array of wallet addresses
     * @param snapshots Snapshot IDs
     */
    function setDiscountedPurchasesRemaining(
        address[] calldata users,
        uint8[] calldata snapshots
    ) public onlyOwner {
        require(
            users.length == snapshots.length,
            "Users/snapshots length mismatch"
        );

        for (uint256 i = 0; i < users.length * snapshots.length; i++) {
            uint256 userIndex = i / snapshots.length;
            uint256 snapshotIndex = i % snapshots.length;
            discountUsed[users[userIndex]][snapshots[snapshotIndex]] = false;
        }
    }

    /**
     * @notice Admin function to update merkle roots for snapshots
     * @param snapshotId Snapshot to update root for
     * @param newRoot The new merkle root
     */
    function setMerkleRoot(uint8 snapshotId, bytes32 newRoot) public onlyOwner {
        merkleRoots[snapshotId] = newRoot;
    }

    /**
     * @notice Check if a wallet address is valid in the given snapshot
     * @param wallet Wallet address to check
     * @param proof Wallet's merkle proof
     * @param snapshotId Snapshot to check
     */
    function isSnapshot(
        uint8 snapshotId,
        address wallet,
        bytes32[] calldata proof
    ) public view returns (bool) {
        bytes32 merkleRoot = merkleRoots[snapshotId];
        return
            MerkleProof.verify(
                proof,
                merkleRoot,
                keccak256(abi.encodePacked(wallet))
            );
    }

    /**
     * @notice Admin function drain any ETH or APE funds stuck in the contract
     */
    function drain(address to) public onlyOwner {
        // Transfer stuck ETH to the contract owner
        uint256 balanceETH = address(this).balance;
        if (balanceETH > 0) {
            (bool sent, ) = to.call{value: balanceETH}("");
            require(sent, "Failed to send Ether");
        }

        // Transfer stuck APE to the contract owner
        uint256 balanceAPE = apeCoin.balanceOf(address(this));
        if (balanceAPE > 0) {
            apeCoin.safeTransfer(to, balanceAPE);
        }
    }
}