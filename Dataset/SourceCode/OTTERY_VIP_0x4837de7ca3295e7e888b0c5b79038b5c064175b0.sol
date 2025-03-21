/**

 *Submitted for verification at Etherscan.io on 2023-07-28

*/



// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

//website: OTTERY.VIP



// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface of the ERC20 standard as defined in the EIP.

 */

interface IERC20 {

    /**

     * @dev Emitted when `value` tokens are moved from one account (`from`) to

     * another (`to`).

     *

     * Note that `value` may be zero.

     */

    event Transfer(address indexed from, address indexed to, uint256 value);



    /**

     * @dev Emitted when the allowance of a `spender` for an `owner` is set by

     * a call to {approve}. `value` is the new allowance.

     */

    event Approval(address indexed owner, address indexed spender, uint256 value);



    /**

     * @dev Returns the amount of tokens in existence.

     */

    function totalSupply() external view returns (uint256);



    /**

     * @dev Returns the amount of tokens owned by `account`.

     */

    function balanceOf(address account) external view returns (uint256);



    /**

     * @dev Moves `amount` tokens from the caller's account to `to`.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transfer(address to, uint256 amount) external returns (bool);



    /**

     * @dev Returns the remaining number of tokens that `spender` will be

     * allowed to spend on behalf of `owner` through {transferFrom}. This is

     * zero by default.

     *

     * This value changes when {approve} or {transferFrom} are called.

     */

    function allowance(address owner, address spender) external view returns (uint256);



    /**

     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * IMPORTANT: Beware that changing an allowance with this method brings the risk

     * that someone may use both the old and the new allowance by unfortunate

     * transaction ordering. One possible solution to mitigate this race

     * condition is to first reduce the spender's allowance to 0 and set the

     * desired value afterwards:

     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

     *

     * Emits an {Approval} event.

     */

    function approve(address spender, uint256 amount) external returns (bool);



    /**

     * @dev Moves `amount` tokens from `from` to `to` using the

     * allowance mechanism. `amount` is then deducted from the caller's

     * allowance.

     *

     * Returns a boolean value indicating whether the operation succeeded.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(address from, address to, uint256 amount) external returns (bool);

}



// File: @chainlink/contracts/src/v0.8/VRFRequestIDBase.sol





pragma solidity ^0.8.0;



contract VRFRequestIDBase {

  /**

   * @notice returns the seed which is actually input to the VRF coordinator

   *

   * @dev To prevent repetition of VRF output due to repetition of the

   * @dev user-supplied seed, that seed is combined in a hash with the

   * @dev user-specific nonce, and the address of the consuming contract. The

   * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in

   * @dev the final seed, but the nonce does protect against repetition in

   * @dev requests which are included in a single block.

   *

   * @param _userSeed VRF seed input provided by user

   * @param _requester Address of the requesting contract

   * @param _nonce User-specific nonce at the time of the request

   */

  function makeVRFInputSeed(

    bytes32 _keyHash,

    uint256 _userSeed,

    address _requester,

    uint256 _nonce

  ) internal pure returns (uint256) {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));

  }



  /**

   * @notice Returns the id for this request

   * @param _keyHash The serviceAgreement ID to be used for this request

   * @param _vRFInputSeed The seed to be passed directly to the VRF

   * @return The id for this request

   *

   * @dev Note that _vRFInputSeed is not the seed passed by the consuming

   * @dev contract, but the one generated by makeVRFInputSeed

   */

  function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));

  }

}



// File: @chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol





pragma solidity ^0.8.0;



interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);



  function approve(address spender, uint256 value) external returns (bool success);



  function balanceOf(address owner) external view returns (uint256 balance);



  function decimals() external view returns (uint8 decimalPlaces);



  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);



  function increaseApproval(address spender, uint256 subtractedValue) external;



  function name() external view returns (string memory tokenName);



  function symbol() external view returns (string memory tokenSymbol);



  function totalSupply() external view returns (uint256 totalTokensIssued);



  function transfer(address to, uint256 value) external returns (bool success);



  function transferAndCall(

    address to,

    uint256 value,

    bytes calldata data

  ) external returns (bool success);



  function transferFrom(

    address from,

    address to,

    uint256 value

  ) external returns (bool success);

}



