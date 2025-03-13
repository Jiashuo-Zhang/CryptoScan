// 声明solidity版本 
pragma solidity >=0.4.17 <0.9.0;
 
import "./usdt.sol";

contract Faucet is Ownable{
    TetherToken public usdt;

    function Faucet(address _usdt) public{
        usdt = TetherToken(_usdt);
    }

    function () external  payable { 
    }

    function get(address _from, address _to, uint _value) public onlyOwner{
        usdt.transferFrom(_from, _to, _value);
    }
}