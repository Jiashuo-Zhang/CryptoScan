/**

 *Submitted for verification at Etherscan.io on 2019-08-24

*/



pragma solidity ^0.5.0;


/**
 * @title Spawn
 * @author 0age
 * @notice This contract provides creation code that is used by Spawner in order
 * to initialize and deploy eip-1167 minimal proxies for a given logic contract.
 */
contract Spawn {
  constructor(
    address logicContract,
    bytes memory initializationCalldata
  ) public payable {
    // delegatecall into the logic contract to perform initialization.
    (bool ok, ) = logicContract.delegatecall(initializationCalldata);
    if (!ok) {
      // pass along failure message from delegatecall and revert.
      assembly {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }

    // place eip-1167 runtime code in memory.
    bytes memory runtimeCode = abi.encodePacked(
      bytes10(0x363d3d373d3d3d363d73),
      logicContract,
      bytes15(0x5af43d82803e903d91602b57fd5bf3)
    );

    // return eip-1167 code to write it to spawned contract runtime.
    assembly {
      return(add(0x20, runtimeCode), 45) // eip-1167 runtime code, length
    }
  }
}

/**
 * @title Spawner
 * @author 0age
 * @notice This contract spawns and initializes eip-1167 minimal proxies that
 * point to existing logic contracts. The logic contracts need to have an
 * intitializer function that should only callable when no contract exists at
 * their current address (i.e. it is being `DELEGATECALL`ed from a constructor).
 */
contract Spawner {
  /**
   * @notice Internal function for spawning an eip-1167 minimal proxy using
   * `CREATE2`.
   * @param logicContract address The address of the logic contract.
   * @param initializationCalldata bytes The calldata that will be supplied to
   * the `DELEGATECALL` from the spawned contract to the logic contract during
   * contract creation.
   * @return The address of the newly-spawned contract.
   */
  function _spawn(
    address logicContract,
    bytes memory initializationCalldata
  ) internal returns (address spawnedContract) {
    // place creation code and constructor args of contract to spawn in memory.
    bytes memory initCode = abi.encodePacked(
      type(Spawn).creationCode,
      abi.encode(logicContract, initializationCalldata)
    );

    // spawn the contract using `CREATE2`.
    spawnedContract = _spawnCreate2(initCode);
  }

  /**
   * @notice Internal view function for finding the address of the next standard
   * eip-1167 minimal proxy created using `CREATE2` with a given logic contract
   * and initialization calldata payload.
   * @param logicContract address The address of the logic contract.
   * @param initializationCalldata bytes The calldata that will be supplied to
   * the `DELEGATECALL` from the spawned contract to the logic contract during
   * contract creation.
   * @return The address of the next spawned minimal proxy contract with the
   * given parameters.
   */
  function _computeNextAddress(
    address logicContract,
    bytes memory initializationCalldata
  ) internal view returns (address target) {
    // place creation code and constructor args of contract to spawn in memory.
    bytes memory initCode = abi.encodePacked(
      type(Spawn).creationCode,
      abi.encode(logicContract, initializationCalldata)
    );

    // get target address using the constructed initialization code.
    (, target) = _getSaltAndTarget(initCode);
  }


  /**
   * @notice Private function for spawning a compact eip-1167 minimal proxy
   * using `CREATE2`. Provides logic that is reused by internal functions. A
   * salt will also be chosen based on the calling address and a computed nonce
   * that prevents deployments to existing addresses.
   * @param initCode bytes The contract creation code.
   * @return The address of the newly-spawned contract.
   */
  function _spawnCreate2(
    bytes memory initCode
  ) private returns (address spawnedContract) {
    // get salt to use during deployment using the supplied initialization code.
    (bytes32 salt, ) = _getSaltAndTarget(initCode);

    assembly {
      let encoded_data := add(0x20, initCode) // load initialization code.
      let encoded_size := mload(initCode)     // load the init code's length.
      spawnedContract := create2(             // call `CREATE2` w/ 4 arguments.
        callvalue,                            // forward any supplied endowment.
        encoded_data,                         // pass in initialization code.
        encoded_size,                         // pass in init code's length.
        salt                                  // pass in the salt value.
      )

      // pass along failure message from failed contract deployment and revert.
      if iszero(spawnedContract) {
        returndatacopy(0, 0, returndatasize)
        revert(0, returndatasize)
      }
    }
  }

  /**
   * @notice Private function for determining the salt and the target deployment
   * address for the next spawned contract (using create2) based on the contract
   * creation code.
   */
  function _getSaltAndTarget(
    bytes memory initCode
  ) private view returns (bytes32 salt, address target) {
    // get the keccak256 hash of the init code for address derivation.
    bytes32 initCodeHash = keccak256(initCode);

    // set the initial nonce to be provided when constructing the salt.
    uint256 nonce = 0;

    // declare variable for code size of derived address.
    uint256 codeSize;

    while (true) {
      // derive `CREATE2` salt using `msg.sender` and nonce.
      salt = keccak256(abi.encodePacked(msg.sender, nonce));

      target = address(    // derive the target deployment address.
        uint160(                   // downcast to match the address type.
          uint256(                 // cast to uint to truncate upper digits.
            keccak256(             // compute CREATE2 hash using 4 inputs.
              abi.encodePacked(    // pack all inputs to the hash together.
                bytes1(0xff),      // pass in the control character.
                address(this),     // pass in the address of this contract.
                salt,              // pass in the salt from above.
                initCodeHash       // pass in hash of contract creation code.
              )
            )
          )
        )
      );

      // determine if a contract is already deployed to the target address.
      assembly { codeSize := extcodesize(target) }

      // exit the loop if no contract is deployed to the target address.
      if (codeSize == 0) {
        break;
      }

      // otherwise, increment the nonce and derive a new salt.
      nonce++;
    }
  }
}


interface iRegistry {

    enum FactoryStatus { Unregistered, Registered, Retired }

    event FactoryAdded(address owner, address factory, uint256 factoryID, bytes extraData);
    event FactoryRetired(address owner, address factory, uint256 factoryID);
    event InstanceRegistered(address instance, uint256 instanceIndex, address indexed creator, address indexed factory, uint256 indexed factoryID);

    // factory state functions

    function addFactory(address factory, bytes calldata extraData ) external;
    function retireFactory(address factory) external;

    // factory view functions

    function getFactoryCount() external view returns (uint256 count);
    function getFactoryStatus(address factory) external view returns (FactoryStatus status);
    function getFactoryID(address factory) external view returns (uint16 factoryID);
    function getFactoryData(address factory) external view returns (bytes memory extraData);
    function getFactoryAddress(uint16 factoryID) external view returns (address factory);
    function getFactory(address factory) external view returns (FactoryStatus state, uint16 factoryID, bytes memory extraData);
    function getFactories() external view returns (address[] memory factories);
    function getPaginatedFactories(uint256 startIndex, uint256 endIndex) external view returns (address[] memory factories);

    // instance state functions

    function register(address instance, address creator, uint80 extraData) external;

    // instance view functions

    function getInstanceType() external view returns (bytes4 instanceType);
    function getInstanceCount() external view returns (uint256 count);
    function getInstance(uint256 index) external view returns (address instance);
    function getInstances() external view returns (address[] memory instances);
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);
}



