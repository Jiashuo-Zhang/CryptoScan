/**

 *Submitted for verification at Etherscan.io on 2020-10-22

*/



// pragma solidity ^0.5.6;



// /**

//  * @dev A registrar controller for registering and renewing names at fixed cost.

//  */

// contract ETHRegistrarController {



//     uint constant public MIN_REGISTRATION_DURATION = 28 days;



//     uint public minCommitmentAge;

//     uint public maxCommitmentAge;



//     mapping(bytes32=>uint) public commitments;



//     event NameRegistered(string name, bytes32 indexed label, address indexed owner, uint cost, uint expires);

//     event NameRenewed(string name, bytes32 indexed label, uint cost, uint expires);

//     event NewPriceOracle(address indexed oracle);



//     function rentPrice(string memory name, uint duration) view public returns(uint);



//     function valid(string memory name) public view returns(bool);



//     function available(string memory name) public view returns(bool);



//     function makeCommitment(string memory name, address owner, bytes32 secret) pure public returns(bytes32);



//     function commit(bytes32 commitment) public;



//     function register(string calldata name, address owner, uint duration, bytes32 secret) external payable;



//     function renew(string calldata name, uint duration) external payable;



//     function supportsInterface(bytes4 interfaceID) external pure returns (bool);

// }



/**

 * Source Code first verified at https://etherscan.io on Tuesday, April 30, 2019

 (UTC) */



// File: contracts/PriceOracle.sol



pragma solidity >=0.4.24;



interface PriceOracle {

    /**

     * @dev Returns the price to register or renew a name.

     * @param name The name being registered or renewed.

     * @param expires When the name presently expires (0 if this is a new registration).

     * @param duration How long the name is being registered or extended for, in seconds.

     * @return The price of this renewal or registration, in wei.

     */

    function price(string calldata name, uint expires, uint duration) external view returns(uint);

}



// File: @ensdomains/ens/contracts/ENS.sol



pragma solidity >=0.4.24;



interface ENS {



    // Logged when the owner of a node assigns a new owner to a subnode.

    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);



    // Logged when the owner of a node transfers ownership to a new account.

    event Transfer(bytes32 indexed node, address owner);



    // Logged when the resolver for a node changes.

    event NewResolver(bytes32 indexed node, address resolver);



    // Logged when the TTL of a node changes

    event NewTTL(bytes32 indexed node, uint64 ttl);





    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);



}



// File: @ensdomains/ens/contracts/Deed.sol



pragma solidity >=0.4.24;



interface Deed {



    function setOwner(address payable newOwner) external;

    function setRegistrar(address newRegistrar) external;

    function setBalance(uint newValue, bool throwOnFailure) external;

    function closeDeed(uint refundRatio) external;

    function destroyDeed() external;



    function owner() external view returns (address);

    function previousOwner() external view returns (address);

    function value() external view returns (uint);

    function creationDate() external view returns (uint);



}



// File: @ensdomains/ens/contracts/DeedImplementation.sol



pragma solidity ^0.5.0;





/**

 * @title Deed to hold ether in exchange for ownership of a node

 * @dev The deed can be controlled only by the registrar and can only send ether back to the owner.

 */

contract DeedImplementation is Deed {



    address payable constant burn = address(0xdead);



    address payable private _owner;

    address private _previousOwner;

    address private _registrar;



    uint private _creationDate;

    uint private _value;



    bool active;



    event OwnerChanged(address newOwner);

    event DeedClosed();



    modifier onlyRegistrar {

        require(msg.sender == _registrar);

        _;

    }



    modifier onlyActive {

        require(active);

        _;

    }



    constructor(address payable initialOwner) public payable {

        _owner = initialOwner;

        _registrar = msg.sender;

        _creationDate = now;

        active = true;

        _value = msg.value;

    }



    function setOwner(address payable newOwner) external onlyRegistrar {

        require(newOwner != address(0x0));

        _previousOwner = _owner;  // This allows contracts to check who sent them the ownership

        _owner = newOwner;

        emit OwnerChanged(newOwner);

    }



    function setRegistrar(address newRegistrar) external onlyRegistrar {

        _registrar = newRegistrar;

    }



    function setBalance(uint newValue, bool throwOnFailure) external onlyRegistrar onlyActive {

        // Check if it has enough balance to set the value

        require(_value >= newValue);

        _value = newValue;

        // Send the difference to the owner

        require(_owner.send(address(this).balance - newValue) || !throwOnFailure);

    }



    /**

     * @dev Close a deed and refund a specified fraction of the bid value

     *

     * @param refundRatio The amount*1/1000 to refund

     */

    function closeDeed(uint refundRatio) external onlyRegistrar onlyActive {

        active = false;

        require(burn.send(((1000 - refundRatio) * address(this).balance)/1000));

        emit DeedClosed();

        _destroyDeed();

    }



    /**

     * @dev Close a deed and refund a specified fraction of the bid value

     */

    function destroyDeed() external {

        _destroyDeed();

    }



    function owner() external view returns (address) {

        return _owner;

    }



    function previousOwner() external view returns (address) {

        return _previousOwner;

    }



    function value() external view returns (uint) {

        return _value;

    }



    function creationDate() external view returns (uint) {

        _creationDate;

    }



    function _destroyDeed() internal {

        require(!active);



        // Instead of selfdestruct(owner), invoke owner fallback function to allow

        // owner to log an event if desired; but owner should also be aware that

        // its fallback function can also be invoked by setBalance

        if (_owner.send(address(this).balance)) {

            selfdestruct(burn);

        }

    }

}



// File: @ensdomains/ens/contracts/Registrar.sol



pragma solidity >=0.4.24;





interface Registrar {



    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }



    event AuctionStarted(bytes32 indexed hash, uint registrationDate);

    event NewBid(bytes32 indexed hash, address indexed bidder, uint deposit);

    event BidRevealed(bytes32 indexed hash, address indexed owner, uint value, uint8 status);

    event HashRegistered(bytes32 indexed hash, address indexed owner, uint value, uint registrationDate);

    event HashReleased(bytes32 indexed hash, uint value);

    event HashInvalidated(bytes32 indexed hash, string indexed name, uint value, uint registrationDate);



    function startAuction(bytes32 _hash) external;

    function startAuctions(bytes32[] calldata _hashes) external;

    function newBid(bytes32 sealedBid) external payable;

    function startAuctionsAndBid(bytes32[] calldata hashes, bytes32 sealedBid) external payable;

    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) external;

    function cancelBid(address bidder, bytes32 seal) external;

    function finalizeAuction(bytes32 _hash) external;

    function transfer(bytes32 _hash, address payable newOwner) external;

    function releaseDeed(bytes32 _hash) external;

    function invalidateName(string calldata unhashedName) external;

    function eraseNode(bytes32[] calldata labels) external;

    function transferRegistrars(bytes32 _hash) external;

    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) external;

    function entries(bytes32 _hash) external view returns (Mode, address, uint, uint, uint);

}



