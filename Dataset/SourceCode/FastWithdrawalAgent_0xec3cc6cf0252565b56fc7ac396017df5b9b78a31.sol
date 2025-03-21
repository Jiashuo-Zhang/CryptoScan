/**

 *Submitted for verification at Etherscan.io on 2020-10-29

*/



// SPDX-License-Identifier: Apache-2.0

// Copyright 2017 Loopring Technology Limited.

pragma solidity ^0.7.0;



interface IAgent{}



interface IAgentRegistry

{

    /// @dev Returns whether an agent address is an agent of an account owner

    /// @param owner The account owner.

    /// @param agent The agent address

    /// @return True if the agent address is an agent for the account owner, else false

    function isAgent(

        address owner,

        address agent

        )

        external

        view

        returns (bool);



    /// @dev Returns whether an agent address is an agent of all account owners

    /// @param owners The account owners.

    /// @param agent The agent address

    /// @return True if the agent address is an agent for the account owner, else false

    function isAgent(

        address[] calldata owners,

        address            agent

        )

        external

        view

        returns (bool);

}



// Copyright 2017 Loopring Technology Limited.







/// @title Ownable

/// @author Brecht Devos - <[email protected]>

/// @dev The Ownable contract has an owner address, and provides basic

///      authorization control functions, this simplifies the implementation of

///      "user permissions".

contract Ownable

{

    address public owner;



    event OwnershipTransferred(

        address indexed previousOwner,

        address indexed newOwner

    );



    /// @dev The Ownable constructor sets the original `owner` of the contract

    ///      to the sender.

    constructor()

    {

        owner = msg.sender;

    }



    /// @dev Throws if called by any account other than the owner.

    modifier onlyOwner()

    {

        require(msg.sender == owner, "UNAUTHORIZED");

        _;

    }



    /// @dev Allows the current owner to transfer control of the contract to a

    ///      new owner.

    /// @param newOwner The address to transfer ownership to.

    function transferOwnership(

        address newOwner

        )

        public

        virtual

        onlyOwner

    {

        require(newOwner != address(0), "ZERO_ADDRESS");

        emit OwnershipTransferred(owner, newOwner);

        owner = newOwner;

    }



    function renounceOwnership()

        public

        onlyOwner

    {

        emit OwnershipTransferred(owner, address(0));

        owner = address(0);

    }

}



// Copyright 2017 Loopring Technology Limited.











/// @title Claimable

/// @author Brecht Devos - <[email protected]>

/// @dev Extension for the Ownable contract, where the ownership needs

///      to be claimed. This allows the new owner to accept the transfer.

contract Claimable is Ownable

{

    address public pendingOwner;



    /// @dev Modifier throws if called by any account other than the pendingOwner.

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner, "UNAUTHORIZED");

        _;

    }



    /// @dev Allows the current owner to set the pendingOwner address.

    /// @param newOwner The address to transfer ownership to.

    function transferOwnership(

        address newOwner

        )

        public

        override

        onlyOwner

    {

        require(newOwner != address(0) && newOwner != owner, "INVALID_ADDRESS");

        pendingOwner = newOwner;

    }



    /// @dev Allows the pendingOwner address to finalize the transfer.

    function claimOwnership()

        public

        onlyPendingOwner

    {

        emit OwnershipTransferred(owner, pendingOwner);

        owner = pendingOwner;

        pendingOwner = address(0);

    }

}



// Copyright 2017 Loopring Technology Limited.





abstract contract ERC1271 {

    // bytes4(keccak256("isValidSignature(bytes32,bytes)")

    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;



    function isValidSignature(

        bytes32      _hash,

        bytes memory _signature)

        public

        view

        virtual

        returns (bytes4 magicValueB32);



}



// Copyright 2017 Loopring Technology Limited.







/// @title Utility Functions for uint

/// @author Daniel Wang - <[email protected]>

library MathUint

{

    using MathUint for uint;



    function mul(

        uint a,

        uint b

        )

        internal

        pure

        returns (uint c)

    {

        c = a * b;

        require(a == 0 || c / a == b, "MUL_OVERFLOW");

    }



    function sub(

        uint a,

        uint b

        )

        internal

        pure

        returns (uint)

    {

        require(b <= a, "SUB_UNDERFLOW");

        return a - b;

    }



    function add(

        uint a,

        uint b

        )

        internal

        pure

        returns (uint c)

    {

        c = a + b;

        require(c >= a, "ADD_OVERFLOW");

    }



    function add64(

        uint64 a,

        uint64 b

        )

        internal

        pure

        returns (uint64 c)

    {

        c = a + b;

        require(c >= a, "ADD_OVERFLOW");

    }

}



// Copyright 2017 Loopring Technology Limited.



pragma experimental ABIEncoderV2;





//Mainly taken from https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol





library BytesUtil {



    function concat(

        bytes memory _preBytes,

        bytes memory _postBytes

    )

        internal

        pure

        returns (bytes memory)

    {

        bytes memory tempBytes;



        assembly {

            // Get a location of some free memory and store it in tempBytes as

            // Solidity does for memory variables.

            tempBytes := mload(0x40)



            // Store the length of the first bytes array at the beginning of

            // the memory for tempBytes.

            let length := mload(_preBytes)

            mstore(tempBytes, length)



            // Maintain a memory counter for the current write location in the

            // temp bytes array by adding the 32 bytes for the array length to

            // the starting location.

            let mc := add(tempBytes, 0x20)

            // Stop copying when the memory counter reaches the length of the

            // first bytes array.

            let end := add(mc, length)



            for {

                // Initialize a copy counter to the start of the _preBytes data,

                // 32 bytes into its memory.

                let cc := add(_preBytes, 0x20)

            } lt(mc, end) {

                // Increase both counters by 32 bytes each iteration.

                mc := add(mc, 0x20)

                cc := add(cc, 0x20)

            } {

                // Write the _preBytes data into the tempBytes memory 32 bytes

                // at a time.

                mstore(mc, mload(cc))

            }



            // Add the length of _postBytes to the current length of tempBytes

            // and store it as the new length in the first 32 bytes of the

            // tempBytes memory.

            length := mload(_postBytes)

            mstore(tempBytes, add(length, mload(tempBytes)))



            // Move the memory counter back from a multiple of 0x20 to the

            // actual end of the _preBytes data.

            mc := end

            // Stop copying when the memory counter reaches the new combined

            // length of the arrays.

            end := add(mc, length)



            for {

                let cc := add(_postBytes, 0x20)

            } lt(mc, end) {

                mc := add(mc, 0x20)

                cc := add(cc, 0x20)

            } {

                mstore(mc, mload(cc))

            }



            // Update the free-memory pointer by padding our last write location

            // to 32 bytes: add 31 bytes to the end of tempBytes to move to the

            // next 32 byte block, then round down to the nearest multiple of

            // 32. If the sum of the length of the two arrays is zero then add

            // one before rounding down to leave a blank 32 bytes (the length block with 0).

            mstore(0x40, and(

              add(add(end, iszero(add(length, mload(_preBytes)))), 31),

              not(31) // Round down to the nearest 32 bytes.

            ))

        }



        return tempBytes;

    }



    function slice(

        bytes memory _bytes,

        uint _start,

        uint _length

    )

        internal

        pure

        returns (bytes memory)

    {

        require(_bytes.length >= (_start + _length));



        bytes memory tempBytes;



        assembly {

            switch iszero(_length)

            case 0 {

                // Get a location of some free memory and store it in tempBytes as

                // Solidity does for memory variables.

                tempBytes := mload(0x40)



                // The first word of the slice result is potentially a partial

                // word read from the original array. To read it, we calculate

                // the length of that partial word and start copying that many

                // bytes into the array. The first word we copy will start with

                // data we don't care about, but the last `lengthmod` bytes will

                // land at the beginning of the contents of the new array. When

                // we're done copying, we overwrite the full first word with

                // the actual length of the slice.

                let lengthmod := and(_length, 31)



                // The multiplication in the next line is necessary

                // because when slicing multiples of 32 bytes (lengthmod == 0)

                // the following copy loop was copying the origin's length

                // and then ending prematurely not copying everything it should.

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))

                let end := add(mc, _length)



                for {

                    // The multiplication in the next line has the same exact purpose

                    // as the one above.

                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)

                } lt(mc, end) {

                    mc := add(mc, 0x20)

                    cc := add(cc, 0x20)

                } {

                    mstore(mc, mload(cc))

                }



                mstore(tempBytes, _length)



                //update free-memory pointer

                //allocating the array padded to 32 bytes like the compiler does now

                mstore(0x40, and(add(mc, 31), not(31)))

            }

            //if we want a zero-length slice let's just return a zero-length array

            default {

                tempBytes := mload(0x40)



                mstore(0x40, add(tempBytes, 0x20))

            }

        }



        return tempBytes;

    }



    function toAddress(bytes memory _bytes, uint _start) internal  pure returns (address) {

        require(_bytes.length >= (_start + 20));

        address tempAddress;



        assembly {

            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)

        }



        return tempAddress;

    }



    function toUint8(bytes memory _bytes, uint _start) internal  pure returns (uint8) {

        require(_bytes.length >= (_start + 1));

        uint8 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x1), _start))

        }



        return tempUint;

    }



    function toUint16(bytes memory _bytes, uint _start) internal  pure returns (uint16) {

        require(_bytes.length >= (_start + 2));

        uint16 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x2), _start))

        }



        return tempUint;

    }



    function toUint24(bytes memory _bytes, uint _start) internal  pure returns (uint24) {

        require(_bytes.length >= (_start + 3));

        uint24 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x3), _start))

        }



        return tempUint;

    }



    function toUint32(bytes memory _bytes, uint _start) internal  pure returns (uint32) {

        require(_bytes.length >= (_start + 4));

        uint32 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x4), _start))

        }



        return tempUint;

    }



    function toUint64(bytes memory _bytes, uint _start) internal  pure returns (uint64) {

        require(_bytes.length >= (_start + 8));

        uint64 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x8), _start))

        }



        return tempUint;

    }



    function toUint96(bytes memory _bytes, uint _start) internal  pure returns (uint96) {

        require(_bytes.length >= (_start + 12));

        uint96 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0xc), _start))

        }



        return tempUint;

    }



    function toUint128(bytes memory _bytes, uint _start) internal  pure returns (uint128) {

        require(_bytes.length >= (_start + 16));

        uint128 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x10), _start))

        }



        return tempUint;

    }



    function toUint(bytes memory _bytes, uint _start) internal  pure returns (uint256) {

        require(_bytes.length >= (_start + 32));

        uint256 tempUint;



        assembly {

            tempUint := mload(add(add(_bytes, 0x20), _start))

        }



        return tempUint;

    }



    function toBytes4(bytes memory _bytes, uint _start) internal  pure returns (bytes4) {

        require(_bytes.length >= (_start + 4));

        bytes4 tempBytes4;



        assembly {

            tempBytes4 := mload(add(add(_bytes, 0x20), _start))

        }



        return tempBytes4;

    }



    function toBytes20(bytes memory _bytes, uint _start) internal  pure returns (bytes20) {

        require(_bytes.length >= (_start + 20));

        bytes20 tempBytes20;



        assembly {

            tempBytes20 := mload(add(add(_bytes, 0x20), _start))

        }



        return tempBytes20;

    }



    function toBytes32(bytes memory _bytes, uint _start) internal  pure returns (bytes32) {

        require(_bytes.length >= (_start + 32));

        bytes32 tempBytes32;



        assembly {

            tempBytes32 := mload(add(add(_bytes, 0x20), _start))

        }



        return tempBytes32;

    }



    function fastSHA256(

        bytes memory data

        )

        internal

        view

        returns (bytes32)

    {

        bytes32[] memory result = new bytes32[](1);

        bool success;

        assembly {

             let ptr := add(data, 32)

             success := staticcall(sub(gas(), 2000), 2, ptr, mload(data), add(result, 32), 32)

        }

        require(success, "SHA256_FAILED");

        return result[0];

    }

}



// Copyright 2017 Loopring Technology Limited.







/// @title Utility Functions for addresses

/// @author Daniel Wang - <[email protected]>

/// @author Brecht Devos - <[email protected]>

library AddressUtil

{

    using AddressUtil for *;



    function isContract(

        address addr

        )

        internal

        view

        returns (bool)

    {

        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts

        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned

        // for accounts without code, i.e. `keccak256('')`

        bytes32 codehash;

        // solhint-disable-next-line no-inline-assembly

        assembly { codehash := extcodehash(addr) }

        return (codehash != 0x0 &&

                codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);

    }



    function toPayable(

        address addr

        )

        internal

        pure

        returns (address payable)

    {

        return payable(addr);

    }



    // Works like address.send but with a customizable gas limit

    // Make sure your code is safe for reentrancy when using this function!

    function sendETH(

        address to,

        uint    amount,

        uint    gasLimit

        )

        internal

        returns (bool success)

    {

        if (amount == 0) {

            return true;

        }

        address payable recipient = to.toPayable();

        /* solium-disable-next-line */

        (success, ) = recipient.call{value: amount, gas: gasLimit}("");

    }



    // Works like address.transfer but with a customizable gas limit

    // Make sure your code is safe for reentrancy when using this function!

    function sendETHAndVerify(

        address to,

        uint    amount,

        uint    gasLimit

        )

        internal

        returns (bool success)

    {

        success = to.sendETH(amount, gasLimit);

        require(success, "TRANSFER_FAILURE");

    }



    // Works like call but is slightly more efficient when data

    // needs to be copied from memory to do the call.

    function fastCall(

        address to,

        uint    gasLimit,

        uint    value,

        bytes   memory data

        )

        internal

        returns (bool success, bytes memory returnData)

    {

        if (to != address(0)) {

            assembly {

                // Do the call

                success := call(gasLimit, to, value, add(data, 32), mload(data), 0, 0)

                // Copy the return data

                let size := returndatasize()

                returnData := mload(0x40)

                mstore(returnData, size)

                returndatacopy(add(returnData, 32), 0, size)

                // Update free memory pointer

                mstore(0x40, add(returnData, add(32, size)))

            }

        }

    }



    // Like fastCall, but throws when the call is unsuccessful.

    function fastCallAndVerify(

        address to,

        uint    gasLimit,

        uint    value,

        bytes   memory data

        )

        internal

        returns (bytes memory returnData)

    {

        bool success;

        (success, returnData) = fastCall(to, gasLimit, value, data);

        if (!success) {

            assembly {

                revert(add(returnData, 32), mload(returnData))

            }

        }

    }

}











/// @title SignatureUtil

/// @author Daniel Wang - <[email protected]>

/// @dev This method supports multihash standard. Each signature's last byte indicates

///      the signature's type.

library SignatureUtil

