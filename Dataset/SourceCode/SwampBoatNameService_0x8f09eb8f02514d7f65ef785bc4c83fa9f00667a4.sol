{{

  "language": "Solidity",

  "sources": {

    "contracts/subdomain.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// oLand ENS Registration\n\n\npragma solidity ^0.8.14;\n\ninterface IERC721 {\n    function balanceOf(address owner) external view returns (uint256);\n    function ownerOf(uint256 tokenId) external view returns (address);\n}\n\ninterface INFTNames {\n    function names(uint256 tokenId) external view returns (string memory);\n}\n\ninterface IENSResolver {\n    function setAddr(bytes32 node, address addr) external;\n    function addr(bytes32 node) external view returns (address);\n}\n\ninterface IENSRegistry {\n    function setOwner(bytes32 node, address owner) external;\n    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;\n    function setResolver(bytes32 node, address resolver) external;\n    function owner(bytes32 node) external view returns (address);\n    function resolver(bytes32 node) external view returns (address);\n}\n\ncontract SwampBoatNameService {\n    bytes32 private constant EMPTY_NAMEHASH = 0x00;\n    address private owner;\n    IERC721 private immutable tdbc;\n    INFTNames private immutable nftNames;\n    IENSRegistry private registry;\n    IENSResolver private resolver;\n    bool public locked;\n\n    event SubdomainCreated(address indexed creator, address indexed owner, string subdomain, string domain, string topdomain);\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n    event RegistryUpdated(address indexed previousRegistry, address indexed newRegistry);\n    event ResolverUpdated(address indexed previousResolver, address indexed newResolver);\n    event DomainTransfersLocked();\n\n\n    // 0x6761BC096d2537b47673476B483ec1dA54C8088D\n    // 0x6761BC096d2537b47673476B483ec1dA54C8088D\n    // 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e\n    // 0x231b0Ee14048e9dCcD1d247744d114a4EB5E8E63\n\n    constructor(IERC721 _swampBoats, INFTNames _nftNames, IENSRegistry _registry, IENSResolver _resolver) {\n        owner = msg.sender;\n        tdbc = _swampBoats;\n        nftNames = _nftNames;\n        registry = _registry;\n        resolver = _resolver;\n        locked = false;\n    }\n\n    function normalizeSubdomain(string memory _subdomain) internal pure returns (string memory) {\n        bytes memory subdomainBytes = bytes(_subdomain);\n        for (uint i = 0; i < subdomainBytes.length; i++) {\n            if (subdomainBytes[i] >= 0x41 && subdomainBytes[i] <= 0x5A) {\n                // Convert to lowercase\n                subdomainBytes[i] |= 0x20;\n            }\n        }\n        return string(subdomainBytes);\n    }\n\n    modifier onlyOwner() {\n        require(msg.sender == owner);\n        _;\n    }\n\n    function newSubdomain(uint256 _tokenId, string calldata _domain, string calldata _topdomain, address _owner, address _target) external {\n        require(tdbc.ownerOf(_tokenId) == _owner, \"UNAUTHORIZED\");\n\n        string memory _subdomain = nftNames.names(_tokenId);\n        _subdomain = normalizeSubdomain(_subdomain);\n\n        bytes32 topdomainNamehash = keccak256(abi.encodePacked(EMPTY_NAMEHASH, keccak256(abi.encodePacked(_topdomain))));\n        bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));\n        require(registry.owner(domainNamehash) == address(this), \"INVALID_DOMAIN\");\n\n\n        bytes32 subdomainLabelhash = keccak256(abi.encodePacked(_subdomain));\n        bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, subdomainLabelhash));\n        require(registry.owner(subdomainNamehash) == address(0) || registry.owner(subdomainNamehash) == msg.sender, \"SUB_DOMAIN_ALREADY_OWNED\");\n\n        registry.setSubnodeOwner(domainNamehash, subdomainLabelhash, address(this));\n        registry.setResolver(subdomainNamehash, address(resolver));\n        resolver.setAddr(subdomainNamehash, _target);\n        registry.setOwner(subdomainNamehash, _owner);\n\n        emit SubdomainCreated(msg.sender, _owner, _subdomain, _domain, _topdomain);\n    }\n\n    function domainOwner(string calldata _domain, string calldata _topdomain) external view returns (address) {\n        bytes32 topdomainNamehash = keccak256(abi.encodePacked(EMPTY_NAMEHASH, keccak256(abi.encodePacked(_topdomain))));\n        bytes32 namehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));\n        return registry.owner(namehash);\n    }\n\n    function subdomainOwner(string calldata _subdomain, string calldata _domain, string calldata _topdomain) external view returns (address) {\n        bytes32 topdomainNamehash = keccak256(abi.encodePacked(EMPTY_NAMEHASH, keccak256(abi.encodePacked(_topdomain))));\n        bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));\n        bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, keccak256(abi.encodePacked(_subdomain))));\n\n        return registry.owner(subdomainNamehash);\n    }\n\n    function subdomainTarget(string calldata _subdomain, string calldata _domain, string calldata _topdomain) external view returns (address) {\n        bytes32 topdomainNamehash = keccak256(abi.encodePacked(EMPTY_NAMEHASH, keccak256(abi.encodePacked(_topdomain))));\n        bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));\n        bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, keccak256(abi.encodePacked(_subdomain))));\n        address currentResolver = registry.resolver(subdomainNamehash);\n\n        return IENSResolver(currentResolver).addr(subdomainNamehash);\n    }\n\n    function transferDomainOwnership(bytes32 _node, address _owner) external onlyOwner {\n        require(!locked);\n        registry.setOwner(_node, _owner);\n    }\n\n    function lockDomainOwnershipTransfers() external onlyOwner {\n        require(!locked);\n        locked = true;\n        emit DomainTransfersLocked();\n    }\n\n    function updateRegistry(IENSRegistry _registry) external onlyOwner {\n        require(registry != _registry, \"INVALID_REGISTRY\");\n        emit RegistryUpdated(address(registry), address(_registry));\n        registry = _registry;\n    }\n\n    function updateResolver(IENSResolver _resolver) external onlyOwner {\n        require(resolver != _resolver, \"INVALID_RESOLVER\");\n        emit ResolverUpdated(address(resolver), address(_resolver));\n        resolver = _resolver;\n    }\n}\n\n"

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

    }

  }

}}