// File: @ensdomains/ens/contracts/HashRegistrar.sol



pragma solidity ^0.5.0;





/*



Temporary Hash Registrar

========================



This is a simplified version of a hash registrar. It is purporsefully limited:

names cannot be six letters or shorter, new auctions will stop after 4 years.



The plan is to test the basic features and then move to a new contract in at most

2 years, when some sort of renewal mechanism will be enabled.

*/









/**

 * @title Registrar

 * @dev The registrar handles the auction process for each subnode of the node it owns.

 */

contract HashRegistrar is Registrar {

    ENS public ens;

    bytes32 public rootNode;



    mapping (bytes32 => Entry) _entries;

    mapping (address => mapping (bytes32 => Deed)) public sealedBids;



    uint32 constant totalAuctionLength = 5 days;

    uint32 constant revealPeriod = 48 hours;

    uint32 public constant launchLength = 8 weeks;



    uint constant minPrice = 0.01 ether;

    uint public registryStarted;



    struct Entry {

        Deed deed;

        uint registrationDate;

        uint value;

        uint highestBid;

    }



    modifier inState(bytes32 _hash, Mode _state) {

        require(state(_hash) == _state);

        _;

    }



    modifier onlyOwner(bytes32 _hash) {

        require(state(_hash) == Mode.Owned && msg.sender == _entries[_hash].deed.owner());

        _;

    }



    modifier registryOpen() {

        require(now >= registryStarted && now <= registryStarted + (365 * 4) * 1 days && ens.owner(rootNode) == address(this));

        _;

    }



    /**

     * @dev Constructs a new Registrar, with the provided address as the owner of the root node.

     *

     * @param _ens The address of the ENS

     * @param _rootNode The hash of the rootnode.

     */

    constructor(ENS _ens, bytes32 _rootNode, uint _startDate) public {

        ens = _ens;

        rootNode = _rootNode;

        registryStarted = _startDate > 0 ? _startDate : now;

    }



    /**

     * @dev Start an auction for an available hash

     *

     * @param _hash The hash to start an auction on

     */

    function startAuction(bytes32 _hash) external {

        _startAuction(_hash);

    }



    /**

     * @dev Start multiple auctions for better anonymity

     *

     * Anyone can start an auction by sending an array of hashes that they want to bid for.

     * Arrays are sent so that someone can open up an auction for X dummy hashes when they

     * are only really interested in bidding for one. This will increase the cost for an

     * attacker to simply bid blindly on all new auctions. Dummy auctions that are

     * open but not bid on are closed after a week.

     *

     * @param _hashes An array of hashes, at least one of which you presumably want to bid on

     */

    function startAuctions(bytes32[] calldata _hashes) external {

        _startAuctions(_hashes);

    }



    /**

     * @dev Submit a new sealed bid on a desired hash in a blind auction

     *

     * Bids are sent by sending a message to the main contract with a hash and an amount. The hash

     * contains information about the bid, including the bidded hash, the bid amount, and a random

     * salt. Bids are not tied to any one auction until they are revealed. The value of the bid

     * itself can be masqueraded by sending more than the value of your actual bid. This is

     * followed by a 48h reveal period. Bids revealed after this period will be burned and the ether unrecoverable.

     * Since this is an auction, it is expected that most public hashes, like known domains and common dictionary

     * words, will have multiple bidders pushing the price up.

     *

     * @param sealedBid A sealedBid, created by the shaBid function

     */

    function newBid(bytes32 sealedBid) external payable {

        _newBid(sealedBid);

    }



    /**

     * @dev Start a set of auctions and bid on one of them

     *

     * This method functions identically to calling `startAuctions` followed by `newBid`,

     * but all in one transaction.

     *

     * @param hashes A list of hashes to start auctions on.

     * @param sealedBid A sealed bid for one of the auctions.

     */

    function startAuctionsAndBid(bytes32[] calldata hashes, bytes32 sealedBid) external payable {

        _startAuctions(hashes);

        _newBid(sealedBid);

    }



    /**

     * @dev Submit the properties of a bid to reveal them

     *

     * @param _hash The node in the sealedBid

     * @param _value The bid amount in the sealedBid

     * @param _salt The sale in the sealedBid

     */

    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) external {

        bytes32 seal = shaBid(_hash, msg.sender, _value, _salt);

        Deed bid = sealedBids[msg.sender][seal];

        require(address(bid) != address(0x0));



        sealedBids[msg.sender][seal] = Deed(address(0x0));

        Entry storage h = _entries[_hash];

        uint value = min(_value, bid.value());

        bid.setBalance(value, true);



        Mode auctionState = state(_hash);

        if (auctionState == Mode.Owned) {

            // Too late! Bidder loses their bid. Gets 0.5% back.

            bid.closeDeed(5);

            emit BidRevealed(_hash, msg.sender, value, 1);

        } else if (auctionState != Mode.Reveal) {

            // Invalid phase

            revert();

        } else if (value < minPrice || bid.creationDate() > h.registrationDate - revealPeriod) {

            // Bid too low or too late, refund 99.5%

            bid.closeDeed(995);

            emit BidRevealed(_hash, msg.sender, value, 0);

        } else if (value > h.highestBid) {

            // New winner

            // Cancel the other bid, refund 99.5%

            if (address(h.deed) != address(0x0)) {

                Deed previousWinner = h.deed;

                previousWinner.closeDeed(995);

            }



            // Set new winner

            // Per the rules of a vickery auction, the value becomes the previous highestBid

            h.value = h.highestBid;  // will be zero if there's only 1 bidder

            h.highestBid = value;

            h.deed = bid;

            emit BidRevealed(_hash, msg.sender, value, 2);

        } else if (value > h.value) {

            // Not winner, but affects second place

            h.value = value;

            bid.closeDeed(995);

            emit BidRevealed(_hash, msg.sender, value, 3);

        } else {

            // Bid doesn't affect auction

            bid.closeDeed(995);

            emit BidRevealed(_hash, msg.sender, value, 4);

        }

    }



    /**

     * @dev Cancel a bid

     *

     * @param seal The value returned by the shaBid function

     */

    function cancelBid(address bidder, bytes32 seal) external {

        Deed bid = sealedBids[bidder][seal];

        

        // If a sole bidder does not `unsealBid` in time, they have a few more days

        // where they can call `startAuction` (again) and then `unsealBid` during

        // the revealPeriod to get back their bid value.

        // For simplicity, they should call `startAuction` within

        // 9 days (2 weeks - totalAuctionLength), otherwise their bid will be

        // cancellable by anyone.

        require(address(bid) != address(0x0) && now >= bid.creationDate() + totalAuctionLength + 2 weeks);



        // Send the canceller 0.5% of the bid, and burn the rest.

        bid.setOwner(msg.sender);

        bid.closeDeed(5);

        sealedBids[bidder][seal] = Deed(0);

        emit BidRevealed(seal, bidder, 0, 5);

    }



    /**

     * @dev Finalize an auction after the registration date has passed

     *

     * @param _hash The hash of the name the auction is for

     */

    function finalizeAuction(bytes32 _hash) external onlyOwner(_hash) {

        Entry storage h = _entries[_hash];

        

        // Handles the case when there's only a single bidder (h.value is zero)

        h.value = max(h.value, minPrice);

        h.deed.setBalance(h.value, true);



        trySetSubnodeOwner(_hash, h.deed.owner());

        emit HashRegistered(_hash, h.deed.owner(), h.value, h.registrationDate);

    }



    /**

     * @dev The owner of a domain may transfer it to someone else at any time.

     *

     * @param _hash The node to transfer

     * @param newOwner The address to transfer ownership to

     */

    function transfer(bytes32 _hash, address payable newOwner) external onlyOwner(_hash) {

        require(newOwner != address(0x0));



        Entry storage h = _entries[_hash];

        h.deed.setOwner(newOwner);

        trySetSubnodeOwner(_hash, newOwner);

    }



    /**

     * @dev After some time, or if we're no longer the registrar, the owner can release

     *      the name and get their ether back.

     *

     * @param _hash The node to release

     */

    function releaseDeed(bytes32 _hash) external onlyOwner(_hash) {

        Entry storage h = _entries[_hash];

        Deed deedContract = h.deed;



        require(now >= h.registrationDate + 365 days || ens.owner(rootNode) != address(this));



        h.value = 0;

        h.highestBid = 0;

        h.deed = Deed(0);



        _tryEraseSingleNode(_hash);

        deedContract.closeDeed(1000);

        emit HashReleased(_hash, h.value);        

    }



    /**

     * @dev Submit a name 6 characters long or less. If it has been registered,

     *      the submitter will earn 50% of the deed value. 

     * 

     * We are purposefully handicapping the simplified registrar as a way 

     * to force it into being restructured in a few years.

     *

     * @param unhashedName An invalid name to search for in the registry.

     */

    function invalidateName(string calldata unhashedName)

        external

        inState(keccak256(abi.encode(unhashedName)), Mode.Owned)

    {

        require(strlen(unhashedName) <= 6);

        bytes32 hash = keccak256(abi.encode(unhashedName));



        Entry storage h = _entries[hash];



        _tryEraseSingleNode(hash);



        if (address(h.deed) != address(0x0)) {

            // Reward the discoverer with 50% of the deed

            // The previous owner gets 50%

            h.value = max(h.value, minPrice);

            h.deed.setBalance(h.value/2, false);

            h.deed.setOwner(msg.sender);

            h.deed.closeDeed(1000);

        }



        emit HashInvalidated(hash, unhashedName, h.value, h.registrationDate);



        h.value = 0;

        h.highestBid = 0;

        h.deed = Deed(0);

    }



    /**

     * @dev Allows anyone to delete the owner and resolver records for a (subdomain of) a

     *      name that is not currently owned in the registrar. If passing, eg, 'foo.bar.eth',

     *      the owner and resolver fields on 'foo.bar.eth' and 'bar.eth' will all be cleared.

     *

     * @param labels A series of label hashes identifying the name to zero out, rooted at the

     *        registrar's root. Must contain at least one element. For instance, to zero 

     *        'foo.bar.eth' on a registrar that owns '.eth', pass an array containing

     *        [keccak256('foo'), keccak256('bar')].

     */

    function eraseNode(bytes32[] calldata labels) external {

        require(labels.length != 0);

        require(state(labels[labels.length - 1]) != Mode.Owned);



        _eraseNodeHierarchy(labels.length - 1, labels, rootNode);

    }



    /**

     * @dev Transfers the deed to the current registrar, if different from this one.

     *

     * Used during the upgrade process to a permanent registrar.

     *

     * @param _hash The name hash to transfer.

     */

    function transferRegistrars(bytes32 _hash) external onlyOwner(_hash) {

        address registrar = ens.owner(rootNode);

        require(registrar != address(this));



        // Migrate the deed

        Entry storage h = _entries[_hash];

        h.deed.setRegistrar(registrar);



        // Call the new registrar to accept the transfer

        Registrar(registrar).acceptRegistrarTransfer(_hash, h.deed, h.registrationDate);



        // Zero out the Entry

        h.deed = Deed(0);

        h.registrationDate = 0;

        h.value = 0;

        h.highestBid = 0;

    }



    /**

     * @dev Accepts a transfer from a previous registrar; stubbed out here since there

     *      is no previous registrar implementing this interface.

     *

     * @param hash The sha3 hash of the label to transfer.

     * @param deed The Deed object for the name being transferred in.

     * @param registrationDate The date at which the name was originally registered.

     */

    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) external {

        hash; deed; registrationDate; // Don't warn about unused variables

    }



    function entries(bytes32 _hash) external view returns (Mode, address, uint, uint, uint) {

        Entry storage h = _entries[_hash];

        return (state(_hash), address(h.deed), h.registrationDate, h.value, h.highestBid);

    }



    // State transitions for names:

    //   Open -> Auction (startAuction)

    //   Auction -> Reveal

    //   Reveal -> Owned

    //   Reveal -> Open (if nobody bid)

    //   Owned -> Open (releaseDeed or invalidateName)

    function state(bytes32 _hash) public view returns (Mode) {

        Entry storage entry = _entries[_hash];



        if (!isAllowed(_hash, now)) {

            return Mode.NotYetAvailable;

        } else if (now < entry.registrationDate) {

            if (now < entry.registrationDate - revealPeriod) {

                return Mode.Auction;

            } else {

                return Mode.Reveal;

            }

        } else {

            if (entry.highestBid == 0) {

                return Mode.Open;

            } else {

                return Mode.Owned;

            }

        }

    }



    /**

     * @dev Determines if a name is available for registration yet

     *

     * Each name will be assigned a random date in which its auction

     * can be started, from 0 to 8 weeks

     *

     * @param _hash The hash to start an auction on

     * @param _timestamp The timestamp to query about

     */

    function isAllowed(bytes32 _hash, uint _timestamp) public view returns (bool allowed) {

        return _timestamp > getAllowedTime(_hash);

    }



    /**

     * @dev Returns available date for hash

     *

     * The available time from the `registryStarted` for a hash is proportional

     * to its numeric value.

     *

     * @param _hash The hash to start an auction on

     */

    function getAllowedTime(bytes32 _hash) public view returns (uint) {

        return registryStarted + ((launchLength * (uint(_hash) >> 128)) >> 128);

        // Right shift operator: a >> b == a / 2**b

    }



    /**

     * @dev Hash the values required for a secret bid

     *

     * @param hash The node corresponding to the desired namehash

     * @param value The bid amount

     * @param salt A random value to ensure secrecy of the bid

     * @return The hash of the bid values

     */

    function shaBid(bytes32 hash, address owner, uint value, bytes32 salt) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(hash, owner, value, salt));

    }



    function _tryEraseSingleNode(bytes32 label) internal {

        if (ens.owner(rootNode) == address(this)) {

            ens.setSubnodeOwner(rootNode, label, address(this));

            bytes32 node = keccak256(abi.encodePacked(rootNode, label));

            ens.setResolver(node, address(0x0));

            ens.setOwner(node, address(0x0));

        }

    }



    function _startAuction(bytes32 _hash) internal registryOpen() {

        Mode mode = state(_hash);

        if (mode == Mode.Auction) return;

        require(mode == Mode.Open);



        Entry storage newAuction = _entries[_hash];

        newAuction.registrationDate = now + totalAuctionLength;

        newAuction.value = 0;

        newAuction.highestBid = 0;

        emit AuctionStarted(_hash, newAuction.registrationDate);

    }



    function _startAuctions(bytes32[] memory _hashes) internal {

        for (uint i = 0; i < _hashes.length; i ++) {

            _startAuction(_hashes[i]);

        }

    }



    function _newBid(bytes32 sealedBid) internal {

        require(address(sealedBids[msg.sender][sealedBid]) == address(0x0));

        require(msg.value >= minPrice);



        // Creates a new hash contract with the owner

        Deed bid = (new DeedImplementation).value(msg.value)(msg.sender);

        sealedBids[msg.sender][sealedBid] = bid;

        emit NewBid(sealedBid, msg.sender, msg.value);

    }



    function _eraseNodeHierarchy(uint idx, bytes32[] memory labels, bytes32 node) internal {

        // Take ownership of the node

        ens.setSubnodeOwner(node, labels[idx], address(this));

        node = keccak256(abi.encodePacked(node, labels[idx]));



        // Recurse if there are more labels

        if (idx > 0) {

            _eraseNodeHierarchy(idx - 1, labels, node);

        }



        // Erase the resolver and owner records

        ens.setResolver(node, address(0x0));

        ens.setOwner(node, address(0x0));

    }



    /**

     * @dev Assign the owner in ENS, if we're still the registrar

     *

     * @param _hash hash to change owner

     * @param _newOwner new owner to transfer to

     */

    function trySetSubnodeOwner(bytes32 _hash, address _newOwner) internal {

        if (ens.owner(rootNode) == address(this))

            ens.setSubnodeOwner(rootNode, _hash, _newOwner);

    }



    /**

     * @dev Returns the maximum of two unsigned integers

     *

     * @param a A number to compare

     * @param b A number to compare

     * @return The maximum of two unsigned integers

     */

    function max(uint a, uint b) internal pure returns (uint) {

        if (a > b)

            return a;

        else

            return b;

    }



    /**

     * @dev Returns the minimum of two unsigned integers

     *

     * @param a A number to compare

     * @param b A number to compare

     * @return The minimum of two unsigned integers

     */

    function min(uint a, uint b) internal pure returns (uint) {

        if (a < b)

            return a;

        else

            return b;

    }



    /**

     * @dev Returns the length of a given string

     *

     * @param s The string to measure the length of

     * @return The length of the input string

     */

    function strlen(string memory s) internal pure returns (uint) {

        s; // Don't warn about unused variables

        // Starting here means the LSB will be the byte we care about

        uint ptr;

        uint end;

        assembly {

            ptr := add(s, 1)

            end := add(mload(s), ptr)

        }

        uint len = 0;

        for (len; ptr < end; len++) {

            uint8 b;

            assembly { b := and(mload(ptr), 0xFF) }

            if (b < 0x80) {

                ptr += 1;

            } else if (b < 0xE0) {

                ptr += 2;

            } else if (b < 0xF0) {

                ptr += 3;

            } else if (b < 0xF8) {

                ptr += 4;

            } else if (b < 0xFC) {

                ptr += 5;

            } else {

                ptr += 6;

            }

        }

        return len;

    }



}



