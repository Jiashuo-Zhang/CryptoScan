// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IL1ERC20Bridge} from "./interfaces/IL1ERC20Bridge.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";

/// @title AevoDeposit
/// @notice Processes deposits to the Aevo smart contract
contract AevoDeposit is Owned {
    using SafeTransferLib for ERC20;

    /*//////////////////////////////////////////////////////////////
                               IMMUTABLES
    //////////////////////////////////////////////////////////////*/

    /// @notice The L1 bridge contract
    IL1ERC20Bridge public immutable l1Bridge;

    /// @notice The L1 token address
    ERC20 public immutable l1Token;

    /// @notice The L2 token address
    ERC20 public immutable l2Token;

    /// @notice Gas limit required to complete the deposit on L2
    uint32 public immutable l2Gas;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a fees are claimed
    /// @param amount The amount of fees claimed
    event Claimed(uint256 amount);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Constructor
    /// @param _l1Bridge The L1 bridge
    /// @param _l1Token The L1 token address
    /// @param _l2Token The L2 token address
    /// @param _l2Gas The L2 gas limit
    /// @param _owner The owner address
    constructor(address _l1Bridge, address _l1Token, address _l2Token, uint32 _l2Gas, address _owner) Owned(_owner) {
        l1Bridge = IL1ERC20Bridge(_l1Bridge);
        l1Token = ERC20(_l1Token);
        l2Token = ERC20(_l2Token);
        l2Gas = _l2Gas;

        // Max approve the token to the L1 bridge
        ERC20(_l1Token).safeApprove(_l1Bridge, type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////
                             DEPOSIT LOGIC
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposit an amount of the l1Token to the accounts balance on L2 using an EIP-2612 permit signature
    /// @dev Gets called by a keeper which relays the signature
    /// @param account The account to transfer the tokens from
    /// @param amount Amount of the l1Token to deposit
    /// @param fee Amount of the l1Token to charge as a fee
    /// @param deadline A timestamp, the current blocktime must be less than or equal to this timestamp
    /// @param v Must produce valid secp256k1 signature from the holder along with r and s
    /// @param r Must produce valid secp256k1 signature from the holder along with v and s
    /// @param s Must produce valid secp256k1 signature from the holder along with r and v
    function deposit(address account, uint256 amount, uint256 fee, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        external
    {
        // Approve the tokens from the sender to this contract
        l1Token.permit(account, address(this), amount, deadline, v, r, s);

        // Transfer the tokens from the sender to this contract
        l1Token.safeTransferFrom(account, address(this), amount);

        // Deposit the tokens to the senders balance on L2
        l1Bridge.depositERC20To(address(l1Token), address(l2Token), account, amount - fee, l2Gas, "");
    }

    /// @notice Transfers all fees generated from the contract to the owner
    /// @dev Callable by anyone
    function claim() external {
        // Transfer the fees
        uint256 amount = l1Token.balanceOf(address(this));
        l1Token.safeTransfer(owner, amount);

        // Emit the event
        emit Claimed(amount);
    }
}