/**

 *Submitted for verification at Etherscan.io on 2019-05-23

*/



/**

 * Source Code first verified at https://etherscan.io on Friday, March 29, 2019

 (UTC) */



/*



ORACLIZE_API



Copyright (c) 2015-2016 Oraclize SRL

Copyright (c) 2016 Oraclize LTD



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

pragma solidity >= 0.5.10; // Incompatible compiler version - please select a compiler within the stated pragma range, or use a different version of the oraclizeAPI!



// Dummy contract only used to emit to end-user they are using wrong solc

contract solcChecker {

    /* INCOMPATIBLE SOLC: import the following instead: "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.sol" */ function f(bytes calldata x) external;

}



contract OraclizeI {



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



contract OraclizeAddrResolverI {

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

contract usingOraclize {



    using CBOR for Buffer.buffer;



    OraclizeI oraclize;

    OraclizeAddrResolverI OAR;



    uint constant day = 60 * 60 * 24;

    uint constant week = 60 * 60 * 24 * 7;

    uint constant month = 60 * 60 * 24 * 30;



    byte constant proofType_NONE = 0x00;

    byte constant proofType_Ledger = 0x30;

    byte constant proofType_Native = 0xF0;

    byte constant proofStorage_IPFS = 0x01;

    byte constant proofType_Android = 0x40;

    byte constant proofType_TLSNotary = 0x10;



    string oraclize_network_name;

    uint8 constant networkID_auto = 0;

    uint8 constant networkID_morden = 2;

    uint8 constant networkID_mainnet = 1;

    uint8 constant networkID_testnet = 2;

    uint8 constant networkID_consensys = 161;



    mapping(bytes32 => bytes32) oraclize_randomDS_args;

    mapping(bytes32 => bool) oraclize_randomDS_sessionKeysHashVerified;



    modifier oraclizeAPI {

        if ((address(OAR) == address(0)) || (getCodeSize(address(OAR)) == 0)) {

            oraclize_setNetwork(networkID_auto);

        }

        if (address(oraclize) != OAR.getAddress()) {

            oraclize = OraclizeI(OAR.getAddress());

        }

        _;

    }



    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string memory _result, bytes memory _proof) {

        // RandomDS Proof Step 1: The prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (uint8(_proof[2]) == uint8(1)));

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        require(proofVerified);

        _;

    }



    function oraclize_setNetwork(uint8 _networkID) internal returns (bool _networkSet) {

        return oraclize_setNetwork();

        _networkID; // silence the warning and remain backwards compatible

    }



    function oraclize_setNetworkName(string memory _network_name) internal {

        oraclize_network_name = _network_name;

    }



    function oraclize_getNetworkName() internal view returns (string memory _networkName) {

        return oraclize_network_name;

    }



    function oraclize_setNetwork() internal returns (bool _networkSet) {

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed) > 0) { //mainnet

            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);

            oraclize_setNetworkName("eth_mainnet");

            return true;

        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1) > 0) { //ropsten testnet

            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);

            oraclize_setNetworkName("eth_ropsten3");

            return true;

        }

        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e) > 0) { //kovan testnet

            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);

            oraclize_setNetworkName("eth_kovan");

            return true;

        }

        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48) > 0) { //rinkeby testnet

            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);

            oraclize_setNetworkName("eth_rinkeby");

            return true;

        }

        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475) > 0) { //ethereum-bridge

            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

            return true;

        }

        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF) > 0) { //ether.camp ide

            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);

            return true;

        }

        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA) > 0) { //browser-solidity

            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);

            return true;

        }

        return false;

    }



    function __callback(bytes32 _myid, string memory _result) public {

        __callback(_myid, _result, new bytes(0));

    }



    function __callback(bytes32 _myid, string memory _result, bytes memory _proof) public {

        return;

        _myid; _result; _proof; // Silence compiler warnings

    }



    function oraclize_getPrice(string memory _datasource) oraclizeAPI internal returns (uint _queryPrice) {

        return oraclize.getPrice(_datasource);

    }



    function oraclize_getPrice(string memory _datasource, uint _gasLimit) oraclizeAPI internal returns (uint _queryPrice) {

        return oraclize.getPrice(_datasource, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string memory _arg) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query.value(price)(0, _datasource, _arg);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string memory _arg) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query.value(price)(_timestamp, _datasource, _arg);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string memory _arg, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource,_gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query_withGasLimit.value(price)(_timestamp, _datasource, _arg, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string memory _arg, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query_withGasLimit.value(price)(0, _datasource, _arg, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string memory _arg1, string memory _arg2) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query2.value(price)(0, _datasource, _arg1, _arg2);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query2.value(price)(_timestamp, _datasource, _arg1, _arg2);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string memory _arg1, string memory _arg2, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query2_withGasLimit.value(price)(_timestamp, _datasource, _arg1, _arg2, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string memory _arg1, string memory _arg2, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        return oraclize.query2_withGasLimit.value(price)(0, _datasource, _arg1, _arg2, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[] memory _argN) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return oraclize.queryN.value(price)(0, _datasource, args);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[] memory _argN) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return oraclize.queryN.value(price)(_timestamp, _datasource, args);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[] memory _argN, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return oraclize.queryN_withGasLimit.value(price)(_timestamp, _datasource, args, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[] memory _argN, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = stra2cbor(_argN);

        return oraclize.queryN_withGasLimit.value(price)(0, _datasource, args, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[1] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[1] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[1] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[1] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[2] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[2] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[2] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[2] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[3] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[3] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[3] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[3] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[4] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[4] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[4] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[4] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[5] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[5] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, string[5] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, string[5] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[] memory _argN) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return oraclize.queryN.value(price)(0, _datasource, args);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[] memory _argN) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource);

        if (price > 1 ether + tx.gasprice * 200000) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return oraclize.queryN.value(price)(_timestamp, _datasource, args);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[] memory _argN, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return oraclize.queryN_withGasLimit.value(price)(_timestamp, _datasource, args, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[] memory _argN, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        uint price = oraclize.getPrice(_datasource, _gasLimit);

        if (price > 1 ether + tx.gasprice * _gasLimit) {

            return 0; // Unexpectedly high price

        }

        bytes memory args = ba2cbor(_argN);

        return oraclize.queryN_withGasLimit.value(price)(0, _datasource, args, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[1] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[1] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[1] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[1] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = _args[0];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[2] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[2] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[2] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[2] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[3] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[3] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[3] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[3] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[4] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[4] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[4] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[4] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[5] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[5] memory _args) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_timestamp, _datasource, dynargs);

    }



    function oraclize_query(uint _timestamp, string memory _datasource, bytes[5] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_timestamp, _datasource, dynargs, _gasLimit);

    }



    function oraclize_query(string memory _datasource, bytes[5] memory _args, uint _gasLimit) oraclizeAPI internal returns (bytes32 _id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = _args[0];

        dynargs[1] = _args[1];

        dynargs[2] = _args[2];

        dynargs[3] = _args[3];

        dynargs[4] = _args[4];

        return oraclize_query(_datasource, dynargs, _gasLimit);

    }



    function oraclize_setProof(byte _proofP) oraclizeAPI internal {

        return oraclize.setProofType(_proofP);

    }





    function oraclize_cbAddress() oraclizeAPI internal returns (address _callbackAddress) {

        return oraclize.cbAddress();

    }



    function getCodeSize(address _addr) view internal returns (uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function oraclize_setCustomGasPrice(uint _gasPrice) oraclizeAPI internal {

        return oraclize.setCustomGasPrice(_gasPrice);

    }



    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32 _sessionKeyHash) {

        return oraclize.randomDS_getSessionPubKeyHash();

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



    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32 _queryId) {

        require((_nbytes > 0) && (_nbytes <= 32));

        _delay *= 10; // Convert from seconds to ledger timer ticks

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(uint8(_nbytes));

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

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

        bytes32 queryId = oraclize_query("random", args, _customGasLimit);

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

        oraclize_randomDS_setCommitment(queryId, keccak256(abi.encodePacked(delay_bytes8_left, args[1], sha256(args[0]), args[2])));

        return queryId;

    }



    function oraclize_randomDS_setCommitment(bytes32 _queryId, bytes32 _commitment) internal {

        oraclize_randomDS_args[_queryId] = _commitment;

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



    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes memory _proof, uint _sig2offset) internal returns (bool _proofVerified) {

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



    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string memory _result, bytes memory _proof) internal returns (uint8 _returnCode) {

        // Random DS Proof Step 1: The prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L") || (_proof[1] != "P") || (uint8(_proof[2]) != uint8(1))) {

            return 1;

        }

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

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



    function oraclize_randomDS_proofVerify__main(bytes memory _proof, bytes32 _queryId, bytes memory _result, string memory _contextName) internal returns (bool _proofVerified) {

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

        if (oraclize_randomDS_args[_queryId] == keccak256(abi.encodePacked(commitmentSlice1, sessionPubkeyHash))) { //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[_queryId];

        } else return false;

        // Random DS Proof Step 5: Validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32 + 8 + 1 + 32);

        copyBytes(_proof, ledgerProofLength, 32 + 8 + 1 + 32, tosign1, 0);

        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) {

            return false;

        }

        // Verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (!oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash]) {

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(_proof, sig2offset);

        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

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

