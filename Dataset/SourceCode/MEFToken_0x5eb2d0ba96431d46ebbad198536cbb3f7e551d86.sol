/**

 *Submitted for verification at Etherscan.io on 2018-05-17

*/



pragma solidity 0.4.24;

contract Token{

    uint256 public totalSupply;



    function balanceOf(address _owner) constant returns (uint256 balance);



    function transfer(address _to, uint256 _value) returns (bool success);



    function transferFrom(address _from, address _to, uint256 _value) returns   

    (bool success);



    function approve(address _spender, uint256 _value) returns (bool success);



    function allowance(address _owner, address _spender) constant returns 

    (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    event Approval(address indexed _owner, address indexed _spender, uint256 

    _value);

}



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {

        require(balances[msg.sender] >= _value);

        balances[msg.sender] -= _value;

        balances[_to] += _value;

        Transfer(msg.sender, _to, _value);

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= 

        // _value && balances[_to] + _value > balances[_to]);

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] += _value;

        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);

        return true;

    }

    function balanceOf(address _owner) constant returns (uint256 balance) {

        return balances[_owner];

    }





    function approve(address _spender, uint256 _value) returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }





    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {

        return allowed[_owner][_spender];//允许_spender从_owner中转出的token数

    }

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

}



contract MEFToken is StandardToken {

    /* Public variables of the token */

    string public name;

    uint8 public decimals;

    string public symbol;

    string public version = '1.0';



    function MEFToken(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) {

        balances[msg.sender] = _initialAmount;

        totalSupply = _initialAmount;

        name = _tokenName;

        decimals = _decimalUnits;

        symbol = _tokenSymbol;

    }



    /* Approves and then calls the receiving contract */

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));

        return true;

    }

}