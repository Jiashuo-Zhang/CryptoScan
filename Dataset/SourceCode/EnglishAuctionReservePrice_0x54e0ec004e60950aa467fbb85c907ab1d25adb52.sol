{{

  "language": "Solidity",

  "sources": {

    "contracts/EnglishAuctionReservePrice.sol": {

      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.6.7;\n\nlibrary SafeMath {\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\n        uint256 c = a + b;\n        require(c >= a, \"SafeMath: addition overflow\");\n        return c;\n    }\n    \n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\n        return sub(a, b, \"SafeMath: subtraction overflow\");\n    }\n    \n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b <= a, errorMessage);\n        uint256 c = a - b;\n        return c;\n    }\n    \n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\n        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the\n        // benefit is lost if 'b' is also tested.\n        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522\n        if (a == 0) {\n            return 0;\n        }\n        uint256 c = a * b;\n        require(c / a == b, \"SafeMath: multiplication overflow\");\n        return c;\n    }\n    \n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\n        return div(a, b, \"SafeMath: division by zero\");\n    }\n    \n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        // Solidity only automatically asserts when dividing by 0\n        require(b > 0, errorMessage);\n        uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn't hold\n        return c;\n    }\n    \n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\n        return mod(a, b, \"SafeMath: modulo by zero\");\n    }\n    \n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\n        require(b != 0, errorMessage);\n        return a % b;\n    }\n}\n\ninterface IERC1155 {\n    function balanceOf(address _owner, uint256 _id) external view returns (uint256);\n    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;\n}\n\ncontract EnglishAuctionReservePrice {\n    using SafeMath for uint256;\n    using SafeMath for uint8;\n    // System settings\n    uint8 public percentageIncreasePerBid;\n    uint256 public hausFeePercentage;\n    uint256 public tokenId;\n    address public tokenAddress;\n    bool public ended = false;\n    address public controller;\n    address public deployer;\n    \n    // Current winning bid\n    uint256 public lastBid;\n    address payable public winning;\n    \n    uint256 public length;\n    uint256 public startTime;\n    uint256 public endTime;\n    \n    address payable public haus;\n    address payable public seller;\n    \n    event Bid(address who, uint256 amount);\n    event Won(address who, uint256 amount);\n    \n    constructor(\n        uint256 _tokenId,\n        address _tokenAddress,\n        uint256 _reservePriceWei,\n        uint8 _hausFeePercentage,\n        uint8 _percentageIncreasePerBid,\n        address _sellerAddress,\n        address _hausAddress,\n        address _controllerAddress\n    ) public {\n        tokenAddress = address(_tokenAddress);\n        tokenId = _tokenId;\n        lastBid = _reservePriceWei;\n        hausFeePercentage = _hausFeePercentage;\n        percentageIncreasePerBid = _percentageIncreasePerBid;\n        seller = payable(_sellerAddress);\n        haus = payable(_hausAddress);\n        controller = _controllerAddress;\n        deployer = msg.sender;\n    }\n    \n    function bid() public payable {\n        require(msg.sender == tx.origin, \"no contracts\");\n        \n        // Give back the last bidders money\n        if (winning != address(0)) {\n            require(block.timestamp >= startTime, \"Auction not started\");\n            require(block.timestamp < endTime, \"Auction ended\");\n            uint8 base = 100;\n            uint256 multiplier = base.add(percentageIncreasePerBid);\n            require(msg.value >= lastBid.mul(multiplier).div(100), \"Bid too small\"); // % increase\n            winning.transfer(lastBid);\n        } else {\n            require(msg.value >= lastBid, \"Bid too small\"); // no increase required for reserve price to be met\n            // First bid, reserve met, start auction\n            startTime = block.timestamp;\n            length = 24 hours;\n            endTime = startTime + length;\n        }\n        \n        if (endTime - now < 15 minutes) {\n            endTime = now + 15 minutes;\n        }\n        \n        lastBid = msg.value;\n        winning = msg.sender;\n        emit Bid(msg.sender, msg.value);\n    }\n    \n    function end() public {\n        require(!ended, \"end already called\");\n        require(winning != address(0), \"no bids\");\n        require(!live(), \"Auction live\");\n        // transfer erc1155 to winner\n        IERC1155(tokenAddress).safeTransferFrom(address(this), winning, tokenId, 1, new bytes(0x0)); // Will transfer IERC1155 from current owner to new owner\n        uint256 balance = address(this).balance;\n        uint256 hausFee = balance.div(100).mul(hausFeePercentage);\n        haus.transfer(hausFee);\n        seller.transfer(address(this).balance);\n        ended = true;\n        emit Won(winning, lastBid);\n    }\n    \n    function pull() public {\n        require(msg.sender == controller, \"must be controller\");\n        require(!ended, \"end already called\");\n        require(winning == address(0), \"There were bids\");\n        require(!live(), \"Auction live\");\n        // transfer erc1155 to seller\n        IERC1155(tokenAddress).safeTransferFrom(address(this), seller, tokenId, 1, new bytes(0x0));\n        ended = true;\n    }\n    \n    function live() public view returns(bool) {\n        return block.timestamp < endTime;\n    }\n\n    function containsAuctionNFT() public view returns(bool) {\n        return IERC1155(tokenAddress).balanceOf(address(this), tokenId) > 0;\n    }\n    \n    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure returns(bytes4) {\n        return bytes4(keccak256(\"onERC1155Received(address,address,uint256,uint256,bytes)\"));\n    }\n}"

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

          "abi"

        ]

      }

    },

    "libraries": {}

  }

}}