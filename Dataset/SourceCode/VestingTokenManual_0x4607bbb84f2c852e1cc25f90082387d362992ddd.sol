// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;



import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";



contract VestingTokenManual is Ownable{



    using SafeERC20 for IERC20;

    IERC20 public token;

    mapping(address =>bool) public isAdmin;



    mapping(bytes => bool) public isClaimed;



    constructor(){

        isAdmin[msg.sender] = true;

    }



    function addAdmin(address user) public onlyOwner{

        isAdmin[user] = true;

    }



    function removeAdmin(address user) public onlyOwner{

        isAdmin[user] = false;

    }

    function setTokenAdd(address tokenAdd) public onlyOwner{

        token = IERC20(tokenAdd);

    }



    function claim(address user, uint256 amount, bytes memory signature,uint256 id) public {



        require(!isClaimed[signature],"User claimed");

         bytes32 _msgHash = keccak256(

            abi.encodePacked(

                "\x19Ethereum Signed Message:\n32",

                keccak256(

                    abi.encodePacked(

                        "CLAIM_TOKEN",

                        user,

                        amount,

                        id

                    )

                )

            )

        );

        address signer = getSigner(_msgHash, signature);

        require(isAdmin[signer], "MM: invalid signer");

        isClaimed[signature] = true;

        token.safeTransfer(user, amount);

    }



    function getSigner(bytes32 msgHash, bytes memory _signature)

        private

        pure

        returns (address)

    {

        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);



        return ecrecover(msgHash, v, r, s);

    }



    function splitSignature(bytes memory signature)

        private

        pure

        returns (

            bytes32 r,

            bytes32 s,

            uint8 v

        )

    {

        require(signature.length == 65, "MM: invalid signature length");

        assembly {

            r := mload(add(signature, 32))

            s := mload(add(signature, 64))

            v := byte(0, mload(add(signature, 96)))

        }

    }









}