/**

 *Submitted for verification at Etherscan.io on 2020-02-15

*/



pragma solidity >=0.4.21 <0.7.0;



pragma experimental ABIEncoderV2;



// <provableAPI>

/*

Copyright (c) 2015-2016 Oraclize SRL

Copyright (c) 2016-2019 Oraclize LTD

Copyright (c) 2019 Provable Things Limited

Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in

all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN

THE SOFTWARE.

*/

pragma solidity >= 0.5.0 < 0.6.0; // Incompatible compiler version - please select a compiler within the stated pragma range, or use a different version of the provableAPI!



// Dummy contract only used to emit to end-user they are using wrong solc

contract solcChecker {

/* INCOMPATIBLE SOLC: import the following instead: "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.sol" */ function f(bytes calldata x) external;

}



contract ProvableI {



    address public cbAddress;



    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function getPrice(string memory _datasource) public returns (uint _dsprice);

    function randomDS_getSessionPubKeyHash() external view returns (bytes32 _sessionKeyHash);

    function getPrice(string memory _datasource, uint _gasLimit) public returns (uint _dsprice);

    function queryN(uint _timestamp, string memory _datasource, bytes memory _argN) public payable returns (bytes32 _id);

    function query(uint _timestamp, string calldata _datasource, string calldata _arg) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2) public payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string calldata _datasource, string calldata _arg, uint _gasLimit) external payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string calldata _datasource, bytes calldata _argN, uint _gasLimit) external payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string calldata _datasource, string calldata _arg1, string calldata _arg2, uint _gasLimit) external payable returns (bytes32 _id);

}



contract OracleAddrResolverI {

    function getAddress() public returns (address _address);

}

/*

Begin solidity-cborutils

https://github.com/smartcontractkit/solidity-cborutils

MIT License

Copyright (c) 2018 SmartContract ChainLink, Ltd.

Permission is hereby granted, free of charge, to any person obtaining a copy

of this software and associated documentation files (the "Software"), to deal

in the Software without restriction, including without limitation the rights

to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

copies of the Software, and to permit persons to whom the Software is

furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all

copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

SOFTWARE.

*/

library Buffer {



    struct buffer {

        bytes buf;

        uint capacity;

    }



    function init(buffer memory _buf, uint _capacity) internal pure {

        uint capacity = _capacity;

        if (capacity % 32 != 0) {

            capacity += 32 - (capacity % 32);

        }

        _buf.capacity = capacity; // Allocate space for the buffer data

        assembly {

            let ptr := mload(0x40)

            mstore(_buf, ptr)

            mstore(ptr, 0)

            mstore(0x40, add(ptr, capacity))

        }

    }



    function resize(buffer memory _buf, uint _capacity) private pure {

        bytes memory oldbuf = _buf.buf;

        init(_buf, _capacity);

        append(_buf, oldbuf);

    }



    function max(uint _a, uint _b) private pure returns (uint _max) {

        if (_a > _b) {

            return _a;

        }

        return _b;

    }

    /**

      * @dev Appends a byte array to the end of the buffer. Resizes if doing so

      *      would exceed the capacity of the buffer.

      * @param _buf The buffer to append to.

      * @param _data The data to append.

      * @return The original buffer.

      *

      */

    function append(buffer memory _buf, bytes memory _data) internal pure returns (buffer memory _buffer) {

        if (_data.length + _buf.buf.length > _buf.capacity) {

            resize(_buf, max(_buf.capacity, _data.length) * 2);

        }

        uint dest;

        uint src;

        uint len = _data.length;

        assembly {

            let bufptr := mload(_buf) // Memory address of the buffer data

            let buflen := mload(bufptr) // Length of existing buffer data

            dest := add(add(bufptr, buflen), 32) // Start address = buffer address + buffer length + sizeof(buffer length)

            mstore(bufptr, add(buflen, mload(_data))) // Update buffer length

            src := add(_data, 32)

        }

        for(; len >= 32; len -= 32) { // Copy word-length chunks while possible

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }

        uint mask = 256 ** (32 - len) - 1; // Copy remaining bytes

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }

        return _buf;

    }

    /**

      *

      * @dev Appends a byte to the end of the buffer. Resizes if doing so would

      * exceed the capacity of the buffer.

      * @param _buf The buffer to append to.

      * @param _data The data to append.

      * @return The original buffer.

      *

      */

    function append(buffer memory _buf, uint8 _data) internal pure {

        if (_buf.buf.length + 1 > _buf.capacity) {

            resize(_buf, _buf.capacity * 2);

        }

        assembly {

            let bufptr := mload(_buf) // Memory address of the buffer data

            let buflen := mload(bufptr) // Length of existing buffer data

            let dest := add(add(bufptr, buflen), 32) // Address = buffer address + buffer length + sizeof(buffer length)

            mstore8(dest, _data)

            mstore(bufptr, add(buflen, 1)) // Update buffer length

        }

    }

    /**

      *

      * @dev Appends a byte to the end of the buffer. Resizes if doing so would

      * exceed the capacity of the buffer.

      * @param _buf The buffer to append to.

      * @param _data The data to append.

      * @return The original buffer.

      *

      */

    function appendInt(buffer memory _buf, uint _data, uint _len) internal pure returns (buffer memory _buffer) {

        if (_len + _buf.buf.length > _buf.capacity) {

            resize(_buf, max(_buf.capacity, _len) * 2);

        }

        uint mask = 256 ** _len - 1;

        assembly {

            let bufptr := mload(_buf) // Memory address of the buffer data

            let buflen := mload(bufptr) // Length of existing buffer data

            let dest := add(add(bufptr, buflen), _len) // Address = buffer address + buffer length + sizeof(buffer length) + len

            mstore(dest, or(and(mload(dest), not(mask)), _data))

            mstore(bufptr, add(buflen, _len)) // Update buffer length

        }

        return _buf;

    }

}



