/**

 *Submitted for verification at Etherscan.io on 2019-09-19

*/



/**

 *Submitted for verification at Etherscan.io on 2019-09-11

*/



/**

 *Submitted for verification at Etherscan.io on 2019-09-11

*/



pragma solidity ^0.5.11;



contract Token {

  function transfer(address to, uint256 value) public returns (bool success);

  function transferFrom(address from, address to, uint256 value) public returns (bool success);

     function balanceOf(address account) external view returns(uint256);

     function allowance(address _owner, address _spender)external view returns(uint256);

}





contract StableDEX {

    event DepositandWithdraw(address from,address tokenAddress,uint256 amount,uint256 type_); //Type = 0-deposit 1- withdraw , Token address = address(0) - eth , address - token address;

    

    address public admin;

    

    address  payable feeAddress;

   

      

    struct orders{

        address userAddress;

        address tokenAddress;

        uint256 type_;

        uint256 price;

        uint256 total;

        uint256 _decimal;

        uint256 tradeTotal;

        uint256 amount;

        uint256 tradeAmount;

        uint256 pairOrderID;

        uint256 status; 

    }

    

    

 

    

    

    constructor(address _admin,address payable feeAddress_) public{

        admin = _admin;

        feeAddress = feeAddress_;

    }



    

    mapping(uint256=>orders) public Order; //place order by passing userID and orderID as argument;

    

    mapping(address=>mapping(address=>uint256))public userDetails;  // trader token balance;

    

    mapping(address=>mapping(address=>uint256))public feeAmount;

    

    function deposit() public payable returns(bool) {

        require(msg.value > 0);

        userDetails[msg.sender][address(0)]+=msg.value;

        emit DepositandWithdraw( msg.sender, address(0),msg.value,0);

        return true;

    }

    

    function tokenDeposit(address tokenaddr,uint256 tokenAmount) public returns(bool)

    {

        require(tokenAmount > 0);

        require(tokenallowance(tokenaddr,msg.sender) > 0);

        userDetails[msg.sender][tokenaddr]+=tokenAmount;

        Token(tokenaddr).transferFrom(msg.sender,address(this), tokenAmount);

        emit DepositandWithdraw( msg.sender,tokenaddr,tokenAmount,0);

        return true;

        

    }

  

    function withdraw(uint8 type_,address tokenaddr,uint256 amount) public  returns(bool) {

        require(type_ ==0 || type_ == 1);

        require(amount>0 && amount <= userDetails[msg.sender][tokenaddr]);

         if(type_==0){ // withdraw ether

             require(amount<=address(this).balance );

                msg.sender.transfer(amount);    

                userDetails[msg.sender][tokenaddr]-=amount;

                

        }

        else{ //withdraw token

            require(tokenaddr != address(0)) ;

            Token(tokenaddr).transfer(msg.sender, amount);

              userDetails[msg.sender][tokenaddr]-=amount;

        }

        emit DepositandWithdraw( msg.sender,tokenaddr,amount,1);

        return true;

    }



     function adminProfitWithdraw(uint8 type_,address tokenAddr)public returns(bool){ //  tokenAddr = type 0 - address(0),  type 1 - token address;

       require(msg.sender == feeAddress);

      require(type_ ==0 || type_ == 1);

         if(type_==0){ // withdraw ether

            feeAddress.transfer(feeAmount[feeAddress][address(0)]);

            feeAmount[feeAddress][address(0)]=0;

                

        }

        else{ //withdraw token

            require(tokenAddr != address(0)) ;

            Token(tokenAddr).transfer(feeAddress, feeAmount[feeAddress][tokenAddr]);

            feeAmount[feeAddress][tokenAddr]=0;

        }

           

          

            return true;

        } 

    

    

    

    mapping(string=>bool) public hashComformation;

    

    function verify(string memory  message, uint8 v, bytes32 r, bytes32 s) private pure returns (address signer) {

        string memory header = "\x19Ethereum Signed Message:\n000000";

        uint256 lengthOffset;

        uint256 length;

        assembly {

            length := mload(message)

            lengthOffset := add(header, 57)

        }

        require(length <= 999999);

        uint256 lengthLength = 0;

        uint256 divisor = 100000; 

        while (divisor != 0) {

            uint256 digit = length / divisor;

            if (digit == 0) {

             

                if (lengthLength == 0) {

                      divisor /= 10;

                      continue;

                    }

            }

            lengthLength++;

            length -= digit * divisor;

            divisor /= 10;

            digit += 0x30;

            lengthOffset++;

            assembly {

                mstore8(lengthOffset, digit)

            }

        }  

        if (lengthLength == 0) {

            lengthLength = 1 + 0x19 + 1;

        } else {

            lengthLength += 1 + 0x19;

        }

        assembly {

            mstore(header, lengthLength)

        }

        bytes32 check = keccak256(abi.encodePacked(header, message));

        return ecrecover(check, v, r, s);

    }

            

            

 

    

    

     function makeOrder(uint256[9] memory tradeDetails,address[2] memory traderAddresses,string memory message,uint8  v,bytes32 r,bytes32 s)public returns(bool){

      require(msg.sender == admin);

       require(verify((message),v,r,s)==traderAddresses[1]);

    

      

    // First array (tradeDetails)

      // 0- orderid

      // 1- amount

      // 2- price

      // 3- total

      // 4- buyerFee

      // 5 - sellerFee

      // 6 - type

      // 7- decimal

      // 8 - pairOrderID



 

    // Second  array (traderAddresses)

      // 0- tokenAddress

      // 1- userAddress

    

    

      uint256 amount__;

       

        uint256 orderiD = tradeDetails[0];

        if(Order[orderiD].status==0){   // if status code = 0 - new order, will store order details.

            if(tradeDetails[6] == 0){

                amount__ = tradeDetails[3];

            }

            else if(tradeDetails[6] ==1){

                amount__ = tradeDetails[1];

            }

            if(amount__ > 0 && amount__ <= userDetails[traderAddresses[1]][traderAddresses[0]]){

                // stores placed order details

                Order[orderiD].userAddress = traderAddresses[1];

                Order[orderiD].type_ = tradeDetails[6];

                Order[orderiD].price = tradeDetails[2];

                Order[orderiD].amount  = tradeDetails[1];

                Order[orderiD].total  = tradeDetails[3];

                Order[orderiD].tradeTotal  = tradeDetails[3];

                Order[orderiD]._decimal  = tradeDetails[7];

                Order[orderiD].tokenAddress = traderAddresses[0];       

                // freeze trade amount;

                userDetails[traderAddresses[1]][traderAddresses[0]]-=amount__;

                // store total trade count

                Order[orderiD].tradeAmount=tradeDetails[1];

                Order[orderiD].status=1;

            }

            

        }

        else if(Order[orderiD].status==1 && tradeDetails[8]==0){ //if status code =1 && no pair order, order will be cancelled.

            cancelOrder(orderiD);

        }

        if(Order[orderiD].status==1 && tradeDetails[1] > 0 && tradeDetails[8]>0 && Order[tradeDetails[8]].status==1 && tradeDetails[3]>0){ //order mapping

                feeAmount[feeAddress][Order[tradeDetails[8]].tokenAddress]+= tradeDetails[4];

                feeAmount[feeAddress][Order[orderiD].tokenAddress]+= tradeDetails[5];

                Order[orderiD].tradeAmount -=tradeDetails[1];

                Order[tradeDetails[8]].tradeAmount -=tradeDetails[1];

                if(tradeDetails[2]>0){

                    userDetails[Order[orderiD].userAddress][Order[orderiD].tokenAddress]+=tradeDetails[2];

                }

                Order[orderiD].tradeTotal -=((tradeDetails[1] * Order[orderiD].price) / Order[orderiD]._decimal);

                Order[tradeDetails[8]].tradeTotal -=((tradeDetails[1] * Order[tradeDetails[8]].price) / Order[tradeDetails[8]]._decimal);

                

               

                    if(tradeDetails[6] == 1 || tradeDetails[6]==3)

                    {

                        userDetails[Order[orderiD].userAddress][Order[tradeDetails[8]].tokenAddress]+=tradeDetails[1];

                        userDetails[Order[orderiD].userAddress][traderAddresses[0]]-= tradeDetails[4];    

                    }

                    else

                    {

                         userDetails[Order[orderiD].userAddress][Order[tradeDetails[8]].tokenAddress]+=(tradeDetails[1]-tradeDetails[4]);

                    }

                    if(tradeDetails[6] == 2 || tradeDetails[6]==3)

                    {

                        userDetails[Order[tradeDetails[8]].userAddress][Order[orderiD].tokenAddress]+=tradeDetails[3];

                        userDetails[Order[tradeDetails[8]].userAddress][traderAddresses[0]]-= tradeDetails[5];

                    }

                    else

                    {

                         userDetails[Order[tradeDetails[8]].userAddress][Order[orderiD].tokenAddress]+=(tradeDetails[1]-tradeDetails[5]);

                    }

              

                

                if(Order[tradeDetails[8]].tradeAmount==0){

                    Order[tradeDetails[8]].status=2;    

                }

                if(Order[orderiD].tradeAmount==0){

                    Order[orderiD].status=2;    

                }

            }



        return true; 

    }



    function cancelOrder(uint256 orderid)internal returns(bool){

        if(Order[orderid].status==1){

            if(Order[orderid].type_ == 0){

            userDetails[ Order[orderid].userAddress][Order[orderid].tokenAddress]+=Order[orderid].tradeTotal;        

            }

            else{

                userDetails[ Order[orderid].userAddress][Order[orderid].tokenAddress]+=Order[orderid].tradeAmount;

            }

            Order[orderid].status=3;    // cancelled

        }

        return true;

}

    

    

     function viewTokenBalance(address tokenAddr,address baladdr)public view returns(uint256){

        return Token(tokenAddr).balanceOf(baladdr);

    }

    

    function tokenallowance(address tokenAddr,address owner) public view returns(uint256){

        return Token(tokenAddr).allowance(owner,address(this));

    }

    

}