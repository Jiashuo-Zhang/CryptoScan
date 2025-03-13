// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.4.22 <0.9.0;
contract UniscriptionFactoryV1{
    // Struct to store owner and content
    struct Uniscription {
         address owner;
         bytes content;
    }
    // Array to store all Uniscriptions
    Uniscription[] private uniscriptions;

    // Mapping to store content hash to index
    mapping(bytes32 => uint) private contentHashToIndex;

    // Variable to store the fee for creating an Uniscription
    uint public fee;

    // Variable to store the admin's address
    address public admin;

    // Variable to store the dataLimit for Gas Saving
    uint public dataLimit = 280;

    // Mapping to store approved addresses for each Uniscription
   mapping(uint => mapping(address => mapping(address => bool))) private uniscriptionApprovals;

    // Event to log new Uniscription
    event NewUniscription(uint indexed id, address indexed owner, bytes content);

    // Event to log Uniscription transfer
    event UniscriptionTransfer(uint indexed id, address indexed from, address to);
 
   // Event to log Uniscription approval
   event Approval(address indexed owner, address indexed spender, uint indexed id);

  modifier onlyOwner() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
    // Set initial admin at contract creation
    constructor() public{
        admin = msg.sender;
        createUniscription(msg.sender,"Hello World");
    }

    // Allow admin to set the fee
    function setFee(uint _fee) public  onlyOwner{
        
        fee = _fee;
    }

    // Allow admin to set the dataLimit
    function setOnChainDataLimit(uint _limit) public onlyOwner{
        dataLimit = _limit;
    }

    // Allow admin to withdraw contract's Ether
    function withdraw() public onlyOwner{
        payable(admin).transfer(address(this).balance);
    }

    // Allow admin to transfer admin role
    function transferAdmin(address _newAdmin) public onlyOwner{
        admin = _newAdmin;
    }

    // Allow users to create a new Uniscription
    function createUniscription(address receiver, bytes memory _content) public payable {
        require(msg.sender == tx.origin, "only EOA");
        bytes32 contentHash = keccak256(abi.encodePacked(_content));
        uint existingIndex = contentHashToIndex[contentHash];
        require(existingIndex == 0, "This content already exists.");
        require(msg.value >= fee, "You must send the creat fee.");
        if(_content.length > dataLimit){
            _content="";
        }
        uint id = uniscriptions.length + 1;
        uniscriptions.push(Uniscription(receiver, _content));
        contentHashToIndex[contentHash] = id;
        emit NewUniscription(id, msg.sender, _content);
    }

  
    fallback() external payable {
        createUniscription(msg.sender,msg.data);
    }

    // Allow users to transfer their Uniscription
function transferUniscription(uint _id, address _to) public {
        require(msg.sender == uniscriptions[_id-1].owner, "Only the owner can transfer this Uniscription.");
        // Transfer the Uniscription
        uniscriptions[_id-1].owner = _to;
        emit UniscriptionTransfer(_id, msg.sender, _to);
    }

function approve(uint _id, address _spender) public {
    require(msg.sender == uniscriptions[_id-1].owner, "Only the owner can approve this Uniscription.");
    uniscriptionApprovals[_id][msg.sender][_spender] = true;
    emit Approval(msg.sender, _spender, _id);
}

function safeTransferFrom(address _from, address _to, uint _id) public {
    require(uniscriptionApprovals[_id][_from][_to], "Transfer not approved for this Uniscription.");
    require(_from == uniscriptions[_id-1].owner, "Only the owner can transfer this Uniscription.");
    // Transfer the Uniscription
    uniscriptions[_id-1].owner = _to;
    uniscriptionApprovals[_id][_from][_to]=false;
    emit UniscriptionTransfer(_id, _from, _to);
}

 function isApproved(uint _id, address _owner, address _spender) public view returns (bool) {
    return uniscriptionApprovals[_id][_owner][_spender];
}
    // Allow users to get the count of Uniscriptions
    function getUniscriptionsCount() public view returns (uint) {
        return uniscriptions.length;
    }

    // Allow users to get specific Uniscription content
    function getUniscription(uint _id) public view returns (address, bytes memory) {
        return (uniscriptions[_id-1].owner, uniscriptions[_id-1].content);
    }

    function getUniscriptionByContent(bytes memory _content) public view returns (uint,address) {
        bytes32 contentHash = keccak256(abi.encodePacked(_content));
        uint id= contentHashToIndex[contentHash];
        return (id,uniscriptions[id-1].owner);
    }



}