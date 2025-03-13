// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;



import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/security/Pausable.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "@openzeppelin/contracts/utils/Counters.sol";

import "./interface/ILancetPasscard.sol";



contract LancetFactory is Ownable, Pausable, ReentrancyGuard {

    using ECDSA for bytes32;

    using Counters for Counters.Counter;



    // =========================================================================

    //                               Event

    // =========================================================================

    event Mint (address indexed account,uint256 indexed index);



    // =========================================================================

    //                               Modifier

    // =========================================================================

    address[] public presaleList;

    address[] public mintList; 

    mapping(address => uint256) public mintIndex; 



    Counters.Counter public mintlistAirdroppedAmount;

    Counters.Counter public presalelistAiredroppedAmount;

    Counters.Counter public currentIndex = Counters.Counter(1);

    Counters.Counter public remainSupply = Counters.Counter(777);



    address public signer;

    address public passcardAddress; 



    uint256 public mintPrice = 0.175 ether;



    uint256 public guaranteeStartTimestamp = 1680710400;

    uint256 public fcfsStartTimestamp = 1680712200;

    uint256 public endTimestamp = 1680715800;

    

    // =========================================================================

    //                               Modifier

    // =========================================================================

    modifier callerIsUser{

        require(tx.origin == _msgSender());

        _;

    }



    // =========================================================================

    //                               Function

    // =========================================================================

    function mint(uint8 _phase,bytes memory _signature) whenNotPaused nonReentrant callerIsUser external payable{

        require(mintIndex[_msgSender()] == 0,"Already Minted");

        require(_verifySignature(_msgSender(),_phase,_signature),"Invalid Signature");

        require(currentPhase() >= _phase,"Invalid Phase");

        require(msg.value == mintPrice,"Invalid Mint Price");

        require(remainSupply.current() > 0,"Sold Out");

        remainSupply.decrement() ;



        mintList.push(_msgSender());



        mintIndex[_msgSender()] = currentIndex.current();

        currentIndex.increment();



        emit Mint(_msgSender(),mintIndex[_msgSender()]);

    }



    function airdropmintList(uint256 _amount) onlyOwner nonReentrant external{

        ILancetPasscard lancetPasscard = ILancetPasscard(passcardAddress);

        for (uint256 i = 0; i < _amount; i ++){

            address recipient = mintList[mintlistAirdroppedAmount.current()];

            mintlistAirdroppedAmount.increment();

            lancetPasscard.mint(recipient);

        }

    }



    function airdropPresaleList(uint256 _amount) onlyOwner nonReentrant external{

        ILancetPasscard lancetPasscard = ILancetPasscard(passcardAddress);

        for (uint256 i = 0; i < _amount; i ++){

            address recipient = presaleList[presalelistAiredroppedAmount.current()];

            presalelistAiredroppedAmount.increment();

            lancetPasscard.mint(recipient);

        }

    }



    function addPresaleList(address[] memory _accounts) onlyOwner nonReentrant external{

        for (uint256 i = 0; i < _accounts.length; i ++){

            address account = _accounts[i];

            require(account != address(0),"Cannot Add Zero Address");

            remainSupply.decrement();

            presaleList.push(account);

        }

    }



    function resetPresaleList() onlyOwner nonReentrant external{

        remainSupply._value = remainSupply.current() + presaleList.length;

        address[] memory newPresaleList;

        presaleList = newPresaleList;

    }   



    function setSigner(address _signer) onlyOwner external{

        signer = _signer;

    }



    function setPasscardAddress(address _passcardAddress) onlyOwner external{

        passcardAddress = _passcardAddress;

    }



    function setMintPrice(uint256 _mintPrice) onlyOwner external{

        mintPrice = _mintPrice;

    }



    function setGuaranteeStartTimestamp(uint256 _timestamp) onlyOwner external{

        guaranteeStartTimestamp = _timestamp;

    }



    function setFcfsStartTimestamp(uint256 _timestamp) onlyOwner external{

        fcfsStartTimestamp = _timestamp;

    }



    function setEndTimestamp(uint256 _timestamp) onlyOwner external{

        endTimestamp = _timestamp;

    }



    function currentPhase() public view returns(uint8){

        uint256 blockTimestamp = block.timestamp;

        if (blockTimestamp > endTimestamp){

            return 0;

        }



        if (blockTimestamp >= fcfsStartTimestamp && fcfsStartTimestamp != 0){

            return 2;

        }

        

        if (blockTimestamp >= guaranteeStartTimestamp && guaranteeStartTimestamp != 0){

            return 1;

        }



        return 0;

    }



    function _verifySignature(address _account,uint8 _phase,bytes memory _signature) internal view returns(bool){

        bytes32 messageHash = _getMessageHash(_account,_phase);

        return messageHash.recover(_signature) == signer;

    }



    function _getMessageHash(address _account,uint8 _phase) internal pure returns(bytes32){

        bytes memory message = abi.encodePacked(_account,_phase);

        bytes32 messageHash = keccak256(message);

        return messageHash;

    }

    

    function withdraw() onlyOwner nonReentrant external {

        (bool success,) = msg.sender.call{value : (address(this).balance)}("");

        require(success, "Transaction Unsuccessful");

    }

}