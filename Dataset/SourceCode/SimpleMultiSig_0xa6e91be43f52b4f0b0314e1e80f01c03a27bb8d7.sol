pragma solidity ^0.5.13;



contract SimpleMultiSig {



// EIP712 Precomputed hashes:

// keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)")

bytes32 constant EIP712DOMAINTYPE_HASH = 0xd87cd6ef79d4e2b95e15ce8abf732db51ec771f1ca2edccf22a46c729ac56472;



// keccak256("Simple MultiSig")

bytes32 constant NAME_HASH = 0xb7a0bfa1b79f2443f4d73ebb9259cddbcd510b18be6fc4da7d1aa7b1786e73e6;



// keccak256("1")

bytes32 constant VERSION_HASH = 0xc89efdaa54c0f20c7adf612882df0950f5a951637e0307cdcb4c672f298b8bc6;



// keccak256("MultiSigTransaction(address destination,uint256 value,bytes data,uint256 nonce,address executor,uint256 gasLimit)")

bytes32 constant TXTYPE_HASH = 0x3ee892349ae4bbe61dce18f95115b5dc02daf49204cc602458cd4c1f540d56d7;



bytes32 constant SALT = 0x251543af6a222378665a76fe38dbceae4871a070b7fdaf5c6c30cf758dc33cc0;



  event Execute(address[] _confirmAddrs, address _destination, uint _value, bytes data);

  event Deposit(address indexed _from,uint _value);



  // debug events

  // event DbgExecuteParam(bytes32 sperator, bytes32 txInputHash, bytes32 totalHash, bytes txInput);

  // event DbgRecover(address _recovered);



  uint public nonce;                 // (only) mutable state

  uint public threshold;             // immutable state

  mapping (address => bool) isOwner; // immutable state

  address[] public ownersArr;        // immutable state



  bytes32 DOMAIN_SEPARATOR;          // hash for EIP712, computed from contract address



  // Note that owners_ must be strictly increasing, in order to prevent duplicates

  constructor(uint threshold_, address[] memory owners_, uint chainId) public {

    require(owners_.length <= 10 && threshold_ <= owners_.length && threshold_ > 0, "0<threshold<owners.length");



    address lastAdd = address(0);

    for (uint i = 0; i < owners_.length; i++) {

      require(owners_[i] > lastAdd, "repeated owner or not sorted");

      isOwner[owners_[i]] = true;

      lastAdd = owners_[i];

    }

    ownersArr = owners_;

    threshold = threshold_;



    DOMAIN_SEPARATOR = keccak256(abi.encode(EIP712DOMAINTYPE_HASH,

                                            NAME_HASH,

                                            VERSION_HASH,

                                            chainId,

                                            this,

                                            SALT));

  }



  // Note that address recovered from signatures must be strictly increasing, in order to prevent duplicates

  function execute(uint8[] memory sigV, bytes32[] memory sigR, bytes32[] memory sigS,

    address destination, uint value, bytes memory data, address executor, uint gasLimit) public {



    require(sigR.length == threshold, "R len not equal to threshold");

    require(sigR.length == sigS.length && sigR.length == sigV.length, "length of r/s/v not match");

    require(executor == msg.sender || executor == address(0), "wrong executor");



    // EIP712 scheme: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-712.md

    bytes32 txInputHash = keccak256(abi.encode(TXTYPE_HASH, destination, value, keccak256(data), nonce, executor, gasLimit));

    bytes32 totalHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, txInputHash));



    // emit DbgExecuteParam(DOMAIN_SEPARATOR, txInputHash, totalHash, abi.encode(TXTYPE_HASH, destination, value, keccak256(data), nonce, executor, gasLimit));



    address lastAdd = address(0); // cannot have address(0) as an owner

    address[] memory confirmAddrs = new address[](threshold);

    for (uint i = 0; i < threshold; i++) {

      address recovered = ecrecover(totalHash, sigV[i], sigR[i], sigS[i]);

      require(recovered > lastAdd && isOwner[recovered], "Verify sig failed");

      // emit DbgRecover(recovered);

      confirmAddrs[i] = recovered;

      lastAdd = recovered;

    }



    // If we make it here all signatures are accounted for.

    // The address.call() syntax is no longer recommended, see:

    // https://github.com/ethereum/solidity/issues/2884

    nonce = nonce + 1;

    bool success = false;

    assembly { success := call(gasLimit, destination, value, add(data, 0x20), mload(data), 0, 0) }

    require(success, "not_success");

    emit Execute(confirmAddrs, destination, value, data);

  }



  function getVersion() external pure returns (string memory) {

    return "1"; //

  }



  function getOwersLength() external view returns (int8) {

    return int8(ownersArr.length); //owners.length <= 10 (see constructor), so type convert is ok

  }



  function () external payable {

    emit Deposit(msg.sender, msg.value);

  }

}