// File: @chainlink/contracts/src/v0.8/VRFConsumerBase.sol





pragma solidity ^0.8.0;







/** ****************************************************************************

 * @notice Interface for contracts using VRF randomness

 * *****************************************************************************

 * @dev PURPOSE

 *

 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness



 * @dev until it calls responds to a request.

 */

abstract contract VRFConsumerBase is VRFRequestIDBase {

  /**

   * @notice fulfillRandomness handles the VRF response. Your contract must

   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important

   * @notice principles to keep in mind when implementing your fulfillRandomness

   * @notice method.

   *

   * @dev VRFConsumerBase expects its subcontracts to have a method with this

   * @dev signature, and will call it once it has verified the proof

   * @dev associated with the randomness. (It is triggered via a call to

   * @dev rawFulfillRandomness, below.)

   *

   * @param requestId The Id initially returned by requestRandomness

   * @param randomness the VRF output

   */

  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal virtual;



  /**

   * @dev In order to keep backwards compatibility we have kept the user

   * seed field around. We remove the use of it because given that the blockhash

   * enters later, it overrides whatever randomness the used seed provides.

   * Given that it adds no security, and can easily lead to misunderstandings,

   * we have removed it from usage and can now provide a simpler API.

   */

  uint256 private constant USER_SEED_PLACEHOLDER = 0;



  /**

   * @notice requestRandomness initiates a request for VRF output given _seed

   *

   * @dev The fulfillRandomness method receives the output, once it's provided

   * @dev by the Oracle, and verified by the vrfCoordinator.

   *

   * @dev The _keyHash must already be registered with the VRFCoordinator, and

   * @dev the _fee must exceed the fee specified during registration of the

   * @dev _keyHash.

   *

   * @dev The _seed parameter is vestigial, and is kept only for API

   * @dev compatibility with older versions. It can't *hurt* to mix in some of

   * @dev your own randomness, here, but it's not necessary because the VRF

   * @dev oracle will mix the hash of the block containing your request into the

   * @dev VRF seed it ultimately uses.

   *

   * @param _keyHash ID of public key against which randomness is generated

   * @param _fee The amount of LINK to send with the request

   *

   * @return requestId unique ID for this request

   *

   * @dev The returned requestId can be used to distinguish responses to

   * @dev concurrent requests. It is passed as the first argument to

   * @dev fulfillRandomness.

   */

  function requestRandomness(bytes32 _keyHash, uint256 _fee) internal returns (bytes32 requestId) {

    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));

    // This is the seed passed to VRFCoordinator. The oracle will mix this with

    // the hash of the block containing this request to obtain the seed/input

    // which is finally passed to the VRF cryptographic machinery.

    uint256 vRFSeed = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);

    // nonces[_keyHash] must stay in sync with

    // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above

    // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).

    // This provides protection against the user repeating their input seed,

    // which would result in a predictable/duplicate output, if multiple such

    // requests appeared in the same block.

    nonces[_keyHash] = nonces[_keyHash] + 1;

    return makeRequestId(_keyHash, vRFSeed);

  }



  LinkTokenInterface internal immutable LINK;

  address private immutable vrfCoordinator;



  // Nonces for each VRF key from which randomness has been requested.

  //

  // Must stay in sync with VRFCoordinator[_keyHash][this]

  mapping(bytes32 => uint256) /* keyHash */ /* nonce */

    private nonces;



  /**

   * @param _vrfCoordinator address of VRFCoordinator contract

   * @param _link address of LINK token contract

   *

   * @dev https://docs.chain.link/docs/link-token-contracts

   */

  constructor(address _vrfCoordinator, address _link) {

    vrfCoordinator = _vrfCoordinator;

    LINK = LinkTokenInterface(_link);

  }



  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF

  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating

  // the origin of the call

  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {

    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");

    fulfillRandomness(requestId, randomness);

  }

}



