// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
    @title Bounty Contract Version 1

    @notice This contract allows for the creation, funding, and completion of blockchain intelligence
    bounties in a decentralized manner.

    @dev This contract is intended to be used with the ARKM token.

    Users can submit bounties by putting up ARKM, and other users can complete the bounties by
    staking ARKM to submit IDs that correspond to solutions.

    Submission IDs are not submitted raw, but instead hashed with the submitter's address to
    prevent front-running. The IDs are effectively secrets that only the submitters know on
    submission.

    bountyIDs and submissionIDs correspond to off-chain records that detail the bounty and contain
    solutions. For v1, these records live on the Arkham platform. In the future there could be any
    number of secondary services that host these records.

    Once submissions are made, only a set of approver addresses can approve or reject them -- NOT
    the posters of the bounty. Approver addresses can be added or removed by the the contract
    owner.

    Once a bounty is funded, it cannot be closed until after its expiration. Bounties also must
    remain open until any submission to the bounty has been approved or rejected. Once a bounty is
    closed, it cannot be reopened. If a funder closes their bounty, they receive the amount of the
    bounty back. (Bounty funders can receive a maximum of 100% of their initial funding back. if
    there is excess funding from rejected submissions, it is accrued as fees.)

    The contract owner sets the initial submission stake, maker fee, and taker fee.

    A maker fee is charged when a bounty is funded. A taker fee is charged when a submission is
    paid out. These fees are in basis points, e.g. 100 basis points = 1%. Fees are disbursed at the
    discretion of the owner. A fraction of fees are burned, and the rest are withdrawn to an
    address set at contract creation and changeable by the owner.

    If a submission is approved, the submitter receives the bounty amount plus their stake back,
    less a taker fee. If a submission is rejected, the submitter does NOT receive their stake back,
    and the bounty amount increases by the amount staked. Only one submission may be active for a
    given bounty at a time.

    Delivery of the information corresponding to the accepted submission to the funder is handled
    off-chain.
 */