library CBOR {



    using Buffer for Buffer.buffer;



    uint8 private constant MAJOR_TYPE_INT = 0;

    uint8 private constant MAJOR_TYPE_MAP = 5;

    uint8 private constant MAJOR_TYPE_BYTES = 2;

    uint8 private constant MAJOR_TYPE_ARRAY = 4;

    uint8 private constant MAJOR_TYPE_STRING = 3;

    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;

    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;



    function encodeType(Buffer.buffer memory _buf, uint8 _major, uint _value) private pure {

        if (_value <= 23) {

            _buf.append(uint8((_major << 5) | _value));

        } else if (_value <= 0xFF) {

            _buf.append(uint8((_major << 5) | 24));

            _buf.appendInt(_value, 1);

        } else if (_value <= 0xFFFF) {

            _buf.append(uint8((_major << 5) | 25));

            _buf.appendInt(_value, 2);

        } else if (_value <= 0xFFFFFFFF) {

            _buf.append(uint8((_major << 5) | 26));

            _buf.appendInt(_value, 4);

        } else if (_value <= 0xFFFFFFFFFFFFFFFF) {

            _buf.append(uint8((_major << 5) | 27));

            _buf.appendInt(_value, 8);

        }

    }



    function encodeIndefiniteLengthType(Buffer.buffer memory _buf, uint8 _major) private pure {

        _buf.append(uint8((_major << 5) | 31));

    }



    function encodeUInt(Buffer.buffer memory _buf, uint _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_INT, _value);

    }



    function encodeInt(Buffer.buffer memory _buf, int _value) internal pure {

        if (_value >= 0) {

            encodeType(_buf, MAJOR_TYPE_INT, uint(_value));

        } else {

            encodeType(_buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - _value));

        }

    }



    function encodeBytes(Buffer.buffer memory _buf, bytes memory _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_BYTES, _value.length);

        _buf.append(_value);

    }



    function encodeString(Buffer.buffer memory _buf, string memory _value) internal pure {

        encodeType(_buf, MAJOR_TYPE_STRING, bytes(_value).length);

        _buf.append(bytes(_value));

    }



    function startArray(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_ARRAY);

    }



    function startMap(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_MAP);

    }



    function endSequence(Buffer.buffer memory _buf) internal pure {

        encodeIndefiniteLengthType(_buf, MAJOR_TYPE_CONTENT_FREE);

    }

}

/*

End solidity-cborutils

*/