// File: openzeppelin-solidity/contracts/introspection/IERC165.sol



pragma solidity ^0.5.0;



/**

 * @title IERC165

 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md

 */

interface IERC165 {

    /**

     * @notice Query if a contract implements an interface

     * @param interfaceId The interface identifier, as specified in ERC-165

     * @dev Interface identification is specified in ERC-165. This function

     * uses less than 30,000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol



pragma solidity ^0.5.0;





/**

 * @title ERC721 Non-Fungible Token Standard basic interface

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



    function balanceOf(address owner) public view returns (uint256 balance);

    function ownerOf(uint256 tokenId) public view returns (address owner);



    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);



    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address owner, address operator) public view returns (bool);



    function transferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId) public;



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}



// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol



pragma solidity ^0.5.0;



/**

 * @title ERC721 token receiver interface

 * @dev Interface for any contract that wants to support safeTransfers

 * from ERC721 asset contracts.

 */

contract IERC721Receiver {

    /**

     * @notice Handle the receipt of an NFT

     * @dev The ERC721 smart contract calls this function on the recipient

     * after a `safeTransfer`. This function MUST return the function selector,

     * otherwise the caller will revert the transaction. The selector to be

     * returned can be obtained as `this.onERC721Received.selector`. This

     * function MAY throw to revert and reject the transfer.

     * Note: the ERC721 contract address is always the message sender.

     * @param operator The address which called `safeTransferFrom` function

     * @param from The address which previously owned the token

     * @param tokenId The NFT identifier which is being transferred

     * @param data Additional data with no specified format

     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

     */

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)