contract BountyV1 is Ownable {
    address private immutable _arkm;

    uint256 private _submissionStake;
    uint256 private _makerFee;
    uint256 private _takerFee;
    bool    private _acceptingBounties;
    uint256 private _accruedFees;
    address private _feeReceiverAddress;

    uint64 private immutable _bountyDuration;

    uint64  private constant _MAX_BPS = 10000;

    /// @dev Bounty ID --> Bounty
    mapping(uint256 => Bounty) private _bounties;

    /// @dev Bounty ID --> Submission. There can only be one submission per bounty at a time.
    mapping(uint256 => Submission) private _submissions;

    /// @dev Payload --> bool. Tracks rejected payloads.
    mapping(uint256 => bool) private _rejectedPayloads;

    /// @dev Approver address --> is approver
    mapping(address => bool) private _approvers;

    /// @notice Struct representing a bounty
    /// @dev No submissions may be posted to the bounty after the unlock time. If there is an
    /// active submission when the unlock time is reached, it may still be approved after the
    /// unlock time. The bounty is only considered closed when it is past the expiration AND there
    /// is no active submission. The ID corresponds to a record kept on the Arkham platform - or in
    /// the future, on any number of secondary serivices.
    struct Bounty {
        uint256 amount;
        uint256 initialAmount;
        uint64 expiration;
        address funder;
        bool closed;
    }

    /// @notice Struct representing a submission to a bounty
    /// @dev The payload is a hash of the submission ID and the submitter's address to prevent
    /// front-running. This ID corresponds to a record on the Arkham platform - or, in the future,
    /// any secondary service that bounty-approvers can use to verify the submission.
    struct Submission {
        bytes32 payload;
        address submitter;
        uint256 stake;
    }

    /// @notice Emitted when a bounty is funded
    /// @param bountyID The ID of the funded bounty
    /// @param funder The address of the funder
    /// @param initialValue The initial value of the bounty
    /// @param expiration The unlock time of the bounty
    event FundBounty (
        uint256 indexed bountyID,
        address indexed funder,
        uint256 initialValue,
        uint64  expiration
    );

    /// @notice Emitted when a submission is made for a bounty
    /// @param bountyID The ID of the bounty for which the submission is made
    /// @param submitter The address of the submitter
    /// @param stake The stake of the submission
    /// @param payload The payload of the submission
    event FundSubmission (
        uint256 indexed bountyID,
        address indexed submitter,
        uint256 stake,
        bytes32 payload
    );

    /// @notice Emitted when a submission for a bounty is rejected
    /// @param bountyID The ID of the bounty for which the submission is rejected
    /// @param submitter The address of the submitter
    /// @param stake The stake of the rejected submission
    /// @param payload The payload of the rejected submission
    event RejectSubmission (
        uint256 indexed bountyID,
        address indexed submitter,
        uint256 stake,
        bytes32 payload
    );

    /// @notice Emitted when a submission for a bounty is approved
    /// @param bountyID The ID of the bounty for which the submission is approved
    /// @param submitter The address of the submitter
    /// @param stake The stake of the approved submission
    /// @param payload The payload of the approved submission
    /// @param payoutToSubmitter The payout to the submitter
    event SubmissionApproved (
        uint256 indexed bountyID,
        address indexed submitter,
        uint256 stake,
        bytes32 payload,
        uint256 payoutToSubmitter
    );

    /// @notice Emitted when a bounty is closed
    /// @param bountyID The ID of the closed bounty
    /// @param funder The address of the funder
    /// @param payoutToFunder The payout to the funder
    /// @param excessFromStaking The excess fees
    event CloseBounty (
        uint256 indexed bountyID,
        address indexed funder,
        address indexed closedBy,
        uint256 payoutToFunder,
        uint256 excessFromStaking
    );

    /// @notice Emitted when an account is granted approver status
    /// @param account The account granted approver status
    event GrantApprover (
        address indexed account
    );

    /// @notice Emitted when an account has its approver status revoked
    /// @param account The account that had its approver status revoked
    event RevokeApprover (
        address indexed account
    );

    /// @notice Emitted when the maker fee is set
    /// @param newFee The new maker fee
    /// @param oldFee The old maker fee
    event SetMakerFee (
        uint256 newFee,
        uint256 oldFee
    );

    /// @notice Emitted when the taker fee is set
    /// @param newFee The new taker fee
    /// @param oldFee The old taker fee
    event SetTakerFee (
        uint256 newFee,
        uint256 oldFee
    );

    /// @notice Emitted when the submission stake is set
    /// @param newStake The new submission stake
    /// @param oldStake The old submission stake
    event SetSubmissionStake (
        uint256 newStake,
        uint256 oldStake
    );

    /// @notice Emitted when the contract stops accepting bounties
    event CloseBountySubmissions ();

    /// @notice Emitted when accrued fees are withdrawn
    /// @param amount The amount of accrued fees withdrawn
    event WithdrawFees (
        uint256 amount
    );

    /// @notice Contract constructor that sets initial values
    /// @param arkmAddress Address of the ERC20 token to be used (ARKM)
    /// @param initialSubmissionStake Initial stake required for a submission, e.g. 10 e18
    /// @param initialMakerFee Initial fee for creating a bounty, in basis points
    /// @param initialTakerFee Initial fee for completing a bounty, in basis points
    /// @param bountyDuration Duration of a bounty, in days, i.e. time until expiration
    /// @dev We check to make sure the arkmAddress implements ERC20Burnable so we can burn fees.
    /// This also makes sure the address is a valid ERC20 token.
    constructor(address arkmAddress, uint256 initialSubmissionStake, uint256 initialMakerFee, uint256 initialTakerFee, uint64 bountyDuration, address feeReceiverAddress) {
        require(initialMakerFee <= _MAX_BPS, "BountyV1: maker fee must be <= 10000");
        require(initialTakerFee <= _MAX_BPS, "BountyV1: taker fee must be <= 10000");
        require(feeReceiverAddress != address(0), "BountyV1: fee receiver address cannot be 0x0");
        require(bountyDuration <= 36500, "BountyV1: bounty duration must be <= 36500 days");

        try ERC20Burnable(arkmAddress).totalSupply() returns (uint256) {
            _arkm = arkmAddress;
        } catch {
            revert("BountyV1: provided token address does not implement ERC20Burnable");
        }

        _submissionStake = initialSubmissionStake;
        _makerFee = initialMakerFee;
        _takerFee = initialTakerFee;
        _acceptingBounties = true;
        _bountyDuration = bountyDuration;
        _feeReceiverAddress = feeReceiverAddress;
    }

    /// @return The amount of ARKM accrued from fees
    function accruedFees() public view virtual returns (uint256) {
        return _accruedFees;
    }

    /// @return The address of the ERC20 token to be used
    function arkm() public view virtual returns (address) {
        return _arkm;
    }

    /// @return The fee for creating a bounty, in basis points
    function makerFee() public view virtual returns (uint256) {
        return _makerFee;
    }

    /// @return The fee for completing a bounty, in basis points
    function takerFee() public view virtual returns (uint256) {
        return _takerFee;
    }

    /// @return The stake required for a submission, in value of the ERC20 token
    function submissionStake() public view virtual returns (uint256) {
        return _submissionStake;
    }

    /// @return The duration of a bounty, in days
    function bountyDurationDays() public view virtual returns (uint64) {
        return _bountyDuration;
    }

    /// @param bounty The int representation of the UUID of the bounty
    function funder(uint256 bounty) public view virtual returns (address) {
        return _bounties[bounty].funder;
    }

    /// @param bounty The ID of the bounty
    /// @return The amount of the bounty
    function amount(uint256 bounty) public view virtual returns (uint256) {
        return _bounties[bounty].amount;
    }

    /// @param bounty The ID of the bounty
    /// @return The initial amount of the bounty
    function initialAmount(uint256 bounty) public view virtual returns (uint256) {
        return _bounties[bounty].initialAmount;
    }

    /// @param bounty The ID of the bounty
    /// @return The expiration time of the bounty
    function expiration(uint256 bounty) public view virtual returns (uint64) {
        return _bounties[bounty].expiration;
    }

    /// @param bounty The ID of the bounty
    /// @return Whether the bounty is closed or not
    /// @dev 'closed' is only true once a submission has been approved OR the bounty has been
    /// closed by the funder, which can only happen after the unlock time when there is no active
    /// submission.
    function closed(uint256 bounty) public view virtual returns (bool) {
        return _bounties[bounty].closed;
    }

    /// @param payload The payload of a submission
    /// @return Whether the payload has been rejected or not
    /// @dev This is how we keep track of which submissions have been rejected.
    function rejectedPayload(bytes32 payload) public view virtual returns (bool) {
        return _rejectedPayloads[uint256(payload)] == true;
    }

    /// @param account The account to check
    /// @return Whether the account is an approver or not
    function approver(address account) public view virtual returns (bool) {
        return _approvers[account];
    }

    /// @param bounty The ID of the bounty the submission corresponds to
    /// @param submission The ID of the submission
    /// @return Whether the submission is approved or not
    function approvedSubmission(uint256 bounty, uint256 submission) public view virtual returns (bool) {
        return isValidCurrentSubmission(bounty, submission) && closed(bounty);
    }

    /// @param bounty The ID of the bounty
    /// @return The address of the submitter of the bounty
    function submitter(uint256 bounty) public view virtual returns (address) {
        return _submissions[bounty].submitter;
    }

    /// @param bounty The ID of the bounty
    /// @return The amount of the ERC20 staked in the submission of the bounty
    /// @dev If there is no submission, this will return 0.
    function submissionStaked(uint256 bounty) public view virtual returns (uint256) {
        return _submissions[bounty].stake;
    }

    /// @return Whether the contract is accepting bounties or not
    function acceptingBounties() public view virtual returns (bool) {
        return _acceptingBounties;
    }

    /// @param value The value to calculate the fee from
    /// @param maker Whether the fee is for creating a bounty or not
    /// @return The calculated fee
    /// @dev The 10000 accounts for denomination in basis points.
    function fee(uint256 value, bool maker) public view virtual returns (uint256) {
        return value * (maker ? _makerFee : _takerFee) / 10000;
    }

    /// @notice Validates a submission for a bounty
    /// @param bounty The ID of the bounty the submission corresponds to
    /// @param submission The ID of the submission
    /// @return Whether the submission is valid or not
    /// @dev The submissionID x submitterAddress hash must match the payload of the submission.
    function isValidCurrentSubmission(uint256 bounty, uint256 submission) public view virtual returns (bool) {
        return keccak256(abi.encodePacked(submission, submitter(bounty))) == _submissions[bounty].payload;
    }

    /// @notice Modifier to require that the caller is an approver
    modifier onlyApprover() {
        require(approver(_msgSender()), "BountyV1: caller is not approver");
        _;
    }

    /// @notice Funds a bounty
    /// @param bounty The ID of the bounty to fund
    /// @param _amount The amount of the ERC20 to fund the bounty with
    /// @dev Additional bounty information like name and description is stored on an off-chain
    /// platform, e.g. Arkham. In the current implementation, Bounty records are generated
    /// on the Arkham platform and the bountyID is the int representation of the UUID of those
    /// records.
    function fundBounty(uint256 bounty, uint256 _amount) external {
        require(_acceptingBounties, "BountyV1: contract no longer accepting bounties");
        require(_amount > 0, "BountyV1: amount must be > 0");
        require(amount(bounty) == 0, "BountyV1: bounty already funded");
        require(_amount - fee(_amount, true) > _submissionStake, "BountyV1: amount after fee must be at least the submission stake");

        // Should not allow funding a bounty that is closed. However that is covered by the
        // fact that you can not fund an already funded bounty and you can not close an
        // unfunded bounty.

        _accruedFees += fee(_amount, true);

        uint64 _expiration = uint64(block.timestamp + _bountyDuration * 1 days);

        _bounties[bounty] = Bounty({
            amount: _amount - fee(_amount, true),
            initialAmount: _amount - fee(_amount, true),
            expiration: _expiration,
            funder: _msgSender(),
            closed: false
        });
        SafeERC20.safeTransferFrom(IERC20(_arkm), _msgSender(), address(this), _amount);

        emit FundBounty(
            bounty,
            _msgSender(),
            _amount,
            _expiration
        );
    }

    /// @notice Closes a bounty and returns the funds to the funder
    /// @param bounty The ID of the bounty to close
    /// @dev The bounty may be closed by anyone after the unlock time when there is no active
    /// submission. Funds are returned to the funder. Approvers can close bounties before expiration.
    function closeBounty(uint256 bounty) external {
        require(amount(bounty) > 0, "BountyV1: bounty not funded");
        require(expiration(bounty) <= block.timestamp || approver(_msgSender()), "BountyV1: only approvers can close before expiration");
        require(_submissions[bounty].submitter == address(0), "BountyV1: has active submission");
        require(!closed(bounty), "BountyV1: bounty already closed");

        /// @dev If there have been rejected submissions, the funder will receive up to their full
        /// initial funding amount. Staked funds from rejected submissions are accrued as fees.
        uint256 excessFromStaking = _bounties[bounty].amount - _bounties[bounty].initialAmount;

        _bounties[bounty].closed = true;
        SafeERC20.safeTransfer(IERC20(_arkm), _bounties[bounty].funder, _bounties[bounty].initialAmount);

        _accruedFees += excessFromStaking;

        emit CloseBounty(
            bounty,
            _bounties[bounty].funder,
            _msgSender(),
            _bounties[bounty].initialAmount,
            excessFromStaking
        );
    }

    /// @notice Makes a submission for a bounty by staking the ERC20
    /// @param bounty The ID of the bounty to make a submission to
    /// @param payload The payload of the submission, used to validate the sender's address
    /// @dev The payload is a hash of the submission ID and the submitter's address to prevent
    /// front-running. All submissions must provide a stake, which is returned if the submission
    /// is approved (less fees) or forfeit (and added to the bounty) if the submission is rejected.
    /// This is to prevent spamming of submissions.
    function makeSubmission(uint256 bounty, bytes32 payload) external {
        require(amount(bounty) > 0, "BountyV1: bounty not funded");
        // Not allowed to make submission on closed bounty but it is covered by the fact that
        // you can not close a bounty that is not expired.
        require(expiration(bounty) > block.timestamp, "BountyV1: bounty expired");
        require(submitter(bounty) == address(0), "BountyV1: submission already made");
        require(!rejectedPayload(payload), "BountyV1: payload rejected");
        require(!approver(_msgSender()), "BountyV1: approvers cannot submit");

        _submissions[bounty] = Submission({
            payload: payload,
            submitter: _msgSender(),
            stake: _submissionStake
        });
        SafeERC20.safeTransferFrom(IERC20(_arkm), _msgSender(), address(this), _submissionStake);

        emit FundSubmission(
            bounty,
            _msgSender(),
            _submissionStake,
            payload
        );
    }

    /// @notice Approves and pays out for a submission to a bounty
    /// @param bounty The ID of the bounty whose submission to approve
    /// @param submission The ID of the submission to approve
    /// @dev The bounty is paid out to the address that submitted the approved submission, plus
    /// their initial stake, less fees. The bounty is closed and will no longer receive
    /// submissions. Off-chain, the information corresponding to the submission ID is delivered to
    /// the funder.
    function approveSubmission(uint256 bounty, uint256 submission) external onlyApprover {
        require(submitter(bounty) != address(0), "BountyV1: no submission not made");
        // Approving a submission on a closed bounty is not allowed but handled by check that makes
        // it impossible to submit to a closed bounty and the check that makes it impossible to close
        // a bounty that has an active submission.
        require(isValidCurrentSubmission(bounty, submission), "BountyV1: invalid submission");
        require(submitter(bounty) != _msgSender(), "BountyV1: cannot approve own submission");

        /// @dev If there have been other rejected submissions, their stake will be reflected in
        /// the bounty amount.
        uint256 _amount = amount(bounty);
        uint256 _stake = submissionStaked(bounty);
        _accruedFees += fee(_amount, false);

        _bounties[bounty].closed = true;

        uint256 payout = _amount + _stake - fee(_amount, false);
        SafeERC20.safeTransfer(IERC20(_arkm), submitter(bounty), payout);

        emit SubmissionApproved(
            bounty,
            submitter(bounty),
            _stake,
            _submissions[bounty].payload,
            payout
        );
    }

    /// @notice Rejects a submission for a bounty
    /// @param bounty The ID of the bounty whose submission to reject
    /// @dev Only one submission may exist for a bounty at a time. Once the submission is rejected,
    /// another submission may be made, as long as it is not past the bounty's unlock time. The
    /// stake of the rejected submission is forfeit and added to the bounty amount (less fees).
    function rejectSubmission(uint256 bounty) external onlyApprover {
        require(submitter(bounty) != address(0), "BountyV1: submission not made");
        // Should not be able to reject submissions on closed bounties but you are not allowed
        // to close a bounty that has an active submission so it is covered.
        // Neither should you be able to reject a payload twice, but after it is rejected it gets
        // removed from the _subbmission mapping and thus fall under the "submission not made".

        _accruedFees += fee(_submissions[bounty].stake, true);
        _bounties[bounty].amount += _submissions[bounty].stake - fee(_submissions[bounty].stake, true);
        _rejectedPayloads[uint256(_submissions[bounty].payload)] = true;

        emit RejectSubmission(
            bounty,
            submitter(bounty),
            _submissions[bounty].stake,
            _submissions[bounty].payload
        );
        // Remove the submission that has been rejected.
        delete _submissions[bounty];
    }

    /// @notice Grants approver status to an account
    /// @param account The account to grant approver status to
    /// @dev There can be any number of approvers. Only one approver is required to approve a
    /// submission.
    function grantApprover(address account) external onlyOwner {
        require(!approver(account), "BountyV1: already approver");
        _approvers[account] = true;

        emit GrantApprover(
            account
        );
    }

    /// @notice Revokes approver status from an account
    /// @param account The account to revoke approver status from
    function revokeApprover(address account) external onlyOwner {
        require(approver(account), "BountyV1: not approver");
        _approvers[account] = false;

        emit RevokeApprover(
            account
        );
    }


    /// @notice Sets a new maker fee
    /// @param newFee The new maker fee, in basis points
    function setMakerFee(uint256 newFee) external onlyOwner {
        require(newFee <= _MAX_BPS, "BountyV1: maker fee must be <= 100%");
        uint256 _oldFee = _makerFee;
        _makerFee = newFee;

        emit SetMakerFee(
            newFee,
            _oldFee
        );
    }

    /// @notice Sets a new taker fee
    /// @param newFee The new taker fee, in basis points
    function setTakerFee(uint256 newFee) external onlyOwner {
        require(newFee <= _MAX_BPS, "BountyV1: taker fee must be <= 100%");
        uint256 _oldFee = _takerFee;
        _takerFee = newFee;

        emit SetTakerFee(
            newFee,
            _oldFee
        );
    }

    /// @notice Sets a new submission stake
    /// @param newStake The new submission stake, in value of the ERC20 token e.g. 10 e18
    function setSubmissionStake(uint256 newStake) external onlyOwner {
        uint256 _oldStake = _submissionStake;
        _submissionStake = newStake;

        emit SetSubmissionStake(
            newStake,
            _oldStake
        );
    }

    /// @notice Sets a new fee receiver address
    /// @param feeReceiverAddress The new fee receiver address
    /// @dev This is the address that will receive fees when there is a burn.
    function setFeeReceiverAddress(address feeReceiverAddress) external onlyOwner {
        require(feeReceiverAddress != address(0), "BountyV1: fee receiver address cannot be 0x0");
        _feeReceiverAddress = feeReceiverAddress;
    }

    /// @notice Prevent any further bounties from being created
    /// @dev This is how we will sunset the contract when we want to move to a new version. It's
    /// important that we continue to allow submissions to existing bounties until they all expire.
    /// Once all bounties have expired and we have approved or rejected all submissions, we can
    /// disburse any remaining fees.
    function stopAcceptingBounties() external onlyOwner {
        _acceptingBounties = false;

        emit CloseBountySubmissions();
    }

    /// @notice Burn fees and widthraw the rest
    /// @dev This can be called periodically by the owner. The burn rate is fixed. The burn
    /// fraction is in basis points.
    function withdrawFees() external onlyOwner {
        uint256 fees = _accruedFees;
        _accruedFees = 0;
        SafeERC20.safeTransfer(IERC20(_arkm), _feeReceiverAddress, fees);

        emit WithdrawFees(
            fees
        );
    }
}