contract usingProvable {



    using CBOR for Buffer.buffer;



    ProvableI provable;

    OracleAddrResolverI OAR;



    uint constant day = 60 * 60 * 24;

    uint constant week = 60 * 60 * 24 * 7;

    uint constant month = 60 * 60 * 24 * 30;



    byte constant proofType_NONE = 0x00;

    byte constant proofType_Ledger = 0x30;

    byte constant proofType_Native = 0xF0;

    byte constant proofStorage_IPFS = 0x01;

    byte constant proofType_Android = 0x40;

    byte constant proofType_TLSNotary = 0x10;



    string provable_network_name;

    uint8 constant networkID_auto = 0;

    uint8 constant networkID_morden = 2;

    uint8 constant networkID_mainnet = 1;

    uint8 constant networkID_testnet = 2;

    uint8 constant networkID_consensys = 161;



    mapping(bytes32 => bytes32) provable_randomDS_args;

    mapping(bytes32 => bool) provable_randomDS_sessionKeysHashVerified;



    modifier provableAPI {

        if ((address(OAR) == address(0)) || (getCodeSize(address(OAR)) == 0)) {

            provable_setNetwork(networkID_auto);

        }

        if (address(provable) != OAR.getAddress()) {

            provable = ProvableI(OAR.getAddress());

        }

        _;

    }



    modifier provable_randomDS_proofVerify(bytes32 _queryId, string memory _result, bytes memory _proof) {

        // RandomDS Proof Step 1: The prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (uint8(_proof[2]) == uint8(1)));

        bool proofVerified = provable_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), provable_getNetworkName());

        require(proofVerified);

        _;

    }



    function provable_setNetwork(uint8 _networkID) internal returns (bool _networkSet) {

      _networkID; // NOTE: Silence the warning and remain backwards compatible

      return provable_setNetwork();

    }



    function provable_setNetworkName(string memory _network_name) internal {

        provable_network_name = _network_name;

    }



    function provable_getNetworkName() internal view returns (string memory _networkName) {

        return provable_network_name;

    }



    function provable_setNetwork() internal returns (bool _networkSet) {

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed) > 0) { //mainnet

            OAR = OracleAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);

            provable_setNetworkName("eth_mainnet");

            return true;

        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1) > 0) { //ropsten testnet

            OAR = OracleAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);

            provable_setNetworkName("eth_ropsten3");

            return true;

        }

        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e) > 0) { //kovan testnet

            OAR = OracleAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);

            provable_setNetworkName("eth_kovan");

            return true;

        }

        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48) > 0) { //rinkeby testnet

            OAR = OracleAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);

            provable_setNetworkName("eth_rinkeby");

            return true;

        }

        if (getCodeSize(0xa2998EFD205FB9D4B4963aFb70778D6354ad3A41) > 0) { //goerli testnet

            OAR = OracleAddrResolverI(0xa2998EFD205FB9D4B4963aFb70778D6354ad3A41);

            provable_setNetworkName("eth_goerli");

            return true;

        }

        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475) > 0) { //ethereum-bridge

            OAR = OracleAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

            return true;

        }

        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF) > 0) { //ether.camp ide

            OAR = OracleAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);

            return true;

        }

        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA) > 0) { //browser-solidity

            OAR = OracleAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);

            return true;

        }

        return false;

    }

    /**

     * @dev The following `__callback` functions are just placeholders ideally

     *      meant to be defined in child contract when proofs are used.

     *      The function bodies simply silence compiler warnings.

     */

    function __callback(bytes32 _myid, string memory _result) public {

        __callback(_myid, _result, new bytes(0));

    }



    function __callback(bytes32 _myid, string memory _result, bytes memory _proof) public {

      _myid; _result; _proof;

      provable_randomDS_args[bytes32(0)] = bytes32(0);

    }



    function provable_getPrice(string memory _datasource) provableAPI internal returns (uint _queryPrice) {

        return provable.getPrice(_datasource);

    }



    function provable_getPrice(string memory _datasource, uint _gasLimit) provableAPI internal returns (uint _queryPrice) {

        return provable.getPrice(_datasource, _gasLimit);

    }



    function provable_query(string memory _datasource, string memory _arg) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return provable.query.value(price)(0, _datasource, _arg);

    }



    function provable_query(uint _timestamp, string memory _datasource, string memory _arg) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return provable.query.value(price)(_timestamp, _datasource, _arg);

    }



    function provable_query(uint _timestamp, string memory _datasource, string memory _arg, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource,_gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return provable.query_withGasLimit.value(price)(_timestamp, _datasource, _arg, _gasLimit);

    }



    function provable_query(string memory _datasource, string memory _arg, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

           return 0; // Unexpectedly high price

        }

        return provable.query_withGasLimit.value(price)(0, _datasource, _arg, _gasLimit);

    }



    function provable_query(string memory _datasource, string memory _arg1, string memory _arg2) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return provable.query2.value(price)(0, _datasource, _arg1, _arg2);

    }



    function provable_query(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return provable.query2.value(price)(_timestamp, _datasource, _arg1, _arg2);

    }



    function provable_query(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return provable.query2_withGasLimit.value(price)(_timestamp, _datasource, _arg1, _arg2, _gasLimit);

    }



    function provable_query(string memory _datasource, string memory _arg1, string memory _arg2, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return provable.query2_withGasLimit.value(price)(0, _datasource, _arg1, _arg2, _gasLimit);

    }



    function provable_query(string memory _datasource, string[] memory _argN) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return provable.queryN.value(price)(0, _datasource, args);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[] memory _argN) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return provable.queryN.value(price)(_timestamp, _datasource, args);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[] memory _argN, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return provable.queryN_withGasLimit.value(price)(_timestamp, _datasource, args, _gasLimit);

    }



    function provable_query(string memory _datasource, string[] memory _argN, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return provable.queryN_withGasLimit.value(price)(0, _datasource, args, _gasLimit);

    }



    function provable_query(string memory _datasource, string[1] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[1] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[1] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[1] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[2] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[2] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[2] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[2] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[3] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[3] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[3] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[3] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[4] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[4] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[4] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[4] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[5] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[5] memory _args) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, string[5] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, string[5] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[] memory _argN) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return provable.queryN.value(price)(0, _datasource, args);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[] memory _argN) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return provable.queryN.value(price)(_timestamp, _datasource, args);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[] memory _argN, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return provable.queryN_withGasLimit.value(price)(_timestamp, _datasource, args, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[] memory _argN, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        uint price = provable.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return provable.queryN_withGasLimit.value(price)(0, _datasource, args, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[1] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[1] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[1] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[1] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[2] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[2] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[2] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[2] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[3] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[3] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[3] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[3] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[4] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[4] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[4] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[4] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[5] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return provable_query(_datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[5] memory _args) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return provable_query(_timestamp, _datasource, dynargs);

    }



    function provable_query(uint _timestamp, string memory _datasource, bytes[5] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return provable_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function provable_query(string memory _datasource, bytes[5] memory _args, uint _gasLimit) provableAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return provable_query(_datasource, dynargs, _gasLimit);

    }



    function provable_setProof(byte _proofP) provableAPI internal {

        return provable.setProofType(_proofP);

    }





    function provable_cbAddress() provableAPI internal returns (address _callbackAddress) {

        return provable.cbAddress();

    }



    function getCodeSize(address _addr) view internal returns (uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function provable_setCustomGasPrice(uint _gasPrice) provableAPI internal {

        return provable.setCustomGasPrice(_gasPrice);

    }



    function provable_randomDS_getSessionPubKeyHash() provableAPI internal returns (bytes32 _sessionKeyHash) {

        return provable.randomDS_getSessionPubKeyHash();

    }



    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {

        bytes memory tmp = bytes(_a);

        uint160 iaddr = 0;

        uint160 b1;

        uint160 b2;

        for (uint i = 2; i < 2 + 2 * 20; i += 2) {

            iaddr *= 256;

            b1 = uint160(uint8(tmp[i]));

            b2 = uint160(uint8(tmp[i + 1]));

            if ((b1 >= 97) && (b1 <= 102)) {

                b1 -= 87;

            } else if ((b1 >= 65) && (b1 <= 70)) {

                b1 -= 55;

            } else if ((b1 >= 48) && (b1 <= 57)) {

                b1 -= 48;

            }

            if ((b2 >= 97) && (b2 <= 102)) {

                b2 -= 87;

            } else if ((b2 >= 65) && (b2 <= 70)) {

                b2 -= 55;

            } else if ((b2 >= 48) && (b2 <= 57)) {

                b2 -= 48;

            }

            iaddr += (b1 * 16 + b2);

        }

        return address(iaddr);

    }



    function strCompare(string memory _a, string memory _b) internal pure returns (int _returnCode) {

        bytes memory a = bytes(_a);

        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) {

            minLength = b.length;

        }

        for (uint i = 0; i < minLength; i ++) {

            if (a[i] < b[i]) {

                return -1;

            } else if (a[i] > b[i]) {

                return 1;

            }

        }

        if (a.length < b.length) {

            return -1;

        } else if (a.length > b.length) {

            return 1;

        } else {

            return 0;

        }

    }



    function indexOf(string memory _haystack, string memory _needle) internal pure returns (int _returnCode) {

        bytes memory h = bytes(_haystack);

        bytes memory n = bytes(_needle);

        if (h.length < 1 || n.length < 1 || (n.length > h.length)) {

            return -1;

        } else if (h.length > (2 ** 128 - 1)) {

            return -1;

        } else {

            uint subindex = 0;

            for (uint i = 0; i < h.length; i++) {

                if (h[i] == n[0]) {

                    subindex = 1;

                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) {

                        subindex++;

                    }

                    if (subindex == n.length) {

                        return int(i);

                    }

                }

            }

            return -1;

        }

    }



    function strConcat(string memory _a, string memory _b) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, "", "", "");

    }



    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) internal pure returns (string memory _concatenatedString) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) internal pure returns (string memory _concatenatedString) {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory _bc = bytes(_c);

        bytes memory _bd = bytes(_d);

        bytes memory _be = bytes(_e);

        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

        bytes memory babcde = bytes(abcde);

        uint k = 0;

        uint i = 0;

        for (i = 0; i < _ba.length; i++) {

            babcde[k++] = _ba[i];

        }

        for (i = 0; i < _bb.length; i++) {

            babcde[k++] = _bb[i];

        }

        for (i = 0; i < _bc.length; i++) {

            babcde[k++] = _bc[i];

        }

        for (i = 0; i < _bd.length; i++) {

            babcde[k++] = _bd[i];

        }

        for (i = 0; i < _be.length; i++) {

            babcde[k++] = _be[i];

        }

        return string(babcde);

    }



    function safeParseInt(string memory _a) internal pure returns (uint _parsedInt) {

        return safeParseInt(_a, 0);

    }



    function safeParseInt(string memory _a, uint _b) internal pure returns (uint _parsedInt) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i = 0; i < bresult.length; i++) {

            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {

                if (decimals) {

                   if (_b == 0) break;

                    else _b--;

                }

                mint *= 10;

                mint += uint(uint8(bresult[i])) - 48;

            } else if (uint(uint8(bresult[i])) == 46) {

                require(!decimals, 'More than one decimal encountered in string!');

                decimals = true;

            } else {

                revert("Non-numeral character encountered in string!");

            }

        }

        if (_b > 0) {

            mint *= 10 ** _b;

        }

        return mint;

    }



    function parseInt(string memory _a) internal pure returns (uint _parsedInt) {

        return parseInt(_a, 0);

    }



    function parseInt(string memory _a, uint _b) internal pure returns (uint _parsedInt) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i = 0; i < bresult.length; i++) {

            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {

                if (decimals) {

                   if (_b == 0) {

                       break;

                   } else {

                       _b--;

                   }

                }

                mint *= 10;

                mint += uint(uint8(bresult[i])) - 48;

            } else if (uint(uint8(bresult[i])) == 46) {

                decimals = true;

            }

        }

        if (_b > 0) {

            mint *= 10 ** _b;

        }

        return mint;

    }



    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {

            return "0";

        }

        uint j = _i;

        uint len;

        while (j != 0) {

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (_i != 0) {

            bstr[k--] = byte(uint8(48 + _i % 10));

            _i /= 10;

        }

        return string(bstr);

    }



    function stra2cbor(string[] memory _arr) internal pure returns (bytes memory _cborEncoding) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < _arr.length; i++) {

            buf.encodeString(_arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    function ba2cbor(bytes[] memory _arr) internal pure returns (bytes memory _cborEncoding) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < _arr.length; i++) {

            buf.encodeBytes(_arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    function provable_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32 _queryId) {

        require((_nbytes > 0) && (_nbytes <= 32));

        _delay *= 10; // Convert from seconds to ledger timer ticks

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(uint8(_nbytes));

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = provable_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            /*

             The following variables can be relaxed.

             Check the relaxed random contract at https://github.com/oraclize/ethereum-examples

             for an idea on how to override and replace commit hash variables.

            */

            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))

            mstore(sessionKeyHash, 0x20)

            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)

        }

        bytes memory delay = new bytes(32);

        assembly {

            mstore(add(delay, 0x20), _delay)

        }

        bytes memory delay_bytes8 = new bytes(8);

        copyBytes(delay, 24, 8, delay_bytes8, 0);

        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];

        bytes32 queryId = provable_query("random", args, _customGasLimit);

        bytes memory delay_bytes8_left = new bytes(8);

        assembly {

            let x := mload(add(delay_bytes8, 0x20))

            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))

            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))

        }

        provable_randomDS_setCommitment(queryId, keccak256(abi.encodePacked(delay_bytes8_left, args[1], sha256(args[0]), args[2])));

        return queryId;

    }



    function provable_randomDS_setCommitment(bytes32 _queryId, bytes32 _commitment) internal {

        provable_randomDS_args[_queryId] = _commitment;

    }



    function verifySig(bytes32 _tosignh, bytes memory _dersig, bytes memory _pubkey) internal returns (bool _sigVerified) {

        bool sigok;

        address signer;

        bytes32 sigr;

        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);

        uint offset = 4 + (uint(uint8(_dersig[3])) - 0x20);

        sigr_ = copyBytes(_dersig, offset, 32, sigr_, 0);

        bytes memory sigs_ = new bytes(32);

        offset += 32 + 2;

        sigs_ = copyBytes(_dersig, offset + (uint(uint8(_dersig[offset - 1])) - 0x20), 32, sigs_, 0);

        assembly {

            sigr := mload(add(sigr_, 32))

            sigs := mload(add(sigs_, 32))

        }

        (sigok, signer) = safer_ecrecover(_tosignh, 27, sigr, sigs);

        if (address(uint160(uint256(keccak256(_pubkey)))) == signer) {

            return true;

        } else {

            (sigok, signer) = safer_ecrecover(_tosignh, 28, sigr, sigs);

            return (address(uint160(uint256(keccak256(_pubkey)))) == signer);

        }

    }



    function provable_randomDS_proofVerify__sessionKeyValidity(bytes memory _proof, uint _sig2offset) internal returns (bool _proofVerified) {

        bool sigok;

        // Random DS Proof Step 6: Verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)

        bytes memory sig2 = new bytes(uint(uint8(_proof[_sig2offset + 1])) + 2);

        copyBytes(_proof, _sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);

        copyBytes(_proof, 3 + 1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1 + 65 + 32);

        tosign2[0] = byte(uint8(1)); //role

        copyBytes(_proof, _sig2offset - 65, 65, tosign2, 1);

        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";

        copyBytes(CODEHASH, 0, 32, tosign2, 1 + 65);

        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (!sigok) {

            return false;

        }

        // Random DS Proof Step 7: Verify the APPKEY1 provenance (must be signed by Ledger)

        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1 + 65);

        tosign3[0] = 0xFE;

        copyBytes(_proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(uint8(_proof[3 + 65 + 1])) + 2);

        copyBytes(_proof, 3 + 65, sig3.length, sig3, 0);

        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);

        return sigok;

    }



    function provable_randomDS_proofVerify__returnCode(bytes32 _queryId, string memory _result, bytes memory _proof) internal returns (uint8 _returnCode) {

        // Random DS Proof Step 1: The prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L") || (_proof[1] != "P") || (uint8(_proof[2]) != uint8(1))) {

            return 1;

        }

        bool proofVerified = provable_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), provable_getNetworkName());

        if (!proofVerified) {

            return 2;

        }

        return 0;

    }



    function matchBytes32Prefix(bytes32 _content, bytes memory _prefix, uint _nRandomBytes) internal pure returns (bool _matchesPrefix) {

        bool match_ = true;

        require(_prefix.length == _nRandomBytes);

        for (uint256 i = 0; i< _nRandomBytes; i++) {

            if (_content[i] != _prefix[i]) {

                match_ = false;

            }

        }

        return match_;

    }



    function provable_randomDS_proofVerify__main(bytes memory _proof, bytes32 _queryId, bytes memory _result, string memory _contextName) internal returns (bool _proofVerified) {

        // Random DS Proof Step 2: The unique keyhash has to match with the sha256 of (context name + _queryId)

        uint ledgerProofLength = 3 + 65 + (uint(uint8(_proof[3 + 65 + 1])) + 2) + 32;

        bytes memory keyhash = new bytes(32);

        copyBytes(_proof, ledgerProofLength, 32, keyhash, 0);

        if (!(keccak256(keyhash) == keccak256(abi.encodePacked(sha256(abi.encodePacked(_contextName, _queryId)))))) {

            return false;

        }

        bytes memory sig1 = new bytes(uint(uint8(_proof[ledgerProofLength + (32 + 8 + 1 + 32) + 1])) + 2);

        copyBytes(_proof, ledgerProofLength + (32 + 8 + 1 + 32), sig1.length, sig1, 0);

        // Random DS Proof Step 3: We assume sig1 is valid (it will be verified during step 5) and we verify if '_result' is the _prefix of sha256(sig1)

        if (!matchBytes32Prefix(sha256(sig1), _result, uint(uint8(_proof[ledgerProofLength + 32 + 8])))) {

            return false;

        }

        // Random DS Proof Step 4: Commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8 + 1 + 32);

        copyBytes(_proof, ledgerProofLength + 32, 8 + 1 + 32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength + 32 + (8 + 1 + 32) + sig1.length + 65;

        copyBytes(_proof, sig2offset - 64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (provable_randomDS_args[_queryId] == keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))) { //unonce, nbytes and sessionKeyHash match

            delete provable_randomDS_args[_queryId];

        } else return false;

        // Random DS Proof Step 5: Validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32 + 8 + 1 + 32);

        copyBytes(_proof, ledgerProofLength, 32 + 8 + 1 + 32, tosign1, 0);

        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) {

            return false;

        }

        // Verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (!provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash]) {

            provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = provable_randomDS_proofVerify__sessionKeyValidity(_proof, sig2offset);

        }

        return provable_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }

    /*

     The following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    */

    function copyBytes(bytes memory _from, uint _fromOffset, uint _length, bytes memory _to, uint _toOffset) internal pure returns (bytes memory _copiedBytes) {

        uint minLength = _length + _toOffset;

        require(_to.length >= minLength); // Buffer too small. Should be a better way?

        uint i = 32 + _fromOffset; // NOTE: the offset 32 is added to skip the `size` field of both bytes variables

        uint j = 32 + _toOffset;

        while (i < (32 + _fromOffset + _length)) {

            assembly {

                let tmp := mload(add(_from, i))

                mstore(add(_to, j), tmp)

            }

            i += 32;

            j += 32;

        }

        return _to;

    }

    /*

     The following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

     Duplicate Solidity's ecrecover, but catching the CALL return value

    */

    function safer_ecrecover(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) internal returns (bool _success, address _recoveredAddress) {

        /*

         We do our own memory management here. Solidity uses memory offset

         0x40 to store the current end of memory. We write past it (as

         writes are memory extensions), but don't update the offset so

         Solidity will reuse it. The memory used here is only needed for

         this context.

         FIXME: inline assembly can't access return values

        */

        bool ret;

        address addr;

        assembly {

            let size := mload(0x40)

            mstore(size, _hash)

            mstore(add(size, 32), _v)

            mstore(add(size, 64), _r)

            mstore(add(size, 96), _s)

            ret := call(3000, 1, 0, size, 128, size, 32) // NOTE: we can reuse the request memory because we deal with the return code.

            addr := mload(size)

        }

        return (ret, addr);

    }

    /*

     The following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    */

    function ecrecovery(bytes32 _hash, bytes memory _sig) internal returns (bool _success, address _recoveredAddress) {

        bytes32 r;

        bytes32 s;

        uint8 v;

        if (_sig.length != 65) {

            return (false, address(0));

        }

        /*

         The signature format is a compact form of:

           {bytes32 r}{bytes32 s}{uint8 v}

         Compact means, uint8 is not padded to 32 bytes.

        */

        assembly {

            r := mload(add(_sig, 32))

            s := mload(add(_sig, 64))

            /*

             Here we are loading the last 32 bytes. We exploit the fact that

             'mload' will pad with zeroes if we overread.

             There is no 'mload8' to do this, but that would be nicer.

            */

            v := byte(0, mload(add(_sig, 96)))

            /*

              Alternative solution:

              'byte' is not working due to the Solidity parser, so lets

              use the second best option, 'and'

              v := and(mload(add(_sig, 65)), 255)

            */

        }

        /*

         albeit non-transactional signatures are not specified by the YP, one would expect it

         to match the YP range of [27, 28]

         geth uses [0, 1] and some clients have followed. This might change, see:

         https://github.com/ethereum/go-ethereum/issues/2053

        */

        if (v < 27) {

            v += 27;

        }

        if (v != 27 && v != 28) {

            return (false, address(0));

        }

        return safer_ecrecover(_hash, v, r, s);

    }



    function safeMemoryCleaner() internal pure {

        assembly {

            let fmem := mload(0x40)

            codecopy(fmem, codesize, sub(msize, fmem))

        }

    }

}

