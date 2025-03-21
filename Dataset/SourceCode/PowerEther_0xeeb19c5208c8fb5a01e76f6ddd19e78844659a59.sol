pragma solidity ^0.4.24;





// <ORACLIZE_API>

/*

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



// This api is currently targeted at 0.4.18, please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary



//pragma solidity ^0.4.18;// Incompatible compiler version... please select one stated within pragma solidity or use different oraclizeAPI version



contract OraclizeI {

    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);

    function getPrice(string _datasource) public returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);

    function setProofType(byte _proofType) external;

    function setCustomGasPrice(uint _gasPrice) external;

    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);

}



contract OraclizeAddrResolverI {

    function getAddress() public returns (address _addr);

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



    function init(buffer memory buf, uint _capacity) internal pure {

        uint capacity = _capacity;

        if(capacity % 32 != 0) capacity += 32 - (capacity % 32);

        // Allocate space for the buffer data

        buf.capacity = capacity;

        assembly {

            let ptr := mload(0x40)

            mstore(buf, ptr)

            mstore(ptr, 0)

            mstore(0x40, add(ptr, capacity))

        }

    }



    function resize(buffer memory buf, uint capacity) private pure {

        bytes memory oldbuf = buf.buf;

        init(buf, capacity);

        append(buf, oldbuf);

    }



    function max(uint a, uint b) private pure returns(uint) {

        if(a > b) {

            return a;

        }

        return b;

    }



    /**

     * @dev Appends a byte array to the end of the buffer. Resizes if doing so

     *      would exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function append(buffer memory buf, bytes data) internal pure returns(buffer memory) {

        if(data.length + buf.buf.length > buf.capacity) {

            resize(buf, max(buf.capacity, data.length) * 2);

        }



        uint dest;

        uint src;

        uint len = data.length;

        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Start address = buffer address + buffer length + sizeof(buffer length)

            dest := add(add(bufptr, buflen), 32)

            // Update buffer length

            mstore(bufptr, add(buflen, mload(data)))

            src := add(data, 32)

        }



        // Copy word-length chunks while possible

        for(; len >= 32; len -= 32) {

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }



        // Copy remaining bytes

        uint mask = 256 ** (32 - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }



        return buf;

    }



    /**

     * @dev Appends a byte to the end of the buffer. Resizes if doing so would

     * exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function append(buffer memory buf, uint8 data) internal pure {

        if(buf.buf.length + 1 > buf.capacity) {

            resize(buf, buf.capacity * 2);

        }



        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Address = buffer address + buffer length + sizeof(buffer length)

            let dest := add(add(bufptr, buflen), 32)

            mstore8(dest, data)

            // Update buffer length

            mstore(bufptr, add(buflen, 1))

        }

    }



    /**

     * @dev Appends a byte to the end of the buffer. Resizes if doing so would

     * exceed the capacity of the buffer.

     * @param buf The buffer to append to.

     * @param data The data to append.

     * @return The original buffer.

     */

    function appendInt(buffer memory buf, uint data, uint len) internal pure returns(buffer memory) {

        if(len + buf.buf.length > buf.capacity) {

            resize(buf, max(buf.capacity, len) * 2);

        }



        uint mask = 256 ** len - 1;

        assembly {

            // Memory address of the buffer data

            let bufptr := mload(buf)

            // Length of existing buffer data

            let buflen := mload(bufptr)

            // Address = buffer address + buffer length + sizeof(buffer length) + len

            let dest := add(add(bufptr, buflen), len)

            mstore(dest, or(and(mload(dest), not(mask)), data))

            // Update buffer length

            mstore(bufptr, add(buflen, len))

        }

        return buf;

    }

}



library CBOR {

    using Buffer for Buffer.buffer;



    uint8 private constant MAJOR_TYPE_INT = 0;

    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;

    uint8 private constant MAJOR_TYPE_BYTES = 2;

    uint8 private constant MAJOR_TYPE_STRING = 3;

    uint8 private constant MAJOR_TYPE_ARRAY = 4;

    uint8 private constant MAJOR_TYPE_MAP = 5;

    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;



    function encodeType(Buffer.buffer memory buf, uint8 major, uint value) private pure {

        if(value <= 23) {

            buf.append(uint8((major << 5) | value));

        } else if(value <= 0xFF) {

            buf.append(uint8((major << 5) | 24));

            buf.appendInt(value, 1);

        } else if(value <= 0xFFFF) {

            buf.append(uint8((major << 5) | 25));

            buf.appendInt(value, 2);

        } else if(value <= 0xFFFFFFFF) {

            buf.append(uint8((major << 5) | 26));

            buf.appendInt(value, 4);

        } else if(value <= 0xFFFFFFFFFFFFFFFF) {

            buf.append(uint8((major << 5) | 27));

            buf.appendInt(value, 8);

        }

    }



    function encodeIndefiniteLengthType(Buffer.buffer memory buf, uint8 major) private pure {

        buf.append(uint8((major << 5) | 31));

    }



    function encodeUInt(Buffer.buffer memory buf, uint value) internal pure {

        encodeType(buf, MAJOR_TYPE_INT, value);

    }



    function encodeInt(Buffer.buffer memory buf, int value) internal pure {

        if(value >= 0) {

            encodeType(buf, MAJOR_TYPE_INT, uint(value));

        } else {

            encodeType(buf, MAJOR_TYPE_NEGATIVE_INT, uint(-1 - value));

        }

    }



    function encodeBytes(Buffer.buffer memory buf, bytes value) internal pure {

        encodeType(buf, MAJOR_TYPE_BYTES, value.length);

        buf.append(value);

    }



    function encodeString(Buffer.buffer memory buf, string value) internal pure {

        encodeType(buf, MAJOR_TYPE_STRING, bytes(value).length);

        buf.append(bytes(value));

    }



    function startArray(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);

    }



    function startMap(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);

    }



    function endSequence(Buffer.buffer memory buf) internal pure {

        encodeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);

    }

}



/*

End solidity-cborutils

 */



