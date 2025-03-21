pragma solidity >=0.5.13 <0.7.0;



import "ds-stop/stop.sol";

import "./base.sol";



contract DSDelegateToken is DSTokenBase(0), DSStop {

    // --- Variables ---

    // @notice The coin's symbol

    string public symbol;

    // @notice The coin's name

    string public name;

    /// @notice Standard token precision. Override to customize

    uint256 public decimals = 18;

    /// @notice A record of each accounts delegate

    mapping (address => address) public delegates;

    /// @notice A record of votes checkpoints for each account, by index

    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;

    /// @notice The number of checkpoints for each account

    mapping (address => uint32) public numCheckpoints;

    /// @notice A record of states for signing / validating signatures

    mapping (address => uint) public nonces;



    // --- Structs ---

    /// @notice A checkpoint for marking number of votes from a given block

    struct Checkpoint {

        uint256 fromBlock;

        uint256 votes;

    }



    // --- Constants ---

    /// @notice The EIP-712 typehash for the contract's domain

    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the delegation struct used by the contract

    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");



    // --- Events ---

    /// @notice An event that's emitted when the contract mints tokens

    event Mint(address indexed guy, uint wad);

    /// @notice An event that's emitted when the contract burns tokens

    event Burn(address indexed guy, uint wad);

    /// @notice An event that's emitted when an account changes its delegate

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /// @notice An event that's emitted when a delegate account's vote balance changes

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);



    constructor(string memory name_, string memory symbol_) public {

        name   = name_;

        symbol = symbol_;

    }



    // --- Functionality ---

    /**

     * @notice Approve an address to transfer all of your tokens

     * @param guy The address to give approval to

     */

    function approve(address guy) public stoppable returns (bool) {

        return super.approve(guy, uint(-1));

    }

    /**

     * @notice Approve an address to transfer part of your tokens

     * @param guy The address to give approval to

     * @param wad The amount of tokens to approve

     */

    function approve(address guy, uint wad) override public stoppable returns (bool) {

        return super.approve(guy, wad);

    }



    /**

     * @notice Transfer tokens from src to dst

     * @param src The address to transfer tokens from

     * @param dst The address to transfer tokens to

     * @param wad The amount of tokens to transfer

     */

    function transferFrom(address src, address dst, uint wad)

        override

        public

        stoppable

        returns (bool)

    {

        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {

            require(_approvals[src][msg.sender] >= wad, "ds-delegate-token-insufficient-approval");

            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);

        }



        require(_balances[src] >= wad, "ds-delegate-token-insufficient-balance");

        _balances[src] = sub(_balances[src], wad);

        _balances[dst] = add(_balances[dst], wad);



        emit Transfer(src, dst, wad);



        _moveDelegates(delegates[src], delegates[dst], wad);



        return true;

    }

    /**

     * @notice Transfer tokens to dst

     * @param dst The address to transfer tokens to

     * @param wad The amount of tokens to transfer

     */

    function push(address dst, uint wad) public {

        transferFrom(msg.sender, dst, wad);

    }

    /**

     * @notice Transfer tokens from src to yourself

     * @param src The address to transfer tokens frpom

     * @param wad The amount of tokens to transfer

     */

    function pull(address src, uint wad) public {

        transferFrom(src, msg.sender, wad);

    }

    /**

     * @notice Transfer tokens between two addresses

     * @param src The address to transfer tokens from

     * @param dst The address to transfer tokens to

     * @param wad The amount of tokens to transfer

     */

    function move(address src, address dst, uint wad) public {

        transferFrom(src, dst, wad);

    }



    /**

     * @notice Mint tokens for yourself

     * @param wad The amount of tokens to mint

     */

    function mint(uint wad) public {

        mint(msg.sender, wad);

    }

    /**

     * @notice Burn your own tokens

     * @param wad The amount of tokens to burn

     */

    function burn(uint wad) public {

        burn(msg.sender, wad);

    }

    /**

     * @notice Mint tokens for guy

     * @param guy The address to mint tokens for

     * @param wad The amount of tokens to mint

     */

    function mint(address guy, uint wad) public auth stoppable {

        _balances[guy] = add(_balances[guy], wad);

        _supply = add(_supply, wad);

        emit Mint(guy, wad);



        _moveDelegates(delegates[address(0)], delegates[guy], wad);

    }

    /**

     * @notice Burn guy's tokens

     * @param guy The address to burn tokens from

     * @param wad The amount of tokens to burn

     */

    function burn(address guy, uint wad) public auth stoppable {

        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {

            require(_approvals[guy][msg.sender] >= wad, "ds-delegate-token-insufficient-approval");

            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);

        }



        require(_balances[guy] >= wad, "ds-delegate-token-insufficient-balance");

        _balances[guy] = sub(_balances[guy], wad);

        _supply = sub(_supply, wad);

        emit Burn(guy, wad);



        _moveDelegates(delegates[guy], delegates[address(0)], wad);

    }



    /**

     * @notice Delegate votes from `msg.sender` to `delegatee`

     * @param delegatee The address to delegate votes to

     */

    function delegate(address delegatee) public {

        return _delegate(msg.sender, delegatee);

    }

    /**

     * @notice Delegates votes from signatory to `delegatee`

     * @param delegatee The address to delegate votes to

     * @param nonce The contract state required to match the signature

     * @param expiry The time at which to expire the signature

     * @param v The recovery byte of the signature

     * @param r Half of the ECDSA signature pair

     * @param s Half of the ECDSA signature pair

     */

    function delegateBySig(address delegatee, uint nonce, uint expiry, uint8 v, bytes32 r, bytes32 s) public {

        bytes32 domainSeparator = keccak256(abi.encode(DOMAIN_TYPEHASH, keccak256(abi.encodePacked(name)), getChainId(), address(this)));

        bytes32 structHash = keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry));

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        address signatory = ecrecover(digest, v, r, s);

        require(signatory != address(0), "ds-delegate-token-invalid-signature");

        require(nonce == nonces[signatory]++, "ds-delegate-token-invalid-nonce");

        require(now <= expiry, "ds-delegate-token-signature-expired");

        return _delegate(signatory, delegatee);

    }

    /**

     * @notice Internal function to delegate votes from `delegator` to `delegatee`

     * @param delegator The address that delegates its votes

     * @param delegatee The address to delegate votes to

     */

    function _delegate(address delegator, address delegatee) internal {

        address currentDelegate = delegates[delegator];

        delegates[delegator]    = delegatee;



        emit DelegateChanged(delegator, currentDelegate, delegatee);



        _moveDelegates(currentDelegate, delegatee, balanceOf(delegator));

    }

    function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {

        if (srcRep != dstRep && amount > 0) {

            if (srcRep != address(0)) {

                uint32 srcRepNum  = numCheckpoints[srcRep];

                uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;

                uint256 srcRepNew = sub(srcRepOld, amount);

                _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);

            }



            if (dstRep != address(0)) {

                uint32 dstRepNum  = numCheckpoints[dstRep];

                uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;

                uint256 dstRepNew = add(dstRepOld, amount);

                _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);

            }

        }

    }

    function _writeCheckpoint(address delegatee, uint32 nCheckpoints, uint256 oldVotes, uint256 newVotes) internal {

        uint blockNumber = block.number;



        if (nCheckpoints > 0 && checkpoints[delegatee][nCheckpoints - 1].fromBlock == blockNumber) {

            checkpoints[delegatee][nCheckpoints - 1].votes = newVotes;

        } else {

            checkpoints[delegatee][nCheckpoints] = Checkpoint(blockNumber, newVotes);

            numCheckpoints[delegatee] = nCheckpoints + 1;

        }



        emit DelegateVotesChanged(delegatee, oldVotes, newVotes);

    }



    /**

     * @notice Gets the current votes balance for `account`

     * @param account The address to get votes balance

     * @return The number of current votes for `account`

     */

    function getCurrentVotes(address account) external view returns (uint256) {

        uint32 nCheckpoints = numCheckpoints[account];

        return nCheckpoints > 0 ? checkpoints[account][nCheckpoints - 1].votes : 0;

    }



    /**

     * @notice Determine the prior number of votes for an account as of a block number

     * @dev Block number must be a finalized block or else this function will revert to prevent misinformation.

     * @param account The address of the account to check

     * @param blockNumber The block number to get the vote balance at

     * @return The number of votes the account had as of the given block

     */

    function getPriorVotes(address account, uint blockNumber) public view returns (uint256) {

        require(blockNumber < block.number, "ds-delegate-token-not-yet-determined");



        uint32 nCheckpoints = numCheckpoints[account];

        if (nCheckpoints == 0) {

            return 0;

        }



        // First check most recent balance

        if (checkpoints[account][nCheckpoints - 1].fromBlock <= blockNumber) {

            return checkpoints[account][nCheckpoints - 1].votes;

        }



        // Next check implicit zero balance

        if (checkpoints[account][0].fromBlock > blockNumber) {

            return 0;

        }



        uint32 lower = 0;

        uint32 upper = nCheckpoints - 1;

        while (upper > lower) {

            uint32 center = upper - (upper - lower) / 2; // ceil, avoiding overflow

            Checkpoint memory cp = checkpoints[account][center];

            if (cp.fromBlock == blockNumber) {

                return cp.votes;

            } else if (cp.fromBlock < blockNumber) {

                lower = center;

            } else {

                upper = center - 1;

            }

        }

        return checkpoints[account][lower].votes;

    }



    /**

    * @notice Fetch the chain ID

    **/

    function getChainId() internal pure returns (uint) {

        uint256 chainId;

        assembly { chainId := chainid() }

        return chainId;

    }

}