{

    using BytesUtil     for bytes;

    using MathUint      for uint;

    using AddressUtil   for address;



    enum SignatureType {

        ILLEGAL,

        INVALID,

        EIP_712,

        ETH_SIGN,

        WALLET   // deprecated

    }



    bytes4 constant internal ERC1271_MAGICVALUE = 0x1626ba7e;



    function verifySignatures(

        bytes32          signHash,

        address[] memory signers,

        bytes[]   memory signatures

        )

        internal

        view

        returns (bool)

    {

        require(signers.length == signatures.length, "BAD_SIGNATURE_DATA");

        address lastSigner;

        for (uint i = 0; i < signers.length; i++) {

            require(signers[i] > lastSigner, "INVALID_SIGNERS_ORDER");

            lastSigner = signers[i];

            if (!verifySignature(signHash, signers[i], signatures[i])) {

                return false;

            }

        }

        return true;

    }



    function verifySignature(

        bytes32        signHash,

        address        signer,

        bytes   memory signature

        )

        internal

        view

        returns (bool)

    {

        if (signer == address(0)) {

            return false;

        }



        return signer.isContract()?

            verifyERC1271Signature(signHash, signer, signature):

            verifyEOASignature(signHash, signer, signature);

    }



    function recoverECDSASigner(

        bytes32      signHash,

        bytes memory signature

        )

        internal

        pure

        returns (address)

    {

        if (signature.length != 65) {

            return address(0);

        }



        bytes32 r;

        bytes32 s;

        uint8   v;

        // we jump 32 (0x20) as the first slot of bytes contains the length

        // we jump 65 (0x41) per signature

        // for v we load 32 bytes ending with v (the first 31 come from s) then apply a mask

        assembly {

            r := mload(add(signature, 0x20))

            s := mload(add(signature, 0x40))

            v := and(mload(add(signature, 0x41)), 0xff)

        }

        // See https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/cryptography/ECDSA.sol

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {

            return address(0);

        }

        if (v == 27 || v == 28) {

            return ecrecover(signHash, v, r, s);

        } else {

            return address(0);

        }

    }



    function verifyEOASignature(

        bytes32        signHash,

        address        signer,

        bytes   memory signature

        )

        private

        pure

        returns (bool success)

    {

        if (signer == address(0)) {

            return false;

        }



        uint signatureTypeOffset = signature.length.sub(1);

        SignatureType signatureType = SignatureType(signature.toUint8(signatureTypeOffset));



        // Strip off the last byte of the signature by updating the length

        assembly {

            mstore(signature, signatureTypeOffset)

        }



        if (signatureType == SignatureType.EIP_712) {

            success = (signer == recoverECDSASigner(signHash, signature));

        } else if (signatureType == SignatureType.ETH_SIGN) {

            bytes32 hash = keccak256(

                abi.encodePacked("\x19Ethereum Signed Message:\n32", signHash)

            );

            success = (signer == recoverECDSASigner(hash, signature));

        } else {

            success = false;

        }



        // Restore the signature length

        assembly {

            mstore(signature, add(signatureTypeOffset, 1))

        }



        return success;

    }



    function verifyERC1271Signature(

        bytes32 signHash,

        address signer,

        bytes   memory signature

        )

        private

        view

        returns (bool)

    {

        bytes memory callData = abi.encodeWithSelector(

            ERC1271.isValidSignature.selector,

            signHash,

            signature

        );

        (bool success, bytes memory result) = signer.staticcall(callData);

        return (

            success &&

            result.length == 32 &&

            result.toBytes4(0) == ERC1271_MAGICVALUE

        );

    }

}



// Copyright 2017 Loopring Technology Limited.









library EIP712

{

    struct Domain {

        string  name;

        string  version;

        address verifyingContract;

    }



    bytes32 constant internal EIP712_DOMAIN_TYPEHASH = keccak256(

        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"

    );



    string constant internal EIP191_HEADER = "\x19\x01";



    function hash(Domain memory domain)

        internal

        pure

        returns (bytes32)

    {

        uint _chainid;

        assembly { _chainid := chainid() }



        return keccak256(

            abi.encode(

                EIP712_DOMAIN_TYPEHASH,

                keccak256(bytes(domain.name)),

                keccak256(bytes(domain.version)),

                _chainid,

                domain.verifyingContract

            )

        );

    }



    function hashPacked(

        bytes32 domainHash,

        bytes32 dataHash

        )

        internal

        pure

        returns (bytes32)

    {

        return keccak256(

            abi.encodePacked(

                EIP191_HEADER,

                domainHash,

                dataHash

            )

        );

    }

}

// Copyright 2017 Loopring Technology Limited.











// Copyright 2017 Loopring Technology Limited.











// Copyright 2017 Loopring Technology Limited.











// Copyright 2017 Loopring Technology Limited.













/// @title IBlockVerifier

/// @author Brecht Devos - <[email protected]>

abstract contract IBlockVerifier is Claimable

{

    // -- Events --



    event CircuitRegistered(

        uint8  indexed blockType,

        uint16         blockSize,

        uint8          blockVersion

    );



    event CircuitDisabled(

        uint8  indexed blockType,

        uint16         blockSize,

        uint8          blockVersion

    );



    // -- Public functions --



    /// @dev Sets the verifying key for the specified circuit.

    ///      Every block permutation needs its own circuit and thus its own set of

    ///      verification keys. Only a limited number of block sizes per block

    ///      type are supported.

    /// @param blockType The type of the block

    /// @param blockSize The number of requests handled in the block

    /// @param blockVersion The block version (i.e. which circuit version needs to be used)

    /// @param vk The verification key

    function registerCircuit(

        uint8    blockType,

        uint16   blockSize,

        uint8    blockVersion,

        uint[18] calldata vk

        )

        external

        virtual;



    /// @dev Disables the use of the specified circuit.

    ///      This will stop NEW blocks from using the given circuit, blocks that were already committed

    ///      can still be verified.

    /// @param blockType The type of the block

    /// @param blockSize The number of requests handled in the block

    /// @param blockVersion The block version (i.e. which circuit version needs to be used)

    function disableCircuit(

        uint8  blockType,

        uint16 blockSize,

        uint8  blockVersion

        )

        external

        virtual;



    /// @dev Verifies blocks with the given public data and proofs.

    ///      Verifying a block makes sure all requests handled in the block

    ///      are correctly handled by the operator.

    /// @param blockType The type of block

    /// @param blockSize The number of requests handled in the block

    /// @param blockVersion The block version (i.e. which circuit version needs to be used)

    /// @param publicInputs The hash of all the public data of the blocks

    /// @param proofs The ZK proofs proving that the blocks are correct

    /// @return True if the block is valid, false otherwise

    function verifyProofs(

        uint8  blockType,

        uint16 blockSize,

        uint8  blockVersion,

        uint[] calldata publicInputs,

        uint[] calldata proofs

        )

        external

        virtual

        view

        returns (bool);



    /// @dev Checks if a circuit with the specified parameters is registered.

    /// @param blockType The type of the block

    /// @param blockSize The number of requests handled in the block

    /// @param blockVersion The block version (i.e. which circuit version needs to be used)

    /// @return True if the circuit is registered, false otherwise

    function isCircuitRegistered(

        uint8  blockType,

        uint16 blockSize,

        uint8  blockVersion

        )

        external

        virtual

        view

        returns (bool);



    /// @dev Checks if a circuit can still be used to commit new blocks.

    /// @param blockType The type of the block

    /// @param blockSize The number of requests handled in the block

    /// @param blockVersion The block version (i.e. which circuit version needs to be used)

    /// @return True if the circuit is enabled, false otherwise

    function isCircuitEnabled(

        uint8  blockType,

        uint16 blockSize,

        uint8  blockVersion

        )

        external

        virtual

        view

        returns (bool);

}





// Copyright 2017 Loopring Technology Limited.







/// @title IDepositContract.

/// @dev   Contract storing and transferring funds for an exchange.

///

///        ERC1155 tokens can be supported by registering pseudo token addresses calculated

///        as `address(keccak256(real_token_address, token_params))`. Then the custom

///        deposit contract can look up the real token address and paramsters with the

///        pseudo token address before doing the transfers.

/// @author Brecht Devos - <[email protected]>

interface IDepositContract

{

    /// @dev Returns if a token is suppoprted by this contract.

    function isTokenSupported(address token)

        external

        view

        returns (bool);



    /// @dev Transfers tokens from a user to the exchange. This function will

    ///      be called when a user deposits funds to the exchange.

    ///      In a simple implementation the funds are simply stored inside the

    ///      deposit contract directly. More advanced implementations may store the funds

    ///      in some DeFi application to earn interest, so this function could directly

    ///      call the necessary functions to store the funds there.

    ///

    ///      This function needs to throw when an error occurred!

    ///

    ///      This function can only be called by the exchange.

    ///

    /// @param from The address of the account that sends the tokens.

    /// @param token The address of the token to transfer (`0x0` for ETH).

    /// @param amount The amount of tokens to transfer.

    /// @param extraData Opaque data that can be used by the contract to handle the deposit

    /// @return amountReceived The amount to deposit to the user's account in the Merkle tree

    function deposit(

        address from,

        address token,

        uint96  amount,

        bytes   calldata extraData

        )

        external

        payable

        returns (uint96 amountReceived);



    /// @dev Transfers tokens from the exchange to a user. This function will

    ///      be called when a withdrawal is done for a user on the exchange.

    ///      In the simplest implementation the funds are simply stored inside the

    ///      deposit contract directly so this simply transfers the requested tokens back

    ///      to the user. More advanced implementations may store the funds