    public returns (bytes4);

}



// File: openzeppelin-solidity/contracts/math/SafeMath.sol



pragma solidity ^0.5.0;



/**

 * @title SafeMath

 * @dev Unsigned math operations with safety checks that revert on error

 */

library SafeMath {

    /**

    * @dev Multiplies two unsigned integers, reverts on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b);



        return c;

    }



    /**

    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two unsigned integers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }

}



// File: openzeppelin-solidity/contracts/utils/Address.sol



pragma solidity ^0.5.0;



/**

 * Utility library of inline functions on addresses

 */

library Address {

    /**

     * Returns whether the target address is a contract

     * @dev This function will return false if invoked during the constructor of a contract,

     * as the code is not actually created until after the constructor finishes.

     * @param account address of the account to check

     * @return whether the target address is a contract

     */

    function isContract(address account) internal view returns (bool) {

        uint256 size;

        // XXX Currently there is no better way to check if there is a contract in an address

        // than to check the size of the code at that address.

        // See https://ethereum.stackexchange.com/a/14016/36603

        // for more details about how this works.

        // TODO Check this again before the Serenity release, because all addresses will be

        // contracts then.

        // solhint-disable-next-line no-inline-assembly

        assembly { size := extcodesize(account) }

        return size > 0;

    }

}



// File: openzeppelin-solidity/contracts/introspection/ERC165.sol



pragma solidity ^0.5.0;





/**

 * @title ERC165

 * @author Matt Condon (@shrugs)

 * @dev Implements ERC165 using a lookup table.

 */

contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**

     * 0x01ffc9a7 ===

     *     bytes4(keccak256('supportsInterface(bytes4)'))

     */



    /**

     * @dev a mapping of interface id to whether or not it's supported

     */

    mapping(bytes4 => bool) private _supportedInterfaces;



    /**

     * @dev A contract implementing SupportsInterfaceWithLookup

     * implement ERC165 itself

     */

    constructor () internal {

        _registerInterface(_INTERFACE_ID_ERC165);

    }



    /**

     * @dev implement supportsInterface(bytes4) using a lookup table

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {

        return _supportedInterfaces[interfaceId];

    }



    /**

     * @dev internal method for registering an interface

     */

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff);

        _supportedInterfaces[interfaceId] = true;

    }

}



// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol



pragma solidity ^0.5.0;













/**

 * @title ERC721 Non-Fungible Token Standard basic implementation

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md

 */

contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;

    using Address for address;



    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`

    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;



    // Mapping from token ID to owner

    mapping (uint256 => address) private _tokenOwner;



    // Mapping from token ID to approved address

    mapping (uint256 => address) private _tokenApprovals;



    // Mapping from owner to number of owned token

    mapping (address => uint256) private _ownedTokensCount;



    // Mapping from owner to operator approvals

    mapping (address => mapping (address => bool)) private _operatorApprovals;



    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    /*

     * 0x80ac58cd ===

     *     bytes4(keccak256('balanceOf(address)')) ^

     *     bytes4(keccak256('ownerOf(uint256)')) ^

     *     bytes4(keccak256('approve(address,uint256)')) ^

     *     bytes4(keccak256('getApproved(uint256)')) ^

     *     bytes4(keccak256('setApprovalForAll(address,bool)')) ^

     *     bytes4(keccak256('isApprovedForAll(address,address)')) ^

     *     bytes4(keccak256('transferFrom(address,address,uint256)')) ^

     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^

     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))

     */



    constructor () public {

        // register the supported interfaces to conform to ERC721 via ERC165

        _registerInterface(_INTERFACE_ID_ERC721);

    }



    /**

     * @dev Gets the balance of the specified address

     * @param owner address to query the balance of

     * @return uint256 representing the amount owned by the passed address

     */

    function balanceOf(address owner) public view returns (uint256) {

        require(owner != address(0));

        return _ownedTokensCount[owner];

    }



    /**

     * @dev Gets the owner of the specified token ID

     * @param tokenId uint256 ID of the token to query the owner of

     * @return owner address currently marked as the owner of the given token ID

     */

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];

        require(owner != address(0));

        return owner;

    }



    /**

     * @dev Approves another address to transfer the given token ID

     * The zero address indicates there is no approved address.

     * There can only be one approved address per token at a given time.

     * Can only be called by the token owner or an approved operator.

     * @param to address to be approved for the given token ID

     * @param tokenId uint256 ID of the token to be approved

     */

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);

        require(to != owner);

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));



        _tokenApprovals[tokenId] = to;

        emit Approval(owner, to, tokenId);

    }



    /**

     * @dev Gets the approved address for a token ID, or zero if no address set

     * Reverts if the token ID does not exist.

     * @param tokenId uint256 ID of the token to query the approval of

     * @return address currently approved for the given token ID

     */

    function getApproved(uint256 tokenId) public view returns (address) {

        require(_exists(tokenId));

        return _tokenApprovals[tokenId];

    }



    /**

     * @dev Sets or unsets the approval of a given operator

     * An operator is allowed to transfer all tokens of the sender on their behalf

     * @param to operator address to set the approval

     * @param approved representing the status of the approval to be set

     */

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);

        _operatorApprovals[msg.sender][to] = approved;

        emit ApprovalForAll(msg.sender, to, approved);

    }



    /**

     * @dev Tells whether an operator is approved by a given owner

     * @param owner owner address which you want to query the approval of

     * @param operator operator address which you want to query the approval of

     * @return bool whether the given operator is approved by the given owner

     */

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];

    }



    /**

     * @dev Transfers the ownership of a given token ID to another address

     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible

     * Requires the msg sender to be the owner, approved, or operator

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

    */

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));



        _transferFrom(from, to, tokenId);

    }



    /**

     * @dev Safely transfers the ownership of a given token ID to another address

     * If the target address is a contract, it must implement `onERC721Received`,

     * which is called upon a safe transfer, and return the magic value

     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

     * the transfer is reverted.

     *

     * Requires the msg sender to be the owner, approved, or operator

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

    */

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");

    }



    /**

     * @dev Safely transfers the ownership of a given token ID to another address

     * If the target address is a contract, it must implement `onERC721Received`,

     * which is called upon a safe transfer, and return the magic value

     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,

     * the transfer is reverted.

     * Requires the msg sender to be the owner, approved, or operator

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes data to send along with a safe transfer check

     */

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);

        require(_checkOnERC721Received(from, to, tokenId, _data));

    }



    /**

     * @dev Returns whether the specified token exists

     * @param tokenId uint256 ID of the token to query the existence of

     * @return whether the token exists

     */

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];

        return owner != address(0);

    }



    /**

     * @dev Returns whether the given spender can transfer a given token ID

     * @param spender address of the spender to query

     * @param tokenId uint256 ID of the token to be transferred

     * @return bool whether the msg.sender is approved for the given token ID,

     *    is an operator of the owner, or is the owner of the token

     */

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

        address owner = ownerOf(tokenId);

        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));

    }



    /**

     * @dev Internal function to mint a new token

     * Reverts if the given token ID already exists

     * @param to The address that will own the minted token

     * @param tokenId uint256 ID of the token to be minted

     */

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0));

        require(!_exists(tokenId));



        _tokenOwner[tokenId] = to;

        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);



        emit Transfer(address(0), to, tokenId);

    }



    /**

     * @dev Internal function to burn a specific token

     * Reverts if the token does not exist

     * Deprecated, use _burn(uint256) instead.

     * @param owner owner of the token to burn

     * @param tokenId uint256 ID of the token being burned

     */

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner);



        _clearApproval(tokenId);



        _ownedTokensCount[owner] = _ownedTokensCount[owner].sub(1);

        _tokenOwner[tokenId] = address(0);



        emit Transfer(owner, address(0), tokenId);

    }



    /**

     * @dev Internal function to burn a specific token

     * Reverts if the token does not exist

     * @param tokenId uint256 ID of the token being burned

     */

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);

    }



    /**

     * @dev Internal function to transfer ownership of a given token ID to another address.

     * As opposed to transferFrom, this imposes no restrictions on msg.sender.

     * @param from current owner of the token

     * @param to address to receive the ownership of the given token ID

     * @param tokenId uint256 ID of the token to be transferred

    */

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from);

        require(to != address(0));



        _clearApproval(tokenId);



        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);

        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);



        _tokenOwner[tokenId] = to;



        emit Transfer(from, to, tokenId);

    }



    /**

     * @dev Internal function to invoke `onERC721Received` on a target address

     * The call is not executed if the target address is not a contract

     * @param from address representing the previous owner of the given token ID

     * @param to target address that will receive the tokens

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes optional data to send along with the call

     * @return whether the call correctly returned the expected magic value

     */

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)

        internal returns (bool)

    {

        if (!to.isContract()) {

            return true;

        }



        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);

        return (retval == _ERC721_RECEIVED);

    }



    /**

     * @dev Private function to clear current approval of a given token ID

     * @param tokenId uint256 ID of the token to be transferred

     */

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {

            _tokenApprovals[tokenId] = address(0);

        }

    }

}



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



pragma solidity ^0.5.0;



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor () internal {

        _owner = msg.sender;

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @return the address of the owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner());

        _;

    }



    /**

     * @return true if `msg.sender` is the owner of the contract.

     */

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;

    }



    /**

     * @dev Allows the current owner to relinquish control of the contract.

     * @notice Renouncing to ownership will leave the contract without an owner.

     * It will not be possible to call the functions with the `onlyOwner`

     * modifier anymore.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Allows the current owner to transfer control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers control of the contract to a newOwner.

     * @param newOwner The address to transfer ownership to.

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}



// File: contracts/BaseRegistrar.sol



pragma solidity >=0.4.24;











contract BaseRegistrar is ERC721, Ownable {

    uint constant public GRACE_PERIOD = 90 days;



    event ControllerAdded(address indexed controller);

    event ControllerRemoved(address indexed controller);

    event NameMigrated(uint256 indexed id, address indexed owner, uint expires);

    event NameRegistered(uint256 indexed id, address indexed owner, uint expires);

    event NameRenewed(uint256 indexed id, uint expires);



    // Expiration timestamp for migrated domains.

    uint public transferPeriodEnds;



    // The ENS registry

    ENS public ens;



    // The namehash of the TLD this registrar owns (eg, .eth)

    bytes32 public baseNode;



    // The interim registrar

    HashRegistrar public previousRegistrar;



    // A map of addresses that are authorised to register and renew names.

    mapping(address=>bool) public controllers;



    // Authorises a controller, who can register and renew domains.

    function addController(address controller) external;



    // Revoke controller permission for an address.

    function removeController(address controller) external;



    // Set the resolver for the TLD this registrar manages.

    function setResolver(address resolver) external;



    // Returns the expiration timestamp of the specified label hash.

    function nameExpires(uint256 id) external view returns(uint);



    // Returns true iff the specified name is available for registration.

    function available(uint256 id) public view returns(bool);



    /**

     * @dev Register a name.

     */

    function register(uint256 id, address owner, uint duration) external returns(uint);



    function renew(uint256 id, uint duration) external returns(uint);



    /**

     * @dev Reclaim ownership of a name in ENS, if you own it in the registrar.

     */

    function reclaim(uint256 id, address owner) external;



    /**

     * @dev Transfers a registration from the initial registrar.

     * This function is called by the initial registrar when a user calls `transferRegistrars`.

     */

    function acceptRegistrarTransfer(bytes32 label, Deed deed, uint) external;

}



// File: contracts/StringUtils.sol



pragma solidity >=0.4.24;



library StringUtils {

    /**

     * @dev Returns the length of a given string

     *

     * @param s The string to measure the length of

     * @return The length of the input string

     */

    function strlen(string memory s) internal pure returns (uint) {

        uint len;

        uint i = 0;

        uint bytelength = bytes(s).length;

        for(len = 0; i < bytelength; len++) {

            byte b = bytes(s)[i];

            if(b < 0x80) {

                i += 1;

            } else if (b < 0xE0) {

                i += 2;

            } else if (b < 0xF0) {

                i += 3;

            } else if (b < 0xF8) {

                i += 4;

            } else if (b < 0xFC) {

                i += 5;

            } else {

                i += 6;

            }

        }

        return len;

    }

}



// File: contracts/ETHRegistrarController.sol



pragma solidity ^0.5.0;











/**

 * @dev A registrar controller for registering and renewing names at fixed cost.

 */

contract ETHRegistrarController is Ownable {

    using StringUtils for *;



    uint constant public MIN_REGISTRATION_DURATION = 28 days;



    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));

    bytes4 constant private COMMITMENT_CONTROLLER_ID = bytes4(

        keccak256("rentPrice(string,uint256)") ^

        keccak256("available(string)") ^

        keccak256("makeCommitment(string,address,bytes32)") ^

        keccak256("commit(bytes32)") ^

        keccak256("register(string,address,uint256,bytes32)") ^

        keccak256("renew(string,uint256)")

    );



    BaseRegistrar base;

    PriceOracle prices;

    uint public minCommitmentAge;

    uint public maxCommitmentAge;



    mapping(bytes32=>uint) public commitments;



    event NameRegistered(string name, bytes32 indexed label, address indexed owner, uint cost, uint expires);

    event NameRenewed(string name, bytes32 indexed label, uint cost, uint expires);

    event NewPriceOracle(address indexed oracle);



    constructor(BaseRegistrar _base, PriceOracle _prices, uint _minCommitmentAge, uint _maxCommitmentAge) public {

        require(_maxCommitmentAge > _minCommitmentAge);



        base = _base;

        prices = _prices;

        minCommitmentAge = _minCommitmentAge;

        maxCommitmentAge = _maxCommitmentAge;

    }



    function rentPrice(string memory name, uint duration) view public returns(uint) {

        bytes32 hash = keccak256(bytes(name));

        return prices.price(name, base.nameExpires(uint256(hash)), duration);

    }



    function valid(string memory name) public view returns(bool) {

        return name.strlen() > 6;

    }



    function available(string memory name) public view returns(bool) {

        bytes32 label = keccak256(bytes(name));

        return valid(name) && base.available(uint256(label));

    }



    function makeCommitment(string memory name, address owner, bytes32 secret) pure public returns(bytes32) {

        bytes32 label = keccak256(bytes(name));

        return keccak256(abi.encodePacked(label, owner, secret));

    }



    function commit(bytes32 commitment) public {

        require(commitments[commitment] + maxCommitmentAge < now);

        commitments[commitment] = now;

    }



    function register(string calldata name, address owner, uint duration, bytes32 secret) external payable {

        // Require a valid commitment

        bytes32 commitment = makeCommitment(name, owner, secret);

        require(commitments[commitment] + minCommitmentAge <= now);



        // If the commitment is too old, or the name is registered, stop

        require(commitments[commitment] + maxCommitmentAge > now);

        require(available(name));



        delete(commitments[commitment]);



        uint cost = rentPrice(name, duration);

        require(duration >= MIN_REGISTRATION_DURATION);

        require(msg.value >= cost);



        bytes32 label = keccak256(bytes(name));

        uint expires = base.register(uint256(label), owner, duration);

        emit NameRegistered(name, label, owner, cost, expires);



        if(msg.value > cost) {

            msg.sender.transfer(msg.value - cost);

        }

    }



    function renew(string calldata name, uint duration) external payable {

        uint cost = rentPrice(name, duration);

        require(msg.value >= cost);



        bytes32 label = keccak256(bytes(name));

        uint expires = base.renew(uint256(label), duration);



        if(msg.value > cost) {

            msg.sender.transfer(msg.value - cost);

        }



        emit NameRenewed(name, label, cost, expires);

    }



    function setPriceOracle(PriceOracle _prices) public onlyOwner {

        prices = _prices;

        emit NewPriceOracle(address(prices));

    }



    function setCommitmentAges(uint _minCommitmentAge, uint _maxCommitmentAge) public onlyOwner {

        minCommitmentAge = _minCommitmentAge;

        maxCommitmentAge = _maxCommitmentAge;

    }



    function withdraw() public onlyOwner {

        msg.sender.transfer(address(this).balance);

    }



    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {

        return interfaceID == INTERFACE_META_ID ||

               interfaceID == COMMITMENT_CONTROLLER_ID;

    }

}



/**

 * A simple resolver anyone can use; only allows the owner of a node to set its

 * address.

 */

contract PublicResolver {

    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;

    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;

    bytes4 constant CONTENT_INTERFACE_ID = 0xd8389dc5;

    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;

    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;

    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;

    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;



    event AddrChanged(bytes32 indexed node, address a);

    event ContentChanged(bytes32 indexed node, bytes32 hash);

    event NameChanged(bytes32 indexed node, string name);

    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);



    struct PublicKey {

        bytes32 x;

        bytes32 y;

    }



    struct Record {

        address addr;

        bytes32 content;

        string name;

        PublicKey pubkey;

        mapping(string=>string) text;

        mapping(uint256=>bytes) abis;

    }



    ENS ens;

    mapping (bytes32 => Record) records;



    /**

     * Sets the address associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param addr The address to set.

     */

    function setAddr(bytes32 node, address addr) public;



    /**

     * Sets the content hash associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * Note that this resource type is not standardized, and will likely change

     * in future to a resource type based on multihash.

     * @param node The node to update.

     * @param hash The content hash to set

     */

    function setContent(bytes32 node, bytes32 hash) public;

    

    /**

     * Sets the name associated with an ENS node, for reverse records.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param name The name to set.

     */

    function setName(bytes32 node, string memory name) public;



    /**

     * Sets the ABI associated with an ENS node.

     * Nodes may have one ABI of each content type. To remove an ABI, set it to

     * the empty string.

     * @param node The node to update.

     * @param contentType The content type of the ABI

     * @param data The ABI data.

     */

    function setABI(bytes32 node, uint256 contentType, bytes memory data) public;

    

    /**

     * Sets the SECP256k1 public key associated with an ENS node.

     * @param node The ENS node to query

     * @param x the X coordinate of the curve point for the public key.

     * @param y the Y coordinate of the curve point for the public key.

     */

    function setPubkey(bytes32 node, bytes32 x, bytes32 y) public;



    /**

     * Sets the text data associated with an ENS node and key.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param key The key to set.

     * @param value The text data value to set.

     */

    function setText(bytes32 node, string memory key, string memory value) public;

    /**

     * Returns the text data associated with an ENS node and key.

     * @param node The ENS node to query.

     * @param key The text data key to query.

     * @return The associated text data.

     */

    function text(bytes32 node, string memory key) public view returns (string memory);



    /**

     * Returns the SECP256k1 public key associated with an ENS node.

     * Defined in EIP 619.

     * @param node The ENS node to query

     * @return x, y the X and Y coordinates of the curve point for the public key.

     */

    function pubkey(bytes32 node) public view returns (bytes32 x, bytes32 y);

    /**

     * Returns the ABI associated with an ENS node.

     * Defined in EIP205.

     * @param node The ENS node to query

     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.

     * @return contentType The content type of the return value

     * @return data The ABI data

     */

    function ABI(bytes32 node, uint256 contentTypes) public view returns (uint256 contentType, bytes memory data);

    /**

     * Returns the name associated with an ENS node, for reverse records.

     * Defined in EIP181.

     * @param node The ENS node to query.

     * @return The associated name.

     */

    function name(bytes32 node) public view returns (string memory);

    /**

     * Returns the content hash associated with an ENS node.

     * Note that this resource type is not standardized, and will likely change

     * in future to a resource type based on multihash.

     * @param node The ENS node to query.

     * @return The associated content hash.

     */

    function content(bytes32 node) public view returns (bytes32);

    /**

     * Returns the address associated with an ENS node.

     * @param node The ENS node to query.

     * @return The associated address.

     */

    function addr(bytes32 node) public view returns (address);



    /**

     * Returns true if the resolver implements the interface specified by the provided hash.

     * @param interfaceID The ID of the interface to check for.

     * @return True if the contract implements the requested interface.

     */

    function supportsInterface(bytes4 interfaceID) public pure returns (bool);

}





pragma solidity ^0.5.6;





contract ESENSFactory {

  ENS public registry;

  PublicResolver public resolver;

  ETHRegistrarController public permanentRegistrar;

  BaseRegistrar public baseRegistrar;



  uint public network_id;

  

  constructor (uint network) public{

    network_id = network;



    if (network_id == 1) {

      permanentRegistrar = ETHRegistrarController(0xF0AD5cAd05e10572EfcEB849f6Ff0c68f9700455);

      baseRegistrar = BaseRegistrar(0xFaC7BEA255a6990f749363002136aF6556b31e04);

      registry = ENS(0x314159265dD8dbb310642f98f50C066173C1259b);

      resolver = PublicResolver(0x5FfC014343cd971B7eb70732021E26C35B744cc4);

//    registrar = Registrar(0x6090A6e47849629b7245Dfa1Ca21D94cd15878Ef);

//    reverseRegistrar = ReverseRegistrar(0x9062C0A6Dbd6108336BcBe4593a3D1cE05512069);

    } else if (network_id == 3) {

      permanentRegistrar = ETHRegistrarController(0x357DBd063BeA7F0713BF88A3e97B7436B0235979);

      baseRegistrar = BaseRegistrar(0x227Fcb6Ddf14880413EF4f1A3dF2Bbb32bcb29d7);

      registry = ENS(0x112234455C3a32FD11230C42E7Bccd4A84e02010);

      resolver = PublicResolver(0x5FfC014343cd971B7eb70732021E26C35B744cc4);

//    registrar = Registrar(0xc19fD9004B5c9789391679de6d766b981DB94610);

//    reverseRegistrar = ReverseRegistrar(0x67d5418a000534a8F1f5FF4229cC2f439e63BBe2);

//    testRegistrar = FIFSRegistrar(0x21397c1A1F4aCD9132fE36Df011610564b87E24b);

    }

  }

}





pragma solidity ^0.5.6;





contract ESController {



  bytes32 constant TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae; // namehash('eth')

  bytes32 constant ETHSIMPLE_NAMEHASH = 0xff60be0907d071946e59cea1ebac55c2e39e886f0101b78c305f67bdc2c4bd73; // namehash('ethsimple.eth')

  bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2; // namehash('addr.reverse')



  event commitmentSubmitted(bytes32 _commitment, address _owner, uint _submitted);

  event registrationSubmitted(bytes32 _commitment, address _owner, uint _submitted);



  ESENSFactory public ensFactory;

  ENS public registry;

  ETHRegistrarController public permanentRegistrar; 

  PublicResolver public resolver; 

  BaseRegistrar public baseRegistrar; 



  address payable public registrarOwner; 

  address public registrarOperator; 

  

  uint networkFee = 135; 

  uint gasEstimate = 286191 * 10000000000; 

  // TODO: Connect to gas price oracle to estimate what the server will be paying, 

  // and subtract that from the amount sent to the registrar, 

  // also use that in the price estimator

  

  struct Commitment {

    uint totalSent;

    address owner;

    address sender;

  }

  

  mapping (bytes32 => Commitment) public commitments;



  modifier registrar_owner_only() {

    require(msg.sender == registrarOwner);

    _;

  }



  constructor(uint _network_id, address _operator) public {

    registrarOwner = msg.sender;

    registrarOperator = _operator;



    if (_network_id == 1) {

      ensFactory = ESENSFactory(0x306193c2ab1E659EE9ba4E5f0633B80D29CE33B3);

      permanentRegistrar = ETHRegistrarController(0xF0AD5cAd05e10572EfcEB849f6Ff0c68f9700455);

      baseRegistrar = BaseRegistrar(0xFaC7BEA255a6990f749363002136aF6556b31e04);

    } else if (_network_id == 3) {

      ensFactory = ESENSFactory(0xC8349c6dab9682E45E5B482CC633b50b0e458ba8);

      permanentRegistrar = ETHRegistrarController(0x357DBd063BeA7F0713BF88A3e97B7436B0235979);

      baseRegistrar = BaseRegistrar(0x227Fcb6Ddf14880413EF4f1A3dF2Bbb32bcb29d7);

    } else {

      revert("Provide network id");

    }

    registry = ENS(address(ensFactory.registry()));

    resolver = PublicResolver(address(ensFactory.resolver()));

  }



  function makeCommitment(string memory _name, bytes32 _secret) view public returns(bytes32) {

    return permanentRegistrar.makeCommitment(_name, address(this), _secret);

  }

  

  // Estimate the cost for the user before the user queries commit()

  function registrationCost(string memory _name, uint _duration) view public returns(uint) {

      return permanentRegistrar.rentPrice(_name, _duration) * networkFee + gasEstimate;

  }



  function commit(bytes32 _commitment, address _owner) public payable {

      require(commitments[_commitment].owner == address(0), "Domain registration has already been submitted");

      // TODO: Check if name already exists

      require(msg.value >= gasEstimate, "You must submit Ether to register a domain");

      

      commitments[_commitment] = Commitment(msg.value, _owner, msg.sender);

      permanentRegistrar.commit(_commitment);



      emit commitmentSubmitted(_commitment, _owner, msg.value);

  }

  

  function register (

      string memory _name, 

    //   address _registrarAddress,

      uint _duration, 

      bytes32 _secret,

      bytes32 _namehash,

      address _resolver,

      bytes32 _contentHash

    ) public {



      bytes32 commitmentSha = permanentRegistrar.makeCommitment(_name, address(this), _secret);

      Commitment memory commitment = commitments[commitmentSha];



      // Let the registrar owner or purchaser query this

      require(msg.sender == registrarOwner || msg.sender == commitment.owner || msg.sender == commitment.sender || msg.sender == registrarOperator);



      // Leaving the amount sent to the registrar unchecked, can allow for 'coupons', 

      // need to put in stronger checks to ensure we don't lose money on gas fees

      permanentRegistrar.register.value(commitment.totalSent - gasEstimate)(_name, address(this), _duration, _secret); // User can't register a domain for longer than their payment will allow

      registry.setResolver(_namehash, _resolver);

      resolver.setAddr(_namehash, commitment.owner);

      // if (_contentHash != 0x0000000000000000000000000000000000000000000000000000000000000000) {

      resolver.setContent(_namehash, _contentHash);

      // }

      baseRegistrar.reclaim(uint256(keccak256(bytes(_name))), commitment.owner);

      baseRegistrar.safeTransferFrom(address(this), commitment.owner, uint256(keccak256(bytes(_name)))); // TODO Note: This throws an error if someone tries to register a contract address



      emit registrationSubmitted(commitmentSha, commitment.owner, commitment.totalSent);      



      delete commitments[commitmentSha]; // Recover some gas

  }

  

  function withdraw() public registrar_owner_only {

      registrarOwner.transfer(address(this).balance);

  }

  

  function setNetworkPower(uint fee) public registrar_owner_only {

      networkFee = fee;

  }

  

  function setGasEstimate(uint _gasEstimate) public registrar_owner_only {

      gasEstimate = _gasEstimate;

  }

  

  function transferOwnership(address payable _newOwner) public registrar_owner_only {

      registrarOwner = _newOwner;

  }

  

  function setOperator(address payable _newOperator) public registrar_owner_only {

      registrarOperator = _newOperator;

  }

  

  function removeCommitment(bytes32 _commitment) public registrar_owner_only {

      delete commitments[_commitment]; // Recover some gas

  }

  

  // TODO: Maybe backup domain recovery method, though method atomicity should prevent the contract from ever owning a domain

  

  function() external payable { }

  

  function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns(bytes4){

    return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));

  } 

}