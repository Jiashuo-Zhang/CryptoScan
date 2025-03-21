/**

 *Submitted for verification at Etherscan.io on 2019-12-02

*/



/**

 *Submitted for verification at Etherscan.io on 2019-12-02

*/



pragma solidity ^0.5.4;



/**

 * ERC20 contract interface.

 */

contract ERC20 {

    function totalSupply() public view returns (uint);

    function decimals() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

}



/**

 * @title Module

 * @dev Interface for a module. 

 * A module MUST implement the addModule() method to ensure that a wallet with at least one module

 * can never end up in a "frozen" state.

 * @author Julien Niset - <[email protected]>

 */

interface Module {

    function init(BaseWallet _wallet) external;

    function addModule(BaseWallet _wallet, Module _module) external;

    function recoverToken(address _token) external;

}



/**

 * @title BaseWallet

 * @dev Simple modular wallet that authorises modules to call its invoke() method.

 * Based on https://gist.github.com/Arachnid/a619d31f6d32757a4328a428286da186 by 

 * @author Julien Niset - <[email protected]>

 */

contract BaseWallet {

    address public implementation;

    address public owner;

    mapping (address => bool) public authorised;

    mapping (bytes4 => address) public enabled;

    uint public modules;

    function init(address _owner, address[] calldata _modules) external;

    function authoriseModule(address _module, bool _value) external;

    function enableStaticCall(address _module, bytes4 _method) external;

    function setOwner(address _newOwner) external;

    function invoke(address _target, uint _value, bytes calldata _data) external;

    function() external payable;

}



/**

 * @title ModuleRegistry

 * @dev Registry of authorised modules. 

 * Modules must be registered before they can be authorised on a wallet.

 * @author Julien Niset - <[email protected]>

 */

contract ModuleRegistry {

    function registerModule(address _module, bytes32 _name) external;

    function deregisterModule(address _module) external;

    function registerUpgrader(address _upgrader, bytes32 _name) external;

    function deregisterUpgrader(address _upgrader) external;

    function recoverToken(address _token) external;

    function moduleInfo(address _module) external view returns (bytes32);

    function upgraderInfo(address _upgrader) external view returns (bytes32);

    function isRegisteredModule(address _module) external view returns (bool);

    function isRegisteredModule(address[] calldata _modules) external view returns (bool);

    function isRegisteredUpgrader(address _upgrader) external view returns (bool);

}



/**

 * @title GuardianStorage

 * @dev Contract storing the state of wallets related to guardians and lock.

 * The contract only defines basic setters and getters with no logic. Only modules authorised

 * for a wallet can modify its state.

 * @author Julien Niset - <[email protected]>

 * @author Olivier Van Den Biggelaar - <[email protected]>

 */

contract GuardianStorage {

    function addGuardian(BaseWallet _wallet, address _guardian) external;

    function revokeGuardian(BaseWallet _wallet, address _guardian) external;

    function guardianCount(BaseWallet _wallet) external view returns (uint256);

    function getGuardians(BaseWallet _wallet) external view returns (address[] memory);

    function isGuardian(BaseWallet _wallet, address _guardian) external view returns (bool);

    function setLock(BaseWallet _wallet, uint256 _releaseAfter) external;

    function isLocked(BaseWallet _wallet) external view returns (bool);

    function getLock(BaseWallet _wallet) external view returns (uint256);

    function getLocker(BaseWallet _wallet) external view returns (address);

}



// Interface to MakerDAO's Tub contract, used to manage CDPs

contract IMakerCdp {

    IDSValue  public pep; // MKR price feed

    IMakerVox public vox; // DAI price feed



    function sai() external view returns (address);  // DAI

    function skr() external view returns (address);  // PETH

    function gem() external view returns (address);  // WETH

    function gov() external view returns (address);  // MKR



    function lad(bytes32 cup) external view returns (address);

    function ink(bytes32 cup) external view returns (uint);

    function tab(bytes32 cup) external returns (uint);

    function rap(bytes32 cup) external returns (uint);



    function tag() public view returns (uint wad);

    function mat() public view returns (uint ray);

    function per() public view returns (uint ray);

    function safe(bytes32 cup) external returns (bool);

    function ask(uint wad) public view returns (uint);

    function bid(uint wad) public view returns (uint);



    function open() external returns (bytes32 cup);

    function join(uint wad) external; // Join PETH

    function exit(uint wad) external; // Exit PETH

    function give(bytes32 cup, address guy) external;

    function lock(bytes32 cup, uint wad) external;

    function free(bytes32 cup, uint wad) external;

    function draw(bytes32 cup, uint wad) external;

    function wipe(bytes32 cup, uint wad) external;

    function shut(bytes32 cup) external;

    function bite(bytes32 cup) external;

}



interface IMakerVox {

    function par() external returns (uint);

}



interface IDSValue {

    function peek() external view returns (bytes32, bool);

    function read() external view returns (bytes32);

    function poke(bytes32 wut) external;

    function void() external;

} 



interface UniswapFactory {

    function getExchange(address _token) external view returns(address);

}



interface UniswapExchange {

    function getEthToTokenOutputPrice(uint256 _tokens_bought) external view returns (uint256);

    function getEthToTokenInputPrice(uint256 _eth_sold) external view returns (uint256);

    function getTokenToEthOutputPrice(uint256 _eth_bought) external view returns (uint256);

    function getTokenToEthInputPrice(uint256 _tokens_sold) external view returns (uint256);

}



/**

 * @title Interface for a contract that can loan tokens to a wallet.

 * @author Julien Niset - <[email protected]>

 */

interface Loan {



    event LoanOpened(address indexed _wallet, bytes32 indexed _loanId, address _collateral, uint256 _collateralAmount, address _debtToken, uint256 _debtAmount);

    event LoanClosed(address indexed _wallet, bytes32 indexed _loanId);

