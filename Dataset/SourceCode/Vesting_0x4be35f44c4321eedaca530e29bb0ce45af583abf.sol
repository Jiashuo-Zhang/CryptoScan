{{

  "language": "Solidity",

  "sources": {

    "@openzeppelin/contracts/access/Ownable.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"

    },

    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"

    },

    "@openzeppelin/contracts/utils/Context.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"

    },

    "contracts/IERC20.sol": {

      "content": "interface TIERC20 {\n    // Function to get the total supply of tokens\n\n    function transferFrom(address from, address to, uint256 amount) external;\n\n}"

    },

    "contracts/Vesting.sol": {

      "content": "pragma solidity 0.8.21;\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\"; \nimport \"./IERC20.sol\"; \n// import \"hardhat/console.sol\";\n\n\ncontract Vesting is Ownable {\n\n\n    struct Project{ \n        string name;\n        address signer;\n        address token;\n        uint256 IDOCount;\n        uint256 participantsCount;\n        uint256 participantsLimit;\n    }\n\n\n    struct ProjectInvestment{ \n        uint256 id;\n        uint256 amount;\n        uint256 idoNumber;\n        uint8 _paymentOption;\n    }\n\n   \n    mapping (uint256=>Project) public projects;\n    // mapping(string=>uint256) public \n    mapping (address=>mapping(uint256 => bool)) public isInvested;\n\n    mapping (bytes32=>bool) public isRedeemed;\n    mapping (bytes32=>bool) public idoClaimed;\n\n    // uint256 [] projectList;\n    uint256 idCounter = 0;\n    \n    address public multiSig;\n    address[] public paymentOptions = [0xdAC17F958D2ee523a2206206994597C13D831ec7,0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,0xE8799100F8c1C1eD81b62Ba48e9090D5d4f51DC4];\n    uint256 constant Wei1 = 10**18;\n    event TGEDeposited(uint256 id,uint256 amount,address depositer,address token);\n    event ProjectRegistered(uint256 id,string name, address owner,uint256 totalParticipants);\n    event IDOInvested(address investor,uint256 id,uint256 amount,uint256 idoNumber,uint256 _paymentOption);\n    event IDOClaimed(address claimer,uint256 id,uint256 amount,uint256 vestingNumber,uint256 idoNumber);\n \n\n    constructor(address _multiSig) {\n        multiSig = _multiSig;\n    }\n\n    function registerProject(string memory name, address owner,uint256 totalParticipants) external onlyOwner{\n        Project memory pr = Project(name,owner,address(0),0,0,totalParticipants);\n        projects[idCounter] = pr;\n        idCounter++;\n        emit ProjectRegistered(idCounter-1,name,owner,totalParticipants);\n    }\n\n    \n    function TGE(uint256 _id,uint256 initialSHO, address token, bytes memory signature) external {\n        require(projects[_id].signer!=address(0));\n        require(token!=address(0),\"Invalid Token Address\");\n        require(initialSHO>0,\"Invalid SHO\");\n        \n        address sender = msg.sender;\n        address signer = projects[_id].signer;\n        bytes32 message =  keccak256(abi.encode(_id,sender,initialSHO,token,projects[_id].IDOCount));\n        // console.logBytes32(message);\n        (uint8 v, bytes32 r, bytes32 s) = extractRSV(signature);\n        _validate(v, r, s, message, signer);\n        // isRedeemed[message] = true;\n        require(IERC20(token).transferFrom(sender,address(this),initialSHO),\"Transfer_Falied\");\n        projects[_id].token = token;\n        projects[_id].IDOCount += 1;\n\n        emit TGEDeposited(_id,initialSHO,token,sender);\n\n    }\n\n    function purchaseIDO(ProjectInvestment memory pi,bytes memory signature) external {\n        // require(projects[id].token!=address(0),\"No IDO to claim\");\n        require(projects[pi.id].signer!=address(0));\n        require(projects[pi.id].participantsCount<projects[pi.id].participantsLimit,\"Participation Limit Reached\");\n        address sender = msg.sender;\n        address signer = projects[pi.id].signer;\n        bytes32 message =  keccak256(abi.encode(pi.id,sender,pi.amount,pi.idoNumber));\n        require(!isRedeemed[message],\"Signautre Already redeemed\");\n\n        (uint8 v, bytes32 r, bytes32 s) = extractRSV(signature);\n        _validate(v, r, s, message, signer);\n        isRedeemed[message] = true;\n        // console.logBytes32(message);\n        // console.log(userAmount);\n        // uint256 stack_id = id;\n        projects[pi.id].participantsCount +=1; \n        isInvested[sender][pi.id] = true;\n\n        if(pi._paymentOption==0){\n            TIERC20(paymentOptions[pi._paymentOption]).transferFrom(sender,multiSig,pi.amount);\n            // console.log(TIERC20(paymentOptions[pi._paymentOption]).balanceOf(msg.sender));\n            // console.log(userAmount);\n        }\n        else{\n        IERC20(paymentOptions[pi._paymentOption]).transferFrom(sender,multiSig,pi.amount);\n        }\n        // uint256 stack_amount = pi.amount;\n        // uint256 stackIDORate = idoRate;\n        // uint256 stackIdoNumber = idoNumber;\n        // uint256 stackPay = _paymentOption; \n        emit IDOInvested(sender,pi.id,pi.amount,pi.idoNumber,pi._paymentOption);\n\n\n    }\n\n    function claimIDO(uint256 id,uint256 amount,uint256 vestingNumber,uint256 idoNumber,bytes memory signature) external {\n        require(projects[id].token!=address(0),\"No IDO to claim\");\n        address sender = msg.sender;\n        address signer = projects[id].signer;\n        address idoToken = projects[id].token;\n        bytes32 message =  keccak256(abi.encode(id,sender,amount,vestingNumber,idoNumber));\n        require(!idoClaimed[message],\"Invalid Status For Claim\");\n        (uint8 v, bytes32 r, bytes32 s) = extractRSV(signature);\n        _validate(v, r, s, message, signer);\n        idoClaimed[message] = true;\n\n        IERC20(idoToken).transfer(sender,amount);\n\n        emit IDOClaimed(sender, id, amount,idoNumber, vestingNumber);\n    }\n\n\n    function getDomainSeparator() internal view returns (bytes32) {\n        return keccak256(abi.encode(\"0x01\", address(this)));\n    }\n\n    function _validate(\n        uint8 v,\n        bytes32 r,\n        bytes32 s,\n        bytes32 encodeData,\n        address signer\n    ) internal view {\n        bytes32 digest = keccak256(abi.encodePacked(\"\\x19\\x01\", getDomainSeparator(), encodeData));\n        address recoveredAddress = ecrecover(digest, v, r, s);\n\n        // console.logBytes32(digest);\n        \n        // Explicitly disallow authorizations for address(0) as ecrecover returns address(0) on malformed messages\n        require(recoveredAddress!= address(0) && (recoveredAddress == signer), \"INVALID_SIGNATURE\");\n\n    }\n\n    function extractRSV(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {\n        require(signature.length == 65, \"Invalid signature length\");\n\n        assembly {\n            // First 32 bytes are the `r` value\n            r := mload(add(signature, 32))\n\n            // Next 32 bytes are the `s` value\n            s := mload(add(signature, 64))\n\n            // The last byte is the `v` value\n            v := byte(0, mload(add(signature, 96)))\n        }\n    }\n\n    function updatePaymentOption(address[3] memory _paymentoption) external onlyOwner {\n        require(_paymentoption.length==3,\"Invalid Array\");\n        paymentOptions = _paymentoption;\n    }\n\n\n    // Fallback function to reject incoming Ether\n    receive() external payable {\n        \n    }\n}\n\n\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

      "runs": 1

    },

    "evmVersion": "paris",

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

    "libraries": {}

  }

}}