    ///      in some DeFi application to earn interest so the function would

    ///      need to get those tokens back from the DeFi application first before they

    ///      can be transferred to the user.

    ///

    ///      This function needs to throw when an error occurred!

    ///

    ///      This function can only be called by the exchange.

    ///

    /// @param from The address from which 'amount' tokens are transferred.

    /// @param to The address to which 'amount' tokens are transferred.

    /// @param token The address of the token to transfer (`0x0` for ETH).

    /// @param amount The amount of tokens transferred.

    /// @param extraData Opaque data that can be used by the contract to handle the withdrawal

    function withdraw(

        address from,

        address to,

        address token,

        uint    amount,

        bytes   calldata extraData

        )

        external

        payable;



    /// @dev Transfers tokens (ETH not supported) for a user using the allowance set

    ///      for the exchange. This way the approval can be used for all functionality (and

    ///      extended functionality) of the exchange.

    ///      Should NOT be used to deposit/withdraw user funds, `deposit`/`withdraw`

    ///      should be used for that as they will contain specialised logic for those operations.

    ///      This function can be called by the exchange to transfer onchain funds of users

    ///      necessary for Agent functionality.

    ///

    ///      This function needs to throw when an error occurred!

    ///

    ///      This function can only be called by the exchange.

    ///

    /// @param from The address of the account that sends the tokens.

    /// @param to The address to which 'amount' tokens are transferred.

    /// @param token The address of the token to transfer (ETH is and cannot be suppported).

    /// @param amount The amount of tokens transferred.

    function transfer(

        address from,

        address to,

        address token,

        uint    amount

        )

        external

        payable;



    /// @dev Checks if the given address is used for depositing ETH or not.

    ///      Is used while depositing to send the correct ETH amount to the deposit contract.

    ///

    ///      Note that 0x0 is always registered for deposting ETH when the exchange is created!

    ///      This function allows additional addresses to be used for depositing ETH, the deposit

    ///      contract can implement different behaviour based on the address value.

    ///

    /// @param addr The address to check

    /// @return True if the address is used for depositing ETH, else false.

    function isETH(address addr)

        external

        view

        returns (bool);

}



// Copyright 2017 Loopring Technology Limited.











/// @title ILoopringV3

/// @author Brecht Devos - <[email protected]>

/// @author Daniel Wang  - <[email protected]>

abstract contract ILoopringV3 is Claimable

{

    // == Events ==

    event ExchangeStakeDeposited(address exchangeAddr, uint amount);

    event ExchangeStakeWithdrawn(address exchangeAddr, uint amount);

    event ExchangeStakeBurned(address exchangeAddr, uint amount);

    event SettingsUpdated(uint time);



    // == Public Variables ==

    mapping (address => uint) internal exchangeStake;



    address public lrcAddress;

    uint    public totalStake;

    address public blockVerifierAddress;

    uint    public forcedWithdrawalFee;

    uint    public tokenRegistrationFeeLRCBase;

    uint    public tokenRegistrationFeeLRCDelta;

    uint8   public protocolTakerFeeBips;

    uint8   public protocolMakerFeeBips;



    address payable public protocolFeeVault;



    // == Public Functions ==

    /// @dev Updates the global exchange settings.

    ///      This function can only be called by the owner of this contract.

    ///

    ///      Warning: these new values will be used by existing and

    ///      new Loopring exchanges.

    function updateSettings(

        address payable _protocolFeeVault,   // address(0) not allowed

        address _blockVerifierAddress,       // address(0) not allowed

        uint    _forcedWithdrawalFee

        )

        external

        virtual;



    /// @dev Updates the global protocol fee settings.

    ///      This function can only be called by the owner of this contract.

    ///

    ///      Warning: these new values will be used by existing and

    ///      new Loopring exchanges.

    function updateProtocolFeeSettings(

        uint8 _protocolTakerFeeBips,

        uint8 _protocolMakerFeeBips

        )

        external

        virtual;



    /// @dev Gets the amount of staked LRC for an exchange.

    /// @param exchangeAddr The address of the exchange

    /// @return stakedLRC The amount of LRC

    function getExchangeStake(

        address exchangeAddr

        )

        public

        virtual

        view

        returns (uint stakedLRC);



    /// @dev Burns a certain amount of staked LRC for a specific exchange.

    ///      This function is meant to be called only from exchange contracts.

    /// @return burnedLRC The amount of LRC burned. If the amount is greater than

    ///         the staked amount, all staked LRC will be burned.

    function burnExchangeStake(

        uint amount

        )

        external

        virtual

        returns (uint burnedLRC);



    /// @dev Stakes more LRC for an exchange.

    /// @param  exchangeAddr The address of the exchange

    /// @param  amountLRC The amount of LRC to stake

    /// @return stakedLRC The total amount of LRC staked for the exchange

    function depositExchangeStake(

        address exchangeAddr,

        uint    amountLRC

        )

        external

        virtual

        returns (uint stakedLRC);



    /// @dev Withdraws a certain amount of staked LRC for an exchange to the given address.

    ///      This function is meant to be called only from within exchange contracts.

    /// @param  recipient The address to receive LRC

    /// @param  requestedAmount The amount of LRC to withdraw

    /// @return amountLRC The amount of LRC withdrawn

    function withdrawExchangeStake(

        address recipient,

        uint    requestedAmount

        )

        external

        virtual

        returns (uint amountLRC);



    /// @dev Gets the protocol fee values for an exchange.

    /// @return takerFeeBips The protocol taker fee

    /// @return makerFeeBips The protocol maker fee

    function getProtocolFeeValues(

        )

        public

        virtual

        view

        returns (

            uint8 takerFeeBips,

            uint8 makerFeeBips

        );

}







/// @title ExchangeData

/// @dev All methods in this lib are internal, therefore, there is no need

///      to deploy this library independently.

/// @author Daniel Wang  - <[email protected]>

/// @author Brecht Devos - <[email protected]>

library ExchangeData