    event CollateralAdded(address indexed _wallet, bytes32 indexed _loanId, address _collateral, uint256 _collateralAmount);

    event CollateralRemoved(address indexed _wallet, bytes32 indexed _loanId, address _collateral, uint256 _collateralAmount);

    event DebtAdded(address indexed _wallet, bytes32 indexed _loanId, address _debtToken, uint256 _debtAmount);

    event DebtRemoved(address indexed _wallet, bytes32 indexed _loanId, address _debtToken, uint256 _debtAmount);



    /**

     * @dev Opens a collateralized loan.

     * @param _wallet The target wallet.

     * @param _collateral The token used as a collateral.

     * @param _collateralAmount The amount of collateral token provided.

     * @param _debtToken The token borrowed.

     * @param _debtAmount The amount of tokens borrowed.

     * @return (optional) An ID for the loan when the provider enables users to create multiple distinct loans.

     */

    function openLoan(

        BaseWallet _wallet, 

        address _collateral, 

        uint256 _collateralAmount, 

        address _debtToken, 

        uint256 _debtAmount

    ) 

        external 

        returns (bytes32 _loanId);



    /**

     * @dev Closes a collateralized loan by repaying all debts (plus interest) and redeeming all collateral (plus interest).

     * @param _wallet The target wallet.

     * @param _loanId The ID of the loan if any, 0 otherwise.

     */

    function closeLoan(

        BaseWallet _wallet, 

        bytes32 _loanId

    ) 

        external;



    /**

     * @dev Adds collateral to a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the loan if any, 0 otherwise.

     * @param _collateral The token used as a collateral.

     * @param _collateralAmount The amount of collateral to add.

     */

    function addCollateral(

        BaseWallet _wallet, 

        bytes32 _loanId, 

        address _collateral, 

        uint256 _collateralAmount

    ) 

        external;



    /**

     * @dev Removes collateral from a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the loan if any, 0 otherwise.

     * @param _collateral The token used as a collateral.

     * @param _collateralAmount The amount of collateral to remove.

     */

    function removeCollateral(

        BaseWallet _wallet, 

        bytes32 _loanId, 

        address _collateral, 

        uint256 _collateralAmount

    ) 

        external;



    /**

     * @dev Increases the debt by borrowing more token from a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the loan if any, 0 otherwise.

     * @param _debtToken The token borrowed.

     * @param _debtAmount The amount of token to borrow.

     */

    function addDebt(

        BaseWallet _wallet, 

        bytes32 _loanId, 

        address _debtToken, 

        uint256 _debtAmount

    ) 

        external;



    /**

     * @dev Decreases the debt by repaying some token from a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the loan if any, 0 otherwise.

     * @param _debtToken The token to repay.

     * @param _debtAmount The amount of token to repay.

     */

    function removeDebt(

        BaseWallet _wallet, 

        bytes32 _loanId, 

        address _debtToken, 

        uint256 _debtAmount

    ) 

        external;



    /**

     * @dev Gets information about a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the loan if any, 0 otherwise.

     * @return a status [0: no loan, 1: loan is safe, 2: loan is unsafe and can be liquidated, 3: unable to provide info]

     * and a value (in ETH) representing the value that could still be borrowed when status = 1; or the value of the collateral 

     * that should be added to avoid liquidation when status = 2.     

     */

    function getLoan(

        BaseWallet _wallet, 

        bytes32 _loanId

    ) 

        external 

        view 

        returns (uint8 _status, uint256 _ethValue);

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



    /**

    * @dev Multiplies two numbers, reverts on overflow.

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

    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0); // Solidity only automatically asserts when dividing by 0

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);

        uint256 c = a - b;



        return c;

    }



    /**

    * @dev Adds two numbers, reverts on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a);



        return c;

    }



    /**

    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

    * reverts when dividing by zero.

    */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);

        return a % b;

    }



    /**

    * @dev Returns ceil(a / b).

    */

    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;

        if(a % b == 0) {

            return c;

        }

        else {

            return c + 1;

        }

    }



    // from DSMath - operations on fixed precision floats



    uint256 constant WAD = 10 ** 18;

    uint256 constant RAY = 10 ** 27;



    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;

    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;

    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;

    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;

    }

}



/**

 * @title BaseModule

 * @dev Basic module that contains some methods common to all modules.

 * @author Julien Niset - <[email protected]>

 */

contract BaseModule is Module {



    // The adddress of the module registry.

    ModuleRegistry internal registry;



    event ModuleCreated(bytes32 name);

    event ModuleInitialised(address wallet);



    constructor(ModuleRegistry _registry, bytes32 _name) public {

        registry = _registry;

        emit ModuleCreated(_name);

    }



    /**

     * @dev Throws if the sender is not the target wallet of the call.

     */

    modifier onlyWallet(BaseWallet _wallet) {

        require(msg.sender == address(_wallet), "BM: caller must be wallet");

        _;

    }



    /**

     * @dev Throws if the sender is not the owner of the target wallet or the module itself.

     */

    modifier onlyWalletOwner(BaseWallet _wallet) {

        require(msg.sender == address(this) || isOwner(_wallet, msg.sender), "BM: must be an owner for the wallet");

        _;

    }



    /**

     * @dev Throws if the sender is not the owner of the target wallet.

     */

    modifier strictOnlyWalletOwner(BaseWallet _wallet) {

        require(isOwner(_wallet, msg.sender), "BM: msg.sender must be an owner for the wallet");

        _;

    }



    /**

     * @dev Inits the module for a wallet by logging an event.

     * The method can only be called by the wallet itself.

     * @param _wallet The wallet.

     */

    function init(BaseWallet _wallet) external onlyWallet(_wallet) {

        emit ModuleInitialised(address(_wallet));

    }



    /**

     * @dev Adds a module to a wallet. First checks that the module is registered.

     * @param _wallet The target wallet.

     * @param _module The modules to authorise.

     */

    function addModule(BaseWallet _wallet, Module _module) external strictOnlyWalletOwner(_wallet) {

        require(registry.isRegisteredModule(address(_module)), "BM: module is not registered");

        _wallet.authoriseModule(address(_module), true);

    }



    /**

    * @dev Utility method enbaling anyone to recover ERC20 token sent to the

    * module by mistake and transfer them to the Module Registry. 

    * @param _token The token to recover.

    */

    function recoverToken(address _token) external {

        uint total = ERC20(_token).balanceOf(address(this));

        ERC20(_token).transfer(address(registry), total);

    }



    /**

     * @dev Helper method to check if an address is the owner of a target wallet.

     * @param _wallet The target wallet.

     * @param _addr The address.

     */

    function isOwner(BaseWallet _wallet, address _addr) internal view returns (bool) {

        return _wallet.owner() == _addr;

    }

}