/*



END ORACLIZE_API



*/





library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {

            return 0;

        }

        c = a * b;

        assert(c / a == b);

        return c;

    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;

    }



    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;

        assert(c >= a);

        return c;

    }

}



contract Ownable {

    address payable owner; //for tokens

    mapping(address => bool) owners;



    event OwnerAdded(address indexed newOwner);

    event OwnerDeleted(address indexed owner);



    /**

     * @dev The Ownable constructor sets the original `owner` of the contract to the sender

     * account.

     */

    constructor() public {

        owners[0x60240B916E899F102F7654E681314A94FeEDD9CA] = true;

        owner = 0x60240B916E899F102F7654E681314A94FeEDD9CA;

    }





    modifier onlyOwner() {

        require(isOwner(msg.sender));

        _;

    }



    function addOwner(address _newOwner) external onlyOwner {

        require(_newOwner != address(0));

        owners[_newOwner] = true;

        emit OwnerAdded(_newOwner);

    }



    function delOwner(address _owner) external onlyOwner {

        require(owners[_owner]);

        owners[_owner] = false;

        emit OwnerDeleted(_owner);

    }



    function isOwner(address _owner) public view returns (bool) {

        return owners[_owner];

    }



    function changeMainOwner(address payable _owner) public {

        require(msg.sender == owner);

        require(_owner != address(0));

        owner = _owner;

    }

}