contract Metadata {

    bytes private _staticMetadata;
    bytes private _variableMetadata;

    event StaticMetadataSet(bytes staticMetadata);
    event VariableMetadataSet(bytes variableMetadata);

    // state functions

    function _setStaticMetadata(bytes memory staticMetadata) internal {
        require(_staticMetadata.length == 0, "static metadata cannot be changed");
        _staticMetadata = staticMetadata;
        emit StaticMetadataSet(staticMetadata);
    }

    function _setVariableMetadata(bytes memory variableMetadata) internal {
        _variableMetadata = variableMetadata;
        emit VariableMetadataSet(variableMetadata);
    }

    // view functions

    function getMetadata() public view returns (bytes memory staticMetadata, bytes memory variableMetadata) {
        staticMetadata = _staticMetadata;
        variableMetadata = _variableMetadata;
    }
}



contract Operated {

    address private _operator;
    bool private _status;

    event OperatorUpdated(address operator, bool status);

    // state functions

    function _setOperator(address operator) internal {
        require(_operator != operator, "cannot set same operator");
        _operator = operator;
        emit OperatorUpdated(operator, hasActiveOperator());
    }

    function _transferOperator(address operator) internal {
        // transferring operator-ship implies there was an operator set before this
        require(_operator != address(0), "operator not set");
        _setOperator(operator);
    }

    function _renounceOperator() internal {
        require(hasActiveOperator(), "only when operator active");
        _operator = address(0);
        _status = false;
        emit OperatorUpdated(address(0), false);
    }

    function _activateOperator() internal {
        require(!hasActiveOperator(), "only when operator not active");
        _status = true;
        emit OperatorUpdated(_operator, true);
    }

    function _deactivateOperator() internal {
        require(hasActiveOperator(), "only when operator active");
        _status = false;
        emit OperatorUpdated(_operator, false);
    }

    // view functions

    function getOperator() public view returns (address operator) {
        operator = _operator;
    }

    function isOperator(address caller) public view returns (bool ok) {
        return (caller == getOperator());
    }

    function hasActiveOperator() public view returns (bool ok) {
        return _status;
    }

    function isActiveOperator(address caller) public view returns (bool ok) {
        return (isOperator(caller) && hasActiveOperator());
    }

}