// </provableAPI>



/**

 * @dev Wrappers over Solidity's arithmetic operations with added overflow

 * checks.

 *

 * Arithmetic operations in Solidity wrap on overflow. This can easily result

 * in bugs, because programmers usually assume that an overflow raises an

 * error, which is the standard behavior in high level programming languages.

 * `SafeMath` restores this intuition by reverting the transaction when an

 * operation overflows.

 *

 * Using this library instead of the unchecked operations eliminates an entire

 * class of bugs, so it's recommended to use it always.

 */

library SafeMath {

    /**

     * @dev Returns the addition of two unsigned integers, reverting on

     * overflow.

     *

     * Counterpart to Solidity's `+` operator.

     *

     * Requirements:

     * - Addition cannot overflow.

     */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        require(c >= a, "SafeMath: addition overflow");



        return c;

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting on

     * overflow (when the result is negative).

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     * - Subtraction cannot overflow.

     */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");

    }



    /**

     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on

     * overflow (when the result is negative).

     *

     * Counterpart to Solidity's `-` operator.

     *

     * Requirements:

     * - Subtraction cannot overflow.

     *

     * _Available since v2.4.0._

     */

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);

        uint256 c = a - b;



        return c;

    }



    /**

     * @dev Returns the multiplication of two unsigned integers, reverting on

     * overflow.

     *

     * Counterpart to Solidity's `*` operator.

     *

     * Requirements:

     * - Multiplication cannot overflow.

     */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

        // benefit is lost if 'b' is also tested.

        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522

        if (a == 0) {

            return 0;

        }



        uint256 c = a * b;

        require(c / a == b, "SafeMath: multiplication overflow");



        return c;

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator. Note: this function uses a

     * `revert` opcode (which leaves remaining gas untouched) while Solidity

     * uses an invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");

    }



    /**

     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on

     * division by zero. The result is rounded towards zero.

     *

     * Counterpart to Solidity's `/` operator. Note: this function uses a

     * `revert` opcode (which leaves remaining gas untouched) while Solidity

     * uses an invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     *

     * _Available since v2.4.0._

     */

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        // Solidity only automatically asserts when dividing by 0

        require(b > 0, errorMessage);

        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold



        return c;

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts when dividing by zero.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");

    }



    /**

     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),

     * Reverts with custom message when dividing by zero.

     *

     * Counterpart to Solidity's `%` operator. This function uses a `revert`

     * opcode (which leaves remaining gas untouched) while Solidity uses an

     * invalid opcode to revert (consuming all remaining gas).

     *

     * Requirements:

     * - The divisor cannot be zero.

     *

     * _Available since v2.4.0._

     */

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);

        return a % b;

    }

}