// File: Lottery Contract 5.sol





pragma solidity ^0.8.0;



contract OTTERY_VIP is VRFConsumerBase {

    address public manager;

    address public owner;

    address[] public players;

    address public recentWinner;

    uint256 public randomness;

    bytes32 internal keyHash;

    uint256 internal fee;

    IERC20 public token;

    mapping(address => bool) public isEntered;

    mapping(address => uint256) public lastEnteredBalance;



    uint256 public MIN_TOKENS_TO_ENTER = 200000 * 10**8;

    uint256 public counter;

    uint256 public LOTTERY_TRIGGER_COUNT = 30; // Set the initial trigger count



    // Function to set the number of entries that triggers the lottery

    function setLotteryTriggerCount(uint256 _count) external onlyManager {

    	LOTTERY_TRIGGER_COUNT = _count;

}





    constructor(

        address _vrfCoordinator,

        address _link,

        uint256 _fee,

        bytes32 _keyhash

    ) VRFConsumerBase(_vrfCoordinator, _link) {

        manager = msg.sender;

        owner = msg.sender;

        fee = _fee;

        keyHash = _keyhash;

    }



    function recoverFunds() external onlyManager {

        (bool success, ) = manager.call{value: address(this).balance}("");

        require(success, "Failed to send Ether");

    }



// Function to recover all of a specific ERC20 token held by the contract

    function recoverAllERC20Tokens(address _token) external onlyManager {

        token = IERC20(_token);

        uint256 balance = token.balanceOf(address(this));

        require(balance > 0, "No tokens to recover");

        require(token.transfer(manager, balance), "ERC20 token transfer failed");

    }

    function setToken(address _token) external onlyManager {

        token = IERC20(_token);

    }



    function enter() public {

        address player = msg.sender;

        uint256 currentBalance = token.balanceOf(player);

        require(currentBalance > lastEnteredBalance[player], "Your balance must have increased since last entry");

        require(currentBalance >= MIN_TOKENS_TO_ENTER, "Must hold at least 200,000 tokens");

        players.push(player);

        isEntered[player] = true;

        lastEnteredBalance[player] = currentBalance;

        counter++;



        // Check if the contract has enough balance to start the lottery and if counter is divisible by LOTTERY_TRIGGER_COUNT

    if (address(this).balance >= 2 ether && counter % LOTTERY_TRIGGER_COUNT == 0) {

        startLottery();

    }

        

    }



    function startLottery() private {

        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");

        requestRandomness(keyHash, fee);

    }



    function checkIfWon() public view returns (bool) {

        return recentWinner == msg.sender;

    }



    function startLotteryManually() public onlyManager {

        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");

        requestRandomness(keyHash, fee);

    }



    function fulfillRandomness(bytes32 /*requestId*/, uint256 randomnessResult) internal override {

        randomness = randomnessResult;

        uint256 index = randomness % players.length;

        recentWinner = players[index];

        uint256 prizeAmount = address(this).balance / 2; // Calculate 50% of the contract's balance

        // Check if the contract has enough balance to send

        require(address(this).balance >= prizeAmount, "Not enough balance in contract to send prize");

        (bool sent, ) = recentWinner.call{value: prizeAmount}( "");

        require(sent, "Failed to send Ether");

        players = new address[](0); // Reset players array

        for (uint256 i = 0; i < players.length; i++) {

            isEntered[players[i]] = false;

        }

    }

  



    function setChainlinkFee(uint256 _fee) external onlyManager {

        fee = _fee;

    }



    function setMinTokensToEnter(uint256 _minTokens) external onlyManager {

        MIN_TOKENS_TO_ENTER = _minTokens;

    }





    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }





    modifier onlyManager() {

        require(msg.sender == manager);

        _;

    }



    receive() external payable {}

}