pragma solidity ^0.5.11;

contract minerProxy {

    function set(address _miner) public;

}

contract factory {



    address public template = 0xC3f3f8EED592d0Ae8CE6C84C69ce493a6d6a8a5A;



    mapping(address => address) public proxy;



    address[] internal allProxy;



    function getAllProxy() external view returns(address[] memory) {

        return allProxy;

    }



    function createProxy(address miner) public returns (address) {

        require(proxy[miner] == address(0));



        address payable _proxy;

        bytes32 salt = keccak256(abi.encodePacked(miner));

        bytes20 targetBytes = bytes20(template);



        assembly {

            let clone := mload(0x40)

                mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

                mstore(add(clone, 0x14), targetBytes)

                mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

                _proxy := create2(0, clone, 0x37, salt)

        }



        minerProxy(_proxy).set(miner);

        proxy[miner] = _proxy;

        allProxy.push(_proxy);



        return _proxy;

    }



}