contract usingOraclize {

    uint constant day = 60*60*24;

    uint constant week = 60*60*24*7;

    uint constant month = 60*60*24*30;

    byte constant proofType_NONE = 0x00;

    byte constant proofType_TLSNotary = 0x10;

    byte constant proofType_Ledger = 0x30;

    byte constant proofType_Android = 0x40;

    byte constant proofType_Native = 0xF0;

    byte constant proofStorage_IPFS = 0x01;

    uint8 constant networkID_auto = 0;

    uint8 constant networkID_mainnet = 1;

    uint8 constant networkID_testnet = 2;

    uint8 constant networkID_morden = 2;

    uint8 constant networkID_consensys = 161;



    OraclizeAddrResolverI OAR;



    OraclizeI oraclize;

    modifier oraclizeAPI {

        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))

            oraclize_setNetwork(networkID_auto);



        if(address(oraclize) != OAR.getAddress())

            oraclize = OraclizeI(OAR.getAddress());



        _;

    }

    modifier coupon(string code){

        oraclize = OraclizeI(OAR.getAddress());

        _;

    }



    function oraclize_setNetwork(uint8 networkID) internal returns(bool){

      return oraclize_setNetwork();

      networkID; // silence the warning and remain backwards compatible

    }

    function oraclize_setNetwork() internal returns(bool){

        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet

            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);

            oraclize_setNetworkName("eth_mainnet");

            return true;

        }

        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet

            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);

            oraclize_setNetworkName("eth_ropsten3");

            return true;

        }

        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet

            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);

            oraclize_setNetworkName("eth_kovan");

            return true;

        }

        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet

            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);

            oraclize_setNetworkName("eth_rinkeby");

            return true;

        }

        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge

            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

            return true;

        }

        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide

            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);

            return true;

        }

        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity

            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);

            return true;

        }

        return false;

    }



    function __callback(bytes32 myid, string result) public {

        __callback(myid, result, new bytes(0));

    }

    function __callback(bytes32 myid, string result, bytes proof) public {

      return;

      myid; result; proof; // Silence compiler warnings

    }



    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource);

    }



    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){

        return oraclize.getPrice(datasource, gaslimit);

    }



    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(0, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query.value(price)(timestamp, datasource, arg);

    }

    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(0, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);

    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = stra2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        string[] memory dynargs = new string[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(0, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource);

        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN.value(price)(timestamp, datasource, args);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){

        uint price = oraclize.getPrice(datasource, gaslimit);

        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price

        bytes memory args = ba2cbor(argN);

        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](1);

        dynargs[0] = args[0];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](2);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](3);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](4);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        return oraclize_query(datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs);

    }

    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(timestamp, datasource, dynargs, gaslimit);

    }

    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {

        bytes[] memory dynargs = new bytes[](5);

        dynargs[0] = args[0];

        dynargs[1] = args[1];

        dynargs[2] = args[2];

        dynargs[3] = args[3];

        dynargs[4] = args[4];

        return oraclize_query(datasource, dynargs, gaslimit);

    }



    function oraclize_cbAddress() oraclizeAPI internal returns (address){

        return oraclize.cbAddress();

    }

    function oraclize_setProof(byte proofP) oraclizeAPI internal {

        return oraclize.setProofType(proofP);

    }

    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {

        return oraclize.setCustomGasPrice(gasPrice);

    }



    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){

        return oraclize.randomDS_getSessionPubKeyHash();

    }



    function getCodeSize(address _addr) constant internal returns(uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function parseAddr(string _a) internal pure returns (address){

        bytes memory tmp = bytes(_a);

        uint160 iaddr = 0;

        uint160 b1;

        uint160 b2;

        for (uint i=2; i<2+2*20; i+=2){

            iaddr *= 256;

            b1 = uint160(tmp[i]);

            b2 = uint160(tmp[i+1]);

            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;

            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;

            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;

            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;

            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;

            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;

            iaddr += (b1*16+b2);

        }

        return address(iaddr);

    }



    function strCompare(string _a, string _b) internal pure returns (int) {

        bytes memory a = bytes(_a);

        bytes memory b = bytes(_b);

        uint minLength = a.length;

        if (b.length < minLength) minLength = b.length;

        for (uint i = 0; i < minLength; i ++)

            if (a[i] < b[i])

                return -1;

            else if (a[i] > b[i])

                return 1;

        if (a.length < b.length)

            return -1;

        else if (a.length > b.length)

            return 1;

        else

            return 0;

    }



    function indexOf(string _haystack, string _needle) internal pure returns (int) {

        bytes memory h = bytes(_haystack);

        bytes memory n = bytes(_needle);

        if(h.length < 1 || n.length < 1 || (n.length > h.length))

            return -1;

        else if(h.length > (2**128 -1))

            return -1;

        else

        {

            uint subindex = 0;

            for (uint i = 0; i < h.length; i ++)

            {

                if (h[i] == n[0])

                {

                    subindex = 1;

                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])

                    {

                        subindex++;

                    }

                    if(subindex == n.length)

                        return int(i);

                }

            }

            return -1;

        }

    }



    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory _bc = bytes(_c);

        bytes memory _bd = bytes(_d);

        bytes memory _be = bytes(_e);

        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

        bytes memory babcde = bytes(abcde);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

        return string(babcde);

    }



    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string _a, string _b, string _c) internal pure returns (string) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string _a, string _b) internal pure returns (string) {

        return strConcat(_a, _b, "", "", "");

    }



    // parseInt

    function parseInt(string _a) internal pure returns (uint) {

        return parseInt(_a, 0);

    }



    // parseInt(parseFloat*10^_b)

    function parseInt(string _a, uint _b) internal pure returns (uint) {

        bytes memory bresult = bytes(_a);

        uint mint = 0;

        bool decimals = false;

        for (uint i=0; i<bresult.length; i++){

            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){

                if (decimals){

                   if (_b == 0) break;

                    else _b--;

                }

                mint *= 10;

                mint += uint(bresult[i]) - 48;

            } else if (bresult[i] == 46) decimals = true;

        }

        if (_b > 0) mint *= 10**_b;

        return mint;

    }



    function uint2str(uint i) internal pure returns (string){

        if (i == 0) return "0";

        uint j = i;

        uint len;

        while (j != 0){

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }

        return string(bstr);

    }



    using CBOR for Buffer.buffer;

    function stra2cbor(string[] arr) internal pure returns (bytes) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < arr.length; i++) {

            buf.encodeString(arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    function ba2cbor(bytes[] arr) internal pure returns (bytes) {

        safeMemoryCleaner();

        Buffer.buffer memory buf;

        Buffer.init(buf, 1024);

        buf.startArray();

        for (uint i = 0; i < arr.length; i++) {

            buf.encodeBytes(arr[i]);

        }

        buf.endSequence();

        return buf.buf;

    }



    string oraclize_network_name;

    function oraclize_setNetworkName(string _network_name) internal {

        oraclize_network_name = _network_name;

    }



    function oraclize_getNetworkName() internal view returns (string) {

        return oraclize_network_name;

    }



    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){

        require((_nbytes > 0) && (_nbytes <= 32));

        // Convert from seconds to ledger timer ticks

        _delay *= 10;

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(_nbytes);

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            // the following variables can be relaxed

            // check relaxed random contract under ethereum-examples repo

            // for an idea on how to override and replace comit hash vars

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



        oraclize_randomDS_setCommitment(queryId, keccak256(delay_bytes8_left, args[1], sha256(args[0]), args[2]));

        return queryId;

    }



    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {

        oraclize_randomDS_args[queryId] = commitment;

    }



    mapping(bytes32=>bytes32) oraclize_randomDS_args;

    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;



    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){

        bool sigok;

        address signer;



        bytes32 sigr;

        bytes32 sigs;



        bytes memory sigr_ = new bytes(32);

        uint offset = 4+(uint(dersig[3]) - 0x20);

        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);

        bytes memory sigs_ = new bytes(32);

        offset += 32 + 2;

        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);



        assembly {

            sigr := mload(add(sigr_, 32))

            sigs := mload(add(sigs_, 32))

        }





        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);

        if (address(keccak256(pubkey)) == signer) return true;

        else {

            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);

            return (address(keccak256(pubkey)) == signer);

        }

    }



    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {

        bool sigok;



        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)

        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);

        copyBytes(proof, sig2offset, sig2.length, sig2, 0);



        bytes memory appkey1_pubkey = new bytes(64);

        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);



        bytes memory tosign2 = new bytes(1+65+32);

        tosign2[0] = byte(1); //role

        copyBytes(proof, sig2offset-65, 65, tosign2, 1);

        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";

        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);

        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);



        if (sigok == false) return false;





        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)

        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";



        bytes memory tosign3 = new bytes(1+65);

        tosign3[0] = 0xFE;

        copyBytes(proof, 3, 65, tosign3, 1);



        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);

        copyBytes(proof, 3+65, sig3.length, sig3, 0);



        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);



        return sigok;

    }



    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        require(proofVerified);



        _;

    }



    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){

        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;



        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) return 2;



        return 0;

    }



    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){

        bool match_ = true;



        require(prefix.length == n_random_bytes);



        for (uint256 i=0; i< n_random_bytes; i++) {

            if (content[i] != prefix[i]) match_ = false;

        }



        return match_;

    }



    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){



        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)

        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;

        bytes memory keyhash = new bytes(32);

        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);

        if (!(keccak256(keyhash) == keccak256(sha256(context_name, queryId)))) return false;



        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);

        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);



        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)

        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;



        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8+1+32);

        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);



        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;

        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);



        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (oraclize_randomDS_args[queryId] == keccak256(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[queryId];

        } else return false;





        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32+8+1+32);

        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);

        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;



        // verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);

        }



        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {

        uint minLength = length + toOffset;



        // Buffer too small

        require(to.length >= minLength); // Should be a better way?



        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables

        uint i = 32 + fromOffset;

        uint j = 32 + toOffset;



        while (i < (32 + fromOffset + length)) {

            assembly {

                let tmp := mload(add(from, i))

                mstore(add(to, j), tmp)

            }

            i += 32;

            j += 32;

        }



        return to;

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    // Duplicate Solidity's ecrecover, but catching the CALL return value

    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {

        // We do our own memory management here. Solidity uses memory offset

        // 0x40 to store the current end of memory. We write past it (as

        // writes are memory extensions), but don't update the offset so

        // Solidity will reuse it. The memory used here is only needed for

        // this context.



        // FIXME: inline assembly can't access return values

        bool ret;

        address addr;



        assembly {

            let size := mload(0x40)

            mstore(size, hash)

            mstore(add(size, 32), v)

            mstore(add(size, 64), r)

            mstore(add(size, 96), s)



            // NOTE: we can reuse the request memory because we deal with

            //       the return code

            ret := call(3000, 1, 0, size, 128, size, 32)

            addr := mload(size)

        }



        return (ret, addr);

    }



    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {

        bytes32 r;

        bytes32 s;

        uint8 v;



        if (sig.length != 65)

          return (false, 0);



        // The signature format is a compact form of:

        //   {bytes32 r}{bytes32 s}{uint8 v}

        // Compact means, uint8 is not padded to 32 bytes.

        assembly {

            r := mload(add(sig, 32))

            s := mload(add(sig, 64))



            // Here we are loading the last 32 bytes. We exploit the fact that

            // 'mload' will pad with zeroes if we overread.

            // There is no 'mload8' to do this, but that would be nicer.

            v := byte(0, mload(add(sig, 96)))



            // Alternative solution:

            // 'byte' is not working due to the Solidity parser, so lets

            // use the second best option, 'and'

            // v := and(mload(add(sig, 65)), 255)

        }



        // albeit non-transactional signatures are not specified by the YP, one would expect it

        // to match the YP range of [27, 28]

        //

        // geth uses [0, 1] and some clients have followed. This might change, see:

        //  https://github.com/ethereum/go-ethereum/issues/2053

        if (v < 27)

          v += 27;



        if (v != 27 && v != 28)

            return (false, 0);



        return safer_ecrecover(hash, v, r, s);

    }



    function safeMemoryCleaner() internal pure {

        assembly {

            let fmem := mload(0x40)

            codecopy(fmem, codesize, sub(msize, fmem))

        }

    }



}

// </ORACLIZE_API>





/*

 * Ownable

 *

 * Base contract with an owner.

 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.

 */



contract Ownable {

    address public owner;

    function Ownable() {

        owner = msg.sender;

    }



    modifier onlyOwner() {

        if (msg.sender == owner)

        _;

    }



    function transferOwnership(address newOwner) onlyOwner {

        if (newOwner != address(0)) owner = newOwner;

    }



}