/**

 * @title RelayerModule

 * @dev Base module containing logic to execute transactions signed by eth-less accounts and sent by a relayer. 

 * @author Julien Niset - <[email protected]>

 */

contract RelayerModule is Module {



    uint256 constant internal BLOCKBOUND = 10000;



    mapping (address => RelayerConfig) public relayer; 



    struct RelayerConfig {

        uint256 nonce;

        mapping (bytes32 => bool) executedTx;

    }



    event TransactionExecuted(address indexed wallet, bool indexed success, bytes32 signedHash);



    /**

     * @dev Throws if the call did not go through the execute() method.

     */

    modifier onlyExecute {

        require(msg.sender == address(this), "RM: must be called via execute()");

        _;

    }



    /* ***************** Abstract method ************************* */



    /**

    * @dev Gets the number of valid signatures that must be provided to execute a

    * specific relayed transaction.

    * @param _wallet The target wallet.

    * @param _data The data of the relayed transaction.

    * @return The number of required signatures.

    */

    function getRequiredSignatures(BaseWallet _wallet, bytes memory _data) internal view returns (uint256);



    /**

    * @dev Validates the signatures provided with a relayed transaction.

    * The method MUST throw if one or more signatures are not valid.

    * @param _wallet The target wallet.

    * @param _data The data of the relayed transaction.

    * @param _signHash The signed hash representing the relayed transaction.

    * @param _signatures The signatures as a concatenated byte array.

    */

    function validateSignatures(BaseWallet _wallet, bytes memory _data, bytes32 _signHash, bytes memory _signatures) internal view returns (bool);



    /* ************************************************************ */



    /**

    * @dev Executes a relayed transaction.

    * @param _wallet The target wallet.

    * @param _data The data for the relayed transaction

    * @param _nonce The nonce used to prevent replay attacks.

    * @param _signatures The signatures as a concatenated byte array.

    * @param _gasPrice The gas price to use for the gas refund.

    * @param _gasLimit The gas limit to use for the gas refund.

    */

    function execute(

        BaseWallet _wallet,

        bytes calldata _data, 

        uint256 _nonce, 

        bytes calldata _signatures, 

        uint256 _gasPrice,

        uint256 _gasLimit

    )

        external

        returns (bool success)

    {

        uint startGas = gasleft();

        bytes32 signHash = getSignHash(address(this), address(_wallet), 0, _data, _nonce, _gasPrice, _gasLimit);

        require(checkAndUpdateUniqueness(_wallet, _nonce, signHash), "RM: Duplicate request");

        require(verifyData(address(_wallet), _data), "RM: the wallet authorized is different then the target of the relayed data");

        uint256 requiredSignatures = getRequiredSignatures(_wallet, _data);

        if((requiredSignatures * 65) == _signatures.length) {

            if(verifyRefund(_wallet, _gasLimit, _gasPrice, requiredSignatures)) {

                if(requiredSignatures == 0 || validateSignatures(_wallet, _data, signHash, _signatures)) {

                    // solium-disable-next-line security/no-call-value

                    (success,) = address(this).call(_data);

                    refund(_wallet, startGas - gasleft(), _gasPrice, _gasLimit, requiredSignatures, msg.sender);

                }

            }

        }

        emit TransactionExecuted(address(_wallet), success, signHash); 

    }



    /**

    * @dev Gets the current nonce for a wallet.

    * @param _wallet The target wallet.

    */

    function getNonce(BaseWallet _wallet) external view returns (uint256 nonce) {

        return relayer[address(_wallet)].nonce;

    }



    /**

    * @dev Generates the signed hash of a relayed transaction according to ERC 1077.

    * @param _from The starting address for the relayed transaction (should be the module)

    * @param _to The destination address for the relayed transaction (should be the wallet)

    * @param _value The value for the relayed transaction

    * @param _data The data for the relayed transaction

    * @param _nonce The nonce used to prevent replay attacks.

    * @param _gasPrice The gas price to use for the gas refund.

    * @param _gasLimit The gas limit to use for the gas refund.

    */

    function getSignHash(

        address _from,

        address _to, 

        uint256 _value, 

        bytes memory _data, 

        uint256 _nonce,

        uint256 _gasPrice,

        uint256 _gasLimit

    ) 

        internal 

        pure

        returns (bytes32) 

    {

        return keccak256(

            abi.encodePacked(

                "\x19Ethereum Signed Message:\n32",

                keccak256(abi.encodePacked(byte(0x19), byte(0), _from, _to, _value, _data, _nonce, _gasPrice, _gasLimit))

        ));

    }



    /**

    * @dev Checks if the relayed transaction is unique.

    * @param _wallet The target wallet.

    * @param _nonce The nonce

    * @param _signHash The signed hash of the transaction

    */

    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 _signHash) internal returns (bool) {

        if(relayer[address(_wallet)].executedTx[_signHash] == true) {

            return false;

        }

        relayer[address(_wallet)].executedTx[_signHash] = true;

        return true;

    }



    /**

    * @dev Checks that a nonce has the correct format and is valid. 

    * It must be constructed as nonce = {block number}{timestamp} where each component is 16 bytes.

    * @param _wallet The target wallet.

    * @param _nonce The nonce

    */

    function checkAndUpdateNonce(BaseWallet _wallet, uint256 _nonce) internal returns (bool) {

        if(_nonce <= relayer[address(_wallet)].nonce) {

            return false;

        }   

        uint256 nonceBlock = (_nonce & 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000) >> 128;

        if(nonceBlock > block.number + BLOCKBOUND) {

            return false;

        }

        relayer[address(_wallet)].nonce = _nonce;

        return true;    

    }



    /**

    * @dev Recovers the signer at a given position from a list of concatenated signatures.

    * @param _signedHash The signed hash

    * @param _signatures The concatenated signatures.

    * @param _index The index of the signature to recover.

    */

    function recoverSigner(bytes32 _signedHash, bytes memory _signatures, uint _index) internal pure returns (address) {

        uint8 v;

        bytes32 r;

        bytes32 s;

        // we jump 32 (0x20) as the first slot of bytes contains the length

        // we jump 65 (0x41) per signature

        // for v we load 32 bytes ending with v (the first 31 come from s) then apply a mask

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))

            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))

            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)

        }

        require(v == 27 || v == 28); 

        return ecrecover(_signedHash, v, r, s);

    }



    /**

    * @dev Refunds the gas used to the Relayer. 

    * For security reasons the default behavior is to not refund calls with 0 or 1 signatures. 

    * @param _wallet The target wallet.

    * @param _gasUsed The gas used.

    * @param _gasPrice The gas price for the refund.

    * @param _gasLimit The gas limit for the refund.

    * @param _signatures The number of signatures used in the call.

    * @param _relayer The address of the Relayer.

    */

    function refund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _gasLimit, uint _signatures, address _relayer) internal {

        uint256 amount = 29292 + _gasUsed; // 21000 (transaction) + 7620 (execution of refund) + 672 to log the event + _gasUsed

        // only refund if gas price not null, more than 1 signatures, gas less than gasLimit

        if(_gasPrice > 0 && _signatures > 1 && amount <= _gasLimit) {

            if(_gasPrice > tx.gasprice) {

                amount = amount * tx.gasprice;

            }

            else {

                amount = amount * _gasPrice;

            }

            _wallet.invoke(_relayer, amount, "");

        }

    }



    /**

    * @dev Returns false if the refund is expected to fail.

    * @param _wallet The target wallet.

    * @param _gasUsed The expected gas used.

    * @param _gasPrice The expected gas price for the refund.

    */

    function verifyRefund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _signatures) internal view returns (bool) {

        if(_gasPrice > 0 

            && _signatures > 1 

            && (address(_wallet).balance < _gasUsed * _gasPrice || _wallet.authorised(address(this)) == false)) {

            return false;

        }

        return true;

    }



    /**

    * @dev Checks that the wallet address provided as the first parameter of the relayed data is the same

    * as the wallet passed as the input of the execute() method. 

    @return false if the addresses are different.

    */

    function verifyData(address _wallet, bytes memory _data) private pure returns (bool) {

        require(_data.length >= 36, "RM: Invalid dataWallet");

        address dataWallet;

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            //_data = {length:32}{sig:4}{_wallet:32}{...}

            dataWallet := mload(add(_data, 0x24))

        }

        return dataWallet == _wallet;

    }



    /**

    * @dev Parses the data to extract the method signature. 

    */

    function functionPrefix(bytes memory _data) internal pure returns (bytes4 prefix) {

        require(_data.length >= 4, "RM: Invalid functionPrefix");

        // solium-disable-next-line security/no-inline-assembly

        assembly {

            prefix := mload(add(_data, 0x20))

        }

    }

}



