{{

  "language": "Solidity",

  "sources": {

    "contracts/PreSale.sol": {

      "content": "// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.8.0;\r\n\r\ninterface IERC721{\r\n    function balanceOf(address owner) external view returns (uint256 balance);\r\n    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;\r\n\tfunction tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);\r\n\tfunction users(address owner) external view returns (uint256 nftminted);\r\n}\r\n\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\t\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}\r\n\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor() {\r\n        _transferOwnership(_msgSender());\r\n    }\r\n\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\t\r\n    modifier onlyOwner() {\r\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n        _;\r\n    }\r\n\t\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\t\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        _transferOwnership(newOwner);\r\n    }\r\n\t\r\n    function _transferOwnership(address newOwner) internal virtual {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n}\r\n\r\nabstract contract ReentrancyGuard {\r\n    uint256 private constant _NOT_ENTERED = 1;\r\n    uint256 private constant _ENTERED = 2;\r\n\r\n    uint256 private _status;\r\n\r\n    constructor() {\r\n        _status = _NOT_ENTERED;\r\n    }\r\n\t\r\n    modifier nonReentrant() {\r\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\r\n\t\t\r\n        _status = _ENTERED;\r\n\r\n        _;\r\n\t\t\r\n        _status = _NOT_ENTERED;\r\n    }\r\n}\r\n\r\nlibrary MerkleProof {\r\n    function verify(\r\n        bytes32[] memory proof,\r\n        bytes32 root,\r\n        bytes32 leaf\r\n    ) internal pure returns (bool) {\r\n        bytes32 computedHash = leaf;\r\n\r\n        for (uint256 i = 0; i < proof.length; i++) {\r\n            bytes32 proofElement = proof[i];\r\n\r\n            if (computedHash <= proofElement) {\r\n                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));\r\n            } else {\r\n                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));\r\n            }\r\n        }\r\n        return computedHash == root;\r\n    }\r\n}\r\n\r\ncontract PreSale is Ownable, ReentrancyGuard {\r\n\tuint256 public MAX_MINT_NFT = 1;\r\n\tuint256 public MAX_BY_MINT_PER_TRANSACTION = 1;\r\n\tuint256 public PRESALE_PRICE = 0.05 ether;\r\n\t\r\n    bool public whitelistSaleEnable = false;\r\n\t\r\n\tbytes32 public merkleRoot;\r\n\tuint256 public NFT_MINTED;\r\n\t\r\n\tstruct User {\r\n\t  uint256 nftminted;\r\n    }\r\n\t\r\n\tIERC721 public TOADS = IERC721(0x8f393E46Ac410118Fd892011B1432bb7D0fD1A54);\r\n\tmapping(address => User) public users;\r\n\t\r\n\tfunction mintWhitelistNFT(uint256 _count, bytes32[] calldata merkleProof) external payable nonReentrant{\r\n\t\tbytes32 node = keccak256(abi.encodePacked(msg.sender));\r\n\t\trequire(\r\n\t\t\twhitelistSaleEnable, \r\n\t\t\t\"WhitelistSale is not enable\"\r\n\t\t);\r\n        require(\r\n\t\t   _count <= TOADS.balanceOf(address(this)), \r\n\t\t   \"Exceeds max limit\"\r\n\t\t);\r\n\t\trequire(\r\n\t\t\tMerkleProof.verify(merkleProof, merkleRoot, node), \r\n\t\t\t\"MerkleDistributor: Invalid proof.\"\r\n\t\t);\r\n\t\trequire(\r\n\t\t    users[msg.sender].nftminted + _count <= MAX_MINT_NFT,\r\n\t\t    \"Exceeds max mint limit per wallet\"\r\n\t\t);\r\n\t\trequire(\r\n\t\t\t_count <= MAX_BY_MINT_PER_TRANSACTION,\r\n\t\t\t\"Exceeds max mint limit per txn\"\r\n\t\t);\r\n\t\trequire(\r\n\t\t   msg.value >= PRESALE_PRICE * _count,\r\n\t\t   \"Value below price\"\r\n\t\t);\r\n\t\tfor (uint256 i = 0; i < _count; i++) {\r\n\t\t   uint256 tokenID = TOADS.tokenOfOwnerByIndex(address(this), 0);\r\n           TOADS.safeTransferFrom(address(this), address(msg.sender), tokenID, \"\");\r\n\t\t   NFT_MINTED++;\r\n        }\r\n\t\tusers[msg.sender].nftminted += _count;\r\n    }\r\n\t\r\n\tfunction withdrawNFT(uint256 _count) external onlyOwner {\r\n        require(\r\n\t\t   _count <= TOADS.balanceOf(address(this)), \r\n\t\t   \"Exceeds max limit\"\r\n\t\t);\r\n\t\tfor (uint256 i = 0; i < _count; i++) {\r\n\t\t   uint256 tokenID = TOADS.tokenOfOwnerByIndex(address(this), 0);\r\n           TOADS.safeTransferFrom(address(this), address(msg.sender), tokenID, \"\");\r\n        }\r\n    }\r\n\t\r\n\tfunction setWhitelistSaleStatus(bool status) external onlyOwner {\r\n\t   require(whitelistSaleEnable != status);\r\n       whitelistSaleEnable = status;\r\n    }\r\n\t\r\n\tfunction updateMintLimitPerWallet(uint256 newLimit) external onlyOwner {\r\n        MAX_MINT_NFT = newLimit;\r\n    }\r\n\t\r\n\tfunction updateMintLimitPerTransaction(uint256 newLimit) external onlyOwner {\r\n        MAX_BY_MINT_PER_TRANSACTION = newLimit;\r\n    }\r\n\t\r\n\tfunction updateMerkleRoot(bytes32 newRoot) external onlyOwner {\r\n\t   merkleRoot = newRoot;\r\n\t}\r\n\t\r\n\tfunction withdraw() external onlyOwner {\r\n        uint256 balance = address(this).balance;\r\n        payable(msg.sender).transfer(balance);\r\n    }\r\n\t\r\n\tfunction updatePreSalePrice(uint256 newPrice) external onlyOwner {\r\n        PRESALE_PRICE = newPrice;\r\n    }\r\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": true,

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

    },

    "libraries": {}

  }

}}