library SafeMath {



    /**

    * @dev Multiplies two numbers, throws on overflow.

    */

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }



    /**

    * @dev Integer division of two numbers, truncating the quotient.

    */

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        // assert(b > 0); // Solidity automatically throws when dividing by 0

        // uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return a / b;

    }



    /**

    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    */

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    /**

    * @dev Adds two numbers, throws on overflow.

    */

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

}



library strings {

    struct slice {

        uint _len;

        uint _ptr;

    }



    function memcpy(uint dest, uint src, uint len) private {

        // Copy word-length chunks while possible

        for(; len >= 32; len -= 32) {

            assembly {

                mstore(dest, mload(src))

            }

            dest += 32;

            src += 32;

        }



        // Copy remaining bytes

        uint mask = 256 ** (32 - len) - 1;

        assembly {

            let srcpart := and(mload(src), not(mask))

            let destpart := and(mload(dest), mask)

            mstore(dest, or(destpart, srcpart))

        }

    }



    /*

     * @dev Returns a slice containing the entire string.

     * @param self The string to make a slice from.

     * @return A newly allocated slice containing the entire string.

     */

    function toSlice(string self) internal returns (slice) {

        uint ptr;

        assembly {

            ptr := add(self, 0x20)

        }

        return slice(bytes(self).length, ptr);

    }



    /*

     * @dev Returns the length of a null-terminated bytes32 string.

     * @param self The value to find the length of.

     * @return The length of the string, from 0 to 32.

     */

    function len(bytes32 self) internal returns (uint) {

        uint ret;

        if (self == 0)

            return 0;

        if (self & 0xffffffffffffffffffffffffffffffff == 0) {

            ret += 16;

            self = bytes32(uint(self) / 0x100000000000000000000000000000000);

        }

        if (self & 0xffffffffffffffff == 0) {

            ret += 8;

            self = bytes32(uint(self) / 0x10000000000000000);

        }

        if (self & 0xffffffff == 0) {

            ret += 4;

            self = bytes32(uint(self) / 0x100000000);

        }

        if (self & 0xffff == 0) {

            ret += 2;

            self = bytes32(uint(self) / 0x10000);

        }

        if (self & 0xff == 0) {

            ret += 1;

        }

        return 32 - ret;

    }



    /*

     * @dev Returns a slice containing the entire bytes32, interpreted as a

     *      null-termintaed utf-8 string.

     * @param self The bytes32 value to convert to a slice.

     * @return A new slice containing the value of the input argument up to the

     *         first null.

     */

    function toSliceB32(bytes32 self) internal returns (slice ret) {

        // Allocate space for `self` in memory, copy it there, and point ret at it

        assembly {

            let ptr := mload(0x40)

            mstore(0x40, add(ptr, 0x20))

            mstore(ptr, self)

            mstore(add(ret, 0x20), ptr)

        }

        ret._len = len(self);

    }



    /*

     * @dev Returns a new slice containing the same data as the current slice.

     * @param self The slice to copy.

     * @return A new slice containing the same data as `self`.

     */

    function copy(slice self) internal returns (slice) {

        return slice(self._len, self._ptr);

    }



    /*

     * @dev Copies a slice to a new string.

     * @param self The slice to copy.

     * @return A newly allocated string containing the slice's text.

     */

    function toString(slice self) internal returns (string) {

        var ret = new string(self._len);

        uint retptr;

        assembly { retptr := add(ret, 32) }



        memcpy(retptr, self._ptr, self._len);

        return ret;

    }



    /*

     * @dev Returns the length in runes of the slice. Note that this operation

     *      takes time proportional to the length of the slice; avoid using it

     *      in loops, and call `slice.empty()` if you only need to know whether

     *      the slice is empty or not.

     * @param self The slice to operate on.

     * @return The length of the slice in runes.

     */

    function len(slice self) internal returns (uint) {

        // Starting at ptr-31 means the LSB will be the byte we care about

        var ptr = self._ptr - 31;

        var end = ptr + self._len;

        for (uint len = 0; ptr < end; len++) {

            uint8 b;

            assembly { b := and(mload(ptr), 0xFF) }

            if (b < 0x80) {

                ptr += 1;

            } else if(b < 0xE0) {

                ptr += 2;

            } else if(b < 0xF0) {

                ptr += 3;

            } else if(b < 0xF8) {

                ptr += 4;

            } else if(b < 0xFC) {

                ptr += 5;

            } else {

                ptr += 6;

            }

        }

        return len;

    }



    /*

     * @dev Returns true if the slice is empty (has a length of 0).

     * @param self The slice to operate on.

     * @return True if the slice is empty, False otherwise.

     */

    function empty(slice self) internal returns (bool) {

        return self._len == 0;

    }



    /*

     * @dev Returns a positive number if `other` comes lexicographically after

     *      `self`, a negative number if it comes before, or zero if the

     *      contents of the two slices are equal. Comparison is done per-rune,

     *      on unicode codepoints.

     * @param self The first slice to compare.

     * @param other The second slice to compare.

     * @return The result of the comparison.

     */

    function compare(slice self, slice other) internal returns (int) {

        uint shortest = self._len;

        if (other._len < self._len)

            shortest = other._len;



        var selfptr = self._ptr;

        var otherptr = other._ptr;

        for (uint idx = 0; idx < shortest; idx += 32) {

            uint a;

            uint b;

            assembly {

                a := mload(selfptr)

                b := mload(otherptr)

            }

            if (a != b) {

                // Mask out irrelevant bytes and check again

                uint mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);

                var diff = (a & mask) - (b & mask);

                if (diff != 0)

                    return int(diff);

            }

            selfptr += 32;

            otherptr += 32;

        }

        return int(self._len) - int(other._len);

    }



    /*

     * @dev Returns true if the two slices contain the same text.

     * @param self The first slice to compare.

     * @param self The second slice to compare.

     * @return True if the slices are equal, false otherwise.

     */

    function equals(slice self, slice other) internal returns (bool) {

        return compare(self, other) == 0;

    }



    /*

     * @dev Extracts the first rune in the slice into `rune`, advancing the

     *      slice to point to the next rune and returning `self`.

     * @param self The slice to operate on.

     * @param rune The slice that will contain the first rune.

     * @return `rune`.

     */

    function nextRune(slice self, slice rune) internal returns (slice) {

        rune._ptr = self._ptr;



        if (self._len == 0) {

            rune._len = 0;

            return rune;

        }



        uint len;

        uint b;

        // Load the first byte of the rune into the LSBs of b

        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }

        if (b < 0x80) {

            len = 1;

        } else if(b < 0xE0) {

            len = 2;

        } else if(b < 0xF0) {

            len = 3;

        } else {

            len = 4;

        }



        // Check for truncated codepoints

        if (len > self._len) {

            rune._len = self._len;

            self._ptr += self._len;

            self._len = 0;

            return rune;

        }



        self._ptr += len;

        self._len -= len;

        rune._len = len;

        return rune;

    }



    /*

     * @dev Returns the first rune in the slice, advancing the slice to point

     *      to the next rune.

     * @param self The slice to operate on.

     * @return A slice containing only the first rune from `self`.

     */

    function nextRune(slice self) internal returns (slice ret) {

        nextRune(self, ret);

    }



    /*

     * @dev Returns the number of the first codepoint in the slice.

     * @param self The slice to operate on.

     * @return The number of the first codepoint in the slice.

     */

    function ord(slice self) internal returns (uint ret) {

        if (self._len == 0) {

            return 0;

        }



        uint word;

        uint len;

        uint div = 2 ** 248;



        // Load the rune into the MSBs of b

        assembly { word:= mload(mload(add(self, 32))) }

        var b = word / div;

        if (b < 0x80) {

            ret = b;

            len = 1;

        } else if(b < 0xE0) {

            ret = b & 0x1F;

            len = 2;

        } else if(b < 0xF0) {

            ret = b & 0x0F;

            len = 3;

        } else {

            ret = b & 0x07;

            len = 4;

        }



        // Check for truncated codepoints

        if (len > self._len) {

            return 0;

        }



        for (uint i = 1; i < len; i++) {

            div = div / 256;

            b = (word / div) & 0xFF;

            if (b & 0xC0 != 0x80) {

                // Invalid UTF-8 sequence

                return 0;

            }

            ret = (ret * 64) | (b & 0x3F);

        }



        return ret;

    }



    /*

     * @dev Returns the keccak-256 hash of the slice.

     * @param self The slice to hash.

     * @return The hash of the slice.

     */

    function keccak(slice self) internal returns (bytes32 ret) {

        assembly {

            ret := sha3(mload(add(self, 32)), mload(self))

        }

    }



    /*

     * @dev Returns true if `self` starts with `needle`.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return True if the slice starts with the provided text, false otherwise.

     */

    function startsWith(slice self, slice needle) internal returns (bool) {

        if (self._len < needle._len) {

            return false;

        }



        if (self._ptr == needle._ptr) {

            return true;

        }



        bool equal;

        assembly {

            let len := mload(needle)

            let selfptr := mload(add(self, 0x20))

            let needleptr := mload(add(needle, 0x20))

            equal := eq(sha3(selfptr, len), sha3(needleptr, len))

        }

        return equal;

    }



    /*

     * @dev If `self` starts with `needle`, `needle` is removed from the

     *      beginning of `self`. Otherwise, `self` is unmodified.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return `self`

     */

    function beyond(slice self, slice needle) internal returns (slice) {

        if (self._len < needle._len) {

            return self;

        }



        bool equal = true;

        if (self._ptr != needle._ptr) {

            assembly {

                let len := mload(needle)

                let selfptr := mload(add(self, 0x20))

                let needleptr := mload(add(needle, 0x20))

                equal := eq(sha3(selfptr, len), sha3(needleptr, len))

            }

        }



        if (equal) {

            self._len -= needle._len;

            self._ptr += needle._len;

        }



        return self;

    }



    /*

     * @dev Returns true if the slice ends with `needle`.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return True if the slice starts with the provided text, false otherwise.

     */

    function endsWith(slice self, slice needle) internal returns (bool) {

        if (self._len < needle._len) {

            return false;

        }



        var selfptr = self._ptr + self._len - needle._len;



        if (selfptr == needle._ptr) {

            return true;

        }



        bool equal;

        assembly {

            let len := mload(needle)

            let needleptr := mload(add(needle, 0x20))

            equal := eq(sha3(selfptr, len), sha3(needleptr, len))

        }



        return equal;

    }



    /*

     * @dev If `self` ends with `needle`, `needle` is removed from the

     *      end of `self`. Otherwise, `self` is unmodified.

     * @param self The slice to operate on.

     * @param needle The slice to search for.

     * @return `self`

     */

    function until(slice self, slice needle) internal returns (slice) {

        if (self._len < needle._len) {

            return self;

        }



        var selfptr = self._ptr + self._len - needle._len;

        bool equal = true;

        if (selfptr != needle._ptr) {

            assembly {

                let len := mload(needle)

                let needleptr := mload(add(needle, 0x20))

                equal := eq(sha3(selfptr, len), sha3(needleptr, len))

            }

        }



        if (equal) {

            self._len -= needle._len;

        }



        return self;

    }



    // Returns the memory address of the first byte of the first occurrence of

    // `needle` in `self`, or the first byte after `self` if not found.

    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {

        uint ptr;

        uint idx;



        if (needlelen <= selflen) {

            if (needlelen <= 32) {

                // Optimized assembly for 68 gas per byte on short strings

                assembly {

                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))

                    let needledata := and(mload(needleptr), mask)

                    let end := add(selfptr, sub(selflen, needlelen))

                    ptr := selfptr

                    loop:

                    jumpi(exit, eq(and(mload(ptr), mask), needledata))

                    ptr := add(ptr, 1)

                    jumpi(loop, lt(sub(ptr, 1), end))

                    ptr := add(selfptr, selflen)

                    exit:

                }

                return ptr;

            } else {

                // For long needles, use hashing

                bytes32 hash;

                assembly { hash := sha3(needleptr, needlelen) }

                ptr = selfptr;

                for (idx = 0; idx <= selflen - needlelen; idx++) {

                    bytes32 testHash;

                    assembly { testHash := sha3(ptr, needlelen) }

                    if (hash == testHash)

                        return ptr;

                    ptr += 1;

                }

            }

        }

        return selfptr + selflen;

    }



    // Returns the memory address of the first byte after the last occurrence of

    // `needle` in `self`, or the address of `self` if not found.

    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {

        uint ptr;



        if (needlelen <= selflen) {

            if (needlelen <= 32) {

                // Optimized assembly for 69 gas per byte on short strings

                assembly {

                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))

                    let needledata := and(mload(needleptr), mask)

                    ptr := add(selfptr, sub(selflen, needlelen))

                    loop:

                    jumpi(ret, eq(and(mload(ptr), mask), needledata))

                    ptr := sub(ptr, 1)

                    jumpi(loop, gt(add(ptr, 1), selfptr))

                    ptr := selfptr

                    jump(exit)

                    ret:

                    ptr := add(ptr, needlelen)

                    exit:

                }

                return ptr;

            } else {

                // For long needles, use hashing

                bytes32 hash;

                assembly { hash := sha3(needleptr, needlelen) }

                ptr = selfptr + (selflen - needlelen);

                while (ptr >= selfptr) {

                    bytes32 testHash;

                    assembly { testHash := sha3(ptr, needlelen) }

                    if (hash == testHash)

                        return ptr + needlelen;

                    ptr -= 1;

                }

            }

        }

        return selfptr;

    }



    /*

     * @dev Modifies `self` to contain everything from the first occurrence of

     *      `needle` to the end of the slice. `self` is set to the empty slice

     *      if `needle` is not found.

     * @param self The slice to search and modify.

     * @param needle The text to search for.

     * @return `self`.

     */

    function find(slice self, slice needle) internal returns (slice) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);

        self._len -= ptr - self._ptr;

        self._ptr = ptr;

        return self;

    }



    /*

     * @dev Modifies `self` to contain the part of the string from the start of

     *      `self` to the end of the first occurrence of `needle`. If `needle`

     *      is not found, `self` is set to the empty slice.

     * @param self The slice to search and modify.

     * @param needle The text to search for.

     * @return `self`.

     */

    function rfind(slice self, slice needle) internal returns (slice) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);

        self._len = ptr - self._ptr;

        return self;

    }



    /*

     * @dev Splits the slice, setting `self` to everything after the first

     *      occurrence of `needle`, and `token` to everything before it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and `token` is set to the entirety of `self`.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @param token An output parameter to which the first token is written.

     * @return `token`.

     */

    function split(slice self, slice needle, slice token) internal returns (slice) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);

        token._ptr = self._ptr;

        token._len = ptr - self._ptr;

        if (ptr == self._ptr + self._len) {

            // Not found

            self._len = 0;

        } else {

            self._len -= token._len + needle._len;

            self._ptr = ptr + needle._len;

        }

        return token;

    }



    /*

     * @dev Splits the slice, setting `self` to everything after the first

     *      occurrence of `needle`, and returning everything before it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and the entirety of `self` is returned.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @return The part of `self` up to the first occurrence of `delim`.

     */

    function split(slice self, slice needle) internal returns (slice token) {

        split(self, needle, token);

    }



    /*

     * @dev Splits the slice, setting `self` to everything before the last

     *      occurrence of `needle`, and `token` to everything after it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and `token` is set to the entirety of `self`.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @param token An output parameter to which the first token is written.

     * @return `token`.

     */

    function rsplit(slice self, slice needle, slice token) internal returns (slice) {

        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);

        token._ptr = ptr;

        token._len = self._len - (ptr - self._ptr);

        if (ptr == self._ptr) {

            // Not found

            self._len = 0;

        } else {

            self._len -= token._len + needle._len;

        }

        return token;

    }



    /*

     * @dev Splits the slice, setting `self` to everything before the last

     *      occurrence of `needle`, and returning everything after it. If

     *      `needle` does not occur in `self`, `self` is set to the empty slice,

     *      and the entirety of `self` is returned.

     * @param self The slice to split.

     * @param needle The text to search for in `self`.

     * @return The part of `self` after the last occurrence of `delim`.

     */

    function rsplit(slice self, slice needle) internal returns (slice token) {

        rsplit(self, needle, token);

    }



    /*

     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.

     * @param self The slice to search.

     * @param needle The text to search for in `self`.

     * @return The number of occurrences of `needle` found in `self`.

     */

    function count(slice self, slice needle) internal returns (uint count) {

        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;

        while (ptr <= self._ptr + self._len) {

            count++;

            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;

        }

    }



    /*

     * @dev Returns True if `self` contains `needle`.

     * @param self The slice to search.

     * @param needle The text to search for in `self`.

     * @return True if `needle` is found in `self`, false otherwise.

     */

    function contains(slice self, slice needle) internal returns (bool) {

        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;

    }



    /*

     * @dev Returns a newly allocated string containing the concatenation of

     *      `self` and `other`.

     * @param self The first slice to concatenate.

     * @param other The second slice to concatenate.

     * @return The concatenation of the two strings.

     */

    function concat(slice self, slice other) internal returns (string) {

        var ret = new string(self._len + other._len);

        uint retptr;

        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);

        memcpy(retptr + self._len, other._ptr, other._len);

        return ret;

    }



    /*

     * @dev Joins an array of slices, using `self` as a delimiter, returning a

     *      newly allocated string.

     * @param self The delimiter to use.

     * @param parts A list of slices to join.

     * @return A newly allocated string containing all the slices in `parts`,

     *         joined with `self`.

     */

    function join(slice self, slice[] parts) internal returns (string) {

        if (parts.length == 0)

            return "";



        uint len = self._len * (parts.length - 1);

        for(uint i = 0; i < parts.length; i++)

            len += parts[i]._len;



        var ret = new string(len);

        uint retptr;

        assembly { retptr := add(ret, 32) }



        for(i = 0; i < parts.length; i++) {

            memcpy(retptr, parts[i]._ptr, parts[i]._len);

            retptr += parts[i]._len;

            if (i < parts.length - 1) {

                memcpy(retptr, self._ptr, self._len);

                retptr += self._len;

            }

        }



        return ret;

    }

}



