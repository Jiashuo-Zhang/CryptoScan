// SPDX-License-Identifier: GPL-3.0



pragma solidity 0.8.16;

import "./interfaces/IManagement.sol";

import "./interfaces/IPairFactory.sol";

import {LManagement} from "./libraries/LManagement.sol";



contract Management is IManagement {

    enum SigTypeEnum {AddWhitelist,RemoveWhitelist,AddRestrictlist,RemoveRestrictlist,

        AddManager,RemoveManager,SetContractManager,SetFeeAddress,AddWhiteContract,

        RemoveWhiteContract,AddAdmin,RemoveAdmin,SetAmmFactory, SetOTCFactory, 

        SetP2PFactory,SetSecurityTokenFactory,SetManagement,AddBlocklist,RemoveBlocklist

    }



    using LManagement for mapping(address => bool);



    string public constant name = "Management";



    uint private constant requiredCount = 2; //最小个数

    mapping(address => bool) public whiteList;

    mapping(address => bool) public restrictList;

    mapping(address => bool) public blockList;

    mapping(address => bool) public contractList;

    mapping(address => bool) public administers;

    mapping(address => bool) public managers; //管理员地址

    address public contractManager; //合约管理地址

    address public override platformFeeAddress; //手续费地址



    address public ammFactory;

    address public otcFactory; 

    address public p2pFactory;

    address public securityTokenFactory;



    bytes32 public DOMAIN_SEPARATOR;

    // keccak256("AddWhitelist(address investor,uint256 nonce)");

    bytes32 public constant AddWhitelist_TYPEHASH =0xbae36f97ece7ff6d06ff73064049b6deade63e84a39445ca59a9f59d7b0e9d37;

    // keccak256("RemoveWhitelist(address investor,uint256 nonce)");

    bytes32 public constant RemoveWhitelist_TYPEHASH =0x64c10c1478cf7c3721d359e2f78dfa299c48914c2b6eee9faf35f8508efaeb66;

    // keccak256("AddRestrictlist(address investor,uint256 nonce)");

    bytes32 public constant AddRestrictlist_TYPEHASH =0x998c128fd52190b99cc267054dba040f747bb1889483c451e6e62ecec6f6d836;

    // keccak256("RemoveRestrictlist(address investor,uint256 nonce)");

    bytes32 public constant RemoveRestrictlist_TYPEHASH =0x67e02dd9101cb5ec4ba888b64cf2c887af2342ac87015f0d3964de766f752ba3;

    // keccak256("AddManager(address investor,uint256 nonce)");

    bytes32 public constant AddManager_TYPEHASH =0x163ef0b23224e585a532cb21be056017dc5e24df899e899050f87fb0d9d0e6af;

    // keccak256("RemoveManager(address investor,uint256 nonce)");

    bytes32 public constant RemoveManager_TYPEHASH =0x5ec50e1700093b09774f85c99fe10b2181ff7ebf6137116fee769be0f81fa805;

    // keccak256("SetContractManager(address investor,uint256 nonce)");

    bytes32 public constant SetContractManager_TYPEHASH =0xb5f4b13180b35446f001da8d7a0d31d20f8ec9923e348cc5febdad1de8b247a6;

    // keccak256("SetFeeAddress(address investor,uint256 nonce)");

    bytes32 public constant SetFeeAddress_TYPEHASH =0x3dcf3f15c74bb4d23ab46e4d6ad7cb01451ac366ec11b9471bc09f7db736ad9a;

    // keccak256("AddWhiteContract(address investor,uint256 nonce)");

    bytes32 public constant AddWhiteContract_TYPEHASH =0x1c12de27ba3f67de1dcc525f385b6a129320bf3a5498f39609f3162fdff12174;

    // keccak256("RemoveWhiteContract(address investor,uint256 nonce)");

    bytes32 public constant RemoveWhiteContract_TYPEHASH =0x1be7eca310a863b2bb7cd7bec55909338bc6875ad0756ac9ddfa750c868aa176;

    // keccak256("AddBlocklist(address investor,uint256 nonce)");

    bytes32 public constant AddBlocklist_TYPEHASH =0x3d89d6d5d11eb76b63c2c6f18dfb34b3af7acc2d703db73c28069a378ff7aec2;

    // keccak256("RemoveBlocklist(address investor,uint256 nonce)");

    bytes32 public constant RemoveBlocklist_TYPEHASH =0x9cc9d087aba7064e2e525ccec3dcf261b9e6580c2ceefdf3a7ac50a56474f344;

    // keccak256("AddAdmin(address investor,uint256 nonce)");

    bytes32 public constant AddAdmin_TYPEHASH =0xcf8112dd5614e0034cc93ebdb4f9f2022169d42d53deb26955289b3166922bd6;

    // keccak256("RemoveAdmin(address investor,uint256 nonce)");

    bytes32 public constant RemoveAdmin_TYPEHASH =0x7720a4a484039e81f3c0e5fb52777da87964d87481af2590bb33051987c3978d;

    // keccak256("SetAmmFactory(address investor,uint256 nonce)");

    bytes32 public constant SetAmmFactory_TYPEHASH =0x82a5ca036b13d3a4d2434003f390437bc3cca474cb0105d5d00dc876270e886c;

    // keccak256("SetOTCFactory(address investor,uint256 nonce)");

    bytes32 public constant SetOTCFactory_TYPEHASH =0x359c99fc0cb49cd48a2b30e841fa0eb69dd24d1a27568d10de6bbf66a2b682ca;

    // keccak256("SetP2PFactory(address investor,uint256 nonce)");

    bytes32 public constant SetP2PFactory_TYPEHASH =0xbf8bfccdd4104913963fd44789a30b476f07bb27996c4e09368cd28b0ad312f0;

    // keccak256("SetSecurityTokenFactory(address investor,uint256 nonce)");

    bytes32 public constant SetSecurityTokenFactory_TYPEHASH =0x907bf65e4c55c6e6b92c6b773f9d37c37ecac28d90231a91f35473e6400203d0;

    // keccak256("SetManagement(address[] memory pairs,address newManagement,uint256 nonce)");

    bytes32 public constant SetManagement_TYPEHASH =0xd33bb19e110fdd3dde0f5adcf90869ca157d2bda52f50a3f08594dcbeedb5260;



    mapping(SigTypeEnum => bytes32) private typehashMap;

    mapping(SigTypeEnum => uint) public nonces;



    event AddWhitelistEvent(address indexed from, address indexed addr);

    event RemoveWhitelistEvent(address indexed from, address indexed addr);

    event AddRestrictlistEvent(address indexed from, address indexed addr);

    event RemoveRestrictlistEvent(address indexed from, address indexed addr);

    event AddBlocklistEvent(address indexed from, address indexed addr);

    event RemoveBlocklistEvent(address indexed from, address indexed addr);

    event AddManagerEvent(address indexed from, address indexed addr);

    event RemoveManagerEvent(address indexed from, address indexed addr);

    event SetContractManagerEvent(address indexed from, address indexed addr);

    event SetFeeAddressEvent(address indexed from, address indexed addr);

    event AddWhiteContractEvent(address indexed from, address indexed addr);

    event RemoveWhiteContractEvent(address indexed from, address indexed addr);

    event AddAdminEvent(address indexed from, address indexed addr);

    event RemoveAdminEvent(address indexed from, address indexed addr);

    event SetAmmFactoryEvent(address indexed from, address _ammFactory);

    event SetOTCFactoryEvent(address indexed from, address _otcFactory);

    event SetP2PFactoryEvent(address indexed from, address _p2pFactory);

    event SetSTFactoryEvent(address indexed from,address _securityTokenFactory);



    event CreateSTEvent(address indexed from,address indexed addr,string name,address issuer);

    event CreateAMMEvent(address indexed from,address indexed addr,address tokenA,address tokenB,string _name);

    event CreateOTCEvent(address indexed from,address indexed addr,address tokenA,address tokenB);

    event CreateP2PEvent(address indexed from,address indexed addr,address tokenA,address tokenB);

    event SetManagementEvent(address indexed from,address[] pairs,address newManagement);



    modifier onlyContractManager() {

        require(

            msg.sender == contractManager,"Caller is not contract manager");

        _;

    }



    constructor(address[] memory _admins, address[] memory _factories) {

        

        DOMAIN_SEPARATOR = keccak256(

            abi.encode(

                keccak256(

                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"

                ),

                keccak256(bytes(name)),

                keccak256(bytes("1")),

                block.chainid,

                address(this)

            )

        );

        typehashMap[SigTypeEnum.AddWhitelist] = AddWhitelist_TYPEHASH;

        typehashMap[SigTypeEnum.RemoveWhitelist] = RemoveWhitelist_TYPEHASH;

        typehashMap[SigTypeEnum.AddRestrictlist] = AddRestrictlist_TYPEHASH;

        typehashMap[SigTypeEnum.RemoveRestrictlist] = RemoveRestrictlist_TYPEHASH;

        typehashMap[SigTypeEnum.AddManager] = AddManager_TYPEHASH;

        typehashMap[SigTypeEnum.RemoveManager] = RemoveManager_TYPEHASH;

        typehashMap[SigTypeEnum.SetContractManager ] = SetContractManager_TYPEHASH;

        typehashMap[SigTypeEnum.SetFeeAddress] = SetFeeAddress_TYPEHASH;

        typehashMap[SigTypeEnum.AddWhiteContract] = AddWhiteContract_TYPEHASH;

        typehashMap[SigTypeEnum.RemoveWhiteContract] = RemoveWhiteContract_TYPEHASH;

        typehashMap[SigTypeEnum.AddAdmin] = AddAdmin_TYPEHASH;

        typehashMap[SigTypeEnum.RemoveAdmin] = RemoveAdmin_TYPEHASH;

        typehashMap[SigTypeEnum.SetAmmFactory] = SetAmmFactory_TYPEHASH;

        typehashMap[SigTypeEnum.SetOTCFactory] = SetOTCFactory_TYPEHASH;

        typehashMap[SigTypeEnum.SetP2PFactory] = SetP2PFactory_TYPEHASH;

        typehashMap[SigTypeEnum.SetSecurityTokenFactory ] = SetSecurityTokenFactory_TYPEHASH;

        typehashMap[SigTypeEnum.SetManagement] = SetManagement_TYPEHASH;

        typehashMap[SigTypeEnum.AddBlocklist] = AddBlocklist_TYPEHASH;

        typehashMap[SigTypeEnum.RemoveBlocklist] = RemoveBlocklist_TYPEHASH;

        for (uint256 i = 0; i < _admins.length; i++) {

            administers[_admins[i]] = true;

        }

        ammFactory = _factories[0];

        otcFactory = _factories[1];

        p2pFactory = _factories[2];

        securityTokenFactory = _factories[3];

    }



    function validSignature(

        SigTypeEnum sigType,

        mapping(address => bool) storage _managers,address investor,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) private view returns (bool) {

        require(vs.length == rs.length);

        require(rs.length == ss.length);

        require(vs.length >= requiredCount);

        address[] memory addrs = new address[](vs.length);

        bytes32 typehash = typehashMap[sigType];

        uint nonce = nonces[sigType];

        for (uint i = 0; i < vs.length; i++) {

            addrs[i] = LManagement.getSigAddress(

                DOMAIN_SEPARATOR,typehash,nonce,investor,vs[i],rs[i],ss[i]

            );

        }

        require(_managers.distinctOwners(addrs), "managers invalid");

        return true;

    }



    function validManagementSignature(

        SigTypeEnum sigType,

        mapping(address => bool) storage _managers,

        address[] memory pairs,

        address newManagement,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) private view returns (bool) {

        require(vs.length == rs.length);

        require(rs.length == ss.length);

        require(vs.length >= requiredCount);

        address[] memory addrs = new address[](vs.length);

        bytes32 typehash = typehashMap[sigType];

        uint nonce = nonces[sigType];

        for (uint i = 0; i < vs.length; i++) {

            addrs[i] = LManagement.getSigManagementAddress(

                DOMAIN_SEPARATOR,typehash,nonce,pairs,newManagement,vs[i],rs[i],ss[i]

            );

        }

        require(_managers.distinctOwners(addrs), "managers invalid");

        return true;

    }



    function addWhitelist(

        address investor,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.AddWhitelist,managers,investor,vs,rs,ss),"invalid signatures");

        if (restrictList[investor]) {

            restrictList[investor] = false;

        }

        whiteList[investor] = true;

        nonces[SigTypeEnum.AddWhitelist]++;

        emit AddWhitelistEvent(address(this), investor);

    }



    function removeWhitelist(

        address investor,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.RemoveWhitelist,managers,investor,vs,rs,ss),"invalid signatures");

        whiteList[investor] = false;

        nonces[SigTypeEnum.RemoveWhitelist]++;

        emit RemoveWhitelistEvent(address(this), investor);

    }



    function addRestrictlist(

        address investor,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.AddRestrictlist,managers,investor,vs,rs,ss),"invalid signatures");

        if (whiteList[investor]) {

            whiteList[investor] = false;

        }

        restrictList[investor] = true;

        nonces[SigTypeEnum.AddRestrictlist]++;

        emit AddRestrictlistEvent(address(this), investor);

    }



    function removeRestrictlist(

        address investor,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.RemoveRestrictlist,managers,investor,vs,rs,ss),"invalid signatures");

        restrictList[investor] = false;

        nonces[SigTypeEnum.RemoveRestrictlist]++;

        emit RemoveRestrictlistEvent(address(this), investor);

    }

    function addBlocklist(

        address investor,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.AddBlocklist,managers,investor,vs,rs,ss),"invalid signatures");

        blockList[investor] = true;

        nonces[SigTypeEnum.AddBlocklist]++;

        emit AddBlocklistEvent(address(this), investor);

    }



    function removeBlocklist(

        address investor,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.RemoveBlocklist,managers,investor,vs,rs,ss),"invalid signatures");

        blockList[investor] = false;

        nonces[SigTypeEnum.RemoveBlocklist]++;

        emit RemoveBlocklistEvent(address(this), investor);

    }

    function addManager(

        address manager,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.AddManager,administers,manager,vs,rs,ss),"invalid signatures");

        managers[manager] = true;

        nonces[SigTypeEnum.AddManager]++;

        emit AddManagerEvent(address(this), manager);

    }



    function removeManager(

        address manager,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.RemoveManager,administers,manager,vs,rs,ss),"invalid signatures");

        managers[manager] = false;

        nonces[SigTypeEnum.RemoveManager]++;

        emit RemoveManagerEvent(address(this), manager);

    }



    function addAdmin(

        address manager,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.AddAdmin,administers,manager,vs,rs,ss),"invalid signatures");

        administers[manager] = true;

        nonces[SigTypeEnum.AddAdmin]++;

        emit AddAdminEvent(address(this), manager);

    }



    function removeAdmin(

        address manager,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.RemoveAdmin,administers,manager,vs,rs,ss),"invalid signatures");

        administers[manager] = false;

        nonces[SigTypeEnum.RemoveAdmin]++;

        emit RemoveAdminEvent(address(this), manager);

    }



    function setContractManager(

        address manager,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.SetContractManager,administers,manager,vs,rs,ss),"invalid signatures");

        contractManager = manager;

        nonces[SigTypeEnum.SetContractManager]++;

        emit SetContractManagerEvent(address(this), manager);

    }



    function setFeeAddress(

        address _platformFeeAddress,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.SetFeeAddress,administers,_platformFeeAddress,vs,rs,ss),"invalid signatures");

        if(platformFeeAddress != address(0)){

            whiteList[platformFeeAddress] = false;

        }

        platformFeeAddress = _platformFeeAddress;

        nonces[SigTypeEnum.SetFeeAddress]++;

        whiteList[_platformFeeAddress] = true;

        emit SetFeeAddressEvent(address(this), _platformFeeAddress);

    }



    function addWhiteContract(

        address contractAddress,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.AddWhiteContract,administers,contractAddress,vs,rs,ss),"invalid signatures");

        contractList[contractAddress] = true;

        nonces[SigTypeEnum.AddWhiteContract]++;

        emit AddWhiteContractEvent(address(this), contractAddress);

    }



    function removeWhiteContract(

        address contractAddress,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.RemoveWhiteContract,administers,contractAddress,vs,rs,ss),"invalid signatures");

        contractList[contractAddress] = false;

        nonces[SigTypeEnum.RemoveWhiteContract]++;

        emit RemoveWhiteContractEvent(address(this), contractAddress);

    }



    function setAmmFactory(

        address _ammFactoryAddress,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.SetAmmFactory,administers,_ammFactoryAddress,vs,rs,ss),"invalid signatures");

        ammFactory = _ammFactoryAddress;

        nonces[SigTypeEnum.SetAmmFactory]++;

        emit SetAmmFactoryEvent(address(this), _ammFactoryAddress);

    }



    function setOTCFactory(

        address _otcFactoryAddress,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.SetOTCFactory,administers,_otcFactoryAddress,vs,rs,ss),"invalid signatures");

        otcFactory = _otcFactoryAddress;

        nonces[SigTypeEnum.SetOTCFactory]++;

        emit SetOTCFactoryEvent(address(this), _otcFactoryAddress);

    }



    function setP2PFactory(

        address _p2pFactoryAddress,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.SetP2PFactory,administers,_p2pFactoryAddress,vs,rs,ss),"invalid signatures");

        p2pFactory = _p2pFactoryAddress;

        nonces[SigTypeEnum.SetP2PFactory]++;

        emit SetP2PFactoryEvent(address(this), _p2pFactoryAddress);

    }



    function setSecurityTokenFactory(

        address _securityTokenFactoryAddress,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(validSignature(SigTypeEnum.SetSecurityTokenFactory,administers,_securityTokenFactoryAddress,vs,rs,ss),"invalid signatures");

        securityTokenFactory = _securityTokenFactoryAddress;

        nonces[SigTypeEnum.SetSecurityTokenFactory]++;

        emit SetSTFactoryEvent(address(this),_securityTokenFactoryAddress);

    }



    function createSecurityToken(

        string memory stName,

        address issuer,

        uint amount

    ) external onlyContractManager {

        address contractAddress = IPairFactory(securityTokenFactory)

            .createSecurityToken(stName, issuer, amount, address(this));

        contractList[contractAddress] = true;

        emit CreateSTEvent(address(this), contractAddress, stName, issuer);

    }



    function createAMMPair(

        string memory _name,

        address issuer,

        address tokenA,

        address tokenB,

        uint[] memory params

    ) external onlyContractManager {

        address contractAddress = IPairFactory(ammFactory).createAMMPair(

            _name,issuer,tokenA,tokenB,address(this),params);

        contractList[contractAddress] = true;

        emit CreateAMMEvent(address(this),contractAddress,tokenA,tokenB,_name);

    }



    function createOTCPair(

        address tokenA,

        address tokenB,

        uint maxOrderAmount,

        uint platformFeeRate

    ) external onlyContractManager {

        address contractAddress = IPairFactory(otcFactory).createOTCPair(

            tokenA,tokenB,address(this),maxOrderAmount,platformFeeRate);

        contractList[contractAddress] = true;

        emit CreateOTCEvent(address(this), contractAddress, tokenA, tokenB);

    }



    function createP2PPair(

        address tokenA,

        address tokenB,

        uint maxOrderAmount,

        uint platformFeeRate

    ) external onlyContractManager {

        address contractAddress = IPairFactory(p2pFactory).createP2PPair(

            tokenA,tokenB,address(this),maxOrderAmount,platformFeeRate);

        contractList[contractAddress] = true;

        emit CreateP2PEvent(address(this), contractAddress, tokenA, tokenB);

    }



    function setManagement(

        address[] memory pairs,

        address newManagement,

        uint8[] memory vs,

        bytes32[] memory rs,

        bytes32[] memory ss

    ) external {

        require(

            validManagementSignature(SigTypeEnum.SetManagement,administers,pairs,newManagement,vs,rs,ss),"invalid signatures");

        for (uint i = 0; i < pairs.length; i++) {

            address pair = pairs[i];

            IPairFactory(pair).setManagement(newManagement);

        }

        nonces[SigTypeEnum.SetManagement]++;

        emit SetManagementEvent(address(this), pairs, newManagement);

    }



    function isWhiteInvestor(address investor)external view override returns (bool){

        return whiteList[investor];

    }



    function isRestrictInvestor(address investor)external view override returns (bool){

        return restrictList[investor];

    }

    function isBlockInvestor(address investor)external view override returns (bool){

        return blockList[investor];

    }



    function isContractManager(address manager)external view override returns (bool){

        if (manager == contractManager) {

            return true;

        } else {

            return false;

        }

    }



    function isWhiteContract(address contractAddress) external view override returns (bool){ 

        return contractList[contractAddress];

    }

}