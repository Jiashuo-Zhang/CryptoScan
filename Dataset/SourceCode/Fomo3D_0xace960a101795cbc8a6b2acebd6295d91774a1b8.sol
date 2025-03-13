/**

 *Submitted for verification at Etherscan.io on 2024-01-09

*/



// File: @openzeppelin/[email protected]/utils/introspection/IERC165.sol





// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)



pragma solidity ^0.8.0;



/**

 * @dev Interface of the ERC165 standard, as defined in the

 * https://eips.ethereum.org/EIPS/eip-165[EIP].

 *

 * Implementers can declare support of contract interfaces, which can then be

 * queried by others ({ERC165Checker}).

 *

 * For an implementation, see {ERC165}.

 */

interface IERC165 {

    /**

     * @dev Returns true if this contract implements the interface defined by

     * `interfaceId`. See the corresponding

     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]

     * to learn more about how these ids are created.

     *

     * This function call must use less than 30 000 gas.

     */

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



// File: @openzeppelin/[email protected]/utils/introspection/ERC165.sol





// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)



pragma solidity ^0.8.0;





/**

 * @dev Implementation of the {IERC165} interface.

 *

 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check

 * for the additional interface id that will be supported. For example:

 *

 * ```solidity

 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);

 * }

 * ```

 *

 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.

 */

abstract contract ERC165 is IERC165 {

    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IERC165).interfaceId;

    }

}



// File: @openzeppelin/[email protected]/utils/Strings.sol





// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)



pragma solidity ^0.8.0;



/**

 * @dev String operations.

 */

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";



    /**

     * @dev Converts a `uint256` to its ASCII `string` decimal representation.

     */

    function toString(uint256 value) internal pure returns (string memory) {

        // Inspired by OraclizeAPI's implementation - MIT licence

        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol



        if (value == 0) {

            return "0";

        }

        uint256 temp = value;

        uint256 digits;

        while (temp != 0) {

            digits++;

            temp /= 10;

        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {

            digits -= 1;

            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));

            value /= 10;

        }

        return string(buffer);

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.

     */

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {

            return "0x00";

        }

        uint256 temp = value;

        uint256 length = 0;

        while (temp != 0) {

            length++;

            temp >>= 8;

        }

        return toHexString(value, length);

    }



    /**

     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.

     */

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);

        buffer[0] = "0";

        buffer[1] = "x";

        for (uint256 i = 2 * length + 1; i > 1; --i) {

            buffer[i] = _HEX_SYMBOLS[value & 0xf];

            value >>= 4;

        }

        require(value == 0, "Strings: hex length insufficient");

        return string(buffer);

    }

}



// File: @openzeppelin/[email protected]/utils/Context.sol





// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)



pragma solidity ^0.8.0;



/**

 * @dev Provides information about the current execution context, including the

 * sender of the transaction and its data. While these are generally available

 * via msg.sender and msg.data, they should not be accessed in such a direct

 * manner, since when dealing with meta-transactions the account sending and

 * paying for execution may not be the actual sender (as far as an application

 * is concerned).

 *

 * This contract is only required for intermediate, library-like contracts.

 */

abstract contract Context {

    function _msgSender() internal view virtual returns (address) {

        return msg.sender;

    }



    function _msgData() internal view virtual returns (bytes calldata) {

        return msg.data;

    }

}



// File: @openzeppelin/[email protected]/access/IAccessControl.sol





// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)



pragma solidity ^0.8.0;



/**

 * @dev External interface of AccessControl declared to support ERC165 detection.

 */

interface IAccessControl {

    /**

     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`

     *

     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite

     * {RoleAdminChanged} not being emitted signaling this.

     *

     * _Available since v3.1._

     */

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);



    /**

     * @dev Emitted when `account` is granted `role`.

     *

     * `sender` is the account that originated the contract call, an admin role

     * bearer except when using {AccessControl-_setupRole}.

     */

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);



    /**

     * @dev Emitted when `account` is revoked `role`.

     *

     * `sender` is the account that originated the contract call:

     *   - if using `revokeRole`, it is the admin role bearer

     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)

     */

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);



    /**

     * @dev Returns `true` if `account` has been granted `role`.

     */

    function hasRole(bytes32 role, address account) external view returns (bool);



    /**

     * @dev Returns the admin role that controls `role`. See {grantRole} and

     * {revokeRole}.

     *

     * To change a role's admin, use {AccessControl-_setRoleAdmin}.

     */

    function getRoleAdmin(bytes32 role) external view returns (bytes32);



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function grantRole(bytes32 role, address account) external;



    /**

     * @dev Revokes `role` from `account`.

     *

     * If `account` had been granted `role`, emits a {RoleRevoked} event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function revokeRole(bytes32 role, address account) external;



    /**

     * @dev Revokes `role` from the calling account.

     *

     * Roles are often managed via {grantRole} and {revokeRole}: this function's

     * purpose is to provide a mechanism for accounts to lose their privileges

     * if they are compromised (such as when a trusted device is misplaced).

     *

     * If the calling account had been granted `role`, emits a {RoleRevoked}

     * event.

     *

     * Requirements:

     *

     * - the caller must be `account`.

     */

    function renounceRole(bytes32 role, address account) external;

}