//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";



contract PowerEtherBase is Ownable {

    

    /**

     * 

     *  

     *      ╔═╗╦  ╦╔═╗╔╗╔╦╗╔═╗

     *      ║╣ ╚╗╔╝║╣ ║║║║ ╚═╗

     *      ╚═╝ ╚╝ ╚═╝╝╚╝╩ ╚═╝

     *    

     * 

     */

    

    /**

     * @dev Fired whenever a PowerEther game is won or lost.

     */

    event PowerEtherResults(

        address playerAddress,

        uint256 resultSerialNumber,

        uint256 gameType,           // 1 - PowerOne, 2 - PowerTwo, 4 - PowerFour

        uint256 powerNumberOne,

        uint256 powerNumberTwo,

        uint256 powerNumberThree,

        uint256 powerNumberFour,

        uint256 jackpot,

        bool isGameWon,

        bool isMegaJackpotWon

        );

    

    /**

     * @dev Fired, whenever a MegaJackpot is won via reached cap.

     */

    event MegaJackpotCapWin(

        address playerAddress,

        uint256 megaJackpot

        );

    

    /**

     * @dev Fired, whenever a refund is initiated.

     */

    event Refund(

        address playerAddress,

        uint256 gameType

        );

    

    /**

     * @dev Fired to log the Oraclize query.

     */

    event LogQuery(

        address playerAddress,  

        uint256 gameType,           // 1 - PowerOne, 2 - PowerTwo, 4 - PowerFour

        uint256 randomQueryId,

        uint256 powerNumberOne,

        uint256 powerNumberTwo,

        uint256 powerNumberThree,

        uint256 powerNumberFour

        );

        

    /**

     * @dev Fired whenever ether is manually added to the balance by the CEO.

     */

    event balanceUpdated(

        uint256 _amount

        );

        

    /**

     *

     * 

     *      ╦  ╦╔═╗╦═╗╦╔═╗╔╗ ╦  ╔═╗╔═╗

     *      ╚╗╔╝╠═╣╠╦╝║╠═╣╠╩╗║  ║╣ ╚═╗

     *       ╚╝ ╩ ╩╩╚═╩╩ ╩╚═╝╩═╝╚═╝╚═╝

     *

     * 

     */

    

    /// Public constants for PromiseCoin contract.

    string public constant NAME = "PowerEther";

    

    /// The bid amount for PowerOne game.

    uint256 public powerOneBid = 0.03 ether;

    

    /// The fee amount for PowerOne game.

    uint256 public powerOneFee = 0.01 ether;

    

    /// The bid amount for PowerTwo game.

    uint256 public powerTwoBid = 0.02 ether;

    

    /// The fee amount for PowerTwo game.

    uint256 public powerTwoFee = 0.01 ether;

    

    /// The bid amount for PowerFour game.

    uint256 public powerFourBid = 0.01 ether;

    

    /// The fee amount for PowerTwo game.

    uint256 public powerFourFee = 0.01 ether;

    

    /// The jackpot of PowerOne game.

    uint256 public powerOneJackpot = 0 ether;

    

    /// The jackpot of PowerTwo game.

    uint256 public powerTwoJackpot = 0 ether;

    

    /// The jackpot of PowerFour game.

    uint256 public powerFourJackpot = 0 ether;

    

    /// The MegaJackpot that is won whenever a PowerFour game has been won.

    uint256 public megaJackpot = 0 ether;

    

    /// The MegaJackpot that is won whenever a PowerFour game has been won.

    uint256 public megaJackpotFee = 0.01 ether;

    

    /**

     * @dev Sets the hard cap of the MegaJackpot. Once reached, the MegaJackpot

     * is split among the last 1000 players.

     */

    uint256 public megaJackpotCap = 100 ether;

    

    /// Counts MegaJacpot wins.

    uint256 public megaJackpotWinCount = 0;

    

    /// The counter for PowerOne game.

    uint256 public powerOneWinCounter = 0;

    

    /// The counter for PowerTwo game.

    uint256 public powerTwoWinCounter = 0;

    

    /// The counter for PowerFour game.

    uint256 public powerFourWinCounter = 0;



    /// @dev The CEO address to transfer the cut.

    address public ceoAddress;

    

    /// @dev The platform cut (as denumenator in the calculation equation).

    uint256 public platformCut = 95;

    

    /// @dev Counts uncollected fees for PowerOne.

    uint256 public powerOneFeesToCollect;

    

    /// @dev Counts uncollected fees for PowerTwo.

    uint256 public powerTwoFeesToCollect;

    

    /// @dev Counts uncollected fees for PowerFour.

    uint256 public powerFourFeesToCollect;

    

    /// @dev Contract activation switch.

    bool public activated_ = false;

    

    /// @dev Sanity check for maximum and minimum inputs.

    uint256 public minNumber;

    uint256 public maxNumber;

    

    /// @dev Gas for Oraclize.

    uint32 public gasForOraclize;

    

    /// @dev Oraclize random Query ID counter.

    uint256 public randomQueryId;



    /// @dev Stats - total Ether won.

    uint256 public totalEtherWon;



    /// @dev Stats - total games played.

    uint256 public totalGamesPlayed;

    

    /// @dev A mapping form a queryId to the player's address.

    mapping (bytes32 => address) senderAddresses;

    

    /// @dev A mapping form a queryId to the game type.

    mapping (bytes32 => uint256) gameTypes;

    

    /// @dev A mapping form a queryId to the first Power Number.

    mapping (bytes32 => uint256) powerNumberOne;

    

    /// @dev A mapping form a queryId to the second Power Number.

    mapping (bytes32 => uint256) powerNumberTwo;

    

    /// @dev A mapping form a queryId to the third Power Number.

    mapping (bytes32 => uint256) powerNumberThree;

    

    /// @dev A mapping form a queryId to the fourth Power Number.

    mapping (bytes32 => uint256) powerNumberFour;

    

    /// @dev A mapping from the player address to the pending withdrawal amount.

    mapping (address => uint256) playerFundsToWithdraw;

    

    /**

     *

     * 

     *      ╔╦╗╔═╗╔╦╗╦╔═╗╦╔═╗╦═╗╔═╗

     *      ║║║║ ║ ║║║╠╣ ║║╣ ╠╦╝╚═╗

     *      ╩ ╩╚═╝═╩╝╩╚  ╩╚═╝╩╚═╚═╝

     *

     * 

     */



    /// @dev Access only to the CEO-functionality.

    modifier onlyCEO() {

        require(msg.sender == ceoAddress, "This action is available only to the current CEO");

        _;

    }

    

    /// @dev Checks for contract activation.

    modifier isActivated() {

        require(activated_ == true, "The contract is inactive");

        _;

    }

    

    /// @dev Sanity check for incoming transactions

    modifier isWithinLimits(uint256 _eth) {

        require(_eth >= 1000000000, "Too little");

        require(_eth <= 100000000000000000000000, "Woah! Too much!");

        _;    

    }

    

    /// @dev Checks for human interaction

    modifier isHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;

        

        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "This contract can interact only with humans");

        _;

    }

    

}