contract Context {

    // Empty internal constructor, to prevent people from mistakenly deploying

    // an instance of this contract, which should be used via inheritance.

    constructor () internal { }

    // solhint-disable-previous-line no-empty-blocks



    function _msgSender() internal view returns (address payable) {

        return msg.sender;

    }



    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691

        return msg.data;

    }

}



contract Ownable is Context {

    address private _owner;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



    /**

     * @dev Initializes the contract setting the deployer as the initial owner.

     */

    constructor () internal {

        _owner = _msgSender();

        emit OwnershipTransferred(address(0), _owner);

    }



    /**

     * @dev Returns the address of the current owner.

     */

    function owner() public view returns (address) {

        return _owner;

    }



    /**

     * @dev Throws if called by any account other than the owner.

     */

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");

        _;

    }



    /**

     * @dev Returns true if the caller is the current owner.

     */

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;

    }



    /**

     * @dev Leaves the contract without owner. It will not be possible to call

     * `onlyOwner` functions anymore. Can only be called by the current owner.

     *

     * NOTE: Renouncing ownership will leave the contract without an owner,

     * thereby removing any functionality that is only available to the owner.

     */

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));

        _owner = address(0);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     * Can only be called by the current owner.

     */

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);

    }



    /**

     * @dev Transfers ownership of the contract to a new account (`newOwner`).

     */

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);

        _owner = newOwner;

    }

}





 /**

 * @dev Interface to interact with HEX ERC20 tokens

 */