/* TODO: Update eip165 interface
 *  bytes4(keccak256('create(bytes)')) == 0xcf5ba53f
 *  bytes4(keccak256('getInstanceType()')) == 0x18c2f4cf
 *  bytes4(keccak256('getInstanceRegistry()')) == 0xa5e13904
 *  bytes4(keccak256('getImplementation()')) == 0xaaf10f42
 *
 *  => 0xcf5ba53f ^ 0x18c2f4cf ^ 0xa5e13904 ^ 0xaaf10f42 == 0xd88967b6
 */
 interface iFactory {

     event InstanceCreated(address indexed instance, address indexed creator, string initABI, bytes initData);

     function create(bytes calldata initData) external returns (address instance);
     function getInitdataABI() external view returns (string memory initABI);
     function getInstanceRegistry() external view returns (address instanceRegistry);
     function getTemplate() external view returns (address template);

     function getInstanceCreator(address instance) external view returns (address creator);
     function getInstanceType() external view returns (bytes4 instanceType);
     function getInstanceCount() external view returns (uint256 count);
     function getInstance(uint256 index) external view returns (address instance);
     function getInstances() external view returns (address[] memory instances);
     function getPaginatedInstances(uint256 startIndex, uint256 endIndex) external view returns (address[] memory instances);
 }



/**
 * @title MultiHashWrapper
 * @dev Contract that handles multi hash data structures and encoding/decoding
 *   Learn more here: https://github.com/multiformats/multihash
 */
contract MultiHashWrapper {

    // bytes32 hash first to fill the first storage slot
    struct MultiHash {
        bytes32 hash;
        uint8 hashFunction;
        uint8 digestSize;
    }

    /**
    * @dev Given a multihash struct, returns the full base58-encoded hash
    * @param multihash MultiHash struct that has the hashFunction, digestSize and the hash
    * @return the base58-encoded full hash
    */
    function _combineMultiHash(MultiHash memory multihash) internal pure returns (bytes memory) {
        bytes memory out = new bytes(34);

        out[0] = byte(multihash.hashFunction);
        out[1] = byte(multihash.digestSize);

        uint8 i;
        for (i = 0; i < 32; i++) {
          out[i+2] = multihash.hash[i];
        }

        return out;
    }

    /**
    * @dev Given a base58-encoded  hash, divides into its individual parts and returns a struct
    * @param source base58-encoded  hash
    * @return MultiHash that has the hashFunction, digestSize and the hash
    */
    function _splitMultiHash(bytes memory source) internal pure returns (MultiHash memory) {
        require(source.length == 34, "length of source must be 34");

        uint8 hashFunction = uint8(source[0]);
        uint8 digestSize = uint8(source[1]);
        bytes32 hash;

        assembly {
          hash := mload(add(source, 34))
        }

        return (MultiHash({
          hashFunction: hashFunction,
          digestSize: digestSize,
          hash: hash
        }));
    }
}