contract PowerEtherHelper is PowerEtherBase {

    

    using SafeMath for *;

    using strings for *;

    

    /**

     *

     * 

     *      ╦ ╦╔═╗╦  ╔═╗╔═╗╦═╗  ╔═╗╦ ╦╔╗╔╔═╗╔╦╗╦╔═╗╔╗╔╔═╗

     *      ╠═╣║╣ ║  ╠═╝║╣ ╠╦╝  ╠╣ ║ ║║║║║   ║ ║║ ║║║║╚═╗

     *      ╩ ╩╚═╝╩═╝╩  ╚═╝╩╚═  ╚  ╚═╝╝╚╝╚═╝ ╩ ╩╚═╝╝╚╝╚═╝

     *

     * 

     */

    

    /**

     * @dev Activates the contract.

     */

    function activate() 

        external 

        onlyCEO {

            

            require(msg.sender != address(0));

        

            activated_ = !activated_;

        }

    

    /**

     * @dev Deactivates the contract.

     */    

    function deactivate() 

        external 

        onlyCEO {

            

            require(msg.sender != address(0));

        

            activated_ = false;

        }

    

    /**

     * @dev Sets the new CEO address. Only available to the current CFO. 

     */

    function setCEO(address _newCEO) 

        external 

        onlyCEO 

        isHuman {

            

            require(_newCEO != address(0));



            ceoAddress = _newCEO;

        }

    

    /**

     * @dev Sets the Bid price for the PowerOne game. Only available to the 

     * current CEO. 

     */

    function setPowerOneBidPrice(uint256 _newBid) 

        external 

        onlyCEO 

        isHuman 

        isWithinLimits(_newBid) {

            

            powerOneBid = _newBid;

        }

    

    /**

     * @dev Sets the Fee price for the PowerOne game. Only available to the

     * current CEO. 

     */

    function setPowerOneFeePrice(uint256 _newFee) 

        external 

        onlyCEO 

        isHuman 

        isWithinLimits(_newFee) {

            

            powerOneFee = _newFee;

        }

    

    /**

     * @dev Sets the Bid price for the PowerTwo game. Only available to the 

     * current CEO. 

     */

    function setPowerTwoBidPrice(uint256 _newBid) 

        external 

        onlyCEO 

        isHuman 

        isWithinLimits(_newBid) {

            

            powerTwoBid = _newBid;

        }

    

    /**

     * @dev Sets the Fee price for the PowerTwo game. Only available to the

     * current CEO. 

     */

    function setPowerTwoFeePrice(uint256 _newFee) 

        external 

        onlyCEO 

        isHuman 

        isWithinLimits(_newFee) {

            

            powerTwoFee = _newFee;

        }

    

    /**

     * @dev Sets the Bid price for the PowerFour game. Only available to the 

     * current CEO. 

     */

    function setPowerFourBidPrice(uint256 _newBid) 

        external 

        onlyCEO 

        isHuman 

        isWithinLimits(_newBid) {

            

            powerFourBid = _newBid;

        }

    

    /**

     * @dev Sets the Fee price for the PowerFour game. Only available to the

     * current CEO. 

     */

    function setPowerFourFeePrice(uint256 _newFee) 

        external 

        onlyCEO 

        isHuman 

        isWithinLimits(_newFee) {

            

            powerFourFee = _newFee;

        }

    

    /**

     * @dev Sets the platform cut denumenator percentage. 

     * Only available to the current CEO. 

     */

    function setPlatformCut(uint256 _newPlatformCut)

        external

        onlyCEO

        isHuman {

            

            platformCut = _newPlatformCut;

            

        }

    

    /**

     * @dev Sets the new limit for the megaJackpotCap. Only available to the

     * current CEO.

     */

    function setMegaJackpotCap(uint256 _newCap)

        external

        onlyCEO

        isHuman {

            

            megaJackpotCap = _newCap;

            

        }

        

    /**

     * @dev Sets the new MegaJackpot fee.

     */

    function setMegaJackpotFee(uint256 _newMegaJackpotFee)

        external

        onlyCEO

        isHuman {

            

            megaJackpotFee = _newMegaJackpotFee;

            

        }

        

    /**

     * @dev Sets the gas limit for Oraclize Query.

     */

    function setGasForOraclize(uint32 _newGasLimit)

        external

        onlyCEO

        isHuman {

            

            gasForOraclize = _newGasLimit;

            

        }

        

    /**

     * @dev Sets the new minNumber.

     */

    function setMinNumber(uint256 _newMinNumber)

        external

        onlyCEO

        isHuman {

            

            minNumber = _newMinNumber;

            

        }

    

    /**

     * @dev Sets the new maxNumber.

     */

    function setMaxNumber(uint256 _newMaxNumber)

        external

        onlyCEO

        isHuman {

            

            maxNumber = _newMaxNumber;

            

        }

    

    /**

     * @dev Internal function to check the PowerNumbers of PowerTwo Game.

     */

    function _checkTwo(

        uint256 _resultNumberOne,

        uint256 _resultNumberTwo,

        uint256 _powerNumberOne,

        uint256 _powerNumberTwo

        ) 

        internal 

        returns (bool) {

            if ((_resultNumberOne == _powerNumberOne ||

                _resultNumberOne == _powerNumberTwo) &&

                (_resultNumberTwo == _powerNumberOne ||

                _resultNumberTwo == _powerNumberTwo)

                ) {

                    return (true);

                } else {

                    return (false);

                }

        }

    

    /**

     * @dev Internal function to check the PowerNumbers of PowerFour Game.

     */

    function _checkFour(

        uint256 _resultNumberOne,

        uint256 _resultNumberTwo,

        uint256 _resultNumberThree,

        uint256 _resultNumberFour,

        uint256 _powerNumberOne,

        uint256 _powerNumberTwo,

        uint256 _powerNumberThree,

        uint256 _powerNumberFour

        )

        internal

        returns (bool) {

            if ((_resultNumberOne == _powerNumberOne ||

                _resultNumberOne == _powerNumberTwo ||

                _resultNumberOne == _powerNumberThree ||

                _resultNumberOne == _powerNumberFour) &&

                (_resultNumberTwo == _powerNumberOne ||

                _resultNumberTwo == _powerNumberTwo ||

                _resultNumberTwo == _powerNumberThree ||

                _resultNumberTwo == _powerNumberFour) &&

                (_resultNumberThree == _powerNumberOne ||

                _resultNumberThree == _powerNumberTwo ||

                _resultNumberThree == _powerNumberThree ||

                _resultNumberThree == _powerNumberFour) &&

                (_resultNumberFour == _powerNumberOne ||

                _resultNumberFour == _powerNumberTwo ||

                _resultNumberFour == _powerNumberThree ||

                _resultNumberFour == _powerNumberFour)) {

                    return true;

                } else {

                    return false;

                }

        }

        

    /**

     * @dev Collects the fees for transactions. Only available to the current

     * CEO.

     */

    function collectFees()

        external

        onlyCEO

        isHuman {

            

            uint256 powerOnePayouts = SafeMath.mul(powerOneFee, powerOneFeesToCollect);

            uint256 powerTwoPayouts = SafeMath.mul(powerTwoFee, powerTwoFeesToCollect);

            uint256 powerFourPayouts = SafeMath.mul(powerFourFee, powerFourFeesToCollect);

            

            uint256 totalOneTwo = SafeMath.add(powerOnePayouts, powerTwoPayouts);

            uint256 totalAll = SafeMath.add(totalOneTwo, powerFourPayouts);

            

            require(totalAll <= address(this).balance, "Insufficient funds!");

            

            ceoAddress.transfer(totalAll);

            

            // reset the counters

            powerOneFeesToCollect = 0;

            powerTwoFeesToCollect = 0;

            powerFourFeesToCollect = 0;

            

        }

    

    /**

     * @dev Checks whether the MegaJackpotCap has been reached. If so,

     * transfers the MegaJackpot to the current player.

     */

    function _checkMegaJackpotCap(address playerAddress) 

        internal

        returns (bool) {

            

        // Checking for the MegaJackpotCap.

        if (megaJackpot >= megaJackpotCap) {

                    

        require(megaJackpot <= address(this).balance, "Insufficient funds!");

                    

        uint256 megaJackpotPayout = SafeMath.div(SafeMath.mul(megaJackpot, platformCut), 100);

        uint256 platformMegaCutPayout = SafeMath.sub(megaJackpot, megaJackpotPayout);

                        

        emit MegaJackpotCapWin(

            playerAddress,

            megaJackpotPayout

        );

                    

        playerAddress.transfer(megaJackpotPayout);

        ceoAddress.transfer(platformMegaCutPayout);

                    

        megaJackpot = 0;

        megaJackpotWinCount ++;



        totalEtherWon += megaJackpotPayout;



        return true;

                    

        }

        return false;

    }

    

    /**

     * @dev Updates the contract balance. Only available to the current CEO. 

     */

    function updateBalance(uint256 etherToAdd)

        public

        payable

        onlyCEO {

        

            emit balanceUpdated(etherToAdd);

        

        }

    

    /**

     * @dev Updates the PowerOne balance. Only available to the current CEO. 

     */

    function updatePowerOneBalance(uint256 etherToAdd)

        public

        payable

        onlyCEO {

            

            powerOneJackpot += etherToAdd;

            emit balanceUpdated(etherToAdd);

        

        }

    

    /**

     * @dev Updates the PowerTwo balance. Only available to the current CEO. 

     */

    function updatePowerTwoBalance(uint256 etherToAdd)

        public

        payable

        onlyCEO {

            

            powerTwoJackpot += etherToAdd;

            emit balanceUpdated(etherToAdd);

        

        }

    

    /**

     * @dev Updates the PowerFour balance. Only available to the current CEO. 

     */

    function updatePowerFourBalance(uint256 etherToAdd)

        public

        payable

        onlyCEO {

            

            powerFourJackpot += etherToAdd;

            emit balanceUpdated(etherToAdd);

        

        }

    

    /**

     * @dev Player manually withdraws funds if there was a transaction error.

     */

    function withdrawPendingTransactions() 

        public 

        isHuman

        isActivated

        returns (bool) {

            

            uint256 amount = playerFundsToWithdraw[msg.sender];

            

            playerFundsToWithdraw[msg.sender] = 0;

        

            if (msg.sender.call.value(amount)()) {

                

                return true;

                

            } else {

            

            // Can try to refund later if goes wrong.

            playerFundsToWithdraw[msg.sender] = amount;

            

            return false;

        }

    }

    

    /**

     * @dev Checks for the pending withdrawals.

     */



    function getPendingTransactions(address playerAddress) 

        public 

        constant 

        returns (uint256) {

            

            return playerFundsToWithdraw[playerAddress];

        }

    

}





