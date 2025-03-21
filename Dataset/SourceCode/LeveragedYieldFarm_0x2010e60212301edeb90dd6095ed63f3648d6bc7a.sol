/**
 *Submitted for verification at Etherscan.io on 2022-06-08
*/

pragma solidity ^0.5.12;
pragma experimental ABIEncoderV2;

interface Erc20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
}

interface CErc20 {
    function balanceOf(address owner) external view returns (uint);
    function mint(uint256) external returns (uint256);
    function redeem(uint) external returns (uint);
    function redeemUnderlying(uint) external returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function repayBorrow(uint repayAmount) external returns (uint);
}

interface Comptroller {
    function enterMarkets(address[] calldata)
        external
        returns (uint256[] memory);

    function claimComp(address holder) external;

}

interface Structs {
    struct Val {
        uint256 value;
    }

    enum ActionType {
      Deposit,   // supply tokens
      Withdraw,  // borrow tokens
      Transfer,  // transfer balance between accounts
      Buy,       // buy an amount of some token (externally)
      Sell,      // sell an amount of some token (externally)
      Trade,     // trade tokens against another account
      Liquidate, // liquidate an undercollateralized or expiring account
      Vaporize,  // use excess tokens to zero-out a completely negative account
      Call       // send arbitrary data to an address
    }

    enum AssetDenomination {
        Wei // the amount is denominated in wei
    }

    enum AssetReference {
        Delta // the amount is given as a delta from the current value
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }

    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }

    struct Info {
        address owner;  // The address that owns the account
        uint256 number; // A nonce that allows a single address to control many accounts
    }

    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }
}

contract DyDxPool is Structs {
    function getAccountWei(Info memory account, uint256 marketId) public view returns (Wei memory);
    function operate(Info[] memory, ActionArgs[] memory) public;
}

pragma solidity ^0.5.0;


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

pragma solidity ^0.5.0;


contract DyDxFlashLoan is Structs {
    DyDxPool pool = DyDxPool(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);

    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public SAI = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
    address public USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    mapping(address => uint256) public currencies;

    constructor() public {
        currencies[WETH] = 1;
        currencies[SAI] = 2;
        currencies[USDC] = 3;
        currencies[DAI] = 4;
    }

    modifier onlyPool() {
        require(
            msg.sender == address(pool),
            "FlashLoan: could be called by DyDx pool only"
        );
        _;
    }

    function tokenToMarketId(address token) public view returns (uint256) {
        uint256 marketId = currencies[token];
        require(marketId != 0, "FlashLoan: Unsupported token");
        return marketId - 1;
    }

    // the DyDx will call `callFunction(address sender, Info memory accountInfo, bytes memory data) public` after during `operate` call
    function flashloan(address token, uint256 amount, bytes memory data)
        internal
    {
        IERC20(token).approve(address(pool), amount + 1);
        Info[] memory infos = new Info[](1);
        ActionArgs[] memory args = new ActionArgs[](3);

        infos[0] = Info(address(this), 0);

        AssetAmount memory wamt = AssetAmount(
            false,
            AssetDenomination.Wei,
            AssetReference.Delta,
            amount
        );
        ActionArgs memory withdraw;
        withdraw.actionType = ActionType.Withdraw;
        withdraw.accountId = 0;
        withdraw.amount = wamt;
        withdraw.primaryMarketId = tokenToMarketId(token);
        withdraw.otherAddress = address(this);

        args[0] = withdraw;

        ActionArgs memory call;
        call.actionType = ActionType.Call;
        call.accountId = 0;
        call.otherAddress = address(this);
        call.data = data;

        args[1] = call;

        ActionArgs memory deposit;
        AssetAmount memory damt = AssetAmount(
            true,
            AssetDenomination.Wei,
            AssetReference.Delta,
            amount + 1
        );
        deposit.actionType = ActionType.Deposit;
        deposit.accountId = 0;
        deposit.amount = damt;
        deposit.primaryMarketId = tokenToMarketId(token);
        deposit.otherAddress = address(this);

        args[2] = deposit;

        pool.operate(infos, args);
    }
}

pragma solidity ^0.5.0;