contract ERC20{

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

}



contract HEX2{

    function distribute(uint256 _amount) public returns (uint256);

}



 /**

 * @dev HexLotto game contract

 */

contract HexLotto is Ownable, usingProvable{



    using SafeMath for uint256;

     

    struct Entry {

        address buyer;

        uint256 tickets;

        uint256 hexAmount;

    }



    struct PlayerStats {

        uint256 totalAmount;

        uint256 totalTickets;

        uint256 amountWon;

    }



    mapping(bytes32 => uint8) validQueryIds;

    mapping(address => PlayerStats) public playerStats;



    uint256 public ticketPrice;

    uint256 public minimumPotAmount;

    uint256 public minimumParticipants;

    uint256 nonce;



    address token;

    address hex2;

    address devWallet;

 

    address[] public players;



    uint256 public hourlyPot;

    uint256 public dailyPot;

    uint256 public weeklyPot;

    uint256 public monthlyPot;

    uint256 public yearlyPot;

    uint256 public threeYearlyPot;



    uint256 public hourlyTickets;

    uint256 public dailyTickets;

    uint256 public weeklyTickets;

    uint256 public monthlyTickets;

    uint256 public yearlyTickets;

    uint256 public threeYearlyTickets;



    uint256 public hex2amount;

  

    uint256 public lastHourly = now;

    uint256 public lastDaily = now;

    uint256 public lastWeekly = now;

    uint256 public lastMonthly = now;

    uint256 public lastYearly = now;

    uint256 public lastThreeYearly = now;



    uint256 hour = 3600;

    uint256 day = 86400;

    uint256 week = 604800;

    uint256 month = 2629743;

    uint256 threeHundredDays = day * 300;

    uint256 threeYears = 31556926 * 3;



    uint256 hourlyGas;

    uint256 dailyGas;

    uint256 weeklyGas;

    uint256 monthlyGas;

    uint256 yearlyGas;

    uint256 threeYearlyGas;

  

    uint256 QUERY_EXECUTION_DELAY = 0;

    uint constant MAX_INT_FROM_BYTE = 256;

    uint constant NUM_RANDOM_BYTES_REQUESTED = 7;



    Entry[] public hourlyParticipants;

    Entry[] public dailyParticipants;

    Entry[] public weeklyParticipants;

    Entry[] public monthlyParticipants;

    Entry[] public yearlyParticipants;

    Entry[] public threeYearlyParticipants;



    event LogNewProvableQuery(

        string description

    );



    event generatedRandomNumber(

        uint256 randomNumber

    );



    event Enter(

        address indexed from, 

        uint amount, 

        uint time

    );



    constructor() public {

        //HexToken address

        token = address(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39); 

        hex2 = address(0xD495cC8C7c29c7fA3E027a5759561Ab68C363609); 

        devWallet = address(0x35e9034f47cc00b8A9b555fC1FDB9598b2c245fD);



        nonce = 1;

        minimumParticipants = 3;

        ticketPrice = 500000000000; //default ticket price 5000 HEX

        minimumPotAmount = 2550000000000; //default min pot amount 25500 HEX

        

        hourlyGas = 400000;

        dailyGas = 400000;

        weeklyGas = 400000;

        monthlyGas = 400000;

        yearlyGas = 800000;

        threeYearlyGas = 800000;



        //Set proof type for provable oracle

        provable_setProof(proofType_Ledger);

    }



    /**

     * @dev Allows contract owner to change gas amount needed for provable Oracle callback

    */

    function setGasAmounts(

        uint256 newHour, 

        uint256 newDay, 

        uint256 newWeek, 

        uint256 newMonth, 

        uint256 newYear, 

        uint256 newThreeYears

    ) public onlyOwner{

        require(

            newHour > 0 && newDay > 0 && newWeek > 0 && newMonth > 0 && newYear > 0 && newThreeYears > 0,

            "Gas values must be positive"

        );



        hourlyGas = newHour;

        dailyGas = newDay;

        weeklyGas = newWeek;

        monthlyGas = newMonth;

        yearlyGas = newYear;

        threeYearlyGas = newThreeYears;

    }

    

    /**

     * @dev Sets ticket price for a single lotto ticket

    */

    function setTicketPrice(uint256 amount) public onlyOwner{

        require(amount > 0, "amount must be greater than 0");

        ticketPrice = amount;

    }



    /**

     * @dev Sets the minimum pot for all tiers before game can finish

    */

    function setMinimumPot(uint256 amount) public onlyOwner{

        require(amount > 0, "amount must be greater than 0");

        minimumPotAmount = amount;

    }



    /**

     * @dev Array getter functions

    */

    function getHourlyParticipants() public view returns(Entry[] memory) {

        return hourlyParticipants;

    }



    function getDailyParticipants() public view returns(Entry[] memory) {

        return dailyParticipants;

    }



    function getWeeklyParticipants() public view returns(Entry[] memory) {

        return weeklyParticipants;

    }



    function getMonthlyParticipants() public view returns(Entry[] memory) {

        return monthlyParticipants;

    }



    function getYearlyParticipants() public view returns(Entry[] memory) {

        return yearlyParticipants;

    }



    function getThreeYearlyParticipants() public view returns(Entry[] memory) {

        return threeYearlyParticipants;

    }



    function getPlayers() public view returns(address[] memory) {

        return players;

    }



    /**

     * @dev Distributes HEX quantities into the relevant tiers, treasury wallets and approves for HEX2

    */

    function distribute(uint256 quantity) private returns(uint256[9] memory) {

        uint256[9] memory quantities;

        

        quantities[0] = quantity.mul(34).div(100); //Hourly

        quantities[1] = quantity.mul(23).div(100); //Daily

        quantities[2] = quantity.mul(18).div(100); //Weekly

        quantities[3] = quantity.mul(10).div(100); //Monthly

        quantities[4] = quantity.mul(4).div(100); //300 days

        quantities[5] = quantity.mul(1).div(100); //3 yearly

        quantities[6] = quantity.mul(6).div(100); //Treasury 

        quantities[7] = quantity.mul(1).div(100); //Hex2

        quantities[8] = quantity.mul(3).div(100); //Dev wallet

        

        //send 6% to treasury 

        require(ERC20(token).transfer(owner(), quantities[6]));



        //approve 1% for hex2 distribution

        //need to call hex distribute function after tokens are approved

        ERC20(token).approve(hex2, quantities[7]);

        hex2amount += quantities[7];



        //send 3% to dev

        require(ERC20(token).transfer(devWallet, quantities[8]));



        hourlyPot += quantities[0];

        dailyPot += quantities[1];

        weeklyPot += quantities[2];

        monthlyPot += quantities[3];

        yearlyPot += quantities[4];

        threeYearlyPot += quantities[5];



        return quantities;

    }



    /**

     * @dev Buys 'tickets' for lottery and splits tokens into tier entries

     * User must call approve with this contract address before entering

    */

    function entry (uint256 tickets) public{



        uint256 quantity = ticketPrice.mul(tickets);



        //get the user's balance

        uint256 userBalance = ERC20(token).balanceOf(msg.sender);



        //check user's balance

        require(userBalance >= quantity, "Not enough HEX tokens in balance.");



        //transfer pre approved amount to contract       

        require(ERC20(token).transferFrom(msg.sender, address(this), quantity), "Transfer failed.");        

        

        // 34% Hourly, 23% Daily, 18% Weekly, 10% Monthly, 4% 300 Days, and 1% 3 Years

        uint256[9] memory quantities = distribute(quantity);        



        saveEntries(tickets, quantities);

     

        playerStats[msg.sender].totalAmount += quantity;

        playerStats[msg.sender].totalTickets += tickets;



        emit Enter(msg.sender, quantity, now);

     }



    /**

    * @dev Creates ticket entries into arrays for all tiers

    */

    function saveEntries(uint256 tickets, uint256[9] memory quantities ) private {

        Entry memory hourlyEntry = Entry(msg.sender, tickets, quantities[0]);

        Entry memory dailyEntry = Entry(msg.sender, tickets, quantities[1]);

        Entry memory weeklyEntry = Entry(msg.sender, tickets, quantities[2]);

        Entry memory monthlyEntry = Entry(msg.sender, tickets, quantities[3]);

        Entry memory yearlyEntry = Entry(msg.sender, tickets, quantities[4]);

        Entry memory threeYearlyEntry = Entry(msg.sender, tickets, quantities[5]);



        hourlyParticipants.push(hourlyEntry);

        dailyParticipants.push(dailyEntry);

        weeklyParticipants.push(weeklyEntry);

        monthlyParticipants.push(monthlyEntry);

        yearlyParticipants.push(yearlyEntry);

        threeYearlyParticipants.push(threeYearlyEntry);



        hourlyTickets += tickets;

        dailyTickets += tickets;

        weeklyTickets += tickets;

        monthlyTickets += tickets;

        yearlyTickets += tickets;

        threeYearlyTickets += tickets;



        players.push(msg.sender);

    }

         

    /**

    * @dev Calls provable oracle to return random number

    */

     function provableRandomNumber(uint8 tier) private {



        uint256 gasAmount;



        if (tier == 0) {

            gasAmount = hourlyGas;

        }

        else if (tier == 1) {

            gasAmount = dailyGas;

        }

        else if (tier == 2) {

            gasAmount = weeklyGas;

        }

        else if (tier == 3) {

            gasAmount = monthlyGas;

        }

        else if (tier == 4) {

            gasAmount = yearlyGas;

        }

        else if (tier == 5) {

            gasAmount = threeYearlyGas;

        }

        else {

            gasAmount = hourlyGas;

        }



        bytes32 queryId = provable_newRandomDSQuery(

            QUERY_EXECUTION_DELAY,

            NUM_RANDOM_BYTES_REQUESTED,

            gasAmount

        );



        validQueryIds[queryId] = tier; //0 = hourly tier, 1 = daily, 2 = weekly, 3 = monthly, 4 = yearly, 5 = 3 yearly



        emit LogNewProvableQuery("Provable query for prize was sent, waiting for random number...");

     }

    

    /**

    * @dev Generates a random number based on the provable oracle result

    */

    function generateRandomNumber(string memory provableResult) private returns(uint256) {

        //Convert provable random result into a random number

        uint ceiling = (MAX_INT_FROM_BYTE ** NUM_RANDOM_BYTES_REQUESTED) - 1;

        nonce++;

        return uint256(keccak256(abi.encodePacked(now, provableResult, nonce))) % ceiling;

    }



    /**

    * @dev Distributes the total currently approved amount to the hex2 contract distribution

    */

    function distributeToHex2() public {

        HEX2(hex2).distribute(hex2amount);

    }



    /**

    * @dev Schedule to call once per hour

    * Finishes current game and calls provable random number

    */

    function finishHourly() external {

        require(now > lastHourly.add(hour), "Can only finish game once per hour.");

        require(hourlyParticipants.length >= minimumParticipants);

        require(hourlyPot > minimumPotAmount, "Hourly pot needs to be higher before game can finish");

        

        provableRandomNumber(0);

    }



     /**

    * @dev Transfers prize to random winner

    */

    function pickHourlyWinner(uint256 random) private {

        

        uint256 randomWinner = random % hourlyTickets - 1;

        address hourlyWinner = pickWinner(hourlyParticipants, randomWinner);

        

        require(hourlyWinner != address(0), "Can not send to 0 address");

        require(ERC20(token).transfer(hourlyWinner, hourlyPot), "transfer failed");

        playerStats[hourlyWinner].amountWon += hourlyPot;



        lastHourly = now;      

        hourlyPot = 0;

        hourlyTickets = 0;

        delete hourlyParticipants;

     }

     

    /**

    * @dev Schedule to call once per day

    * Finishes current game and calls provable random number

    */

    function finishDaily() external {

        require(now > lastDaily.add(day),  "Can only finish game once per day.");

        require(dailyParticipants.length >= minimumParticipants);

        require(dailyPot > minimumPotAmount, "Daily pot needs to be higher before game can finish");

        

        provableRandomNumber(1);

    }



    /**

    * @dev Transfers prize to random winner

    */

    function pickDailyWinner(uint256 random) private {

        uint256 randomWinner = random % dailyTickets - 1;

        address dailyWinner = pickWinner(dailyParticipants, randomWinner);

        require(dailyWinner != address(0), "Can not send to 0 address");



        require(ERC20(token).transfer(dailyWinner, dailyPot), "Transfer failed");

        playerStats[dailyWinner].amountWon += dailyPot;

        

        lastDaily = now;

        dailyPot = 0;

        dailyTickets = 0;

        delete dailyParticipants;

     }



    /**

    * @dev Schedule to call once per week

    * Finishes current game and calls provable random number

    */

    function finishWeekly() external {

        require(now > lastWeekly.add(week),  "Can only finish game once per week.");

        require(weeklyParticipants.length >= minimumParticipants);

        require(weeklyPot > minimumPotAmount, "Weekly pot needs to be higher before game can finish");

        

        provableRandomNumber(2);

    }



    /**

    * @dev Transfers prize to random winner

    */

    function pickWeeklyWinner(uint256 random, uint256 prizeAmount) private  {

        uint256 randomWinner = random % weeklyTickets - 1;

        address weeklyWinner = pickWinner(weeklyParticipants, randomWinner);

        require(weeklyWinner != address(0), "Can not send to 0 address");



        require(ERC20(token).transfer(weeklyWinner, prizeAmount), "Transfer failed");

        playerStats[weeklyWinner].amountWon += prizeAmount;

        

        weeklyPot -= prizeAmount;



        if(weeklyPot < 2){

            lastWeekly = now;

            weeklyTickets = 0;

            delete weeklyParticipants;

        }

     }

     

    /**

    * @dev Schedule to call once per month

    * Finishes current game and calls provable random number

    */

    function finishMonthly() external { 

        require(now > lastMonthly.add(month),  "Can only finish game once per month.");

        require(monthlyParticipants.length >= minimumParticipants);

        require(monthlyPot > minimumPotAmount, "Monthly pot needs to be higher before game can finish");



        provableRandomNumber(3);

       

    }

     

    /**

    * @dev Transfers prize to random winner

    */

    function pickMonthlyWinner(uint256 random, uint256 prizeAmount) private {

        uint256 randomWinner = random % monthlyTickets - 1;

        address monthlyWinner = pickWinner(monthlyParticipants, randomWinner);

        require(monthlyWinner != address(0), "Can not send to 0 address");



        require(ERC20(token).transfer(monthlyWinner, prizeAmount), "Transfer failed");

        playerStats[monthlyWinner].amountWon += prizeAmount;



        monthlyPot -= prizeAmount;



        if(monthlyPot < 3) {

            lastMonthly = now;

            monthlyTickets = 0;

            delete monthlyParticipants;

        }

     }



    /**

    * @dev Schedule to call once per year

    * Finishes current game and calls provable random number

    */

    function finishYearly() external {

        require(now > lastYearly.add(threeHundredDays),  "Can only finish game once every 300 days.");

        require(yearlyParticipants.length >= minimumParticipants);

        require(yearlyPot > minimumPotAmount, "Yearly pot needs to be higher before game can finish");

        

        //Picks 6 random winners from yearly participants based on number of entries

        provableRandomNumber(4);  

    }

    

    /**

    * @dev Transfers prize to random winner

    */

    function pickYearlyWinner(uint256 random, uint256 prizeAmount) private {

        uint256 randomWinner = random % yearlyTickets - 1;

        address yearlyWinner = pickWinner(yearlyParticipants, randomWinner);

         require(yearlyWinner != address(0), "Can not send to 0 address");



        require(ERC20(token).transfer(yearlyWinner, prizeAmount), "Transfer failed");

        playerStats[yearlyWinner].amountWon += prizeAmount;

        

        yearlyPot -= prizeAmount;

        

        if(yearlyPot < 6){

            lastYearly = now;

            yearlyTickets = 0;

            delete yearlyParticipants;

        }

     }



    /**

    * @dev Schedule to call once every 3 years

    * Finishes current game and calls provable random number

    */

    function finishThreeYearly() external {

        require(now > lastThreeYearly.add(threeYears),  "Can only finish game every three years.");

        require(threeYearlyParticipants.length >= minimumParticipants);

        require(threeYearlyPot >  minimumPotAmount, "3 yearly pot needs to be higher before game can finish");



        provableRandomNumber(5);

    }

    

    /**

    * @dev Transfers prize to random winner

    */

    function pickThreeYearlyWinner(uint256 random) private {

        uint256 randomWinner = random % threeYearlyTickets - 1;

        address threeYearlyWinner = pickWinner(threeYearlyParticipants, randomWinner);

        require(threeYearlyWinner != address(0), "Can not send to 0 address");



        require(ERC20(token).transfer(threeYearlyWinner, threeYearlyPot), "Transfer failed");

        playerStats[threeYearlyWinner].amountWon += threeYearlyPot;



        lastThreeYearly = now;

        threeYearlyPot = 0;

        threeYearlyTickets = 0;

        delete threeYearlyParticipants;

     }



    /**

     * @dev callback function used by provable to process random number 

     */

    function __callback(

        bytes32 _queryId,

        string memory _result,

        bytes memory _proof

    )

        public

    {

        require(msg.sender == provable_cbAddress());



        if (

            provable_randomDS_proofVerify__returnCode(

                _queryId,

                _result,

                _proof

            ) != 0

        ) {

            revert("Proof verification failed.");

        } else {            

            

            uint8 thisTier = validQueryIds[_queryId];

           

            if(thisTier == 0) { 

                pickHourlyWinner(generateRandomNumber(_result));

            }

            if(thisTier == 1) {

                pickDailyWinner(generateRandomNumber(_result));

            }

            if(thisTier == 2) {

                uint256 firstWeeklyPrize = weeklyPot.mul(70).div(100);

                uint256 secondWeeklyPrize = weeklyPot.mul(30).div(100);

                pickWeeklyWinner(generateRandomNumber(_result), firstWeeklyPrize);

                pickWeeklyWinner(generateRandomNumber(_result), secondWeeklyPrize);

            }

            if(thisTier == 3) {

                uint256 firstMonthlyPrize = monthlyPot.mul(50).div(100);

                uint256 secondMonthlyPrize = monthlyPot.mul(30).div(100);

                uint256 thirdMonthlyPrize = monthlyPot.mul(20).div(100);



                pickMonthlyWinner(generateRandomNumber(_result), firstMonthlyPrize);

                pickMonthlyWinner(generateRandomNumber(_result), secondMonthlyPrize);

                pickMonthlyWinner(generateRandomNumber(_result), thirdMonthlyPrize);

            }

            if(thisTier == 4) {

                uint256 yearlyPrize = yearlyPot.div(6);

                for(uint i=0; i<6; i++){

                    pickYearlyWinner(generateRandomNumber(_result), yearlyPrize);

                }

            }

            if(thisTier == 5) {

                pickThreeYearlyWinner(generateRandomNumber(_result));

            }

  

            delete validQueryIds[_queryId];

        }

    }



    /**

    * @dev Returns a winner address chosen at random from the participant list

    */

    function pickWinner(Entry[] memory entries, uint256 random) internal returns(address) {



        address winner;



        uint256 counter = random;

        for (uint i=0; i < entries.length; i++) {

            uint quantity = entries[i].tickets;

            if (quantity >= counter) {

                winner = entries[i].buyer;

                break;

            } else {

                counter -= quantity;

            }

        }



        emit generatedRandomNumber(random);

        return winner;

     }



    /**

    * @dev Default payable function, need eth for provable call

    */

    function() external payable {

      

    }

}