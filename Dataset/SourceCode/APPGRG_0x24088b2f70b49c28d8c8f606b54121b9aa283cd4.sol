// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;



import "erc721a/contracts/ERC721A.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@manifoldxyz/royalty-registry-solidity/contracts/overrides/RoyaltyOverrideCore.sol";

import "./interface/ITokenURI.sol";

import "./interface/IContractAllowListProxy.sol";



abstract contract APPGRGcore is Ownable{

    ITokenURI public tokenuri;  // Upgradable FullOnChain

    IContractAllowListProxy public cal;



    address public constant WITHDRAW_ADDRESS = 0xD416442dC3D81A0E58010941acFFeBEB51d76336;

    uint256 public constant MAX_SUPPLY = 5555;

    

    uint256 public cost = 0.002 ether;

    string public baseURI;

    string public baseExtension = ".json";

    bytes32 public merkleRoot;

    bool public pause = true;

    bool public isPublicSale;   // default:false

    uint256 public calLevel = 1;



    mapping(address => uint256) public mintedCount;

}



abstract contract APPGRGadmin is APPGRGcore,ERC721A,EIP2981RoyaltyOverrideCore{

    function supportsInterface(bytes4 interfaceId) public view virtual 

        override(ERC721A, EIP2981RoyaltyOverrideCore) returns (bool) {

        return

        ERC721A.supportsInterface(interfaceId) ||

        EIP2981RoyaltyOverrideCore.supportsInterface(interfaceId) ||

        super.supportsInterface(interfaceId);

    }



    // onlyOwner

    function setCost(uint256 _value) external onlyOwner {

        cost = _value;

    }



    function setBaseURI(string memory _newBaseURI) external onlyOwner {

        baseURI = _newBaseURI;

    }



    function setBaseExtension(string memory _newBaseExtension) external onlyOwner {

        baseExtension = _newBaseExtension;

    }



    function setPause(bool _pause) external onlyOwner {

        pause = _pause;

    }



    function setPublicSale(bool _isPublicSale) external onlyOwner {

        isPublicSale = _isPublicSale;

    }



    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {

        merkleRoot = _merkleRoot;

    }



    function withdraw() external onlyOwner {

        (bool os, ) = payable(WITHDRAW_ADDRESS).call{value: address(this).balance}("");

        require(os);

    }



    function setTokenURI(ITokenURI _tokenuri) external onlyOwner{

        tokenuri = _tokenuri;

    }



    function setCalContract(IContractAllowListProxy _cal) external onlyOwner{

        cal = _cal;

    }



    function setCalLevel(uint256 _value) external onlyOwner{

        calLevel = _value;

    }



    // EIP2981RoyaltyOverrideCore

    function setTokenRoyalties(TokenRoyaltyConfig[] calldata royaltyConfigs)

    external override onlyOwner{

        _setTokenRoyalties(royaltyConfigs);

    }



    function setDefaultRoyalty(TokenRoyalty calldata royalty)

        external override onlyOwner

    {

        _setDefaultRoyalty(royalty);

    }



    function admin_mint(address[] calldata _airdropAddresses , uint256[] memory _UserMintAmount) external onlyOwner{

        uint256 _mintAmount = 0;

        for (uint256 i = 0; i < _UserMintAmount.length; i++) {

            _mintAmount += _UserMintAmount[i];

        }

        require(_mintAmount > 0, "need to mint at least 1 NFT");

        require(_mintAmount + totalSupply() <= MAX_SUPPLY, "claim is over the max supply");

        require(_airdropAddresses.length == _UserMintAmount.length, "array length unmuch");



        for (uint256 i = 0; i < _UserMintAmount.length; i++) {

            _safeMint(_airdropAddresses[i], _UserMintAmount[i] );

        }

    } 

}