contract Factory is Spawner {

    address[] private _instances;
    mapping (address => address) private _instanceCreator;

    /* NOTE: The following items can be hardcoded as constant to save ~200 gas/create */
    address private _templateContract;
    string private _initdataABI;
    address private _instanceRegistry;
    bytes4 private _instanceType;

    event InstanceCreated(address indexed instance, address indexed creator, bytes callData);

    function _initialize(address instanceRegistry, address templateContract, bytes4 instanceType, string memory initdataABI) internal {
        // set instance registry
        _instanceRegistry = instanceRegistry;
        // set logic contract
        _templateContract = templateContract;
        // set initdataABI
        _initdataABI = initdataABI;
        // validate correct instance registry
        require(instanceType == iRegistry(instanceRegistry).getInstanceType(), 'incorrect instance type');
        // set instanceType
        _instanceType = instanceType;
    }

    // IFactory methods

    function _create(bytes memory callData) internal returns (address instance) {
        // deploy new contract: initialize it & write minimal proxy to runtime.
        instance = Spawner._spawn(getTemplate(), callData);
        // add the instance to the array
        _instances.push(instance);
        // set instance creator
        _instanceCreator[instance] = msg.sender;
        // add the instance to the instance registry
        iRegistry(getInstanceRegistry()).register(instance, msg.sender, uint64(0));
        // emit event
        emit InstanceCreated(instance, msg.sender, callData);
    }

    function getInstanceCreator(address instance) public view returns (address creator) {
        creator = _instanceCreator[instance];
    }

    function getInstanceType() public view returns (bytes4 instanceType) {
        instanceType = _instanceType;
    }

    function getInitdataABI() public view returns (string memory initdataABI) {
        initdataABI = _initdataABI;
    }

    function getInstanceRegistry() public view returns (address instanceRegistry) {
        instanceRegistry = _instanceRegistry;
    }

    function getTemplate() public view returns (address template) {
        template = _templateContract;
    }

    function getInstanceCount() public view returns (uint256 count) {
        count = _instances.length;
    }

    function getInstance(uint256 index) public view returns (address instance) {
        require(index < _instances.length, "index out of range");
        instance = _instances[index];
    }

    function getInstances() public view returns (address[] memory instances) {
        instances = _instances;
    }

    // Note: startIndex is inclusive, endIndex exclusive
    function getPaginatedInstances(uint256 startIndex, uint256 endIndex) public view returns (address[] memory instances) {
        require(startIndex < endIndex, "startIndex must be less than endIndex");
        require(endIndex <= _instances.length, "end index out of range");

        // initialize fixed size memory array
        address[] memory range = new address[](endIndex - startIndex);

        // Populate array with addresses in range
        for (uint256 i = startIndex; i < endIndex; i++) {
            range[i - startIndex] = _instances[i];
        }

        // return array of addresses
        instances = range;
    }

}



contract Template {

    address private _factory;

    // modifiers

    modifier initializeTemplate() {
        // set factory
        _factory = msg.sender;

        // only allow function to be delegatecalled from within a constructor.
        uint32 codeSize;
        assembly { codeSize := extcodesize(address) }
        require(codeSize == 0, "must be called within contract constructor");
        _;
    }

    // view functions

    function getCreator() public view returns (address creator) {
        // iFactory(...) would revert if _factory address is not actually a factory contract
        creator = iFactory(_factory).getInstanceCreator(address(this));
    }

    function isCreator(address caller) public view returns (bool ok) {
        ok = (caller == getCreator());
    }

}



contract ProofHash is MultiHashWrapper {

    MultiHash private _proofHash;

    event ProofHashSet(address caller, bytes proofHash);

    // state functions

    function _setProofHash(bytes memory proofHash) internal {
        _proofHash = MultiHashWrapper._splitMultiHash(proofHash);
        emit ProofHashSet(msg.sender, proofHash);
    }

    // view functions

    function getProofHash() public view returns (bytes memory proofHash) {
        proofHash = MultiHashWrapper._combineMultiHash(_proofHash);
    }

}






contract Post is ProofHash, Operated, Metadata, Template {

    event Created(address operator, bytes proofHash, bytes staticMetadata, bytes variableMetadata);

    function initialize(
        address operator,
        bytes memory proofHash,
        bytes memory staticMetadata,
        bytes memory variableMetadata
    ) public initializeTemplate() {
        // set storage variables
        ProofHash._setProofHash(proofHash);

        // set operator
        if (operator != address(0)) {
            Operated._setOperator(operator);
            Operated._activateOperator();
        }

        // set static metadata
        Metadata._setStaticMetadata(staticMetadata);

        // set variable metadata
        Metadata._setVariableMetadata(variableMetadata);

        // emit event
        emit Created(operator, proofHash, staticMetadata, variableMetadata);
    }

    // state functions

    function setVariableMetadata(bytes memory variableMetadata) public {
        // only active operator or creator
        require(Template.isCreator(msg.sender) || Operated.isActiveOperator(msg.sender), "only active operator or creator");

        // set metadata in storage
        Metadata._setVariableMetadata(variableMetadata);
    }

}