// File: @openzeppelin/[email protected]/access/AccessControl.sol





// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)



pragma solidity ^0.8.0;











/**

 * @dev Contract module that allows children to implement role-based access

 * control mechanisms. This is a lightweight version that doesn't allow enumerating role

 * members except through off-chain means by accessing the contract event logs. Some

 * applications may benefit from on-chain enumerability, for those cases see

 * {AccessControlEnumerable}.

 *

 * Roles are referred to by their `bytes32` identifier. These should be exposed

 * in the external API and be unique. The best way to achieve this is by

 * using `public constant` hash digests:

 *

 * ```

 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");

 * ```

 *

 * Roles can be used to represent a set of permissions. To restrict access to a

 * function call, use {hasRole}:

 *

 * ```

 * function foo() public {

 *     require(hasRole(MY_ROLE, msg.sender));

 *     ...

 * }

 * ```

 *

 * Roles can be granted and revoked dynamically via the {grantRole} and

 * {revokeRole} functions. Each role has an associated admin role, and only

 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.

 *

 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means

 * that only accounts with this role will be able to grant or revoke other

 * roles. More complex role relationships can be created by using

 * {_setRoleAdmin}.

 *

 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to

 * grant and revoke this role. Extra precautions should be taken to secure

 * accounts that have been granted it.

 */