/**

 * @title OnlyOwnerModule

 * @dev Module that extends BaseModule and RelayerModule for modules where the execute() method

 * must be called with one signature frm the owner.

 * @author Julien Niset - <[email protected]>

 */

contract OnlyOwnerModule is BaseModule, RelayerModule {



    // *************** Implementation of RelayerModule methods ********************* //



    // Overrides to use the incremental nonce and save some gas

    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 _signHash) internal returns (bool) {

        return checkAndUpdateNonce(_wallet, _nonce);

    }



    function validateSignatures(BaseWallet _wallet, bytes memory _data, bytes32 _signHash, bytes memory _signatures) internal view returns (bool) {

        address signer = recoverSigner(_signHash, _signatures, 0);

        return isOwner(_wallet, signer); // "OOM: signer must be owner"

    }



    function getRequiredSignatures(BaseWallet _wallet, bytes memory _data) internal view returns (uint256) {

        return 1;

    }

}



/**

 * @title MakerManager

 * @dev Module to borrow tokens with MakerDAO

 * @author Olivier VDB - <[email protected]>, Julien Niset - <[email protected]>

 */

contract MakerManager is Loan, BaseModule, RelayerModule, OnlyOwnerModule {



    bytes32 constant NAME = "MakerManager";



    // The Guardian storage 

    GuardianStorage public guardianStorage;

    // The Maker Tub contract

    IMakerCdp public makerCdp;

    // The Uniswap Factory contract

    UniswapFactory public uniswapFactory;



    // Mock token address for ETH

    address constant internal ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;



    // Method signatures to reduce gas cost at depoyment

    bytes4 constant internal CDP_DRAW = bytes4(keccak256("draw(bytes32,uint256)"));

    bytes4 constant internal CDP_WIPE = bytes4(keccak256("wipe(bytes32,uint256)"));

    bytes4 constant internal CDP_SHUT = bytes4(keccak256("shut(bytes32)"));

    bytes4 constant internal CDP_JOIN = bytes4(keccak256("join(uint256)"));

    bytes4 constant internal CDP_LOCK = bytes4(keccak256("lock(bytes32,uint256)"));

    bytes4 constant internal CDP_FREE = bytes4(keccak256("free(bytes32,uint256)"));

    bytes4 constant internal CDP_EXIT = bytes4(keccak256("exit(uint256)"));

    bytes4 constant internal WETH_DEPOSIT = bytes4(keccak256("deposit()"));

    bytes4 constant internal WETH_WITHDRAW = bytes4(keccak256("withdraw(uint256)"));

    bytes4 constant internal ERC20_APPROVE = bytes4(keccak256("approve(address,uint256)"));

    bytes4 constant internal ETH_TOKEN_SWAP_OUTPUT = bytes4(keccak256("ethToTokenSwapOutput(uint256,uint256)"));

    bytes4 constant internal ETH_TOKEN_SWAP_INPUT = bytes4(keccak256("ethToTokenSwapInput(uint256,uint256)"));

    bytes4 constant internal TOKEN_ETH_SWAP_INPUT = bytes4(keccak256("tokenToEthSwapInput(uint256,uint256,uint256)"));



    using SafeMath for uint256;



    /**

     * @dev Throws if the wallet is locked.

     */

    modifier onlyWhenUnlocked(BaseWallet _wallet) {

        // solium-disable-next-line security/no-block-members

        require(!guardianStorage.isLocked(_wallet), "MakerManager: wallet must be unlocked");

        _;

    }



    constructor(

        ModuleRegistry _registry,

        GuardianStorage _guardianStorage,

        IMakerCdp _makerCdp,

        UniswapFactory _uniswapFactory

    )

        BaseModule(_registry, NAME)

        public

    {

        guardianStorage = _guardianStorage;

        makerCdp = _makerCdp;

        uniswapFactory = _uniswapFactory;

    }



    /* ********************************** Implementation of Loan ************************************* */



   /**

     * @dev Opens a collateralized loan.

     * @param _wallet The target wallet.

     * @param _collateral The token used as a collateral (must be 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE).

     * @param _collateralAmount The amount of collateral token provided.

     * @param _debtToken The token borrowed (must be the address of the DAI contract).

     * @param _debtAmount The amount of tokens borrowed.

     * @return The ID of the created CDP.

     */

    function openLoan(

        BaseWallet _wallet, 

        address _collateral, 

        uint256 _collateralAmount, 

        address _debtToken, 

        uint256 _debtAmount

    ) 

        external 

        onlyWalletOwner(_wallet)

        onlyWhenUnlocked(_wallet)

        returns (bytes32 _loanId)

    {

        require(_collateral == ETH_TOKEN_ADDRESS, "Maker: collateral must be ETH");

        require(_debtToken == makerCdp.sai(), "Maker: debt token must be DAI");

        _loanId = openCdp(_wallet, _collateralAmount, _debtAmount, makerCdp);

        emit LoanOpened(address(_wallet), _loanId, _collateral, _collateralAmount, _debtToken, _debtAmount);

    }



    /**

     * @dev Closes a collateralized loan by repaying all debts (plus interest) and redeeming all collateral (plus interest).

     * @param _wallet The target wallet.

     * @param _loanId The ID of the target CDP.

     */

    function closeLoan(

        BaseWallet _wallet, 

        bytes32 _loanId

    ) 

        external

        onlyWalletOwner(_wallet)

        onlyWhenUnlocked(_wallet)

    {

        closeCdp(_wallet, _loanId, makerCdp, uniswapFactory);

        emit LoanClosed(address(_wallet), _loanId);

    }



    /**

     * @dev Adds collateral to a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the target CDP.

     * @param _collateral The token used as a collateral (must be 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE).

     * @param _collateralAmount The amount of collateral to add.

     */

    function addCollateral(

        BaseWallet _wallet, 

        bytes32 _loanId, 

        address _collateral, 

        uint256 _collateralAmount

    ) 

        external

        onlyWalletOwner(_wallet)

        onlyWhenUnlocked(_wallet)

    {

        require(_collateral == ETH_TOKEN_ADDRESS, "Maker: collateral must be ETH");

        addCollateral(_wallet, _loanId, _collateralAmount, makerCdp);

        emit CollateralAdded(address(_wallet), _loanId, _collateral, _collateralAmount);

    }



    /**

     * @dev Removes collateral from a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the target CDP.

     * @param _collateral The token used as a collateral (must be 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE).

     * @param _collateralAmount The amount of collateral to remove.

     */

    function removeCollateral(

        BaseWallet _wallet, 

        bytes32 _loanId, 

        address _collateral, 

        uint256 _collateralAmount

    ) 

        external 

        onlyWalletOwner(_wallet)

        onlyWhenUnlocked(_wallet)

    {

        require(_collateral == ETH_TOKEN_ADDRESS, "Maker: collateral must be ETH");

        removeCollateral(_wallet, _loanId, _collateralAmount, makerCdp);

        emit CollateralRemoved(address(_wallet), _loanId, _collateral, _collateralAmount);

    }



    /**

     * @dev Increases the debt by borrowing more token from a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the target CDP.

     * @param _debtToken The token borrowed (must be the address of the DAI contract).

     * @param _debtAmount The amount of token to borrow.

     */

    function addDebt(

        BaseWallet _wallet,

        bytes32 _loanId,

        address _debtToken,

        uint256 _debtAmount

    )

        external

        onlyWalletOwner(_wallet)

        onlyWhenUnlocked(_wallet)

    {

        require(_debtToken == makerCdp.sai(), "Maker: debt token must be DAI");

        addDebt(_wallet, _loanId, _debtAmount, makerCdp);

        emit DebtAdded(address(_wallet), _loanId, _debtToken, _debtAmount);

    }



    /**

     * @dev Decreases the debt by repaying some token from a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the target CDP.

     * @param _debtToken The token to repay (must be the address of the DAI contract).

     * @param _debtAmount The amount of token to repay.

     */

    function removeDebt(

        BaseWallet _wallet,

        bytes32 _loanId,

        address _debtToken,

        uint256 _debtAmount

    )

        external

        onlyWalletOwner(_wallet)

        onlyWhenUnlocked(_wallet)

    {

        require(_debtToken == makerCdp.sai(), "Maker: debt token must be DAI");

        removeDebt(_wallet, _loanId, _debtAmount, makerCdp, uniswapFactory);

        emit DebtRemoved(address(_wallet), _loanId, _debtToken, _debtAmount);

    }



    /**

     * @dev Gets information about a loan identified by its ID.

     * @param _wallet The target wallet.

     * @param _loanId The ID of the target CDP.

     * @return a status [0: no loan, 1: loan is safe, 2: loan is unsafe and can be liquidated, 3: loan exists but we are unable to provide info] 

     * and a value (in ETH) representing the value that could still be borrowed when status = 1; or the value of the collateral that should be added to 

     * avoid liquidation when status = 2.      

     */

    function getLoan(

        BaseWallet _wallet, 

        bytes32 _loanId

    ) 

        external 

        view 

        returns (uint8 _status, uint256 _ethValue)

    {

        if(exists(_loanId, makerCdp)) {

            return (3,0);

        }

        return (0,0);

    }



    /* *********************************** Maker wrappers ************************************* */



    /* CDP actions */



    /**

     * @dev Lets the owner of a wallet open a new CDP. The owner must have enough ether 

     * in their wallet. The required amount of ether will be automatically converted to 

     * PETH and used as collateral in the CDP.

     * @param _wallet The target wallet

     * @param _pethCollateral The amount of PETH to lock as collateral in the CDP.

     * @param _daiDebt The amount of DAI to draw from the CDP

     * @param _makerCdp The Maker CDP contract

     * @return The id of the created CDP.

     */

    function openCdp(

        BaseWallet _wallet, 

        uint256 _pethCollateral, 

        uint256 _daiDebt,

        IMakerCdp _makerCdp

    ) 

        internal 

        returns (bytes32 _cup)

    {

        // Open CDP (CDP owner will be module)

        _cup = _makerCdp.open();

        // Transfer CDP ownership to wallet

        _makerCdp.give(_cup, address(_wallet));

        // Convert ETH to PETH & lock PETH into CDP

        lockETH(_wallet, _cup, _pethCollateral, _makerCdp);

        // Draw DAI from CDP

        if(_daiDebt > 0) {

            invokeWallet(_wallet, address(_makerCdp), 0, abi.encodeWithSelector(CDP_DRAW, _cup, _daiDebt));

        }

    }



    /**

     * @dev Lets the owner of a CDP add more collateral to their CDP. The owner must have enough ether 

     * in their wallet. The required amount of ether will be automatically converted to 

     * PETH and locked in the CDP.

     * @param _wallet The target wallet

     * @param _cup The id of the CDP.

     * @param _amount The amount of additional PETH to lock as collateral in the CDP.

     * @param _makerCdp The Maker CDP contract

     */

    function addCollateral(

        BaseWallet _wallet, 

        bytes32 _cup,

        uint256 _amount,

        IMakerCdp _makerCdp

    ) 

        internal

    {

        // _wallet must be owner of CDP

        require(address(_wallet) == _makerCdp.lad(_cup), "CM: not CDP owner");

        // convert ETH to PETH & lock PETH into CDP

        lockETH(_wallet, _cup, _amount, _makerCdp);  

    }



    /**

     * @dev Lets the owner of a CDP remove some collateral from their CDP

     * @param _wallet The target wallet

     * @param _cup The id of the CDP.

     * @param _amount The amount of PETH to remove from the CDP.

     * @param _makerCdp The Maker CDP contract

     */

    function removeCollateral(

        BaseWallet _wallet, 

        bytes32 _cup,

        uint256 _amount,

        IMakerCdp _makerCdp

    ) 

        internal

    {

        // unlock PETH from CDP & convert PETH to ETH

        freeETH(_wallet, _cup, _amount, _makerCdp);

    }



    /**

     * @dev Lets the owner of a CDP draw more DAI from their CDP.

     * @param _wallet The target wallet

     * @param _cup The id of the CDP.

     * @param _amount The amount of additional DAI to draw from the CDP.

     * @param _makerCdp The Maker CDP contract

     */

    function addDebt(

        BaseWallet _wallet, 

        bytes32 _cup,

        uint256 _amount,

        IMakerCdp _makerCdp

    ) 

        internal

    {

        // draw DAI from CDP

        invokeWallet(_wallet, address(_makerCdp), 0, abi.encodeWithSelector(CDP_DRAW, _cup, _amount));

    }



    /**

     * @dev Lets the owner of a CDP partially repay their debt. The repayment is made up of 

     * the outstanding DAI debt (including the stability fee if non-zero) plus the MKR governance fee.

     * The method will use the user's MKR tokens in priority and will, if needed, convert the required 

     * amount of ETH to cover for any missing MKR tokens.

     * @param _wallet The target wallet

     * @param _cup The id of the CDP.

     * @param _amount The amount of DAI debt to repay.

     * @param _makerCdp The Maker CDP contract

     * @param _uniswapFactory The Uniswap Factory contract.

     */

    function removeDebt(

        BaseWallet _wallet, 

        bytes32 _cup,

        uint256 _amount,

        IMakerCdp _makerCdp,

        UniswapFactory _uniswapFactory

    ) 

        internal

    {

        // _wallet must be owner of CDP

        require(address(_wallet) == _makerCdp.lad(_cup), "CM: not CDP owner");

        // get governance fee in MKR

        uint256 mkrFee = governanceFeeInMKR(_cup, _amount, _makerCdp);

        // get MKR balance

        address mkrToken = _makerCdp.gov();

        uint256 mkrBalance = ERC20(mkrToken).balanceOf(address(_wallet));

        if (mkrBalance < mkrFee) {

            // Not enough MKR => Convert some ETH into MKR with Uniswap

            address mkrUniswap = _uniswapFactory.getExchange(mkrToken);

            uint256 etherValueOfMKR = UniswapExchange(mkrUniswap).getEthToTokenOutputPrice(mkrFee - mkrBalance);

            invokeWallet(_wallet, mkrUniswap, etherValueOfMKR, abi.encodeWithSelector(ETH_TOKEN_SWAP_OUTPUT, mkrFee - mkrBalance, block.timestamp));

        }

        

        // get DAI balance

        address daiToken =_makerCdp.sai();

        uint256 daiBalance = ERC20(daiToken).balanceOf(address(_wallet));

        if (daiBalance < _amount) {

            // Not enough DAI => Convert some ETH into DAI with Uniswap

            address daiUniswap = _uniswapFactory.getExchange(daiToken);

            uint256 etherValueOfDAI = UniswapExchange(daiUniswap).getEthToTokenOutputPrice(_amount - daiBalance);

            invokeWallet(_wallet, daiUniswap, etherValueOfDAI, abi.encodeWithSelector(ETH_TOKEN_SWAP_OUTPUT, _amount - daiBalance, block.timestamp));

        }



        // Approve DAI to let wipe() repay the DAI debt

        invokeWallet(_wallet, daiToken, 0, abi.encodeWithSelector(ERC20_APPROVE, address(_makerCdp), _amount));

        // Approve MKR to let wipe() pay the MKR governance fee

        invokeWallet(_wallet, mkrToken, 0, abi.encodeWithSelector(ERC20_APPROVE, address(_makerCdp), mkrFee));

        // repay DAI debt and MKR governance fee

        invokeWallet(_wallet, address(_makerCdp), 0, abi.encodeWithSelector(CDP_WIPE, _cup, _amount));

    }



    /**

     * @dev Lets the owner of a CDP close their CDP. The method will 1) repay all debt 

     * and governance fee, 2) free all collateral, and 3) delete the CDP.

     * @param _wallet The target wallet

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @param _uniswapFactory The Uniswap Factory contract.

     */

    function closeCdp(

        BaseWallet _wallet,

        bytes32 _cup,

        IMakerCdp _makerCdp,

        UniswapFactory _uniswapFactory

    ) 

        internal

    {

        // repay all debt (in DAI) + stability fee (in DAI) + governance fee (in MKR)

        uint debt = daiDebt(_cup, _makerCdp);

        if(debt > 0) removeDebt(_wallet, _cup, debt, _makerCdp, _uniswapFactory);

        // free all ETH collateral

        uint collateral = pethCollateral(_cup, _makerCdp);

        if(collateral > 0) removeCollateral(_wallet, _cup, collateral, _makerCdp);

        // shut the CDP

        invokeWallet(_wallet, address(_makerCdp), 0, abi.encodeWithSelector(CDP_SHUT, _cup));

    }



    /* Convenience methods */



    /**

     * @dev Returns the amount of PETH collateral locked in a CDP.

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @return the amount of PETH locked in the CDP.

     */

    function pethCollateral(bytes32 _cup, IMakerCdp _makerCdp) public view returns (uint256) { 

        return _makerCdp.ink(_cup);

    }



    /**

     * @dev Returns the amount of DAI debt (including the stability fee if non-zero) drawn from a CDP.

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @return the amount of DAI drawn from the CDP.

     */

    function daiDebt(bytes32 _cup, IMakerCdp _makerCdp) public returns (uint256) { 

        return _makerCdp.tab(_cup);

    }



    /**

     * @dev Indicates whether a CDP is above the liquidation ratio.

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @return false if the CDP is in danger of being liquidated.

     */

    function isSafe(bytes32 _cup, IMakerCdp _makerCdp) public returns (bool) { 

        return _makerCdp.safe(_cup);

    }



    /**

     * @dev Checks if a CDP exists.

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @return true if the CDP exists, false otherwise.

     */

    function exists(bytes32 _cup, IMakerCdp _makerCdp) public view returns (bool) { 

        return _makerCdp.lad(_cup) != address(0);

    }



    /**

     * @dev Max amount of DAI that can still be drawn from a CDP while keeping it above the liquidation ratio. 

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @return the amount of DAI that can still be drawn from a CDP while keeping it above the liquidation ratio. 

     */

    function maxDaiDrawable(bytes32 _cup, IMakerCdp _makerCdp) public returns (uint256) {

        uint256 maxTab = _makerCdp.ink(_cup).rmul(_makerCdp.tag()).rdiv(_makerCdp.vox().par()).rdiv(_makerCdp.mat());

        return maxTab.sub(_makerCdp.tab(_cup));

    }



    /**

     * @dev Min amount of collateral that needs to be added to a CDP to bring it above the liquidation ratio. 

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @return the amount of collateral that needs to be added to a CDP to bring it above the liquidation ratio.

     */

    function minCollateralRequired(bytes32 _cup, IMakerCdp _makerCdp) public returns (uint256) {

        uint256 minInk = _makerCdp.tab(_cup).rmul(_makerCdp.mat()).rmul(_makerCdp.vox().par()).rdiv(_makerCdp.tag());

        return minInk.sub(_makerCdp.ink(_cup));

    }



    /**

     * @dev Returns the governance fee in MKR.

     * @param _cup The id of the CDP.

     * @param _daiRefund The amount of DAI debt being repaid.

     * @param _makerCdp The Maker CDP contract

     * @return the governance fee in MKR

     */

    function governanceFeeInMKR(bytes32 _cup, uint256 _daiRefund, IMakerCdp _makerCdp) public returns (uint256 _fee) { 

        uint debt = daiDebt(_cup, _makerCdp);

        if (debt == 0) return 0;

        uint256 feeInDAI = _daiRefund.rmul(_makerCdp.rap(_cup).rdiv(debt));

        (bytes32 daiPerMKR, bool ok) = _makerCdp.pep().peek();

        if (ok && daiPerMKR != 0) _fee = feeInDAI.wdiv(uint(daiPerMKR));

    }



    /**

     * @dev Returns the total MKR governance fee to be paid before this CDP can be closed.

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @return the total governance fee in MKR

     */

    function totalGovernanceFeeInMKR(bytes32 _cup, IMakerCdp _makerCdp) external returns (uint256 _fee) { 

        return governanceFeeInMKR(_cup, daiDebt(_cup, _makerCdp), _makerCdp);

    }



    /**

     * @dev Minimum amount of PETH that must be locked in a CDP for it to be deemed "safe"

     * @param _cup The id of the CDP.

     * @param _makerCdp The Maker CDP contract

     * @return The minimum amount of PETH to lock in the CDP

     */

    function minRequiredCollateral(bytes32 _cup, IMakerCdp _makerCdp) public returns (uint256 _minCollateral) { 

        _minCollateral = daiDebt(_cup, _makerCdp)    // DAI debt

            .rmul(_makerCdp.vox().par())         // x ~1 USD/DAI 

            .rmul(_makerCdp.mat())               // x 1.5

            .rmul(1010000000000000000000000000) // x (1+1%) cushion

            .rdiv(_makerCdp.tag());              // ÷ ~170 USD/PETH

    }



    /* *********************************** Utilities ************************************* */



    /**

     * @dev Converts a user's ETH into PETH and locks the PETH in a CDP

     * @param _wallet The target wallet

     * @param _cup The id of the CDP.

     * @param _pethAmount The amount of PETH to buy and lock

     * @param _makerCdp The Maker CDP contract

     */

    function lockETH(

        BaseWallet _wallet, 

        bytes32 _cup,

        uint256 _pethAmount,

        IMakerCdp _makerCdp

    ) 

        internal 

    {

        // 1. Convert ETH to PETH

        address wethToken = _makerCdp.gem();

        // Get WETH/PETH rate

        uint ethAmount = _makerCdp.ask(_pethAmount);

        // ETH to WETH

        invokeWallet(_wallet, wethToken, ethAmount, abi.encodeWithSelector(WETH_DEPOSIT));

        // Approve WETH

        invokeWallet(_wallet, wethToken, 0, abi.encodeWithSelector(ERC20_APPROVE, address(_makerCdp), ethAmount));

        // WETH to PETH

        invokeWallet(_wallet, address(_makerCdp), 0, abi.encodeWithSelector(CDP_JOIN, _pethAmount));



        // 2. Lock PETH into CDP

        address pethToken = _makerCdp.skr();

        // Approve PETH

        invokeWallet(_wallet, pethToken, 0, abi.encodeWithSelector(ERC20_APPROVE, address(_makerCdp), _pethAmount));

        // lock PETH into CDP

        invokeWallet(_wallet, address(_makerCdp), 0, abi.encodeWithSelector(CDP_LOCK, _cup, _pethAmount));

    }



    /**

     * @dev Unlocks PETH from a user's CDP and converts it back to ETH

     * @param _wallet The target wallet

     * @param _cup The id of the CDP.

     * @param _pethAmount The amount of PETH to unlock and sell

     * @param _makerCdp The Maker CDP contract

     */

    function freeETH(

        BaseWallet _wallet, 

        bytes32 _cup,

        uint256 _pethAmount,

        IMakerCdp _makerCdp

    ) 

        internal 

    {

        // 1. Unlock PETH



        // Unlock PETH from CDP

        invokeWallet(_wallet, address(_makerCdp), 0, abi.encodeWithSelector(CDP_FREE, _cup, _pethAmount));



        // 2. Convert PETH to ETH

        address wethToken = _makerCdp.gem();

        address pethToken = _makerCdp.skr();

        // Approve PETH

        invokeWallet(_wallet, pethToken, 0, abi.encodeWithSelector(ERC20_APPROVE, address(_makerCdp), _pethAmount));

        // PETH to WETH

        invokeWallet(_wallet, address(_makerCdp), 0, abi.encodeWithSelector(CDP_EXIT, _pethAmount));

        // Get WETH/PETH rate

        uint ethAmount = _makerCdp.bid(_pethAmount);

        // WETH to ETH

        invokeWallet(_wallet, wethToken, 0, abi.encodeWithSelector(WETH_WITHDRAW, ethAmount));

    }



    /**

     * @dev Conversion rate between DAI and MKR

     * @param _makerCdp The Maker CDP contract

     * @return The amount of DAI per MKR

     */

    function daiPerMkr(IMakerCdp _makerCdp) internal view returns (uint256 _daiPerMKR) {

        (bytes32 daiPerMKR_, bool ok) = _makerCdp.pep().peek();

        require(ok && daiPerMKR_ != 0, "LM: invalid DAI/MKR rate");

        _daiPerMKR = uint256(daiPerMKR_);

    }



    /**

     * @dev Utility method to invoke a wallet

     * @param _wallet The wallet to invoke.

     * @param _to The target address.

     * @param _value The value.

     * @param _data The data.

     */

    function invokeWallet(BaseWallet _wallet, address _to, uint256 _value, bytes memory _data) internal {

        _wallet.invoke(_to, _value, _data);

    }

}