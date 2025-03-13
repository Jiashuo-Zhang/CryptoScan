// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../interface/IERC721SalesItem.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

///////////////////////////////////////////////////////////////////////////
// Struct and Enum
///////////////////////////////////////////////////////////////////////////
enum Phase {
    BeforeMint,
    Mint,
    Exchange
}
  
contract SalesStore is AccessControl {
    ///////////////////////////////////////////////////////////////////////////
    // Variables
    ///////////////////////////////////////////////////////////////////////////
    IERC721SalesItem public NFT;

    address public withdrawAddress = 0xFBb189698A54570d5c82399486049b6f5D008923;

    Phase public phase = Phase.BeforeMint;
    uint16 public currentSaleIndex;

    uint256 public cost = 0.005 ether;
    bytes32 public merkleRoot;
    uint256 public limitGroup;  //0 start
    bool public burnAndMintMode;    // default false;

    ///////////////////////////////////////////////////////////////////////////
    // Error functions
    ///////////////////////////////////////////////////////////////////////////
    error ZeroAddress();
    error SaleIsPaused();
    error NoAllocationInThisSale();
    error InsufficientAllocation();
    error InsufficientFunds();
    error NotGroup();
    error CallerNotUser();
    error MintAmountIsZero();
    error ArrayLengthNotMatch();
    error NotTokenHolder();

    ///////////////////////////////////////////////////////////////////////////
    // constructor
    ///////////////////////////////////////////////////////////////////////////
    constructor(address _NFTcontract) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        NFT = IERC721SalesItem(_NFTcontract);
    }

    ///////////////////////////////////////////////////////////////////////////
    // Withdraw funds and set withdraw address
    ///////////////////////////////////////////////////////////////////////////
    function withdraw() public payable onlyAdmin {
        if (withdrawAddress == address(0)) revert ZeroAddress();
        (bool os, ) = payable(withdrawAddress).call{
            value: address(this).balance
        }("");
        require(os);
    }

    function setWithdrawAddress(address _addr) external onlyAdmin {
        if (_addr == address(0)) revert ZeroAddress();
        withdrawAddress = _addr;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Setter functions : Sales controler
    ///////////////////////////////////////////////////////////////////////////
    function setPhase(Phase _newPhase) external onlyAdmin {
        //0:BeroreMint > Always Stop Sale (1 -> 0 , 2 -> 0)
        //1:Mint > Mint Start (0 -> 1)
        //2:Exchange > Exchange Start (0 -> 2)
        phase = _newPhase;
    }

    function setCurrentSaleIndex(uint16 _index) external onlyAdmin {
        currentSaleIndex = _index;
    }

    function increaseCurrentSaleIndex() external onlyAdmin returns(uint16) {
        uint16 newIndex = currentSaleIndex++;
        return newIndex;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Setter functions : Sales specification setter
    ///////////////////////////////////////////////////////////////////////////
    function setCost(uint256 _value) external onlyAdmin {
        cost = _value;
    }

    function setMerkleRoot(bytes32 _value) external onlyAdmin {
        merkleRoot = _value;
    }

    function setLimitGroup(uint256 _value) external onlyAdmin{
        limitGroup = _value;
    }

    function setBurnAndMintMode(bool _value) external onlyAdmin{
        burnAndMintMode = _value;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Essential getter functions
    ///////////////////////////////////////////////////////////////////////////
    modifier onlyAdmin() {
        _checkRole(DEFAULT_ADMIN_ROLE);
        _;
    }

    modifier whenOnMint() {
        if (phase != Phase.Mint) revert SaleIsPaused();
        _;
    }

    modifier whenOnExchange() {
        if (phase != Phase.Exchange) revert SaleIsPaused();
        _;
    }

    modifier wehenOnGroup(uint256 _group) {
        if (_group > limitGroup) revert NotGroup();
        _;
    }

    modifier callerIsUser() {
        if (tx.origin != msg.sender) revert CallerNotUser();
        _;
    }

    modifier whenValidUseAmount(uint256 _amount, uint256 _alloc, uint256 _group, bytes32[] calldata _proof) {
        // public sale if merkleRoot is 0
        if(merkleRoot != 0){
            if(MerkleProof.verifyCalldata(
                _proof,
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender,uint248(_alloc),uint248(_group)))
                ) == false){
                    revert NoAllocationInThisSale();
            }
            // Check remaining quantity of allocation
            uint256 _used = NFT.getConsumedAllocation(msg.sender, currentSaleIndex);
            if (_amount + _used > _alloc) revert InsufficientAllocation();
        }   

        if (_amount == 0) revert MintAmountIsZero();
        _;
    }

    modifier whenEnoughFunds(uint256 value, uint256 amount) {
        if (value < (amount * cost))
            revert InsufficientFunds();
        _;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Mint functions
    ///////////////////////////////////////////////////////////////////////////
    function mint(uint256 _amount, uint256 _alloc, uint256 _group,
                     bytes32[] calldata _proof,uint256[] calldata _tokenIds)
        external
        payable
        whenOnMint
        wehenOnGroup(_group)
        callerIsUser
        whenValidUseAmount(_amount, _alloc, _group,_proof)
        whenEnoughFunds(msg.value, _amount)
    {
        NFT.addConsumedAllocation(msg.sender, currentSaleIndex, uint16(_amount));

        if(burnAndMintMode == true){
            if(_amount != _tokenIds.length) revert ArrayLengthNotMatch();
            for (uint256 i = 0; i < _tokenIds.length; i++){
                if (NFT.ownerOf(_tokenIds[i]) != msg.sender) revert NotTokenHolder();
                NFT.sellerBurn(_tokenIds[i]);
            }
        }
        
        NFT.sellerMint(msg.sender, _amount);
    }

    function exchange(uint256[] calldata _tokenIds, uint256 _alloc, uint256 _group,
                     bytes32[] calldata _proof)
        external
        payable
        whenOnExchange
        wehenOnGroup(_group)
        callerIsUser
        whenValidUseAmount(_tokenIds.length, _alloc, _group,_proof)
        whenEnoughFunds(msg.value, _tokenIds.length)
    {
        NFT.addConsumedAllocation(msg.sender, currentSaleIndex, uint16(_tokenIds.length));

        for (uint256 i = 0; i < _tokenIds.length; i++){
            if (NFT.ownerOf(_tokenIds[i]) != msg.sender) revert NotTokenHolder();
            NFT.updateToken(_tokenIds[i]);
        }
        
    }

    ///////////////////////////////////////////////////////////////////////////
    // State functions
    ///////////////////////////////////////////////////////////////////////////
    function totalSupply() external view virtual returns(uint256){
        return NFT.totalSupply();
    }

    function getConsumedAllocation(address _minter) external view virtual returns(uint256){
        return NFT.getConsumedAllocation(_minter, currentSaleIndex);
    }

    function getAllocRemain(address _minter, uint256 _alloc, uint256 _group, bytes32[] calldata _proof) external view virtual returns(uint256){
        uint256 remainAlloc;
        if(MerkleProof.verifyCalldata(
                _proof,
                merkleRoot,
                keccak256(abi.encodePacked(_minter,uint248(_alloc),uint248(_group)))
                ) == true){
                remainAlloc = _alloc - NFT.getConsumedAllocation(_minter, currentSaleIndex);
        }
        return remainAlloc;
    }
}