abstract contract AccessControl is Context, IAccessControl, ERC165 {

    struct RoleData {

        mapping(address => bool) members;

        bytes32 adminRole;

    }



    mapping(bytes32 => RoleData) private _roles;



    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;



    /**

     * @dev Modifier that checks that an account has a specific role. Reverts

     * with a standardized message including the required role.

     *

     * The format of the revert reason is given by the following regular expression:

     *

     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/

     *

     * _Available since v4.1._

     */

    modifier onlyRole(bytes32 role) {

        _checkRole(role, _msgSender());

        _;

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {

        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);

    }



    /**

     * @dev Returns `true` if `account` has been granted `role`.

     */

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {

        return _roles[role].members[account];

    }



    /**

     * @dev Revert with a standard message if `account` is missing `role`.

     *

     * The format of the revert reason is given by the following regular expression:

     *

     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/

     */

    function _checkRole(bytes32 role, address account) internal view virtual {

        if (!hasRole(role, account)) {

            revert(

                string(

                    abi.encodePacked(

                        "AccessControl: account ",

                        Strings.toHexString(uint160(account), 20),

                        " is missing role ",

                        Strings.toHexString(uint256(role), 32)

                    )

                )

            );

        }

    }



    /**

     * @dev Returns the admin role that controls `role`. See {grantRole} and

     * {revokeRole}.

     *

     * To change a role's admin, use {_setRoleAdmin}.

     */

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {

        return _roles[role].adminRole;

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {

        _grantRole(role, account);

    }



    /**

     * @dev Revokes `role` from `account`.

     *

     * If `account` had been granted `role`, emits a {RoleRevoked} event.

     *

     * Requirements:

     *

     * - the caller must have ``role``'s admin role.

     */

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {

        _revokeRole(role, account);

    }



    /**

     * @dev Revokes `role` from the calling account.

     *

     * Roles are often managed via {grantRole} and {revokeRole}: this function's

     * purpose is to provide a mechanism for accounts to lose their privileges

     * if they are compromised (such as when a trusted device is misplaced).

     *

     * If the calling account had been revoked `role`, emits a {RoleRevoked}

     * event.

     *

     * Requirements:

     *

     * - the caller must be `account`.

     */

    function renounceRole(bytes32 role, address account) public virtual override {

        require(account == _msgSender(), "AccessControl: can only renounce roles for self");



        _revokeRole(role, account);

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * If `account` had not been already granted `role`, emits a {RoleGranted}

     * event. Note that unlike {grantRole}, this function doesn't perform any

     * checks on the calling account.

     *

     * [WARNING]

     * ====

     * This function should only be called from the constructor when setting

     * up the initial roles for the system.

     *

     * Using this function in any other way is effectively circumventing the admin

     * system imposed by {AccessControl}.

     * ====

     *

     * NOTE: This function is deprecated in favor of {_grantRole}.

     */

    function _setupRole(bytes32 role, address account) internal virtual {

        _grantRole(role, account);

    }



    /**

     * @dev Sets `adminRole` as ``role``'s admin role.

     *

     * Emits a {RoleAdminChanged} event.

     */

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {

        bytes32 previousAdminRole = getRoleAdmin(role);

        _roles[role].adminRole = adminRole;

        emit RoleAdminChanged(role, previousAdminRole, adminRole);

    }



    /**

     * @dev Grants `role` to `account`.

     *

     * Internal function without access restriction.

     */

    function _grantRole(bytes32 role, address account) internal virtual {

        if (!hasRole(role, account)) {

            _roles[role].members[account] = true;

            emit RoleGranted(role, account, _msgSender());

        }

    }



    /**

     * @dev Revokes `role` from `account`.

     *

     * Internal function without access restriction.

     */

    function _revokeRole(bytes32 role, address account) internal virtual {

        if (hasRole(role, account)) {

            _roles[role].members[account] = false;

            emit RoleRevoked(role, account, _msgSender());

        }

    }

}



// File: contracts/Iins.sol







pragma solidity ^0.8;





/**

 * @dev Required interface of an ERC721 compliant contract.

 */

interface Iins  {

    /**

     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.

     */

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);



    /**

     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.

     */

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);



    /**

     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.

     */

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);



    /**

     * @dev Returns the number of tokens in ``owner``'s account.

     */

    function balanceOf(address owner) external view returns (uint256 balance);



    /**

     * @dev Returns the owner of the `tokenId` token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function ownerOf(uint256 tokenId) external view returns (address owner);



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon

     *   a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;



    /**

     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients

     * are aware of the ERC721 protocol to prevent tokens from being forever locked.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must exist and be owned by `from`.

     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or

     *   {setApprovalForAll}.

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon

     *   a safe transfer.

     *

     * Emits a {Transfer} event.

     */

    function safeTransferFrom(address from, address to, uint256 tokenId) external;



    /**

     * @dev Transfers `tokenId` token from `from` to `to`.

     *

     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721

     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must

     * understand this adds an external call which potentially creates a reentrancy vulnerability.

     *

     * Requirements:

     *

     * - `from` cannot be the zero address.

     * - `to` cannot be the zero address.

     * - `tokenId` token must be owned by `from`.

     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.

     *

     * Emits a {Transfer} event.

     */

    function transferFrom(address from, address to, uint256 tokenId) external;



    /**

     * @dev Gives permission to `to` to transfer `tokenId` token to another account.

     * The approval is cleared when the token is transferred.

     *

     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.

     *

     * Requirements:

     *

     * - The caller must own the token or be an approved operator.

     * - `tokenId` must exist.

     *

     * Emits an {Approval} event.

     */

    function approve(address to, uint256 tokenId) external;



    /**

     * @dev Approve or remove `operator` as an operator for the caller.

     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.

     *

     * Requirements:

     *

     * - The `operator` cannot be the address zero.

     *

     * Emits an {ApprovalForAll} event.

     */

    function setApprovalForAll(address operator, bool approved) external;



    /**

     * @dev Returns the account approved for `tokenId` token.

     *

     * Requirements:

     *

     * - `tokenId` must exist.

     */

    function getApproved(uint256 tokenId) external view returns (address operator);



    /**

     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.

     *

     * See {setApprovalForAll}

     */

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**

    * @dev check the balance of the inscription

    */



    function burn(uint tokenId)external ;







}

// File: contracts/fomo7defi.sol





pragma solidity ^0.8.0;







