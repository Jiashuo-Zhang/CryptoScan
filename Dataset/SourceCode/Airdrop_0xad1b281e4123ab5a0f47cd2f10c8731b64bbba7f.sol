// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";

contract Airdrop is Ownable {

    Token   public token;

    uint256 public constant amountAirdrop = 10 * 10**6 * 10**18;
    uint256 public constant maxClaimAddress = 50000;
    uint256 public constant endTime = 1694736000;
    uint256 public currentClaimAddress;

    struct AirdropInfo {
        bool flag;
        uint time;
    }

    mapping(address => AirdropInfo) public airdropInfoMap;

    constructor(address _token){
        token = Token(_token);
    }

    function claim() external {
        if (block.timestamp > endTime)
            revert('Time Invalid');

        if (!airdropInfoMap[msg.sender].flag) {
            if (currentClaimAddress >= maxClaimAddress)
                revert('Maximum Claim Exceed');
            currentClaimAddress++;
        }

        if(airdropInfoMap[msg.sender].time == 0) {
            airdropInfoMap[msg.sender].time = block.timestamp;
            token.transferLockToken(msg.sender, amountAirdrop);
        } else {
            if (block.timestamp - airdropInfoMap[msg.sender].time < 86400)
                revert('Time Invalid');
            airdropInfoMap[msg.sender].time = block.timestamp;
            token.transferLockToken(msg.sender, amountAirdrop);
        }

        airdropInfoMap[msg.sender].flag = true;
    }

    function available() external view returns (uint256) {
        if (!airdropInfoMap[msg.sender].flag)
            return amountAirdrop;
        if (block.timestamp - airdropInfoMap[msg.sender].time >= 86400)
            return amountAirdrop;
        return amountAirdrop / 86400 * (block.timestamp - airdropInfoMap[msg.sender].time);
    }

    function withdrawToken() external onlyOwner {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

}