contract PowerOne is PowerEtherHelper, usingOraclize {

    

    /// @dev checks only Oraclize address is calling

    modifier onlyOraclize {

        require(msg.sender == oraclize_cbAddress());

        _;

    }

    

    /**

     * @dev Makes the bid to the PowerOne game.

     */

    function makePowerOneBid(uint256 numberOne)

        public

        payable

        isHuman

        isActivated {

            

            require(numberOne >= minNumber && numberOne <= maxNumber, "The number chosen is invalid!");

            

            uint256 payment = SafeMath.add(powerOneBid, powerOneFee);

            uint256 totalPayment = SafeMath.add(payment, megaJackpotFee);

            

            require(msg.value == totalPayment, "Wrong payment value!");

            

            randomQueryId += 1;

            

            powerOneFeesToCollect ++;

            

            // Compose the Oraclize query

            string memory queryStringOne = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":\"${[decrypt] BEna2ojyJ8x3euQmExkugHrukwYeMH2Z7o3e9XEqATmN1ApOokRElT5IJEp1JNFhbn3dvdEo3wLaDaZJu5PqRUaoI4ZnbDTwAmMtkfLP1jBD7OldcYReDzG4cc5tdjCdP2KbzhIOEuXskoW3PzkqHzGq641e}\",\"n\":1,\"min\":1,\"max\":10,\"replacement\":false,\"base\":10${[identity] \"}\"},\"id\":";

            string memory queryStringTwo = uint2str(randomQueryId);

            string memory queryStringThree = "${[identity] \"}\"}']";

            

            string memory queryStringOne_Two = queryStringOne.toSlice().concat(queryStringTwo.toSlice());

            string memory queryStringOne_Two_Three = queryStringOne_Two.toSlice().concat(queryStringThree.toSlice());

            

            bytes32 queryId = oraclize_query("nested", queryStringOne_Two_Three, gasForOraclize);

            

            senderAddresses[queryId] = msg.sender;

            

            gameTypes[queryId] = 1;

            

            powerNumberOne[queryId] = numberOne;

            

            powerOneJackpot += powerOneBid;

            

            megaJackpot += megaJackpotFee;



            totalGamesPlayed ++;

            

            emit LogQuery(

                msg.sender,

                1,

                randomQueryId,

                numberOne,

                0,

                0,

                0

                );

                

        }

    

    /**

     * @dev Internal core logic of the PowerOne game

     */

    function _powerOne(

        string result,

        uint256 pnOne,

        address playerAddress

        ) internal {

        // Sanity check

        require(pnOne != 0, "Invalid game, refunded!");

                

        require(powerOneJackpot <= address(this).balance, "Insufficient funds!");

                

        strings.slice memory res = result.toSlice();

        strings.slice memory delim = " ".toSlice();

        uint256[] memory parts = new uint256[](res.count(delim) + 1);

        for (uint256 i = 0; i < parts.length; i ++) {

            parts[i] = parseInt(res.split(delim).toString());

        }

                

        // Refunding if the result is 0 or no proof is provided.       

        if (bytes(result).length == 0) {

                    

            emit Refund(

                playerAddress,

                1

                );

                

            if (!playerAddress.send(SafeMath.add(powerOneBid, powerOneFee))) {

                

                playerFundsToWithdraw[playerAddress] = SafeMath.add(powerOneBid, powerOneFee);                     

            }

                    

            playerAddress = 0x0;

                    

            return;

                    

        }

                

        if (parts[1] == pnOne) {

                    

            if(_checkMegaJackpotCap(playerAddress)) {

                bool checkResult = true;

            } else {

                checkResult = false;

            }

                       

            powerOneWinCounter ++;

                    

            // Calculating the eligible payout

            uint256 eligiblePayout = SafeMath.div(SafeMath.mul(powerOneJackpot, platformCut), 100);

            uint256 platformCutPayout = SafeMath.sub(powerOneJackpot, eligiblePayout);

                    

            playerAddress.transfer(eligiblePayout);

                    

            ceoAddress.transfer(platformCutPayout);



            emit PowerEtherResults(

                playerAddress,

                parts[0],

                1,

                pnOne,

                0,

                0,

                0,

                eligiblePayout,

                true,

                checkResult

                );



            totalEtherWon += eligiblePayout;

                    

            powerOneJackpot = 0;

                    

            playerAddress = 0x0;            



        } else if (parts[1] != pnOne) {

                    

            emit PowerEtherResults(

                playerAddress,

                parts[0],

                1,

                pnOne,

                0,

                0,

                0,

                eligiblePayout,

                false,

                false

                );

                    

            playerAddress = 0x0;



        }

        

    }

    

}