contract APPGRG is APPGRGadmin{

    constructor() ERC721A('APP-GRG', 'GRG') {

        // default royalty set

        _setDefaultRoyalty(

            IEIP2981RoyaltyOverride.TokenRoyalty({bps: 1000, recipient: WITHDRAW_ADDRESS})

        );



        _safeMint(WITHDRAW_ADDRESS, 555);



        baseURI = "https://data.appgrg.com/grg/metadata/";

        cal = IContractAllowListProxy(0xdbaa28cBe70aF04EbFB166b1A3E8F8034e5B9FC7);   // mainnet

        // cal = IContractAllowListProxy(0xb506d7BbE23576b8AAf22477cd9A7FDF08002211);  // goerli

    }



    // overrides

    function setApprovalForAll(address operator, bool approved)

    public virtual override(ERC721A){

        if(address(cal) != address(0)){

            require(cal.isAllowed(operator,calLevel) == true,"address no list");

        }



        super.setApprovalForAll(operator,approved);

    }



    function approve(address to, uint256 tokenId)

    payable public virtual override(ERC721A){

        if(address(cal) != address(0)){

            require(cal.isAllowed(to,calLevel) == true,"address no list");

        }



        super.approve(to, tokenId);

    }

   

    // internal

    function _baseURI() internal view virtual override returns (string memory) {

        return baseURI;

    }



    function _startTokenId() internal view virtual override returns (uint256) {

        return 1;

    }



    // public

    function tokenURI(uint256 tokenId) public view virtual override(ERC721A)  returns (string memory){

        if(address(tokenuri) == address(0))

        {

            return string(abi.encodePacked(ERC721A.tokenURI(tokenId), baseExtension));

        }else{

            // Full-on chain support

            return tokenuri.tokenURI_future(tokenId);

        }

    }



    function getAlRemain(address _address,uint256 _amountMax,bytes32[] calldata _merkleProof)

    public view returns (uint256) {

        uint256 _Amount = 0;

        if(pause == false && isVerify(_address,_amountMax,_merkleProof) == true){

            _Amount = _amountMax - mintedCount[_address];

        }

        return _Amount;

    }



    function isVerify(address _address,uint256 _amountMax,bytes32[] calldata _merkleProof)

    public view returns (bool) {

        bool _exit = false;



        if(MerkleProof.verifyCalldata(_merkleProof, merkleRoot,

         keccak256(abi.encodePacked(_address,uint248(_amountMax)))) == true){

            _exit = true;

        }



        return _exit;

    }



    // external

    function mint(uint256 _mintAmount,uint256 _amountMax,bytes32[] calldata _merkleProof)

    external payable {

        require(pause == false,"sale is not active");

        require(tx.origin == msg.sender,"the caller is another controler");

        require(_mintAmount > 0, "need to mint at least 1 NFT");

        require(_mintAmount + totalSupply() <= MAX_SUPPLY, "claim is over the max supply");

        require(msg.value >= cost * _mintAmount, "not enough eth");



        if(isPublicSale == false){

            require(_mintAmount <= getAlRemain(msg.sender,_amountMax,_merkleProof), "claim is over max amount");

            mintedCount[msg.sender] += _mintAmount;

        }

        

        _safeMint(msg.sender, _mintAmount);

    }



    function mintReserve(uint256 _mintAmount,address _address,uint256 _amountMax,bytes32[] calldata _merkleProof)

    external payable {

        require(pause == false,"sale is not active");

        require(tx.origin == msg.sender,"the caller is another controler");

        require(_mintAmount > 0, "need to mint at least 1 NFT");

        require(_mintAmount + totalSupply() <= MAX_SUPPLY, "claim is over the max supply");

        require(msg.value >= cost * _mintAmount, "not enough eth");



        if(isPublicSale == false){

            require(_mintAmount <= getAlRemain(_address,_amountMax,_merkleProof), "claim is over max amount");

            mintedCount[_address] += _mintAmount;

        }

        

        _safeMint(_address, _mintAmount);

    }

}