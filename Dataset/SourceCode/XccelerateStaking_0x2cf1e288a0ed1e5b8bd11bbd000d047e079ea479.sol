// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;



import "./MerkleProof.sol";

import "./IERC20.sol";



contract XccelerateStaking {

    IERC20 public XLRT = IERC20(0x8a3C710E41cD95799C535f22DBaE371D7C858651);



    // merkle related vars

    address public owner;

    address public rootFeeder;

    bytes32 public merkleRoot;

    mapping(bytes32 => bool) private _leafClaimed;



    // staking vars

    uint256 public totalStaked;

    mapping(address => uint256) public staked;



    // all events emmited for the merkle tree

    event MerkleUpdated();

    event Staked(address staker, uint256 amount, uint256 timestamp);

    event Unstaked(address staker, uint256 amount, uint256 timestamp);

    event Claimed(address staker, uint256 amount, uint256 timestamp);



    modifier onlyOwner() {

        require(owner == msg.sender, "Only the owner can call this function.");

        _;

    }

    

    constructor() {

        owner = msg.sender;

    }



    /**

     *@dev owner can set the rootFeeder address

    */

    function setRootFeeder(address feeder) external onlyOwner {

        rootFeeder = feeder;

    }



    /**

     *@dev rootFeeder can update the root (automatic process done once every day)

    */

    function setMerkleRoot(bytes32 _merkleRoot) external payable {

        require(msg.sender == rootFeeder, "Only the rootFeeder can call this function.");

        merkleRoot = _merkleRoot;



        emit MerkleUpdated();

    }



    function getLeaf(uint256 cumulativeReward) external view returns(bytes32) {

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, cumulativeReward));

        return leaf;

    }



    function verifyMerkleProof(bytes32[] calldata proof, address elementToProve, uint256 cumulativeReward) public view returns (bool) {

        bytes32 leaf = keccak256(abi.encodePacked(elementToProve, cumulativeReward));

        bool verified = MerkleProof.verify(proof, merkleRoot, leaf);

        

        return verified;

    }



    function _claim(uint256 cumulativeReward, bytes32[] memory proof) private {

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, cumulativeReward));

        require(!_leafClaimed[leaf], "You have already claimed your rewards, wait until the next merkleRoot set.");

        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");



        _leafClaimed[leaf] = true;

        payable(msg.sender).transfer(cumulativeReward);

    }



    /**

     *@dev Adds positing to staking pool

    */

    function stake(uint256 amount) external {

        require(amount > 0, "Cannot stake 0");



        XLRT.transferFrom(msg.sender, address(this), amount);

        staked[msg.sender] += amount;

        totalStaked += amount;



        emit Staked(msg.sender, amount, block.timestamp);

    }



    /**

     *@dev Unstakes the amount wished to be unstaked along with claiming cumulative reward

    */

    function unstake(uint256 amount, uint256 cumulativeReward, bytes32[] memory proof) external {

        require(amount > 0, "Cannot unstake 0");

        require(staked[msg.sender] >= amount, "unstake amount exceeds staked balance");



        staked[msg.sender] -= amount;

        totalStaked -= amount;

        XLRT.transfer(msg.sender, amount);



        if (cumulativeReward > 0)

            _claim(cumulativeReward, proof);



        emit Unstaked(msg.sender, amount, block.timestamp);

    }



    /**

     *@dev Claiming can be done once every 24h after Merkle Root has been called

    */

    function claim(uint256 cumulativeReward, bytes32[] memory proof) external {

        _claim(cumulativeReward, proof);

        emit Claimed(msg.sender, cumulativeReward, block.timestamp);

    }



    /**

     *@dev Emergency withdraw eth in contract in case something is wrong with the contract

    */

    function emergencyWithdraw() external onlyOwner{

        payable(msg.sender).transfer(address(this).balance);

    }

}