{

    // -- Enums --

    enum TransactionType

    {

        NOOP,

        DEPOSIT,

        WITHDRAWAL,

        TRANSFER,

        SPOT_TRADE,

        ACCOUNT_UPDATE,

        AMM_UPDATE

    }



    // -- Structs --

    struct Token

    {

        address token;

    }



    struct ProtocolFeeData

    {

        uint32 syncedAt; // only valid before 2105 (85 years to go)

        uint8  takerFeeBips;

        uint8  makerFeeBips;

        uint8  previousTakerFeeBips;

        uint8  previousMakerFeeBips;

    }



    // General auxiliary data for each conditional transaction

    struct AuxiliaryData

    {

        uint  txIndex;

        bytes data;

    }



    // This is the (virtual) block the owner  needs to submit onchain to maintain the

    // per-exchange (virtual) blockchain.

    struct Block

    {

        uint8      blockType;

        uint16     blockSize;

        uint8      blockVersion;

        bytes      data;

        uint256[8] proof;



        // Whether we should store the @BlockInfo for this block on-chain.

        bool storeBlockInfoOnchain;



        // Block specific data that is only used to help process the block on-chain.

        // It is not used as input for the circuits and it is not necessary for data-availability.

        AuxiliaryData[] auxiliaryData;



        // Arbitrary data, mainly for off-chain data-availability, i.e.,

        // the multihash of the IPFS file that contains the block data.

        bytes offchainData;

    }



    struct BlockInfo

    {

        // The time the block was submitted on-chain.

        uint32  timestamp;

        // The public data hash of the block (the 28 most significant bytes).

        bytes28 blockDataHash;

    }



    // Represents an onchain deposit request.

    struct Deposit

    {

        uint96 amount;

        uint64 timestamp;

    }



    // A forced withdrawal request.

    // If the actual owner of the account initiated the request (we don't know who the owner is

    // at the time the request is being made) the full balance will be withdrawn.

    struct ForcedWithdrawal

    {

        address owner;

        uint64  timestamp;

    }



    struct Constants

    {

        uint SNARK_SCALAR_FIELD;

        uint MAX_OPEN_FORCED_REQUESTS;

        uint MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE;

        uint TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS;

        uint MAX_NUM_ACCOUNTS;

        uint MAX_NUM_TOKENS;

        uint MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED;

        uint MIN_TIME_IN_SHUTDOWN;

        uint TX_DATA_AVAILABILITY_SIZE;

        uint MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND;

    }



    function SNARK_SCALAR_FIELD() internal pure returns (uint) {

        // This is the prime number that is used for the alt_bn128 elliptic curve, see EIP-196.

        return 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    }

    function MAX_OPEN_FORCED_REQUESTS() internal pure returns (uint16) { return 4096; }

    function MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE() internal pure returns (uint32) { return 15 days; }

    function TIMESTAMP_HALF_WINDOW_SIZE_IN_SECONDS() internal pure returns (uint32) { return 7 days; }

    function MAX_NUM_ACCOUNTS() internal pure returns (uint) { return 2 ** 32; }

    function MAX_NUM_TOKENS() internal pure returns (uint) { return 2 ** 16; }

    function MIN_AGE_PROTOCOL_FEES_UNTIL_UPDATED() internal pure returns (uint32) { return 7 days; }

    function MIN_TIME_IN_SHUTDOWN() internal pure returns (uint32) { return 30 days; }

    // The amount of bytes each rollup transaction uses in the block data for data-availability.

    // This is the maximum amount of bytes of all different transaction types.

    function TX_DATA_AVAILABILITY_SIZE() internal pure returns (uint32) { return 68; }

    function MAX_AGE_DEPOSIT_UNTIL_WITHDRAWABLE_UPPERBOUND() internal pure returns (uint32) { return 15 days; }

    function ACCOUNTID_PROTOCOLFEE() internal pure returns (uint32) { return 0; }



    function TX_DATA_AVAILABILITY_SIZE_PART_1() internal pure returns (uint32) { return 29; }

    function TX_DATA_AVAILABILITY_SIZE_PART_2() internal pure returns (uint32) { return 39; }



    struct AccountLeaf

    {

        uint32   accountID;

        address  owner;

        uint     pubKeyX;

        uint     pubKeyY;

        uint32   nonce;

        uint     feeBipsAMM;

    }



    struct BalanceLeaf

    {

        uint16   tokenID;

        uint96   balance;

        uint96   weightAMM;

        uint     storageRoot;

    }



    struct MerkleProof

    {

        ExchangeData.AccountLeaf accountLeaf;

        ExchangeData.BalanceLeaf balanceLeaf;

        uint[48]                 accountMerkleProof;

        uint[24]                 balanceMerkleProof;

    }



    struct BlockContext

    {

        bytes32 DOMAIN_SEPARATOR;

        uint32  timestamp;

    }



    // Represents the entire exchange state except the owner of the exchange.

    struct State

    {

        uint32  maxAgeDepositUntilWithdrawable;

        bytes32 DOMAIN_SEPARATOR;



        ILoopringV3      loopring;

        IBlockVerifier   blockVerifier;

        IAgentRegistry   agentRegistry;

        IDepositContract depositContract;





        // The merkle root of the offchain data stored in a Merkle tree. The Merkle tree

        // stores balances for users using an account model.

        bytes32 merkleRoot;



        // List of all blocks

        mapping(uint => BlockInfo) blocks;

        uint  numBlocks;



        // List of all tokens

        Token[] tokens;



        // A map from a token to its tokenID + 1

        mapping (address => uint16) tokenToTokenId;



        // A map from an accountID to a tokenID to if the balance is withdrawn

        mapping (uint32 => mapping (uint16 => bool)) withdrawnInWithdrawMode;



        // A map from an account to a token to the amount withdrawable for that account.

        // This is only used when the automatic distribution of the withdrawal failed.

        mapping (address => mapping (uint16 => uint)) amountWithdrawable;



        // A map from an account to a token to the forced withdrawal (always full balance)

        mapping (uint32 => mapping (uint16 => ForcedWithdrawal)) pendingForcedWithdrawals;



        // A map from an address to a token to a deposit

        mapping (address => mapping (uint16 => Deposit)) pendingDeposits;



        // A map from an account owner to an approved transaction hash to if the transaction is approved or not

        mapping (address => mapping (bytes32 => bool)) approvedTx;



        // A map from an account owner to a destination address to a tokenID to an amount to a storageID to a new recipient address

        mapping (address => mapping (address => mapping (uint16 => mapping (uint => mapping (uint32 => address))))) withdrawalRecipient;





        // Counter to keep track of how many of forced requests are open so we can limit the work that needs to be done by the owner

        uint32 numPendingForcedTransactions;



        // Cached data for the protocol fee

        ProtocolFeeData protocolFeeData;



        // Time when the exchange was shutdown

        uint shutdownModeStartTime;



        // Time when the exchange has entered withdrawal mode

        uint withdrawalModeStartTime;



        // Last time the protocol fee was withdrawn for a specific token

        mapping (address => uint) protocolFeeLastWithdrawnTime;

    }

}







/// @title IExchangeV3

/// @dev Note that Claimable and RentrancyGuard are inherited here to

///      ensure all data members are declared on IExchangeV3 to make it

///      easy to support upgradability through proxies.

///

///      Subclasses of this contract must NOT define constructor to

///      initialize data.

///

/// @author Brecht Devos - <[email protected]>

/// @author Daniel Wang  - <[email protected]>

abstract contract IExchangeV3 is Claimable

