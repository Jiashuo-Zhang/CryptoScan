{{

  "language": "Solidity",

  "sources": {

    "src/Token.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\n/*\n\n███╗   ███╗███████╗███╗   ███╗███████╗██████╗ ██╗   ██╗██████╗ ██████╗ ██╗   ██╗\n████╗ ████║██╔════╝████╗ ████║██╔════╝██╔══██╗██║   ██║██╔══██╗██╔══██╗╚██╗ ██╔╝\n██╔████╔██║█████╗  ██╔████╔██║█████╗  ██████╔╝██║   ██║██║  ██║██║  ██║ ╚████╔╝ \n██║╚██╔╝██║██╔══╝  ██║╚██╔╝██║██╔══╝  ██╔══██╗██║   ██║██║  ██║██║  ██║  ╚██╔╝  \n██║ ╚═╝ ██║███████╗██║ ╚═╝ ██║███████╗██████╔╝╚██████╔╝██████╔╝██████╔╝   ██║   \n╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚═════╝ ╚═════╝    ╚═╝   \n\n*/\n\npragma solidity ^0.8.13;\n\nimport \"solmate/tokens/ERC20.sol\";\nimport \"solmate/auth/Owned.sol\";\nimport {IWETH, IUniswapV2Router} from \"./Uniswap.sol\";\n\ncontract Token is ERC20, Owned {\n    uint256 public buyTaxRate;\n    uint256 public sellTaxRate;\n    address public rewardsPool;\n    mapping(address => bool) public isExcludedFromTax;\n    mapping(address => bool) public taxableAddresses;\n\n    event RewardsWithdrawn(uint256 amount);\n    event SetRewardsPool(address rewardsPool);\n    event SetExcludedFromTax(address account, bool isExcluded);\n    event SetTaxable(address account, bool isTaxable);\n    event SetUniswap(address weth, address uniswapV2Router);\n    event Withdrawn(uint256 amount);\n\n    // Address of the WETH token. This is needed because Uniswap V3 does not directly support ETH,\n    // but it does support WETH, which is a tokenized version of ETH.\n    IWETH weth;\n\n    // Uniswap V2 router\n    IUniswapV2Router uniswapV2Router;\n\n    /**\n     * @dev Contract constructor that sets initial supply, buy and sell tax rates.\n     * @param _name The name of the token.\n     * @param _symbol The symbol of the token.\n     * @param _initialSupply The initial supply of the token.\n     * @param _buyTaxRate The tax rate for buying the token.\n     * @param _sellTaxRate The tax rate for selling the token.\n     */\n    constructor(\n        string memory _name,\n        string memory _symbol,\n        uint256 _initialSupply,\n        uint256 _buyTaxRate,\n        uint256 _sellTaxRate\n    ) ERC20(_name, _symbol, 18) Owned(msg.sender) {\n        _mint(msg.sender, _initialSupply);\n        buyTaxRate = _buyTaxRate;\n        sellTaxRate = _sellTaxRate;\n        isExcludedFromTax[address(this)] = true;\n    }\n\n    /**\n     * @dev Overrides the transfer function of the ERC20 standard.\n     * @param to The address to transfer to.\n     * @param amount The amount to be transferred.\n     * @return A boolean that indicates if the operation was successful.\n     */\n    function transfer(address to, uint256 amount) public override returns (bool) {\n        uint256 transferAmount = calcTax(msg.sender, to, amount);\n\n        balanceOf[msg.sender] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += transferAmount;\n        }\n\n        emit Transfer(msg.sender, to, transferAmount);\n\n        return true;\n    }\n\n    /**\n     * @dev Overrides the transferFrom function of the ERC20 standard.\n     * @param from The address to transfer from.\n     * @param to The address to transfer to.\n     * @param amount The amount to be transferred.\n     * @return A boolean that indicates if the operation was successful.\n     */\n    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\n\n        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;\n\n        uint256 transferAmount = calcTax(from, to, amount);\n\n        balanceOf[from] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += transferAmount;\n        }\n\n        emit Transfer(from, to, transferAmount);\n\n        return true;\n    }\n\n    /**\n     * @dev Calculates the tax for a given transaction.\n     * @param sender The address sending the tokens.\n     * @param recipient The address receiving the tokens.\n     * @param amount The amount of tokens to be transferred.\n     * @return The amount of tokens to be transferred after tax.\n     */\n    function calcTax(address sender, address recipient, uint256 amount) internal returns (uint256) {\n        uint256 taxRate = 0;\n        if (taxableAddresses[sender] && !isExcludedFromTax[recipient]) {\n            // Buy operation\n            taxRate = buyTaxRate;\n        } else if (taxableAddresses[recipient] && !isExcludedFromTax[sender]) {\n            // Sell operation\n            taxRate = sellTaxRate;\n        }\n\n        uint256 tax = 0;\n        if (taxRate > 0) {\n            tax = amount * taxRate / 100;\n            balanceOf[address(this)] += tax;\n            emit Transfer(sender, address(this), tax);\n        }\n        return amount - tax;\n    }\n\n    /**\n     * @dev Withdraws the balance of the contract, swaps to ETH and deposits in the rewards pool.\n     */\n    function withdraw() external onlyOwner {\n        uint256 tokenBalance = balanceOf[address(this)];\n\n        // Generate the uniswap pair path of token -> WETH\n        address[] memory path = new address[](2);\n        path[0] = address(this);\n        path[1] = uniswapV2Router.WETH();\n\n        // Make the swap\n        uniswapV2Router.swapExactTokensForETH(\n            tokenBalance,\n            0, // Accept any amount of ETH\n            path,\n            address(this),\n            block.timestamp\n        );\n\n        // Now that you have WETH, you can unwrap it to get ETH\n        weth.withdraw(weth.balanceOf(address(this)));\n\n        // Transfer the ETH to the rewards pool\n        uint256 ethAmount = address(this).balance;\n        payable(rewardsPool).transfer(ethAmount);\n\n        emit Withdrawn(ethAmount);\n    }\n\n    /**\n     * @dev Sets the rewards pool address.\n     * @param _rewardsPool The address of the rewards pool.\n     */\n    function setRewardsPool(address _rewardsPool) external onlyOwner {\n        rewardsPool = _rewardsPool;\n        isExcludedFromTax[_rewardsPool] = true;\n        emit SetRewardsPool(_rewardsPool);\n    }\n\n    /**\n     * @dev Sets the Uniswap router and WETH addresses.\n     * @param _weth The address of the WETH token.\n     * @param _uniswapRouter The address of the Uniswap router.\n     */\n    function setUniswap(address _weth, address _uniswapRouter) external onlyOwner {\n        weth = IWETH(_weth);\n        uniswapV2Router = IUniswapV2Router(_uniswapRouter);\n        allowance[address(this)][_uniswapRouter] = type(uint256).max;\n        emit SetUniswap(_weth, _uniswapRouter);\n    }\n\n    /**\n     * @dev Sets an address as taxable destination or not. Basically for uniswap addresses.\n     * @param _address The address to be set.\n     * @param isTaxable A boolean that indicates if the address should trigger a tax when transferred to or from.\n     */\n    function setTaxable(address _address, bool isTaxable) external onlyOwner {\n        taxableAddresses[_address] = isTaxable;\n        emit SetTaxable(_address, isTaxable);\n    }\n\n    /**\n     * @dev Excludes an account from tax.\n     * @param _account The account to be excluded from tax.\n     * @param isExcluded A boolean that indicates if the account should be excluded from being taxed\n     */\n    function setExcludedFromTax(address _account, bool isExcluded) external onlyOwner {\n        isExcludedFromTax[_account] = isExcluded;\n        emit SetExcludedFromTax(_account, isExcluded);\n    }\n\n    receive() external payable {}\n}\n"

    },

    "lib/solmate/src/tokens/ERC20.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\n/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)\n/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)\n/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.\nabstract contract ERC20 {\n    /*//////////////////////////////////////////////////////////////\n                                 EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\n\n    /*//////////////////////////////////////////////////////////////\n                            METADATA STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    string public name;\n\n    string public symbol;\n\n    uint8 public immutable decimals;\n\n    /*//////////////////////////////////////////////////////////////\n                              ERC20 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 public totalSupply;\n\n    mapping(address => uint256) public balanceOf;\n\n    mapping(address => mapping(address => uint256)) public allowance;\n\n    /*//////////////////////////////////////////////////////////////\n                            EIP-2612 STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    uint256 internal immutable INITIAL_CHAIN_ID;\n\n    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;\n\n    mapping(address => uint256) public nonces;\n\n    /*//////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(\n        string memory _name,\n        string memory _symbol,\n        uint8 _decimals\n    ) {\n        name = _name;\n        symbol = _symbol;\n        decimals = _decimals;\n\n        INITIAL_CHAIN_ID = block.chainid;\n        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                               ERC20 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function approve(address spender, uint256 amount) public virtual returns (bool) {\n        allowance[msg.sender][spender] = amount;\n\n        emit Approval(msg.sender, spender, amount);\n\n        return true;\n    }\n\n    function transfer(address to, uint256 amount) public virtual returns (bool) {\n        balanceOf[msg.sender] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(msg.sender, to, amount);\n\n        return true;\n    }\n\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) public virtual returns (bool) {\n        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.\n\n        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;\n\n        balanceOf[from] -= amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(from, to, amount);\n\n        return true;\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                             EIP-2612 LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function permit(\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) public virtual {\n        require(deadline >= block.timestamp, \"PERMIT_DEADLINE_EXPIRED\");\n\n        // Unchecked because the only math done is incrementing\n        // the owner's nonce which cannot realistically overflow.\n        unchecked {\n            address recoveredAddress = ecrecover(\n                keccak256(\n                    abi.encodePacked(\n                        \"\\x19\\x01\",\n                        DOMAIN_SEPARATOR(),\n                        keccak256(\n                            abi.encode(\n                                keccak256(\n                                    \"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\"\n                                ),\n                                owner,\n                                spender,\n                                value,\n                                nonces[owner]++,\n                                deadline\n                            )\n                        )\n                    )\n                ),\n                v,\n                r,\n                s\n            );\n\n            require(recoveredAddress != address(0) && recoveredAddress == owner, \"INVALID_SIGNER\");\n\n            allowance[recoveredAddress][spender] = value;\n        }\n\n        emit Approval(owner, spender, value);\n    }\n\n    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {\n        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();\n    }\n\n    function computeDomainSeparator() internal view virtual returns (bytes32) {\n        return\n            keccak256(\n                abi.encode(\n                    keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"),\n                    keccak256(bytes(name)),\n                    keccak256(\"1\"),\n                    block.chainid,\n                    address(this)\n                )\n            );\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                        INTERNAL MINT/BURN LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function _mint(address to, uint256 amount) internal virtual {\n        totalSupply += amount;\n\n        // Cannot overflow because the sum of all user\n        // balances can't exceed the max uint256 value.\n        unchecked {\n            balanceOf[to] += amount;\n        }\n\n        emit Transfer(address(0), to, amount);\n    }\n\n    function _burn(address from, uint256 amount) internal virtual {\n        balanceOf[from] -= amount;\n\n        // Cannot underflow because a user's balance\n        // will never be larger than the total supply.\n        unchecked {\n            totalSupply -= amount;\n        }\n\n        emit Transfer(from, address(0), amount);\n    }\n}\n"

    },

    "lib/solmate/src/auth/Owned.sol": {

      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\n/// @notice Simple single owner authorization mixin.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Owned.sol)\nabstract contract Owned {\n    /*//////////////////////////////////////////////////////////////\n                                 EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event OwnershipTransferred(address indexed user, address indexed newOwner);\n\n    /*//////////////////////////////////////////////////////////////\n                            OWNERSHIP STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    address public owner;\n\n    modifier onlyOwner() virtual {\n        require(msg.sender == owner, \"UNAUTHORIZED\");\n\n        _;\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(address _owner) {\n        owner = _owner;\n\n        emit OwnershipTransferred(address(0), _owner);\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                             OWNERSHIP LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        owner = newOwner;\n\n        emit OwnershipTransferred(msg.sender, newOwner);\n    }\n}\n"

    },

    "src/Uniswap.sol": {

      "content": "// SPDX-License-Identifier: GPL-2.0-or-later\npragma solidity >=0.7.5;\npragma abicoder v2;\n\ninterface IWETH {\n    function withdraw(uint256 wad) external;\n    function balanceOf(address owner) external view returns (uint256);\n}\n\ninterface IUniswapV2Router {\n    function factory() external pure returns (address);\n    function WETH() external pure returns (address);\n\n    function swapExactTokensForETH(\n        uint256 amountIn,\n        uint256 amountOutMin,\n        address[] calldata path,\n        address to,\n        uint256 deadline\n    ) external returns (uint256[] memory amounts);\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "openzeppelin/=lib/openzeppelin-contracts/contracts/",

      "solmate/=lib/solmate/src/",

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",

      "forge-std/=lib/forge-std/src/",

      "openzeppelin-contracts/=lib/openzeppelin-contracts/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "useLiteralContent": false,

      "bytecodeHash": "ipfs",

      "appendCBOR": true

    },

    "outputSelection": {

      "*": {

        "*": [

          "evm.bytecode",

          "evm.deployedBytecode",

          "devdoc",

          "userdoc",

          "metadata",

          "abi"

        ]

      }

    },

    "evmVersion": "paris",

    "libraries": {}

  }

}}