interface tokenRecipient {

    function receiveApproval(

        address _from,

        uint256 _value,

        address _token,

        bytes calldata _extraData

    ) external;

}



contract Mitoshi is Ownable, usingOraclize {

    using SafeMath for uint256;



    string public name = "Mitoshi";

    string public symbol = "MTSH";

    uint8 public decimals = 18;

    uint256 DEC = 10 ** uint256(decimals);



    uint256 public totalSupply = 100000000 * DEC;

    uint256 public tokensForSale = 68000000 * DEC;

    uint256 minPurchase = 25 ether;

    uint256 public curs = 140;

    uint256 public oraclizeBalance;

    uint256 public goal = 2000000 ether;

    uint256 public cap = 10000000 ether;

    uint256 public USDRaised;



    mapping(address => uint256) deposited;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;



    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Burn(address indexed from, uint256 value);

    event RefundsEnabled();

    event Closed();

    event Refunded(address indexed beneficiary, uint256 weiAmount);

    event LogPriceUpdated(string price);

    event LogNewOraclizeQuery(string description);



    enum State {Active, Refunding, Closed}

    State public state;



    modifier transferredIsOn {

        require(state == State.Closed);

        _;

    }



    modifier sellIsOn {

        require(state == State.Active);

        _;

    }



    constructor() public {

        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);

        balanceOf[0x60240B916E899F102F7654E681314A94FeEDD9CA] = totalSupply;

        state = State.Active;

    }



    function() external payable {

        buyTokens(msg.sender);

    }







    function __callback(bytes32 myid, string memory result, bytes memory proof) public {

        myid;

        proof;

        if (msg.sender != oraclize_cbAddress()) revert();

        curs = parseInt(result);

        emit LogPriceUpdated(result);

        updatePrice();

    }





    function transfer(address _to, uint256 _value) transferredIsOn public {

        _transfer(msg.sender, _to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) transferredIsOn public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);

        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);

        _transfer(_from, _to, _value);

        return true;

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        require((_value == 0) || (allowance[msg.sender][_spender] == 0));



        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }



    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)

    public

    returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);

        if (approve(_spender, _value)) {

            spender.receiveApproval(msg.sender, _value, address(this), _extraData);

            return true;

        }

    }



    function transferOwner(address _to, uint256 _value) onlyOwner public {

        _transfer(msg.sender, _to, _value);

    }



    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != address(0));

        require(balanceOf[_from] >= _value);

        require(balanceOf[_to].add(_value) >= balanceOf[_to]);

        balanceOf[_from] = balanceOf[_from].sub(_value);

        balanceOf[_to] = balanceOf[_to].add(_value);

        emit Transfer(_from, _to, _value);

    }





    function buyTokens(address beneficiary) sellIsOn payable public {

        uint cost;

        uint bonus;



        (cost, bonus) = getCostAndBonus();

        uint rate = 1 ether * curs / cost;

        uint amount = rate.mul(msg.value);



        require(amount >= minPurchase && amount <= tokensForSale);



        amount = amount.add(amount.mul(bonus).div(100));



        _transfer(owner, beneficiary, amount);



        tokensForSale = tokensForSale.sub(amount);

        USDRaised = USDRaised.add(msg.value.mul(curs));

        deposited[beneficiary] = deposited[beneficiary].add(msg.value);

    }





    function manualSale(address beneficiary, uint amount, uint ethValue) onlyOwner public {

        _transfer(owner, beneficiary, amount);



        tokensForSale = tokensForSale.sub(amount);

        USDRaised = USDRaised.add(ethValue.mul(curs));

        deposited[beneficiary] = deposited[beneficiary].add(ethValue);

    }



    function enableRefunds() onlyOwner sellIsOn public {

        require(USDRaised < goal);

        state = State.Refunding;

        emit RefundsEnabled();

    }



    function close() onlyOwner public {

        require(USDRaised >= goal);

        state = State.Closed;

        emit Closed();

    }



    function refund(address payable investor) public {

        require(state == State.Refunding);

        require(deposited[investor] > 0);

        uint256 depositedValue = deposited[investor];

        investor.transfer(depositedValue);

        emit Refunded(investor, depositedValue);

        deposited[investor] = 0;

    }



    function withdrawETH(uint _val) onlyOwner external {

        require(address(this).balance > 0);

        owner.transfer(_val);

    }



    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);

        emit Burn(msg.sender, _value);

        return true;

    }



    function updateCurs(uint256 _value) onlyOwner public {

        curs = _value;

    }







    //15 June 2019 to 14 July 2019 1560546000 1563138000

    //15 July 2019 to 14 August 2019 1563138000 1565816400

    //15 August 2019 to 14 September 2019 1565816400 1568494800



    //15 September 2019 to 14 October 2019 1568494800 1571086800

    //15 October 2019 to 14 November 2019 1571086800 1573765200

    //15 November 2019 1573765200





    function getCostAndBonus() internal view returns(uint, uint) {

        uint cost;

        if (block.timestamp >= 1560546000 && block.timestamp < 1563138000) {

            cost = 10 * DEC / 100;

            return (cost, 30);

        } else if (block.timestamp >= 1563138000 && block.timestamp < 1565816400) {

            cost = 14 * DEC / 100;

            return (cost, 25);

        } else if (block.timestamp >= 1565816400 && block.timestamp < 1568494800) {

            cost = 16 * DEC / 100;

            return (cost, 20);

        } else if (block.timestamp >= 1568494800 && block.timestamp < 1571086800) {

            cost = 18 * DEC / 100;

            return (cost, 15);

        } else if (block.timestamp >= 1571086800 && block.timestamp < 1573765200) {

            cost = 20 * DEC / 100;

            return (cost, 10);

        } else if (block.timestamp >= 1573765200) {

            cost = 20 * DEC / 100;

            return (cost, 0);

        } else return (0,0);

    }



    function updatePrice() sellIsOn payable public {

        if (oraclize_getPrice("URL") > address(this).balance) {

            emit LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");

        } else {

            emit LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");

            //43200 = 12 hour

            oraclize_query(43200, "URL", "json(https://api.gdax.com/products/ETH-USD/ticker).price");

        }

    }



    function setGasPrice(uint _newPrice) onlyOwner public {

        oraclize_setCustomGasPrice(_newPrice * 1 wei);

    }



    function addBalanceForOraclize() payable external {

        oraclizeBalance = oraclizeBalance.add(msg.value);

    }

}