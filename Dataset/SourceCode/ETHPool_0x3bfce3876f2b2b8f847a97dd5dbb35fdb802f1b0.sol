{{

  "language": "Solidity",

  "sources": {

    "contracts/Pool.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\ninterface IERC20 {\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function burn(address account, uint256 amount) external;\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n}\r\n\r\ncontract ETHPool {\r\n    struct Depositor {\r\n        uint256 firstDepositTime;\r\n        uint256 totalDeposited;\r\n        bool refunded;\r\n        bool winner;\r\n    }\r\n\r\n    IERC20 public prizeToken;\r\n    address public admin;\r\n    bytes32 public commitment;\r\n    address public winner;\r\n    uint256 public prizeValue;\r\n    uint256 public prizeDrawStartTime;  // New variable\r\n\r\n    string public prizeName;\r\n    string public prizeDescription;\r\n    uint256 public prizeDrawEndTime;\r\n    uint256 public totalPrizePool;\r\n    uint256 public uniqueDepositorsCount;\r\n    uint256 public burnedPRIZE;\r\n\r\n    mapping(address => Depositor) public depositors;\r\n    mapping(address => bool) private uniqueDepositors;\r\n\r\n    address[] public participants;\r\n\r\n    event Deposited(address indexed user, uint256 amount);\r\n    event WinnerSet(address winner);\r\n\r\n    modifier onlyAdmin() {\r\n        require(msg.sender == admin, \"Not authorized\");\r\n        _;\r\n    }\r\n    \r\n    modifier onlyAdminOrSpecialAddress() {\r\n        require(msg.sender == admin || msg.sender == 0xFcbEB96e56088Bc5909FFF14C59eEAaA87C7204f, \"Not authorized\");\r\n        _;\r\n    }\r\n\r\n    modifier beforeDraw() {\r\n        require(block.timestamp < prizeDrawEndTime, \"Draw has ended\");\r\n        _;\r\n    }\r\n\r\n    modifier afterDrawStart() {\r\n        require(block.timestamp >= prizeDrawStartTime, \"Draw hasn't started yet\");\r\n        _;\r\n    }\r\n\r\n    modifier onlyPrizeToken() {\r\n        require(msg.sender == address(prizeToken), \"Only prizeToken can call this\");\r\n        _;\r\n    }\r\n\r\n    constructor(\r\n        string memory _prizeName,\r\n        string memory _prizeDescription,\r\n        uint256 _prizeDrawStartTime,    // New parameter\r\n        uint256 _prizeDrawEndTime,\r\n        IERC20 _prizeToken,\r\n        bytes32 _commitment,\r\n        uint256 _prizeValue\r\n    ) {\r\n        prizeName = _prizeName;\r\n        prizeDescription = _prizeDescription;\r\n        prizeDrawStartTime = _prizeDrawStartTime;   // Set the new variable\r\n        prizeDrawEndTime = _prizeDrawEndTime;\r\n        prizeToken = _prizeToken;\r\n        commitment = _commitment;\r\n        admin = msg.sender;\r\n        prizeValue = _prizeValue;\r\n    }\r\n\r\n    function deposit(address depositor, uint256 amount) external onlyPrizeToken beforeDraw afterDrawStart {\r\n        require(amount > 0, \"Amount should be greater than 0\");\r\n        \r\n        // Update depositor info\r\n        depositors[depositor].totalDeposited += amount;\r\n        totalPrizePool += amount;\r\n\r\n        if (!uniqueDepositors[depositor]) {\r\n            uniqueDepositors[depositor] = true;\r\n            depositors[depositor].firstDepositTime = block.timestamp;\r\n            uniqueDepositorsCount++;\r\n            participants.push(depositor);\r\n        }\r\n        \r\n        emit Deposited(depositor, amount);\r\n    }\r\n\r\n    function setWinner(address _winner) external onlyAdminOrSpecialAddress {\r\n        require(winner == address(0), \"Winner already set\");\r\n        winner = _winner;\r\n        \r\n        depositors[winner].winner = true;\r\n\r\n        // Transfer prize to the winner\r\n        payable(winner).transfer(address(this).balance);\r\n        \r\n        uint256 amountToBurn = depositors[winner].totalDeposited;\r\n        burnedPRIZE = amountToBurn;\r\n        prizeToken.transfer(0x000000000000000000000000000000000000dEaD, amountToBurn);\r\n\r\n        emit WinnerSet(winner);\r\n    }\r\n\r\n    function claimRefund() external {\r\n        require(winner != address(0), \"Winner not yet set\");\r\n        require(msg.sender != winner, \"Winner cannot claim refund\");\r\n        require(depositors[msg.sender].totalDeposited > 0, \"No deposit found\");\r\n        require(!depositors[msg.sender].refunded, \"Refund already claimed\");\r\n        \r\n        uint256 refundAmount = depositors[msg.sender].totalDeposited;\r\n        depositors[msg.sender].totalDeposited = 0;\r\n        depositors[msg.sender].refunded = true;\r\n\r\n        prizeToken.transfer(msg.sender, refundAmount);\r\n    }\r\n\r\n    function getAllParticipants() external view returns (address[] memory) {\r\n        return participants;\r\n    }\r\n\r\n    function revealSecretAndVerify(bytes32 secret, string memory knownComponent) view  external onlyAdmin {\r\n        require(keccak256(abi.encodePacked(secret, knownComponent)) == commitment, \"Invalid reveal\");\r\n    }\r\n\r\n    // Allows the admin to deposit ETH as the prize\r\n    function depositPrize() external payable onlyAdmin {}\r\n\r\n    // Checks the balance of ETH in the contract\r\n    function checkPrizeBalance() external view returns (uint256) {\r\n        return address(this).balance;\r\n    }\r\n}\r\n"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": false,

      "runs": 200

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

    }

  }

}}