{

    // -- Events --



    event ExchangeCloned(

        address exchangeAddress,

        address owner,

        bytes32 genesisMerkleRoot

    );



    event TokenRegistered(

        address token,

        uint16  tokenId

    );



    event Shutdown(

        uint timestamp

    );



    event WithdrawalModeActivated(

        uint timestamp

    );



    event BlockSubmitted(

        uint    indexed blockIdx,

        bytes32         merkleRoot,

        bytes32         publicDataHash

    );



    event DepositRequested(

        address from,

        address to,

        address token,

        uint16  tokenId,

        uint96  amount

    );



    event ForcedWithdrawalRequested(

        address owner,

        address token,

        uint32  accountID

    );



    event WithdrawalCompleted(

        uint8   category,

        address from,

        address to,

        address token,

        uint    amount

    );



    event WithdrawalFailed(

        uint8   category,

        address from,

        address to,

        address token,

        uint    amount

    );



    event ProtocolFeesUpdated(

        uint8 takerFeeBips,

        uint8 makerFeeBips,

        uint8 previousTakerFeeBips,

        uint8 previousMakerFeeBips

    );



    event TransactionApproved(

        address owner,

        bytes32 transactionHash

    );



    // events from libraries

    /*event DepositProcessed(

        address to,

        uint32  toAccountId,

        uint16  token,

        uint    amount

    );*/



    /*event ForcedWithdrawalProcessed(

        uint32 fromAccountID,

        uint16 tokenID,

        uint   amount

    );*/



    /*event ConditionalTransferProcessed(

        address from,

        address to,

        uint16  token,

        uint    amount

    );*/



    /*event AccountUpdated(

        uint32 owner,

        uint   publicKey

    );*/





    // -- Initialization --

    /// @dev Initializes this exchange. This method can only be called once.

    /// @param  loopring The LoopringV3 contract address.

    /// @param  owner The owner of this exchange.

    /// @param  genesisMerkleRoot The initial Merkle tree state.

    function initialize(

        address loopring,

        address owner,

        bytes32 genesisMerkleRoot

        )

        virtual

        external;



    /// @dev Initialized the agent registry contract used by the exchange.

    ///      Can only be called by the exchange owner once.

    /// @param agentRegistry The agent registry contract to be used

    function setAgentRegistry(address agentRegistry)

        external

        virtual;



    /// @dev Gets the agent registry contract used by the exchange.

    /// @return the agent registry contract

    function getAgentRegistry()

        external

        virtual

        view

        returns (IAgentRegistry);



    ///      Can only be called by the exchange owner once.

    /// @param depositContract The deposit contract to be used

    function setDepositContract(address depositContract)

        external

        virtual;



    /// @dev Gets the deposit contract used by the exchange.

    /// @return the deposit contract

    function getDepositContract()

        external

        virtual

        view

        returns (IDepositContract);



    // @dev Exchange owner withdraws fees from the exchange.

    // @param token Fee token address

    // @param feeRecipient Fee recipient address

    function withdrawExchangeFees(

        address token,

        address feeRecipient

        )

        external

        virtual;



    // -- Constants --

    /// @dev Returns a list of constants used by the exchange.

    /// @return constants The list of constants.

    function getConstants()

        external

        virtual

        pure

        returns(ExchangeData.Constants memory);



    // -- Mode --

    /// @dev Returns hether the exchange is in withdrawal mode.

    /// @return Returns true if the exchange is in withdrawal mode, else false.

    function isInWithdrawalMode()

        external

        virtual

        view

        returns (bool);



    /// @dev Returns whether the exchange is shutdown.

    /// @return Returns true if the exchange is shutdown, else false.

    function isShutdown()

        external

        virtual

        view

        returns (bool);



    // -- Tokens --

    /// @dev Registers an ERC20 token for a token id. Note that different exchanges may have

    ///      different ids for the same ERC20 token.

    ///

    ///      Please note that 1 is reserved for Ether (ETH), 2 is reserved for Wrapped Ether (ETH),

    ///      and 3 is reserved for Loopring Token (LRC).

    ///

    ///      This function is only callable by the exchange owner.

    ///

    /// @param  tokenAddress The token's address

    /// @return tokenID The token's ID in this exchanges.

    function registerToken(

        address tokenAddress

        )

        external

        virtual

        returns (uint16 tokenID);



    /// @dev Returns the id of a registered token.

    /// @param  tokenAddress The token's address

    /// @return tokenID The token's ID in this exchanges.

    function getTokenID(

        address tokenAddress

        )

        external

        virtual

        view

        returns (uint16 tokenID);



    /// @dev Returns the address of a registered token.

    /// @param  tokenID The token's ID in this exchanges.

    /// @return tokenAddress The token's address

    function getTokenAddress(

        uint16 tokenID

        )

        external

        virtual

        view

        returns (address tokenAddress);



    // -- Stakes --

    /// @dev Gets the amount of LRC the owner has staked onchain for this exchange.

    ///      The stake will be burned if the exchange does not fulfill its duty by

    ///      processing user requests in time. Please note that order matching may potentially

    ///      performed by another party and is not part of the exchange's duty.

    ///

    /// @return The amount of LRC staked

    function getExchangeStake()

        external

        virtual

        view

        returns (uint);



    /// @dev Withdraws the amount staked for this exchange.

    ///      This can only be done if the exchange has been correctly shutdown:

    ///      - The exchange owner has shutdown the exchange

    ///      - All deposit requests are processed

    ///      - All funds are returned to the users (merkle root is reset to initial state)

    ///

    ///      Can only be called by the exchange owner.

    ///

    /// @return amountLRC The amount of LRC withdrawn

    function withdrawExchangeStake(

        address recipient

        )

        external

        virtual

        returns (uint amountLRC);



    /// @dev Can by called by anyone to burn the stake of the exchange when certain

    ///      conditions are fulfilled.

    ///

    ///      Currently this will only burn the stake of the exchange if

    ///      the exchange is in withdrawal mode.

    function burnExchangeStake()

        external

        virtual;



    // -- Blocks --



    /// @dev Gets the current Merkle root of this exchange's virtual blockchain.

    /// @return The current Merkle root.

    function getMerkleRoot()

        external

        virtual

        view

        returns (bytes32);



    /// @dev Gets the height of this exchange's virtual blockchain. The block height for a

    ///      new exchange is 1.

    /// @return The virtual blockchain height which is the index of the last block.

    function getBlockHeight()

        external

        virtual

        view

        returns (uint);



    /// @dev Gets some minimal info of a previously submitted block that's kept onchain.

    ///      A DEX can use this function to implement a payment receipt verification

    ///      contract with a challange-response scheme.

    /// @param blockIdx The block index.

    function getBlockInfo(uint blockIdx)

        external

        virtual

        view

        returns (ExchangeData.BlockInfo memory);



    /// @dev Sumbits new blocks to the rollup blockchain.

    ///

    ///      This function can only be called by the exchange operator.

    ///

    /// @param blocks The blocks being submitted

    ///      - blockType: The type of the new block

    ///      - blockSize: The number of onchain or offchain requests/settlements

    ///        that have been processed in this block

    ///      - blockVersion: The circuit version to use for verifying the block

    ///      - storeBlockInfoOnchain: If the block info for this block needs to be stored on-chain

    ///      - data: The data for this block

    ///      - offchainData: Arbitrary data, mainly for off-chain data-availability, i.e.,

    ///        the multihash of the IPFS file that contains the block data.

    function submitBlocks(ExchangeData.Block[] calldata blocks)

        external

        virtual;



    /// @dev Gets the number of available forced request slots.

    /// @return The number of available slots.

    function getNumAvailableForcedSlots()

        external

        virtual

        view

        returns (uint);



    // -- Deposits --



    /// @dev Deposits Ether or ERC20 tokens to the specified account.

    ///

    ///      This function is only callable by an agent of 'from'.

    ///

    ///      A fee to the owner is paid in ETH to process the deposit.

    ///      The operator is not forced to do the deposit and the user can send

    ///      any fee amount.

    ///

    /// @param from The address that deposits the funds to the exchange

    /// @param to The account owner's address receiving the funds

    /// @param tokenAddress The address of the token, use `0x0` for Ether.

    /// @param amount The amount of tokens to deposit

    /// @param auxiliaryData Optional extra data used by the deposit contract

    function deposit(

        address from,

        address to,

        address tokenAddress,

        uint96  amount,

        bytes   calldata auxiliaryData

        )

        external

        virtual

        payable;



    /// @dev Gets the amount of tokens that may be added to the owner's account.

    /// @param owner The destination address for the amount deposited.

    /// @param tokenAddress The address of the token, use `0x0` for Ether.

    /// @return The amount of tokens pending.

    function getPendingDepositAmount(

        address owner,

        address tokenAddress

        )

        external

        virtual

        view

        returns (uint96);



    // -- Withdrawals --

    /// @dev Submits an onchain request to force withdraw Ether or ERC20 tokens.

    ///      This request always withdraws the full balance.

    ///

    ///      This function is only callable by an agent of the account.

    ///

    ///      The total fee in ETH that the user needs to pay is 'withdrawalFee'.

    ///      If the user sends too much ETH the surplus is sent back immediately.

    ///

    ///      Note that after such an operation, it will take the owner some

    ///      time (no more than MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE) to process the request

    ///      and create the deposit to the offchain account.

    ///

    /// @param owner The expected owner of the account

    /// @param tokenAddress The address of the token, use `0x0` for Ether.

    /// @param accountID The address the account in the Merkle tree.

    function forceWithdraw(

        address owner,

        address tokenAddress,

        uint32  accountID

        )

        external

        virtual

        payable;



    /// @dev Checks if a forced withdrawal is pending for an account balance.

    /// @param  accountID The accountID of the account to check.

    /// @param  token The token address

    /// @return True if a request is pending, false otherwise

    function isForcedWithdrawalPending(

        uint32  accountID,

        address token

        )

        external

        virtual

        view

        returns (bool);



    /// @dev Submits an onchain request to withdraw Ether or ERC20 tokens from the

    ///      protocol fees account. The complete balance is always withdrawn.

    ///

    ///      Anyone can request a withdrawal of the protocol fees.

    ///

    ///      Note that after such an operation, it will take the owner some

    ///      time (no more than MAX_AGE_FORCED_REQUEST_UNTIL_WITHDRAW_MODE) to process the request

    ///      and create the deposit to the offchain account.

    ///

    /// @param tokenAddress The address of the token, use `0x0` for Ether.

    function withdrawProtocolFees(

        address tokenAddress

        )

        external

        virtual

        payable;



    /// @dev Gets the time the protocol fee for a token was last withdrawn.

    /// @param tokenAddress The address of the token, use `0x0` for Ether.

    /// @return The time the protocol fee was last withdrawn.

    function getProtocolFeeLastWithdrawnTime(

        address tokenAddress

        )

        external

        virtual

        view

        returns (uint);



    /// @dev Allows anyone to withdraw funds for a specified user using the balances stored

    ///      in the Merkle tree. The funds will be sent to the owner of the acount.

    ///

    ///      Can only be used in withdrawal mode (i.e. when the owner has stopped

    ///      committing blocks and is not able to commit any more blocks).

    ///

    ///      This will NOT modify the onchain merkle root! The merkle root stored

    ///      onchain will remain the same after the withdrawal. We store if the user

    ///      has withdrawn the balance in State.withdrawnInWithdrawMode.

    ///

    /// @param  merkleProof The Merkle inclusion proof

    function withdrawFromMerkleTree(

        ExchangeData.MerkleProof calldata merkleProof

        )

        external

        virtual;



    /// @dev Checks if the balance for the account was withdrawn with `withdrawFromMerkleTree`.

    /// @param  accountID The accountID of the balance to check.

    /// @param  token The token address

    /// @return True if it was already withdrawn, false otherwise

    function isWithdrawnInWithdrawalMode(

        uint32  accountID,

        address token

        )

        external

        virtual

        view

        returns (bool);



    /// @dev Allows withdrawing funds deposited to the contract in a deposit request when

    ///      it was never processed by the owner within the maximum time allowed.

    ///

    ///      Can be called by anyone. The deposited tokens will be sent back to

    ///      the owner of the account they were deposited in.

    ///

    /// @param  owner The address of the account the withdrawal was done for.

    /// @param  token The token address

    function withdrawFromDepositRequest(

        address owner,

        address token

        )

        external

        virtual;



    /// @dev Allows withdrawing funds after a withdrawal request (either onchain

    ///      or offchain) was submitted in a block by the operator.

    ///

    ///      Can be called by anyone. The withdrawn tokens will be sent to

    ///      the owner of the account they were withdrawn out.

    ///

    ///      Normally it is should not be needed for users to call this manually.

    ///      Funds from withdrawal requests will be sent to the account owner

    ///      immediately by the owner when the block is submitted.

    ///      The user will however need to call this manually if the transfer failed.

    ///

    ///      Tokens and owners must have the same size.

    ///

    /// @param  owners The addresses of the account the withdrawal was done for.

    /// @param  tokens The token addresses

    function withdrawFromApprovedWithdrawals(

        address[] calldata owners,

        address[] calldata tokens

        )

        external

        virtual;



    /// @dev Gets the amount that can be withdrawn immediately with `withdrawFromApprovedWithdrawals`.

    /// @param  owner The address of the account the withdrawal was done for.

    /// @param  token The token address

    /// @return The amount withdrawable

    function getAmountWithdrawable(

        address owner,

        address token

        )

        external

        virtual

        view

        returns (uint);



    /// @dev Notifies the exchange that the owner did not process a forced request.

    ///      If this is indeed the case, the exchange will enter withdrawal mode.

    ///

    ///      Can be called by anyone.

    ///

    /// @param  accountID The accountID the forced request was made for

    /// @param  token The token address of the the forced request

    function notifyForcedRequestTooOld(

        uint32  accountID,

        address token

        )

        external

        virtual;



    /// @dev Allows a withdrawal to be done to an adddresss that is different

    ///      than initialy specified in the withdrawal request. This can be used to

    ///      implement functionality like fast withdrawals.

    ///

    ///      This function can only be called by an agent.

    ///

    /// @param from The address of the account that does the withdrawal.

    /// @param to The address to which 'amount' tokens were going to be withdrawn.

    /// @param token The address of the token that is withdrawn ('0x0' for ETH).

    /// @param amount The amount of tokens that are going to be withdrawn.

    /// @param storageID The storageID of the withdrawal request.

    /// @param newRecipient The new recipient address of the withdrawal.

    function setWithdrawalRecipient(

        address from,

        address to,

        address token,

        uint96  amount,

        uint32  storageID,

        address newRecipient

        )

        external

        virtual;



    /// @dev Gets the withdrawal recipient.

    ///

    /// @param from The address of the account that does the withdrawal.

    /// @param to The address to which 'amount' tokens were going to be withdrawn.

    /// @param token The address of the token that is withdrawn ('0x0' for ETH).

    /// @param amount The amount of tokens that are going to be withdrawn.

    /// @param storageID The storageID of the withdrawal request.

    function getWithdrawalRecipient(

        address from,

        address to,

        address token,

        uint96  amount,

        uint32  storageID

        )

        external

        virtual

        view

        returns (address);



    /// @dev Allows an agent to transfer ERC-20 tokens for a user using the allowance

    ///      the user has set for the exchange. This way the user only needs to approve a single exchange contract

    ///      for all exchange/agent features, which allows for a more seamless user experience.

    ///

    ///      This function can only be called by an agent.

    ///

    /// @param from The address of the account that sends the tokens.

    /// @param to The address to which 'amount' tokens are transferred.

    /// @param token The address of the token to transfer (ETH is and cannot be suppported).

    /// @param amount The amount of tokens transferred.

    function onchainTransferFrom(

        address from,

        address to,

        address token,

        uint    amount

        )

        external

        virtual;



    /// @dev Allows an agent to approve a rollup tx.

    ///

    ///      This function can only be called by an agent.

    ///

    /// @param owner The owner of the account

    /// @param txHash The hash of the transaction

    function approveTransaction(

        address owner,

        bytes32 txHash

        )

        external

        virtual;



    /// @dev Allows an agent to approve multiple rollup txs.

    ///

    ///      This function can only be called by an agent.

    ///

    /// @param owners The account owners

    /// @param txHashes The hashes of the transactions

    function approveTransactions(

        address[] calldata owners,

        bytes32[] calldata txHashes

        )

        external

        virtual;



    /// @dev Checks if a rollup tx is approved using the tx's hash.

    ///

    /// @param owner The owner of the account that needs to authorize the tx

    /// @param txHash The hash of the transaction

    /// @return True if the tx is approved, else false

    function isTransactionApproved(

        address owner,

        bytes32 txHash

        )

        external

        virtual

        view

        returns (bool);



    // -- Admins --

    /// @dev Sets the max time deposits have to wait before becoming withdrawable.

    /// @param newValue The new value.

    /// @return  The old value.

    function setMaxAgeDepositUntilWithdrawable(

        uint32 newValue

        )

        external

        virtual

        returns (uint32);



    /// @dev Returns the max time deposits have to wait before becoming withdrawable.

    /// @return The value.

    function getMaxAgeDepositUntilWithdrawable()

        external

        virtual

        view

        returns (uint32);



    /// @dev Shuts down the exchange.

    ///      Once the exchange is shutdown all onchain requests are permanently disabled.

    ///      When all requirements are fulfilled the exchange owner can withdraw

    ///      the exchange stake with withdrawStake.

    ///

    ///      Note that the exchange can still enter the withdrawal mode after this function

    ///      has been invoked successfully. To prevent entering the withdrawal mode before the

    ///      the echange stake can be withdrawn, all withdrawal requests still need to be handled

    ///      for at least MIN_TIME_IN_SHUTDOWN seconds.

    ///

    ///      Can only be called by the exchange owner.

    ///

    /// @return success True if the exchange is shutdown, else False

    function shutdown()

        external

        virtual

        returns (bool success);



    /// @dev Gets the protocol fees for this exchange.

    /// @return syncedAt The timestamp the protocol fees were last updated

    /// @return takerFeeBips The protocol taker fee

    /// @return makerFeeBips The protocol maker fee

    /// @return previousTakerFeeBips The previous protocol taker fee

    /// @return previousMakerFeeBips The previous protocol maker fee

    function getProtocolFeeValues()

        external

        virtual

        view

        returns (

            uint32 syncedAt,

            uint8 takerFeeBips,

            uint8 makerFeeBips,

            uint8 previousTakerFeeBips,

            uint8 previousMakerFeeBips

        );



    /// @dev Gets the domain separator used in this exchange.

    function getDomainSeparator()

        external

        virtual

        view

        returns (bytes32);

}