contract LeveragedYieldFarm is DyDxFlashLoan  {
    // Mainnet Dai
    // https://etherscan.io/address/0x6b175474e89094c44da98b954eedeac495271d0f#readContract
    address daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    Erc20 dai = Erc20(daiAddress);

    // Mainnet cDai
    // https://etherscan.io/address/0x5d3a536e4d6dbd6114cc1ead35777bab948e3643#readProxyContract
    address cDaiAddress = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    CErc20 cDai = CErc20(cDaiAddress);

    // Mainnet Comptroller
    // https://etherscan.io/address/0x3d9819210a31b4961b30ef54be2aed79b9c9cd3b#readProxyContract
    address comptrollerAddress = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
    Comptroller comptroller = Comptroller(comptrollerAddress);

    // COMP ERC-20 token
    // https://etherscan.io/token/0xc00e94cb662c3520282e6f5717214004a7f26888
    Erc20 compToken = Erc20(0xc00e94Cb662C3520282E6f5717214004A7f26888);

    // Deposit/Withdraw values
    bytes32 DEPOSIT = keccak256("DEPOSIT");
    bytes32 WITHDRAW = keccak256("WITHDRAW");

    // Contract owner
    address payable owner;

    event FlashLoan(address indexed _from, bytes32 indexed _id, uint _value);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner!");
        _;
    }

    // Don't allow contract to receive Ether by mistake
    function() external payable {
        revert();
    }

    constructor() public {
        // Track the contract owner
        owner = msg.sender;

        // Enter the cDai market so you can borrow another type of asset
        address[] memory cTokens = new address[](1);
        cTokens[0] = cDaiAddress;
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        if (errors[0] != 0) {
            revert("Comptroller.enterMarkets failed.");
        }
    }

    // Do not deposit all your DAI because you must pay flash loan fees
    // Always keep at least 1 DAI in the contract
    function depositDai(uint256 initialAmount) external onlyOwner returns (bool){
        // Total deposit: 30% initial amount, 70% flash loan
        uint256 totalAmount = (initialAmount * 10) / 3;

        // loan is 70% of total deposit
        uint256 flashLoanAmount = totalAmount - initialAmount;

        // Get DAI Flash Loan for "DEPOSIT"
        bytes memory data = abi.encode(totalAmount, flashLoanAmount, DEPOSIT);
        flashloan(daiAddress, flashLoanAmount, data); // execution goes to `callFunction`

        // Handle remaining execution inside handleDeposit() function

        return true;
    }


    // You must have some Dai in your contract still to pay flash loan fee!
    // Always keep at least 1 DAI in the contract
    function withdrawDai(uint256 initialAmount) external onlyOwner returns (bool){
        // Total deposit: 30% initial amount, 70% flash loan
        uint256 totalAmount = (initialAmount * 10) / 3;

        // loan is 70% of total deposit
        uint256 flashLoanAmount = totalAmount - initialAmount;

        // Use flash loan to payback borrowed amount
        bytes memory data = abi.encode(totalAmount, flashLoanAmount, WITHDRAW);
        flashloan(daiAddress, flashLoanAmount, data); // execution goes to `callFunction`

        // Handle repayment inside handleWithdraw() function

        // Claim COMP tokens
        comptroller.claimComp(address(this));

        // Withdraw COMP tokens
        compToken.transfer(owner, compToken.balanceOf(address(this)));

        // Withdraw Dai to the wallet
        dai.transfer(owner, dai.balanceOf(address(this)));

        return true;
    }


    function callFunction(
        address, /* sender */
        Info calldata, /* accountInfo */
        bytes calldata data
    ) external onlyPool {
        (uint256 totalAmount, uint256 flashLoanAmount, bytes32 operation) = abi
            .decode(data, (uint256, uint256, bytes32));

        if(operation == DEPOSIT) {
            handleDeposit(totalAmount, flashLoanAmount);
        }

        if(operation == WITHDRAW) {
            handleWithdraw();
        }
    }

    // You must first send DAI to this contract before you can call this function
    function handleDeposit(uint256 totalAmount, uint256 flashLoanAmount) internal returns (bool) {
        // Approve Dai tokens as collateral
        dai.approve(cDaiAddress, totalAmount);

        // Provide collateral by minting cDai tokens
        cDai.mint(totalAmount);

        // Borrow Dai
        cDai.borrow(flashLoanAmount);

        // Start earning COMP tokens, yay!
        return true;
    }

    function handleWithdraw() internal returns (bool) {
        uint256 balance;

        // Get curent borrow Balance
        balance = cDai.borrowBalanceCurrent(address(this));

        // Approve tokens for repayment
        dai.approve(address(cDai), balance);

        // Repay tokens
        cDai.repayBorrow(balance);

        // Get cDai balance
        balance = cDai.balanceOf(address(this));

        // Redeem cDai
        cDai.redeem(balance);

        return true;
    }

    // Fallback in case any other tokens are sent to this contract
    function withdrawToken(address _tokenAddress) public onlyOwner {
        uint256 balance = Erc20(_tokenAddress).balanceOf(address(this));
        Erc20(_tokenAddress).transfer(owner, balance);
    }

}