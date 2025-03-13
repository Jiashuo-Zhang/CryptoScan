// SPDX-License-Identifier: MIT
//      ______               ___               __  ________
//     /_  __/__ ___ ___ _  / _ )_______ ___ _/ /_/_  __/ /  ______ __
//      / / / -_) _ `/  ' \/ _  / __/ -_) _ `/  '_// / / _ \/ __/ // /
//     /_/  \__/\_,_/_/_/_/____/_/  \__/\_,_/_/\_\/_/ /_//_/_/  \_,_/
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
contract Editions_x_TeamBreakThru is ERC1155Burnable, Ownable, DefaultOperatorFilterer {
    string public name = "Editions_x_TeamBreakThru";
    string public symbol = "ETBT";
    string public contractUri = "https://editions.teambreakthru.net/contract";
    address CouponSigner = 0x0000000000000000000000000000000000000000; 
    address MintSender;
    uint256 public MintPrice = 0 ether; 
    bool public MintEnabled = false; 
    bool public MintPublic = false;
    bool public TokenTypeSingle = true;
    uint256 public MaxTokenAmount = 0;
    struct MintTypes {
        uint256 _MintsByAddress;
	}
    struct Coupon {
		bytes32 r;
		bytes32 s;
		uint8 v;
	}
    enum CouponType {
        Mint
	}
    mapping(string => MintTypes) public addressToMinted;
    mapping(uint256 => uint256) public TokenAmount;   
    using Counters for Counters.Counter;
    Counters.Counter private idTracker;  
    constructor() ERC1155("https://editions.teambreakthru.net/metadata/token_{id}") {
        idTracker.increment();
    }
	function isVerifiedCoupon(bytes32 digest, Coupon memory coupon) internal view returns (bool) {
		address signer = ecrecover(digest, coupon.v, coupon.r, coupon.s);
        require(signer != address(0), 'Zero Address');
		return signer == CouponSigner;
	}
    function getMintPrice() public view returns (uint256) {
        return MintPrice;
    }
    function setMintPrice(uint256 _price) public onlyOwner
    {
        MintPrice = _price;
    }
    function setCouponSigner(address newsigner) public onlyOwner {
        CouponSigner = newsigner;
    }
    function setUri(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    function setContractURI(string memory newuri) public onlyOwner {
        contractUri = newuri;
    }
    function contractURI() public view returns (string memory) {
        return contractUri;
    }
    function setMintEnabled(bool isEnabled) public onlyOwner {
        MintEnabled = isEnabled;
    }
    function setMintPublic(bool isEnabled) public onlyOwner {
        MintPublic = isEnabled;
    }
    function setTokenTypeSingle(bool _tokentypesingle) public onlyOwner
    {
        TokenTypeSingle = _tokentypesingle;
    }
    function incrementTokenID() public onlyOwner
    {
        idTracker.increment();
    }
    function getTokenID() public view returns (uint256) {
        return idTracker.current();
    }
    function setMaxTokenAmount(uint256 _maxtokenamount) public onlyOwner
    {
        MaxTokenAmount = _maxtokenamount;
    }
    function totalSupply() public view returns (uint256) {
        if (TokenTypeSingle) {   
            return idTracker.current()-1;    
        }else{
            return TokenAmount[idTracker.current()];
        }
    }
    function mint(uint256 amount, uint256 allotted, Coupon memory coupon, string memory MinterHash) external payable {
        require(MintEnabled, "Mint not enabled");
        require((MaxTokenAmount >= totalSupply()+amount) || (MaxTokenAmount == 0), "Exceeds Max Token Amount");
        require(msg.value >= MintPrice * amount, "Not enough eth");
        require(amount + addressToMinted[MinterHash]._MintsByAddress < allotted + 1, "Exceeds Max Allotted");
        if(!MintPublic){
            MintSender = msg.sender;
        }else{
            MintSender = CouponSigner;
        }
        bytes32 digest = keccak256(
			abi.encode(CouponType.Mint, allotted, MintSender)
		);
        require(isVerifiedCoupon(digest, coupon), "Invalid Coupon");
        // Increment number of Team tokens minted by wallet
        addressToMinted[MinterHash]._MintsByAddress += amount;
        if (TokenTypeSingle) {   
            for(uint256 i = 0; i < amount; i++){
                _mint(msg.sender, idTracker.current(), 1, "");
                TokenAmount[idTracker.current()] = 1;
                idTracker.increment();
            }
        }else{
            _mint(msg.sender, idTracker.current(), amount, "");
            TokenAmount[idTracker.current()] = TokenAmount[idTracker.current()]+amount;
        }
        
    }
    function safeTransferFrom(address from,address to,uint256 tokenId,uint256 amount,bytes memory data) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }
    function safeBatchTransferFrom(address from,address to,uint256[] memory ids,uint256[] memory amounts,bytes memory data) public virtual override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    } 
    function airdrop(address[] memory to,uint256[] memory amount) public onlyOwner {
        require(
            to.length == amount.length,
            "Length mismatch"
        );   
        for (uint256 i = 0; i < to.length; i++){
            if (TokenTypeSingle) {   
                for(uint256 j = 0; j < amount[i]; j++){
                    _mint(to[i], idTracker.current(), 1, "");
                    TokenAmount[idTracker.current()] = 1;
                    idTracker.increment();
                }
            }else{
                _mint(to[i], idTracker.current(), amount[i], "");
                TokenAmount[idTracker.current()] = TokenAmount[idTracker.current()]+amount[i];
            }
        }    
    }
    function withdraw() public onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }   
}