// Copyright 2017 Loopring Technology Limited.







/// @title ERC20 safe transfer

/// @dev see https://github.com/sec-bit/badERC20Fix

/// @author Brecht Devos - <[email protected]>

library ERC20SafeTransfer

{

    function safeTransferAndVerify(

        address token,

        address to,

        uint    value

        )

        internal

    {

        safeTransferWithGasLimitAndVerify(

            token,

            to,

            value,

            gasleft()

        );

    }



    function safeTransfer(

        address token,

        address to,

        uint    value

        )

        internal

        returns (bool)

    {

        return safeTransferWithGasLimit(

            token,

            to,

            value,

            gasleft()

        );

    }



    function safeTransferWithGasLimitAndVerify(

        address token,

        address to,

        uint    value,

        uint    gasLimit

        )

        internal

    {

        require(

            safeTransferWithGasLimit(token, to, value, gasLimit),

            "TRANSFER_FAILURE"

        );

    }



    function safeTransferWithGasLimit(

        address token,

        address to,

        uint    value,

        uint    gasLimit

        )

        internal

        returns (bool)

    {

        // A transfer is successful when 'call' is successful and depending on the token:

        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)

        // - A single boolean is returned: this boolean needs to be true (non-zero)



        // bytes4(keccak256("transfer(address,uint256)")) = 0xa9059cbb

        bytes memory callData = abi.encodeWithSelector(

            bytes4(0xa9059cbb),

            to,

            value

        );

        (bool success, ) = token.call{gas: gasLimit}(callData);

        return checkReturnValue(success);

    }



    function safeTransferFromAndVerify(

        address token,

        address from,

        address to,

        uint    value

        )

        internal

    {

        safeTransferFromWithGasLimitAndVerify(

            token,

            from,

            to,

            value,

            gasleft()

        );

    }



    function safeTransferFrom(

        address token,

        address from,

        address to,

        uint    value

        )

        internal

        returns (bool)

    {

        return safeTransferFromWithGasLimit(

            token,

            from,

            to,

            value,

            gasleft()

        );

    }



    function safeTransferFromWithGasLimitAndVerify(

        address token,

        address from,

        address to,

        uint    value,

        uint    gasLimit

        )

        internal

    {

        bool result = safeTransferFromWithGasLimit(

            token,

            from,

            to,

            value,

            gasLimit

        );

        require(result, "TRANSFER_FAILURE");

    }



    function safeTransferFromWithGasLimit(

        address token,

        address from,

        address to,

        uint    value,

        uint    gasLimit

        )

        internal

        returns (bool)

    {

        // A transferFrom is successful when 'call' is successful and depending on the token:

        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)

        // - A single boolean is returned: this boolean needs to be true (non-zero)



        // bytes4(keccak256("transferFrom(address,address,uint256)")) = 0x23b872dd

        bytes memory callData = abi.encodeWithSelector(

            bytes4(0x23b872dd),

            from,

            to,

            value

        );

        (bool success, ) = token.call{gas: gasLimit}(callData);

        return checkReturnValue(success);

    }



    function checkReturnValue(

        bool success

        )

        internal

        pure

        returns (bool)

    {

        // A transfer/transferFrom is successful when 'call' is successful and depending on the token:

        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)

        // - A single boolean is returned: this boolean needs to be true (non-zero)

        if (success) {

            assembly {

                switch returndatasize()

                // Non-standard ERC20: nothing is returned so if 'call' was successful we assume the transfer succeeded

                case 0 {

                    success := 1

                }

                // Standard ERC20: a single boolean value is returned which needs to be true

                case 32 {

                    returndatacopy(0, 0, 32)

                    success := mload(0)

                }

                // None of the above: not successful

                default {

                    success := 0

                }

            }

        }

        return success;

    }

}





