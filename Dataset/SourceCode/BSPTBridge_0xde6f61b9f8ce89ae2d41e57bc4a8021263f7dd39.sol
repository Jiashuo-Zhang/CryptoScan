// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./utils/AccessControl.sol";
import "./interfaces/IDepositExecute.sol";
import "./interfaces/IERCHandler.sol";
import "./interfaces/IGenericHandler.sol";

/**
    @title Facilitates deposits, creation and voting of deposit proposals, and deposit executions.
    @author Stafi Protocol.
 */
contract BSPTBridge is Pausable, AccessControl {
    using SafeCast for *;

    // Limit relayers number because proposal can fit only so much votes
    uint256 constant public MAX_RELAYERS = 200;

    uint8 public _chainID;
    uint8 public _relayerThreshold;
    uint128 public _fee;
    address payable _feeRecipient;
    uint40 public _expiry;

    enum ProposalStatus {Inactive, Active, Executed, Cancelled}

    struct Proposal {
        ProposalStatus _status;
        uint200 _yesVotes;      // bitmap, 200 maximum votes
        uint8 _yesVotesTotal;
        uint40 _proposedBlock; // 1099511627775 maximum block
    }

    // destinationChainID => number of deposits
    mapping(uint8 => uint64) public _depositCounts;

    // resourceID => handler address
    mapping(bytes32 => address) public _resourceIDToHandlerAddress;

    // destinationChainID + depositNonce => dataHash => Proposal
    mapping(uint72 => mapping(bytes32 => Proposal)) public _proposals;

    // original deposit ChainID => oldDepositNonce
    mapping(uint8 => uint64)  public _oldDepositNonce;

    event RelayerThresholdChanged(uint256 indexed newThreshold);

    event RelayerAdded(address indexed relayer);

    event RelayerRemoved(address indexed relayer);

    event Deposit(
        uint8 indexed destinationChainID,
        bytes32 indexed resourceID,
        uint64 indexed depositNonce
    );

    event ProposalEvent(
        uint8 indexed originChainID,
        uint64 indexed depositNonce,
        ProposalStatus indexed status,
        bytes32 dataHash
    );

    event ProposalVote(
        uint8 indexed originChainID,
        uint64 indexed depositNonce,
        ProposalStatus indexed status,
        bytes32 dataHash
    );

    bytes32 public constant RELAYER_ROLE = keccak256("RELAYER_ROLE");

    modifier onlyAdmin() {
        _onlyAdmin();
        _;
    }

    modifier onlyAdminOrRelayer() {
        _onlyAdminOrRelayer();
        _;
    }

    modifier onlyRelayers() {
        _onlyRelayers();
        _;
    }

    function _onlyAdminOrRelayer() private view {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender) || hasRole(RELAYER_ROLE, msg.sender),
            "sender is not relayer or admin");
    }

    function _onlyAdmin() private view {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "sender doesn't have admin role");
    }

    function _onlyRelayers() private view {
        require(hasRole(RELAYER_ROLE, msg.sender), "sender doesn't have relayer role");
    }

    function _relayerBit(address relayer) private view returns (uint) {
        return uint(1) << (AccessControl.getRoleMemberIndex(RELAYER_ROLE, relayer));
    }

    function _hasVoted(Proposal memory proposal, address relayer) private view returns (bool) {
        return (_relayerBit(relayer) & uint(proposal._yesVotes)) > 0;
    }

    /**
        @notice Initializes Bridge, creates and grants {msg.sender} the admin role,
        creates and grants {initialRelayers} the relayer role.
        @param chainID ID of chain the Bridge contract exists on.
        @param initialRelayers Addresses that should be initially granted the relayer role.
        @param initialRelayerThreshold Number of votes needed for a deposit proposal to be considered passed.
     */
    constructor (address defaultAdmin, uint8 chainID, address[] memory initialRelayers, uint256 initialRelayerThreshold, uint256 fee, uint256 expiry, address feeRecipient) {
        _chainID = chainID;
        _relayerThreshold = initialRelayerThreshold.toUint8();
        _fee = fee.toUint128();
        _feeRecipient = payable(feeRecipient);
        _expiry = expiry.toUint40();

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        uint256 initialRelayerCount = initialRelayers.length;
        for (uint256 i; i < initialRelayerCount; i++) {
            grantRole(RELAYER_ROLE, initialRelayers[i]);
        }
        _setupRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    /**
        @notice Returns true if {relayer} has voted on {destNonce} {dataHash} proposal.
        @notice Naming left unchanged for backward compatibility.
        @param destNonce destinationChainID + depositNonce of the proposal.
        @param dataHash Hash of data to be provided when deposit proposal is executed.
        @param relayer Address to check.
     */
    function _hasVotedOnProposal(uint72 destNonce, bytes32 dataHash, address relayer) public view returns (bool) {
        return _hasVoted(_proposals[destNonce][dataHash], relayer);
    }

    /**
        @notice Returns true if {relayer} has the relayer role.
        @param relayer Address to check.
     */
    function isRelayer(address relayer) external view returns (bool) {
        return hasRole(RELAYER_ROLE, relayer);
    }

    /**
        @notice Removes admin role from {msg.sender} and grants it to {newAdmin}.
        @notice Only callable by an address that currently has the admin role.
        @param newAdmin Address that admin role will be granted to.
     */
    function renounceAdmin(address newAdmin) external onlyAdmin {
        require(msg.sender != newAdmin, 'Cannot renounce oneself');
        grantRole(DEFAULT_ADMIN_ROLE, newAdmin);
        renounceRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
        @notice Pauses deposits, proposal creation and voting, and deposit executions.
        @notice Only callable by an address that currently has the admin role.
     */
    function adminPauseTransfers() external onlyAdmin {
        _pause();
    }

    /**
        @notice Unpauses deposits, proposal creation and voting, and deposit executions.
        @notice Only callable by an address that currently has the admin role.
     */
    function adminUnpauseTransfers() external onlyAdmin {
        _unpause();
    }

    /**
        @notice Modifies the number of votes required for a proposal to be considered passed.
        @notice Only callable by an address that currently has the admin role.
        @param newThreshold Value {_relayerThreshold} will be changed to.
        @notice Emits {RelayerThresholdChanged} event.
     */
    function adminChangeRelayerThreshold(uint256 newThreshold) external onlyAdmin {
        _relayerThreshold = newThreshold.toUint8();
        emit RelayerThresholdChanged(newThreshold);
    }

    function adminSetOldDepositNonce(uint8 chainId, uint64 oldDepositNonce) external onlyAdmin {
        _oldDepositNonce[chainId] = oldDepositNonce;
    }

    function adminSetDepositCount(uint8 chainId, uint64 depositCount) external onlyAdmin {
        _depositCounts[chainId] = depositCount;
    }

    function adminSetResourceAndBurnable(
        address handlerAddress,
        bytes32[] memory resourceIDs,
        address[] memory tokenContractAddresses,
        address[] memory burnablTokenContractAddresses) external onlyAdmin {

        uint256 resourceIDsLength = resourceIDs.length;
        uint256 burnableContractAddressesLength = burnablTokenContractAddresses.length;
        require(resourceIDsLength == tokenContractAddresses.length,
            "resourceIDs and tokenContractAddresses len mismatch");

        IERCHandler handler = IERCHandler(handlerAddress);

        for (uint256 i = 0; i < resourceIDsLength; i++) {
            _resourceIDToHandlerAddress[resourceIDs[i]] = handlerAddress;
            handler.setResource(resourceIDs[i], tokenContractAddresses[i]);
        }

        for (uint256 i = 0; i < burnableContractAddressesLength; i++) {
            handler.setBurnable(burnablTokenContractAddresses[i]);
        }
    }

    /**
        @notice Grants {relayerAddress} the relayer role.
        @notice Only callable by an address that currently has the admin role, which is
                checked in grantRole().
        @param relayerAddress Address of relayer to be added.
        @notice Emits {RelayerAdded} event.
     */
    function adminAddRelayer(address relayerAddress) external {
        require(!hasRole(RELAYER_ROLE, relayerAddress), "addr already has relayer role!");
        require(_totalRelayers() < MAX_RELAYERS, "relayers limit reached");
        grantRole(RELAYER_ROLE, relayerAddress);
        emit RelayerAdded(relayerAddress);
    }

    /**
        @notice Removes relayer role for {relayerAddress}.
        @notice Only callable by an address that currently has the admin role, which is
                checked in revokeRole().
        @param relayerAddress Address of relayer to be removed.
        @notice Emits {RelayerRemoved} event.
     */
    function adminRemoveRelayer(address relayerAddress) external {
        require(hasRole(RELAYER_ROLE, relayerAddress), "addr doesn't have relayer role!");
        revokeRole(RELAYER_ROLE, relayerAddress);
        emit RelayerRemoved(relayerAddress);
    }

    /**
        @notice Sets a new resource for handler contracts that use the IGenericHandler interface,
        and maps the {handlerAddress} to {resourceID} in {_resourceIDToHandlerAddress}.
        @notice Only callable by an address that currently has the admin role.
        @param handlerAddress Address of handler resource will be set for.
        @param resourceID ResourceID to be used when making deposits.
        @param contractAddress Address of contract to be called when a deposit is made and a deposited is executed.
     */
    function adminSetGenericResource(
        address handlerAddress,
        bytes32 resourceID,
        address contractAddress,
        bytes4 depositFunctionSig,
        uint256 depositFunctionDepositerOffset,
        bytes4 executeFunctionSig
    ) external onlyAdmin {
        _resourceIDToHandlerAddress[resourceID] = handlerAddress;
        IGenericHandler handler = IGenericHandler(handlerAddress);
        handler.setResource(resourceID, contractAddress, depositFunctionSig, depositFunctionDepositerOffset, executeFunctionSig);
    }

    /**
        @notice Returns a proposal.
        @param originChainID Chain ID deposit originated from.
        @param depositNonce ID of proposal generated by proposal's origin Bridge contract.
        @param dataHash Hash of data to be provided when deposit proposal is executed.
        @return Proposal which consists of:
        - _dataHash Hash of data to be provided when deposit proposal is executed.
        - _yesVotes Number of votes in favor of proposal.
        - _noVotes Number of votes against proposal.
        - _status Current status of proposal.
     */
    function getProposal(uint8 originChainID, uint64 depositNonce, bytes32 dataHash) external view returns (Proposal memory) {
        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint72(originChainID);
        return _proposals[nonceAndID][dataHash];
    }

    /**
        @notice Returns total relayers number.
        @notice Added for backwards compatibility.
     */
    function _totalRelayers() public view returns (uint) {
        return AccessControl.getRoleMemberCount(RELAYER_ROLE);
    }

    /**
        @notice Changes deposit fee.
        @notice Only callable by admin.
        @param newFee Value {_fee} will be updated to.
     */
    function adminChangeFee(uint256 newFee) external onlyAdmin {
        require(_fee != newFee, "Current fee is equal to new fee");
        _fee = newFee.toUint128();
    }

    /**
        @notice Used to manually withdraw funds from ERC safes.
        @param handlerAddress Address of handler to withdraw from.
        @param tokenAddress Address of token to withdraw.
        @param recipient Address to withdraw tokens to.
        @param amountOrTokenID Either the amount of ERC20 tokens or the ERC721 token ID to withdraw.
     */
    function adminWithdraw(
        address handlerAddress,
        address tokenAddress,
        address recipient,
        uint256 amountOrTokenID
    ) external onlyAdmin {
        IERCHandler handler = IERCHandler(handlerAddress);
        handler.withdraw(tokenAddress, recipient, amountOrTokenID);
    }

    /**
        @notice Initiates a transfer using a specified handler contract.
        @notice Only callable when Bridge is not paused.
        @param destinationChainID ID of chain deposit will be bridged to.
        @param resourceID ResourceID used to find address of handler to be used for deposit.
        @param data Additional data to be passed to specified handler.
        @notice Emits {Deposit} event.
     */
    function deposit(uint8 destinationChainID, bytes32 resourceID, bytes calldata data) external payable whenNotPaused {
        require(msg.value == _fee, "Incorrect fee supplied");
        require(destinationChainID != _chainID, "destinationChainID cannot be equal to chainID");

        // Transfer fee to _feeRecipient
        _feeRecipient.transfer(_fee);

        address handler = _resourceIDToHandlerAddress[resourceID];
        require(handler != address(0), "resourceID not mapped to handler");

        uint64 depositNonce = ++_depositCounts[destinationChainID];

        IDepositExecute depositHandler = IDepositExecute(handler);
        depositHandler.deposit(resourceID, destinationChainID, depositNonce, msg.sender, data);

        emit Deposit(destinationChainID, resourceID, depositNonce);
    }

    /**
        @notice When called, {msg.sender} will be marked as voting in favor of proposal.
        @notice Only callable by relayers when Bridge is not paused.
        @param chainID ID of chain deposit originated from.
        @param depositNonce ID of deposited generated by origin Bridge contract.
        @param data Data originally provided when deposit was made.
        @notice Proposal must not have already been passed or executed.
        @notice {msg.sender} must not have already voted on proposal.
        @notice Emits {ProposalEvent} event with status indicating the proposal status.
        @notice Emits {ProposalVote} event.
     */
    function voteProposal(uint8 chainID, uint64 depositNonce, bytes32 resourceID, bytes calldata data) external onlyRelayers whenNotPaused {
        address handler = _resourceIDToHandlerAddress[resourceID];
        bytes32 dataHash = keccak256(abi.encodePacked(handler, data));
        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint72(chainID);
        Proposal memory proposal = _proposals[nonceAndID][dataHash];

        require(depositNonce > _oldDepositNonce[chainID], "depositNoce is old");
        require(handler != address(0), "no handler for resourceID");
        require(uint(proposal._status) <= 1, "proposal already executed/cancelled");
        require(!_hasVoted(proposal, msg.sender), "relayer already voted");

        if (proposal._status == ProposalStatus.Inactive) {
            proposal = Proposal({
                _status: ProposalStatus.Active,
                _yesVotes: 0,
                _yesVotesTotal: 0,
                _proposedBlock: uint40(block.number) // Overflow is desired.
            });
            emit ProposalEvent(chainID, depositNonce, ProposalStatus.Active, dataHash);
        } else if (uint40(block.number - proposal._proposedBlock) > _expiry) {
            // if the number of blocks that has passed since this proposal was
            // submitted exceeds the expiry threshold set, cancel the proposal
            proposal._status = ProposalStatus.Cancelled;
            emit ProposalEvent(chainID, depositNonce, ProposalStatus.Cancelled, dataHash);
        }

        if (proposal._status != ProposalStatus.Cancelled) {
            proposal._yesVotes = (proposal._yesVotes | _relayerBit(msg.sender)).toUint200();
            proposal._yesVotesTotal++; // TODO: check if bit counting is cheaper.
            emit ProposalVote(chainID, depositNonce, proposal._status, dataHash);

            // Finalize if _relayerThreshold has been reached
            if (proposal._yesVotesTotal >= _relayerThreshold) {
                proposal._status = ProposalStatus.Executed;

                IDepositExecute depositHandler = IDepositExecute(handler);
                depositHandler.executeProposal(resourceID, data);

                emit ProposalEvent(chainID, depositNonce, ProposalStatus.Executed, dataHash);
            }
        }
        _proposals[nonceAndID][dataHash] = proposal;

    }

    /**
        @notice Cancels a deposit proposal that has not been executed yet.
        @notice Only callable by relayers when Bridge is not paused.
        @param chainID ID of chain deposit originated from.
        @param depositNonce ID of deposited generated by origin Bridge contract.
        @param dataHash Hash of data originally provided when deposit was made.
        @notice Proposal must be past expiry threshold.
        @notice Emits {ProposalEvent} event with status {Cancelled}.
     */
    function cancelProposal(uint8 chainID, uint64 depositNonce, bytes32 dataHash) public onlyAdminOrRelayer {
        uint72 nonceAndID = (uint72(depositNonce) << 8) | uint72(chainID);
        Proposal memory proposal = _proposals[nonceAndID][dataHash];
        ProposalStatus currentStatus = proposal._status;

        require(currentStatus == ProposalStatus.Active,
            "Proposal cannot be cancelled");
        require(uint40(block.number - proposal._proposedBlock) > _expiry, "Proposal not at expiry threshold");

        proposal._status = ProposalStatus.Cancelled;
        _proposals[nonceAndID][dataHash] = proposal;
        emit ProposalEvent(chainID, depositNonce, ProposalStatus.Cancelled, dataHash);
    }

    /**
        @notice Transfers eth in the contract to the specified addresses. The parameters addrs and amounts are mapped 1-1.
        This means that the address at index 0 for addrs will receive the amount (in WEI) from amounts at index 0.
        @param addrs Array of addresses to transfer {amounts} to.
        @param amounts Array of amonuts to transfer to {addrs}.
     */
    function transferFunds(address payable[] calldata addrs, uint[] calldata amounts) external onlyAdmin {
        uint256 addrCount = addrs.length;
        for (uint256 i = 0; i < addrCount; i++) {
            addrs[i].transfer(amounts[i]);
        }
    }

}