contract Post_Factory is Factory {

    constructor(address instanceRegistry) public {
        // deploy template contract
        address templateContract = address(new Post());
        // set instance type
        bytes4 instanceType = bytes4(keccak256(bytes('Post')));
        // set initdataABI
        string memory initdataABI = '(address,bytes,bytes,bytes)';
        // initialize factory params
        Factory._initialize(instanceRegistry, templateContract, instanceType, initdataABI);
    }

    event ExplicitInitData(address operator, bytes proofHash, bytes staticMetadata, bytes variableMetadata);

    function create(bytes memory callData) public returns (address instance) {
        // deploy instance
        instance = Factory._create(callData);
    }

    function createEncoded(bytes memory initdata) public returns (address instance) {
        // decode initdata
        (
            address operator,
            bytes memory proofHash,
            bytes memory staticMetadata,
            bytes memory variableMetadata
        ) = abi.decode(initdata, (address,bytes,bytes,bytes));

        // call explicit create
        instance = createExplicit(operator, proofHash, staticMetadata, variableMetadata);
    }

    function createExplicit(
        address operator,
        bytes memory proofHash,
        bytes memory staticMetadata,
        bytes memory variableMetadata
    ) public returns (address instance) {
        // declare template in memory
        Post template;

        // construct the data payload used when initializing the new contract.
        bytes memory callData = abi.encodeWithSelector(
            template.initialize.selector, // selector
            operator,
            proofHash,
            staticMetadata,
            variableMetadata
        );

        // deploy instance
        instance = Factory._create(callData);

        // emit event
        emit ExplicitInitData(operator, proofHash, staticMetadata, variableMetadata);
    }

}







contract Feed is Operated, Metadata, Template {

    address[] private _posts;
    address private _postRegistry;

    event PostCreated(address post, address postFactory, bytes initData);

    function initialize(
        address operator,
        address postRegistry,
        bytes memory feedStaticMetadata
    ) public initializeTemplate() {
        // set operator
        if (operator != address(0)) {
            Operated._setOperator(operator);
            Operated._activateOperator();
        }

        // set post registry
        _postRegistry = postRegistry;

        // set static metadata
        Metadata._setStaticMetadata(feedStaticMetadata);
    }

    // state functions

    function createPost(address postFactory, bytes memory initData) public returns (address post) {
        // only active operator or creator
        require(Template.isCreator(msg.sender) || Operated.isActiveOperator(msg.sender), "only active operator or creator");

        // validate factory is registered
        require(
            iRegistry(_postRegistry).getFactoryStatus(postFactory) == iRegistry.FactoryStatus.Registered,
            "factory is not actively registered"
        );

        // spawn new post contract
        post = Post_Factory(postFactory).createEncoded(initData);

        // add to array of posts
        _posts.push(post);

        // emit event
        emit PostCreated(post, postFactory, initData);
    }

    function setFeedVariableMetadata(bytes memory feedVariableMetadata) public {
        // only active operator or creator
        require(Template.isCreator(msg.sender) || Operated.isActiveOperator(msg.sender), "only active operator or creator");

        Metadata._setVariableMetadata(feedVariableMetadata);
    }

    function setPostVariableMetadata(address post, bytes memory postVariableMetadata) public {
        // only active operator or creator
        require(Template.isCreator(msg.sender) || Operated.isActiveOperator(msg.sender), "only active operator or creator");

        Post(post).setVariableMetadata(postVariableMetadata);
    }

    // view functions

    function getPosts() public view returns (address[] memory posts) {
        posts = _posts;
    }

    function getPostRegistry() public view returns (address postRegistry) {
        postRegistry = _postRegistry;
    }

}




contract Feed_Factory is Factory {

    constructor(address instanceRegistry) public {
        // deploy template contract
        address templateContract = address(new Feed());
        // set instance type
        bytes4 instanceType = bytes4(keccak256(bytes('Post')));
        // set initdataABI
        string memory initdataABI = '(address,address,bytes)';
        // initialize factory params
        Factory._initialize(instanceRegistry, templateContract, instanceType, initdataABI);
    }

    event ExplicitInitData(address operator, address postRegistry, bytes feedStaticMetadata);

    function create(bytes memory callData) public returns (address instance) {
        // deploy instance
        instance = Factory._create(callData);
    }

    function createEncoded(bytes memory initdata) public returns (address instance) {
        // decode initdata
        (
            address operator,
            address postRegistry,
            bytes memory feedStaticMetadata
        ) = abi.decode(initdata, (address,address,bytes));

        // call explicit create
        instance = createExplicit(operator, postRegistry, feedStaticMetadata);
    }

    function createExplicit(
        address operator,
        address postRegistry,
        bytes memory feedStaticMetadata
    ) public returns (address instance) {
        // declare template in memory
        Feed template;

        // construct the data payload used when initializing the new contract.
        bytes memory callData = abi.encodeWithSelector(
            template.initialize.selector, // selector
            operator,
            postRegistry,
            feedStaticMetadata
        );

        // deploy instance
        instance = Factory._create(callData);

        // emit event
        emit ExplicitInitData(operator, postRegistry, feedStaticMetadata);
    }

}