// Copyright 2017 Loopring Technology Limited.







/// @title ReentrancyGuard

/// @author Brecht Devos - <[email protected]>

/// @dev Exposes a modifier that guards a function against reentrancy

///      Changing the value of the same storage value multiple times in a transaction

///      is cheap (starting from Istanbul) so there is no need to minimize

///      the number of times the value is changed

contract ReentrancyGuard

{

    //The default value must be 0 in order to work behind a proxy.

    uint private _guardValue;



    // Use this modifier on a function to prevent reentrancy

    modifier nonReentrant()

    {

        // Check if the guard value has its original value

        require(_guardValue == 0, "REENTRANCY");



        // Set the value to something else

        _guardValue = 1;



        // Function body

        _;



        // Set the value back

        _guardValue = 0;

    }

}







/// @title Fast withdrawal agent implementation. With the help of liquidity providers (LPs),

///        exchange operators can convert any normal withdrawals into fast withdrawals.

///

///        Fast withdrawals are a way for the owner to provide instant withdrawals for

///        users with the help of a liquidity provider and conditional transfers.

///

///        A fast withdrawal requires the non-trustless cooperation of 2 parties:

///        - A liquidity provider which provides funds to users immediately onchain

///        - The operator which will make sure the user has sufficient funds offchain

///          so that the liquidity provider can be paid back.

///          The operator also needs to process those withdrawals so that the

///          liquidity provider receives its funds back.

///

///        We require the fast withdrawals to be executed by the liquidity provider (as msg.sender)

///        so that the liquidity provider can impose its own rules on how its funds are spent. This will

///        inevitably need to be done in close cooperation with the operator, or by the operator

///        itself using a smart contract where the liquidity provider enforces who, how

///        and even if their funds can be used to facilitate the fast withdrawals.

///

///        The liquidity provider can call `executeFastWithdrawals` to provide users

///        immediately with funds onchain. This allows the security of the funds to be handled

///        by any EOA or smart contract.

///

///        Users that want to make use of this functionality have to

///        authorize this contract as their agent.

///

/// @author Brecht Devos - <[email protected]>

/// @author Kongliang Zhong - <[email protected]>

/// @author Daniel Wang - <[email protected]>

contract FastWithdrawalAgent is ReentrancyGuard, IAgent

{

    using AddressUtil       for address;

    using AddressUtil       for address payable;

    using ERC20SafeTransfer for address;

    using MathUint          for uint;



    event Processed(

        address exchange,

        address from,

        address to,

        address token,

        uint96  amount,

        address provider,

        bool    success

    );



    struct Withdrawal

    {

        address exchange;

        address from;                   // The owner of the account

        address to;                     // The `to` address of the withdrawal

        address token;

        uint96  amount;

        uint32  storageID;

    }



    // This method needs to be called by any liquidity provider

    function executeFastWithdrawals(Withdrawal[] calldata withdrawals)

        public

        nonReentrant

        payable

    {

        // Do all fast withdrawals

        for (uint i = 0; i < withdrawals.length; i++) {

            executeInternal(withdrawals[i]);

        }

        // Return any ETH left into this contract

        // (can happen when more ETH is sent than needed for the fast withdrawals)

        msg.sender.sendETHAndVerify(address(this).balance, gasleft());

    }



    // -- Internal --



    function executeInternal(Withdrawal calldata withdrawal)

        internal

    {

        require(

            withdrawal.exchange != address(0) &&

            withdrawal.from != address(0) &&

            withdrawal.to != address(0) &&

            withdrawal.amount != 0,

            "INVALID_WITHDRAWAL"

        );



        // The liquidity provider always authorizes the fast withdrawal by being the direct caller

        address payable liquidityProvider = msg.sender;



        bool success;

        // Override the destination address of a withdrawal to the address of the liquidity provider

        try IExchangeV3(withdrawal.exchange).setWithdrawalRecipient(

            withdrawal.from,

            withdrawal.to,

            withdrawal.token,

            withdrawal.amount,

            withdrawal.storageID,

            liquidityProvider

        ) {

            // Transfer the tokens immediately to the requested address

            // using funds from the liquidity provider (`msg.sender`).

            transfer(

                liquidityProvider,

                withdrawal.to,

                withdrawal.token,

                withdrawal.amount

            );

            success = true;

        } catch {

            success = false;

        }



        emit Processed(

            withdrawal.exchange,

            withdrawal.from,

            withdrawal.to,

            withdrawal.token,

            withdrawal.amount,

            liquidityProvider,

            success

        );

    }



    function transfer(

        address from,

        address to,

        address token,

        uint    amount

        )

        internal

    {

        if (amount > 0) {

            if (token == address(0)) {

                to.sendETHAndVerify(amount, gasleft()); // ETH

            } else {

                token.safeTransferFromAndVerify(from, to, amount);  // ERC20 token

            }

        }

    }

}