contract PowerTwo is PowerOne {

    

    /**

     * @dev Makes the bid to the PowerTwo game.

     */

    function makePowerTwoBid(

        uint256 numberOne,

        uint256 numberTwo

        )

        public

        payable

        isHuman

        isActivated {

            

            require(numberOne >= minNumber && numberOne <= maxNumber, "The first  number chosen is invalid!");

            require(numberTwo >= minNumber && numberTwo <= maxNumber, "The second number chosen is invalid!");

            

            uint256 payment = SafeMath.add(powerTwoBid, powerTwoFee);

            uint256 totalPayment = SafeMath.add(payment, megaJackpotFee);

            

            require(msg.value == totalPayment, "Wrong payment value!");

            

            randomQueryId += 1;

            

            powerTwoFeesToCollect ++;

            

            // Compose the Oraclize query

            string memory queryStringOne = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":\"${[decrypt] BEna2ojyJ8x3euQmExkugHrukwYeMH2Z7o3e9XEqATmN1ApOokRElT5IJEp1JNFhbn3dvdEo3wLaDaZJu5PqRUaoI4ZnbDTwAmMtkfLP1jBD7OldcYReDzG4cc5tdjCdP2KbzhIOEuXskoW3PzkqHzGq641e}\",\"n\":2,\"min\":1,\"max\":10,\"replacement\":false,\"base\":10${[identity] \"}\"},\"id\":";

            string memory queryStringTwo = uint2str(randomQueryId);

            string memory queryStringThree = "${[identity] \"}\"}']";

            

            string memory queryStringOne_Two = queryStringOne.toSlice().concat(queryStringTwo.toSlice());

            string memory queryStringOne_Two_Three = queryStringOne_Two.toSlice().concat(queryStringThree.toSlice());

            

            bytes32 queryId = oraclize_query("nested", queryStringOne_Two_Three, gasForOraclize);

            

            senderAddresses[queryId] = msg.sender;

            

            gameTypes[queryId] = 2;

            

            powerNumberOne[queryId] = numberOne;

            powerNumberTwo[queryId] = numberTwo;

            

            powerTwoJackpot += powerTwoBid;

            

            megaJackpot += megaJackpotFee;



            totalGamesPlayed ++;

            

            emit LogQuery(

                msg.sender,

                2,

                randomQueryId,

                numberOne,

                numberTwo,

                0,

                0

                );

                

        }

    

    /**

     * @dev Internal core logic of the PowerTwo game

     */

    function _powerTwo(

        string result,

        uint256 pnOne,

        uint256 pnTwo,

        address playerAddress

        ) internal {

            

        // Sanity check

        require(pnOne != 0, "Invalid game, refunded!");

        require(pnTwo != 0, "Invalid game, refunded!");

                

        require(powerTwoJackpot <= address(this).balance, "Insufficient funds!");

                

        strings.slice memory res = result.toSlice();

        strings.slice memory delim = " ".toSlice();

        uint256[] memory parts = new uint256[](res.count(delim) + 1);

        for (uint256 i = 0; i < parts.length; i ++) {

            parts[i] = parseInt(res.split(delim).toString());

        }

                

        // Refunding if the result is 0 or no proof is provided.

        if (bytes(result).length == 0) {

                    

            emit Refund(

                playerAddress,

                1

                );

                

            if (!playerAddress.send(SafeMath.add(powerTwoBid, powerTwoFee))) {

                

                playerFundsToWithdraw[playerAddress] = SafeMath.add(powerTwoBid, powerTwoFee);                     

            }

                    

            playerAddress = 0x0;

                    

            return;

                    

        }

                

        if (_checkTwo(

            parts[1],

            parts[2],

            pnOne,

            pnTwo)) {

                        

            if(_checkMegaJackpotCap(playerAddress)) {

                bool checkResult = true;

            } else {

                checkResult = false;

            }

                    

            powerTwoWinCounter ++;

                    

            // Calculating the eligible payout

            uint256 eligiblePayout = SafeMath.div(SafeMath.mul(powerTwoJackpot, platformCut), 100);

            uint256 platformCutPayout = SafeMath.sub(powerTwoJackpot, eligiblePayout);

                    

            playerAddress.transfer(SafeMath.div(SafeMath.mul(powerTwoJackpot, platformCut), 100));

                    

            ceoAddress.transfer(platformCutPayout);



            emit PowerEtherResults(

                playerAddress,

                parts[0],

                2,

                pnOne,

                pnTwo,

                0,

                0,

                eligiblePayout,

                true,

                checkResult

                );



            totalEtherWon += eligiblePayout;

                    

            powerTwoJackpot = 0;

                        

            playerAddress = 0x0;



        } else if (!_checkTwo(

            parts[1],

            parts[2],

            pnOne,

            pnTwo)) {

                    

            emit PowerEtherResults(

                playerAddress,

                parts[0],

                2,

                pnOne,

                pnTwo,

                0,

                0,

                eligiblePayout,

                false,

                false

                );

                    

            playerAddress = 0x0;



        }

        

    }

    

}