contract Fomo3D is AccessControl{

    Iins ins;

    address public lastBuyer;

    uint256 public endTime;



    uint constant ONE_ETH = 10**18;

    uint256 public constant ROUND_DURATION = 5 minutes;  





    uint public accounter;

    mapping (address => uint) public balance;

    mapping (address => uint) public share;

    mapping (address => uint) public points;

    uint public totalShare;





    uint public jackpot;

    uint public lpFund;

    uint public shareFund;



    //defi

 

    uint public borrowedJackpot;

    uint public borrowedLpFund;

    uint public borrowedShareFund;







    mapping (uint => mapping (address =>uint)) public fomoLaunch;// index => user => balance

    mapping (uint => mapping (address =>uint)) public whiteListFomoLaunch;

    mapping (uint =>bool) public islaunch;

    uint public launchIndex;

    uint public launchStarTime;

    uint public launchEndTime;



    address public whiteListAddr;

    uint public whiteListLaunchIndex;

    uint public whiteListLaunchStarTime;

    uint public whiteListLaunchEndTime;







    uint256 private _guard;



    uint public jackpotRate;

    uint public shareRate;

    uint public lpRate;



    uint public shareTax;







    modifier nonReentrant() {

        require(_guard == 0, "ReentrancyGuard: reentrant call");

        _guard = 1;

        _;

        _guard = 0;

    }



    bytes32 public constant DEFI_ROLE = keccak256("DEFI_ROLE");

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");







    event BuyTickt(address indexed _user,uint indexed _amount);

    event BurnShare(address indexed _user,uint indexed _amount);



    constructor(uint _jackpotRate,uint _shareRate,uint _lpRate, uint _shareTax) {

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _grantRole(DEFI_ROLE, msg.sender);

        _grantRole(ADMIN_ROLE, msg.sender);

        startNewRound();

        accounter = 1;

        require(_jackpotRate + _shareRate + _lpRate == 100,"fuck");

        jackpotRate = _jackpotRate;

        shareRate = _shareRate;

        lpRate = _lpRate;

        shareTax = _shareTax;

    }



    fallback() external payable { }

    receive() external payable { }



    function setLaunch(uint _starTime, uint _endTime,uint _index) public onlyRole(ADMIN_ROLE){

    

        launchStarTime = _starTime;

        launchEndTime = _endTime;

        launchIndex = _index;



    }

    function setWhiteListLaunch(address _whiteListAddr,uint _starTime, uint _endTime,uint _index) public onlyRole(ADMIN_ROLE){

        ins = Iins(_whiteListAddr);

        whiteListAddr = _whiteListAddr;

        whiteListLaunchStarTime = _starTime;

        whiteListLaunchEndTime = _endTime;

        whiteListLaunchIndex = _index;

    }



    function resetRate(uint _jackpotRate,uint _shareRate,uint _lpRate, uint _shareTax)public onlyRole(ADMIN_ROLE){

        require(_jackpotRate + _shareRate + _lpRate == 100,"fuck");

        jackpotRate = _jackpotRate;

        shareRate = _shareRate;

        lpRate = _lpRate;

        shareTax = _shareTax;

    }







    function startNewRound() internal {

        lastBuyer = address(0);

        endTime = block.timestamp + ROUND_DURATION;

    }



    function buyTicketByAmount(uint amount) external payable nonReentrant {

        require(block.timestamp < endTime, "Game over");

        require(msg.value >= amount * 3000000000000000, "Value sent must be greater than 0.003eth");

        uint ethAmount = msg.value;





        if (lastBuyer == address(0)) {

            lpFund += msg.value ;

        } else {

            jackpot += ethAmount*jackpotRate/100;

            lpFund += ethAmount*lpRate/100;

            shareFund += ethAmount*shareRate/100;

        }



        



        



        if(accounter <= 21000){

            balance[msg.sender] += amount * 1000;

        }

        if((accounter > 21000)&&(accounter < 100000))

        {

            points[msg.sender] += amount * getTimeLeft();

        }



        if((accounter > launchStarTime)&&(accounter < launchEndTime))

        {

            fomoLaunch[launchIndex][msg.sender] += amount;

        }



        if((accounter > whiteListLaunchStarTime)&&(accounter < whiteListLaunchEndTime))

        {

            if(ins.balanceOf(msg.sender)>0){

                whiteListFomoLaunch[whiteListLaunchIndex][msg.sender] += amount;

            }



        }



        share[msg.sender] += amount * calShare();

        totalShare += amount * calShare();





        lastBuyer = msg.sender;

        endTime = block.timestamp + ROUND_DURATION;



        accounter = accounter + amount;



        emit BuyTickt(msg.sender, amount * calShare());

    }









    function calShare() public view returns(uint){

        if(accounter <= 3000){

            uint calShareAmount = 3000000 - accounter*700;

            return calShareAmount;

        }else if(accounter < 10000){

            return 500000 - accounter*40;

        }else if(accounter < 30000){

            return 50000 - accounter;

        }else if(accounter < 300000){

            return 1000;

        }else if(accounter < 1000000){

            return 100;

        }else{

            return 10;

        }

    }





    function endRound() external onlyRole(ADMIN_ROLE){

        require(block.timestamp >= endTime, "Round not over yet");

        payable(lastBuyer).transfer(jackpot/2);

        jackpot = jackpot/2;



        startNewRound();

    }



    function eth()external onlyRole(ADMIN_ROLE) {

        payable(msg.sender).transfer(lpFund);

        lpFund = 0;

    }



    function burnShareGetRewards()external nonReentrant(){

        require(share[msg.sender] >0,"require share > 0");

        emit BurnShare(msg.sender,share[msg.sender]);

        uint amount = calShareReward();

        uint ethAmountWithFee = amount*(100 - shareTax)/100;



        totalShare -= share[msg.sender];

        share[msg.sender] = 0;

        shareFund -= ethAmountWithFee;

        payable (msg.sender).transfer(ethAmountWithFee);

        //emit BurnShare(msg.sender, _amount);



    }





    function burnShareGetRewardsByAmount(uint amount)external nonReentrant(){

        require(share[msg.sender] >0,"require share > 0");

        require(amount >0,"require share > 0");

        require(amount <= share[msg.sender],"not enought share");

        emit BurnShare(msg.sender,amount);

        

        uint ethAmount = calShareRewardByAmount(amount);

        uint ethAmountWithFee = ethAmount*(100 - shareTax)/100;

        //uint sharePoolFee = ethAmount*10/100;



        totalShare -= amount;

        share[msg.sender] -= amount;

        

        shareFund -= ethAmountWithFee;



        









        payable (msg.sender).transfer(ethAmountWithFee);

        //emit BurnShare(msg.sender, _amount);



    }



    function calShareReward() public view returns(uint){

        uint reward = shareFund*share[msg.sender]/totalShare;

        return reward;

    }



    function calShareRewardByAmount(uint amount) public view returns(uint){

        uint reward = shareFund*amount/totalShare;

        return reward;

    }



    function calShareRewardByUser(address user) public view returns(uint){

        uint reward = shareFund*share[user]/totalShare;

        return reward;

    }



    function getCurrentJackpot() external view returns (uint256) {

        return jackpot;

    }



    function getTimeLeft() public view returns (uint256) {

        if (block.timestamp < endTime) {

            return endTime - block.timestamp;

        } else {

            return 0;

        }

    }

    //defi



    function borrowJackpot(uint amount) public onlyRole(DEFI_ROLE){

        payable (msg.sender).transfer(amount);

        borrowedJackpot += amount;



    }



    function borrowSharePool(uint amount) public onlyRole(DEFI_ROLE){

        payable (msg.sender).transfer(amount);

        borrowedShareFund += amount;

    }



    function borrowLpPool(uint amount) public onlyRole(DEFI_ROLE){

        payable (msg.sender).transfer(amount);

        borrowedLpFund += amount;

    }



    function repayJackpot() public payable onlyRole(DEFI_ROLE){

        uint amount = msg.value;

        borrowedJackpot -= amount;



    }



    function repaySharePool() public payable onlyRole(DEFI_ROLE){

        uint amount = msg.value;

        borrowedShareFund -= amount;

    }



    function repayLpPool() public payable onlyRole(DEFI_ROLE){

        uint amount = msg.value;

        borrowedLpFund -= amount;

    }

    function calErrorEth()public view returns (uint256){

        uint ethBalance = address(this).balance;

        uint errorEthAmount = ethBalance - jackpot - lpFund - shareFund - borrowedJackpot - borrowedLpFund - borrowedShareFund;

        return errorEthAmount;

    }



    function withdrawErrorTransferEth() public onlyRole(DEFI_ROLE){

        uint ethBalance = address(this).balance;

        uint errorEthAmount = ethBalance - jackpot - lpFund - shareFund - borrowedJackpot - borrowedLpFund - borrowedShareFund;

        payable (msg.sender).transfer(errorEthAmount);

    }







}