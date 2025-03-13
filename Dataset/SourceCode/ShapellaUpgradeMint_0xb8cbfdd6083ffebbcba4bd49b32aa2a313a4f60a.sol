// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;



interface TokenInterface {

  function safeTransferFrom(address from, address to, uint256 id) external;

  function publicMint() external;

}



contract ShapellaUpgradeMint {

    mapping(address=>bool) private haveproxy;



    function createProxie() internal  returns (address proxy){

		bytes memory miniProxy = bytes.concat(bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73), bytes20(address(this)), bytes15(0x5af43d82803e903d91602b57fd5bf3));

        bytes32 salt = keccak256(abi.encodePacked(msg.sender));

        assembly {

            proxy := create2(0, add(miniProxy, 32), mload(miniProxy), salt)

        }

	}





    function proxyFor() private view returns (address proxy) {

		bytes32 salt = keccak256(abi.encodePacked(msg.sender));

        bytes memory miniProxy = bytes.concat(bytes20(0x3D602d80600A3D3981F3363d3d373d3D3D363d73), bytes20(address(this)), bytes15(0x5af43d82803e903d91602b57fd5bf3));

        bytes32 byteCode = keccak256(abi.encodePacked(miniProxy));

        proxy = address(uint160(uint(keccak256(abi.encodePacked(hex'ff', address(this), salt, byteCode)))));

    }



    

    function myWithdrawal(uint256 startTokenId, address master, uint256 Num) external{

        address target = 0x5f04D47D698F79d76F85E835930170Ff4c4EBdB7;

        TokenInterface tokenInterface = TokenInterface(target);

        for (uint i= startTokenId; i< startTokenId + Num;) {

            tokenInterface.safeTransferFrom(address(this), master, i);

            unchecked {i++;}

        }

    }



    function Withdrawal(uint256 startTokenId, uint256 Num) external{

        address master = msg.sender;

        address proxy = proxyFor();

        ShapellaUpgradeMint(proxy).myWithdrawal(startTokenId, master, Num);

   }





    function myMint(uint256 Num) external{

        address target = 0x5f04D47D698F79d76F85E835930170Ff4c4EBdB7;

        TokenInterface tokenInterface = TokenInterface(target);

        for (uint i= 0; i< Num;) {

            tokenInterface.publicMint();

            unchecked {i++;}

        }

    }



	function mint(uint256 Num) external{

        address master = msg.sender;

        address proxy;

        if (haveproxy[master]){

            proxy = proxyFor();

        }else {

            proxy = createProxie();

        }

        ShapellaUpgradeMint(proxy).myMint(Num);

   }

}