contract PowerFour is PowerTwo {

    

    /**

     * @dev Makes the bid to the PowerFour game.

     */

    function makePowerFourBid(

        uint256 numberOne,

        uint256 numberTwo,

        uint256 numberThree,

        uint256 numberFour

        )

        public

        payable

        isHuman

        isActivated {

            

            require(numberOne >= minNumber && numberOne <= maxNumber, "The first number chosen is invalid!");

            require(numberTwo >= minNumber && numberTwo <= maxNumber, "The second number chosen is invalid!");

            require(numberThree >= minNumber && numberThree <= maxNumber, "The third number chosen is invalid!");

            require(numberFour >= minNumber && numberFour <= maxNumber, "The fourth chosen is invalid!");

            

            uint256 payment = SafeMath.add(powerFourBid, powerFourFee);

            uint256 totalPayment = SafeMath.add(payment, megaJackpotFee);

            

            require(msg.value == totalPayment, "Wrong payment value!");

            

            randomQueryId += 1;

            

            powerFourFeesToCollect ++;

            

            // Compose the Oraclize query

            string memory queryStringOne = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":\"${[decrypt] BEna2ojyJ8x3euQmExkugHrukwYeMH2Z7o3e9XEqATmN1ApOokRElT5IJEp1JNFhbn3dvdEo3wLaDaZJu5PqRUaoI4ZnbDTwAmMtkfLP1jBD7OldcYReDzG4cc5tdjCdP2KbzhIOEuXskoW3PzkqHzGq641e}\",\"n\":4,\"min\":1,\"max\":10,\"replacement\":false,\"base\":10${[identity] \"}\"},\"id\":";

            string memory queryStringTwo = uint2str(randomQueryId);

            string memory queryStringThree = "${[identity] \"}\"}']";

            

            string memory queryStringOne_Two = queryStringOne.toSlice().concat(queryStringTwo.toSlice());

            string memory queryStringOne_Two_Three = queryStringOne_Two.toSlice().concat(queryStringThree.toSlice());

            

            bytes32 queryId = oraclize_query("nested", queryStringOne_Two_Three, gasForOraclize);

            

            senderAddresses[queryId] = msg.sender;

            

            gameTypes[queryId] = 4;

            

            powerNumberOne[queryId] = numberOne;

            powerNumberTwo[queryId] = numberTwo;

            powerNumberThree[queryId] = numberThree;

            powerNumberFour[queryId] = numberFour;

            

            powerFourJackpot += powerFourBid;

            

            megaJackpot += megaJackpotFee;



            totalGamesPlayed ++;

                

        }

        

    /**

     * @dev Internal core logic of the PowerFour game

     */

    

    function _powerFour(

        string result,

        uint256 pnOne,

        uint256 pnTwo,

        uint256 pnThree,

        uint256 pnFour,

        address playerAddress

        ) internal {

            

        // Sanity check

        require(pnOne != 0, "Invalid game, refunded!");

        require(pnTwo != 0, "Invalid game, refunded!");

        require(pnThree != 0, "Invalid game, refunded!");

        require(pnFour != 0, "Invalid game, refunded!");

                

        require(powerFourJackpot <= address(this).balance, "Insufficient funds!");

                

        strings.slice memory res = result.toSlice();

        strings.slice memory delim = " ".toSlice();

        uint256[] memory parts = new uint256[](res.count(delim) + 1);

        for (uint256 i = 0; i < parts.length; i ++) {

            parts[i] = parseInt(res.split(delim).toString());

        }

                

        // Refunding if the result is 0 or no proof is provided.

        if (bytes(result).length == 0) {

                      

            emit Refund(

                playerAddress,

                1

                );

                

            if (!playerAddress.send(SafeMath.add(powerFourBid, powerFourFee))) {

                

                playerFundsToWithdraw[playerAddress] = SafeMath.add(powerFourBid, powerFourFee);                  

            }

                    

            playerAddress = 0x0;

                    

            return;

                    

        }

                

        if (_checkFour(

            parts[1],

            parts[2],

            parts[3],

            parts[4],

            pnOne,

            pnTwo,

            pnThree,

            pnFour)) {

                        

            _checkMegaJackpotCap(playerAddress);

                    

            // Calculating the eligible payout

            uint256 eligiblePayout = SafeMath.div(SafeMath.mul(powerFourJackpot, platformCut), 100);

            uint256 platformCutPayout = SafeMath.sub(powerFourJackpot, eligiblePayout);

                    

            playerAddress.transfer(eligiblePayout);

                    

            // Transfering the MegaJackpot to the winner

            playerAddress.transfer(megaJackpot);

                    

            ceoAddress.transfer(platformCutPayout);



            emit PowerEtherResults(

                playerAddress,

                parts[0],

                4,

                pnOne,

                pnTwo,

                pnThree,

                pnFour,

                eligiblePayout,

                true,

                true

                );



            totalEtherWon += eligiblePayout;

                    

            powerFourWinCounter ++;

                    

            megaJackpot = 0;

                    

            powerFourJackpot = 0;

                    

            playerAddress = 0x0;



        } else if (!_checkFour(

            parts[1],

            parts[2],

            parts[3],

            parts[4],

            pnOne,

            pnTwo,

            pnThree,

            pnFour)) {

                        

            emit PowerEtherResults(

                playerAddress,

                parts[0],

                4,

                pnOne,

                pnTwo,

                pnThree,

                pnFour,

                eligiblePayout,

                false,

                false

                );



            playerAddress = 0x0;



        }

        

    }

    

}





contract PowerEther is PowerFour {

    

    /**

     * 

     *    _______ _            ____  _            _    _____  _                                  

     *   |__   __| |          |  _ \| |          | |  |  __ \| |                           

     *      | |  | |__   ___  | |_) | | ___   ___| | _| |__) | | __ _ _   _     

     *      | |  | '_ \ / _ \ |  _ <| |/ _ \ / __| |/ /  ___/| |/ _` | | | |    

     *      | |  | | | |  __/ | |_) | | (_) | (__|   <| |    | | (_| | |_| |    

     *      |_|  |_| |_|\___| |____/|_|\___/ \___|_|\_\_|    |_|\__,_|\__, |    

     *                                                                 __/ |                            

     *                                                                |___/                             

     *                      

     *                                ╔═╗╦═╗╔═╗╦ ╦╔╦╗╦ ╦ ╦   

     *                                ╠═╝╠╦╝║ ║║ ║ ║║║ ╚╦╝   

     *                                ╩  ╩╚═╚═╝╚═╝═╩╝╩═╝╩    

     *                              ╔═╗╦═╗╔═╗╔═╗╔═╗╔╗╔╦╗╔═╗

     *                              ╠═╝╠╦╝║╣ ╚═╗║╣ ║║║║ ╚═╗

     *                              ╩  ╩╚═╚═╝╚═╝╚═╝╝╚╝╩ ╚═╝

     * 

     *

     * 

     *  

     *  ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███████╗████████╗██╗  ██╗███████╗██████╗ 

     *  ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝╚══██╔══╝██║  ██║██╔════╝██╔══██╗

     *  ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝█████╗     ██║   ███████║█████╗  ██████╔╝

     *  ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██╔══╝     ██║   ██╔══██║██╔══╝  ██╔══██╗

     *  ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║███████╗   ██║   ██║  ██║███████╗██║  ██║

     *  ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

     *                                                                              

     *

     * 

     * 

     * PowerEther is the first honest Ethereum lottery based on PowerBall

     * mechanics. There are three types of games: PowerOne - guess one number,

     * PowerTwo - guess two numbers, and PowerFour - guess four numbers.

     * 

     * The rules are simple: if the player does not win the round, the bid is

     * added to the balance of that certain game type. If the game is won, the

     * player gets all the balance of that certain game.

     * 

     * Every time a player loses, a small amount is transferred to the

     * MegaJackpot. the MegaJackpot is won either whenever a PowerFour game is

     * won, or when the hard cap has been reached. If the cap

     * has been reached, the first winner of ANY game gets the MegaJacpot!

     * 

     * Play PowerEther and win TONS of Ether!

     * 

     * 

     * 

     */

     

    /**

     * 

     *

     *      ╔═╗╔═╗╔╗╔╔═╗╔╦╗╦═╗╦ ╦╔═╗╔╦╗╔═╗╦═╗

     *      ║  ║ ║║║║╚═╗ ║ ╠╦╝║ ║║   ║ ║ ║╠╦╝

     *      ╚═╝╚═╝╝╚╝╚═╝ ╩ ╩╚═╚═╝╚═╝ ╩ ╚═╝╩╚═

     *

     * 

     */

     

    constructor() public {

        

        /// Activating the contract.

        activated_ = true;

        

        /// Setting the initial address of the CEO.

        ceoAddress = msg.sender;

        

        /// Setting the gas amount for Oraclize.

        gasForOraclize = 335000;

        

        /// Setting the initial value for the randomQueryId

        randomQueryId = 777;

        

        /// Sets the min and max numbers.

        minNumber = 1;

        maxNumber = 10;

        

    }

    

    /**

     * @dev The Oraclize callback function.

     */

    

    function __callback(

        bytes32 myid, 

        string result) 

        public   

		onlyOraclize

		isActivated {



            require(senderAddresses[myid] != address(0), "Wrong player address!");

            

            if (gameTypes[myid] == 1) {

                

                _powerOne(result, powerNumberOne[myid], senderAddresses[myid]);

                

            } else if (gameTypes[myid] == 2) {

                

                _powerTwo(result, powerNumberOne[myid], powerNumberTwo[myid], senderAddresses[myid]);

                

            } else if (gameTypes[myid] == 4) {



                _powerFour(result, powerNumberOne[myid], powerNumberTwo[myid], powerNumberThree[myid], powerNumberFour[myid], senderAddresses[myid]);

                    

        }

        

    }

    

}