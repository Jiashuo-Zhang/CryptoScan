pragma solidity ^0.4.20;



contract Token {





    function totalSupply() constant returns (uint256 supply) {}



    function balanceOf(address _owner) constant returns (uint256 balance) {}



    function transfer(address _to, uint256 _value) returns (bool success) {}



    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}



    function approve(address _spender, uint256 _value) returns (bool success) {}





    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}





    event Transfer(address indexed _from, address indexed _to, uint256 _value);



    event Approval(address indexed _owner, address indexed _spender, uint256 _value);





}





contract StandardToken is Token {





    function transfer(address _to, uint256 _value) returns (bool success) {



        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {



        if (balances[msg.sender] >= _value && _value > 0) {



            balances[msg.sender] -= _value;



            balances[_to] += _value;



            Transfer(msg.sender, _to, _value);



            return true;



        } else { return false; }



    }





    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {



        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {



        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {



            balances[_to] += _value;



            balances[_from] -= _value;



            allowed[_from][msg.sender] -= _value;



            Transfer(_from, _to, _value);



            return true;



        } else { return false; }



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



      return allowed[_owner][_spender];



    }





    mapping (address => uint256) balances;



    mapping (address => mapping (address => uint256)) allowed;



    uint256 public totalSupply;



}





contract ERC20Token is StandardToken {





    function () {



        //if ether is sent to this address, send it back.



        throw;



    }





    /* Public variables of the token */





    /*



    */



    string public name;                  



    uint8 public decimals;                



    string public symbol;                



    string public version = 'H1.0';       





//



// CHANGE THESE VALUES FOR YOUR TOKEN



//





    function ERC20Token(



        ) {



        balances[msg.sender] = 200000000000000000000000000;               // Give the creator all initial tokens (100000 for example)



        totalSupply = 200000000000000000000000000;                        // Update total supply (100000 for example)



        name = "Imperium";                                   // Set the name for display purposes



        decimals = 18;                            // Amount of decimals for display purposes



        symbol = "IMP";                               // Set the symbol for display purposes



    }





    /* Approves and then calls the receiving contract */



    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {



        allowed[msg.sender][_spender] = _value;



        Approval(msg.sender, _spender, _value);





        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.



        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)



        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.



        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }



        return true;



    }



}