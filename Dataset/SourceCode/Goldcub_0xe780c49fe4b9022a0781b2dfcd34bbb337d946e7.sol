/**

 *Submitted for verification at Etherscan.io on 2018-01-19

*/



pragma solidity 0.4.19;

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



pragma solidity ^0.4.0;//please import oraclizeAPI_pre0.4.sol when solidity < 0.4.0



contract OraclizeI {

    address public cbAddress;

    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);

    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);

    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);

    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);

    function queryN(uint _timestamp, string _datasource, bytes _argN) payable returns (bytes32 _id);

    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);

    function getPrice(string _datasource) returns (uint _dsprice);

    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);

    function useCoupon(string _coupon);

    function setProofType(byte _proofType);

    function setConfig(bytes32 _config);

    function setCustomGasPrice(uint _gasPrice);

    function randomDS_getSessionPubKeyHash() returns(bytes32);

}

contract OraclizeAddrResolverI {

    function getAddress() returns (address _addr);

}

contract usingOraclize {

    uint constant day = 60*60*24;

    uint constant week = 60*60*24*7;

    uint constant month = 60*60*24*30;

    byte constant proofType_NONE = 0x00;

    byte constant proofType_TLSNotary = 0x10;

    byte constant proofType_Android = 0x20;

    byte constant proofType_Ledger = 0x30;

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

        if((address(OAR)==0)||(getCodeSize(address(OAR))==0)) oraclize_setNetwork(networkID_auto);

        oraclize = OraclizeI(OAR.getAddress());

        _;

    }

    modifier coupon(string code){

        oraclize = OraclizeI(OAR.getAddress());

        oraclize.useCoupon(code);

        _;

    }



    function oraclize_setNetwork(uint8 networkID) internal returns(bool){

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



    function __callback(bytes32 myid, string result) {

        __callback(myid, result, new bytes(0));

    }

    function __callback(bytes32 myid, string result, bytes proof) {

    }

    

    function oraclize_useCoupon(string code) oraclizeAPI internal {

        oraclize.useCoupon(code);

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

    function oraclize_setConfig(bytes32 config) oraclizeAPI internal {

        return oraclize.setConfig(config);

    }

    

    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){

        return oraclize.randomDS_getSessionPubKeyHash();

    }



    function getCodeSize(address _addr) constant internal returns(uint _size) {

        assembly {

            _size := extcodesize(_addr)

        }

    }



    function parseAddr(string _a) internal returns (address){

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



    function strCompare(string _a, string _b) internal returns (int) {

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



    function indexOf(string _haystack, string _needle) internal returns (int) {

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



    function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns (string) {

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



    function strConcat(string _a, string _b, string _c, string _d) internal returns (string) {

        return strConcat(_a, _b, _c, _d, "");

    }



    function strConcat(string _a, string _b, string _c) internal returns (string) {

        return strConcat(_a, _b, _c, "", "");

    }



    function strConcat(string _a, string _b) internal returns (string) {

        return strConcat(_a, _b, "", "", "");

    }



    // parseInt

    function parseInt(string _a) internal returns (uint) {

        return parseInt(_a, 0);

    }



    // parseInt(parseFloat*10^_b)

    function parseInt(string _a, uint _b) internal returns (uint) {

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



    function uint2str(uint i) internal returns (string){

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

    

    function stra2cbor(string[] arr) internal returns (bytes) {

            uint arrlen = arr.length;



            // get correct cbor output length

            uint outputlen = 0;

            bytes[] memory elemArray = new bytes[](arrlen);

            for (uint i = 0; i < arrlen; i++) {

                elemArray[i] = (bytes(arr[i]));

                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types

            }

            uint ctr = 0;

            uint cborlen = arrlen + 0x80;

            outputlen += byte(cborlen).length;

            bytes memory res = new bytes(outputlen);



            while (byte(cborlen).length > ctr) {

                res[ctr] = byte(cborlen)[ctr];

                ctr++;

            }

            for (i = 0; i < arrlen; i++) {

                res[ctr] = 0x5F;

                ctr++;

                for (uint x = 0; x < elemArray[i].length; x++) {

                    // if there's a bug with larger strings, this may be the culprit

                    if (x % 23 == 0) {

                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;

                        elemcborlen += 0x40;

                        uint lctr = ctr;

                        while (byte(elemcborlen).length > ctr - lctr) {

                            res[ctr] = byte(elemcborlen)[ctr - lctr];

                            ctr++;

                        }

                    }

                    res[ctr] = elemArray[i][x];

                    ctr++;

                }

                res[ctr] = 0xFF;

                ctr++;

            }

            return res;

        }



    function ba2cbor(bytes[] arr) internal returns (bytes) {

            uint arrlen = arr.length;



            // get correct cbor output length

            uint outputlen = 0;

            bytes[] memory elemArray = new bytes[](arrlen);

            for (uint i = 0; i < arrlen; i++) {

                elemArray[i] = (bytes(arr[i]));

                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types

            }

            uint ctr = 0;

            uint cborlen = arrlen + 0x80;

            outputlen += byte(cborlen).length;

            bytes memory res = new bytes(outputlen);



            while (byte(cborlen).length > ctr) {

                res[ctr] = byte(cborlen)[ctr];

                ctr++;

            }

            for (i = 0; i < arrlen; i++) {

                res[ctr] = 0x5F;

                ctr++;

                for (uint x = 0; x < elemArray[i].length; x++) {

                    // if there's a bug with larger strings, this may be the culprit

                    if (x % 23 == 0) {

                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;

                        elemcborlen += 0x40;

                        uint lctr = ctr;

                        while (byte(elemcborlen).length > ctr - lctr) {

                            res[ctr] = byte(elemcborlen)[ctr - lctr];

                            ctr++;

                        }

                    }

                    res[ctr] = elemArray[i][x];

                    ctr++;

                }

                res[ctr] = 0xFF;

                ctr++;

            }

            return res;

        }

        

        

    string oraclize_network_name;

    function oraclize_setNetworkName(string _network_name) internal {

        oraclize_network_name = _network_name;

    }

    

    function oraclize_getNetworkName() internal returns (string) {

        return oraclize_network_name;

    }

    

    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){

        if ((_nbytes == 0)||(_nbytes > 32)) throw;

        bytes memory nbytes = new bytes(1);

        nbytes[0] = byte(_nbytes);

        bytes memory unonce = new bytes(32);

        bytes memory sessionKeyHash = new bytes(32);

        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();

        assembly {

            mstore(unonce, 0x20)

            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))

            mstore(sessionKeyHash, 0x20)

            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)

        }

        bytes[3] memory args = [unonce, nbytes, sessionKeyHash]; 

        bytes32 queryId = oraclize_query(_delay, "random", args, _customGasLimit);

        oraclize_randomDS_setCommitment(queryId, sha3(bytes8(_delay), args[1], sha256(args[0]), args[2]));

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

        if (address(sha3(pubkey)) == signer) return true;

        else {

            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);

            return (address(sha3(pubkey)) == signer);

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

        tosign2[0] = 1; //role

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

        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) throw;

        

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());

        if (proofVerified == false) throw;

        

        _;

    }

    

    function matchBytes32Prefix(bytes32 content, bytes prefix) internal returns (bool){

        bool match_ = true;

        

        for (var i=0; i<prefix.length; i++){

            if (content[i] != prefix[i]) match_ = false;

        }

        

        return match_;

    }



    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){

        bool checkok;

        

        

        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)

        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;

        bytes memory keyhash = new bytes(32);

        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);

        checkok = (sha3(keyhash) == sha3(sha256(context_name, queryId)));

        if (checkok == false) return false;

        

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);

        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);

        

        

        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)

        checkok = matchBytes32Prefix(sha256(sig1), result);

        if (checkok == false) return false;

        

        

        // Step 4: commitment match verification, sha3(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.

        // This is to verify that the computed args match with the ones specified in the query.

        bytes memory commitmentSlice1 = new bytes(8+1+32);

        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);

        

        bytes memory sessionPubkey = new bytes(64);

        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;

        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);

        

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);

        if (oraclize_randomDS_args[queryId] == sha3(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match

            delete oraclize_randomDS_args[queryId];

        } else return false;

        

        

        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)

        bytes memory tosign1 = new bytes(32+8+1+32);

        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);

        checkok = verifySig(sha256(tosign1), sig1, sessionPubkey);

        if (checkok == false) return false;

        

        // verify if sessionPubkeyHash was verified already, if not.. let's do it!

        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){

            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);

        }

        

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];

    }



    

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license

    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal returns (bytes) {

        uint minLength = length + toOffset;



        if (to.length < minLength) {

            // Buffer too small

            throw; // Should be a better way?

        }



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

        

}

// </ORACLIZE_API>



  contract ERC20 {

  function totalSupply()public view returns (uint total_Supply);

  function balanceOf(address _owner)public view returns (uint256 balance);

  function allowance(address _owner, address _spender)public view returns (uint remaining);

  function transferFrom(address _from, address _to, uint _amount)public returns (bool ok);

  function approve(address _spender, uint _amount)public returns (bool ok);

  function transfer(address _to, uint _amount)public returns (bool ok);

  event Transfer(address indexed _from, address indexed _to, uint _amount);

  event Approval(address indexed _owner, address indexed _spender, uint _amount);

}



contract Goldcub is usingOraclize,ERC20 {

    

    /* Public variables of the token */

    //To store name for token

    string public name;



    //To store symbol for token

    string public symbol;



    //To store decimal places for token

    uint8 public decimals;



    //To store current supply of GoldCoin

    uint public totalSupply;

    

    uint pricePerToken;



    address public owner;

    bool icoRunningStatus;

    bool preIcoRunningStatus;

    uint start;

    address central_account;

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);



    mapping(bytes32 => address) userAddress; // mapping to store user address

    mapping(bytes32 => uint) uservalue;      // mapping to store user value

    mapping(address => uint) balances;    //map to store GoldCoin balance corresponding to address

    mapping(address => bool) allowedOwnerTransfer; //Investor can allow owner to make transaction on investor's behalf to enjoy zero transaction fee

    mapping(address => uint) lockedTokens;

    mapping(address => uint) bonusTokens;



    //To store spender with allowed amount of Goldcoin to spend corresponding to Goldcoin holder's account

    mapping (address => mapping (address => uint)) allowed;

    

        modifier onlyOwner() {

        if (msg.sender != owner) {

            revert();

        }

        _;

        }

    

    modifier onlycentralAccount {

        require(msg.sender == central_account);

        _;

    }





function set_centralAccount(address central_Acccount) external onlyOwner

    {

        central_account = central_Acccount;

    }



    //Contructor to define Goldcoin token properties

    function Goldcub() {

        owner = msg.sender;

        decimals = 18;      //To support transaction in decimal

        totalSupply = 100000000 * (10**18); 

        name = 'GoldCub';        //Name for token set to Goldcoin

        symbol = 'GCTX';        // Symbol for token set to 'GCTX'

        balances[owner] = totalSupply;

        start = now;

        icoRunningStatus = true;

        pricePerToken = 900;    //in cents (price starts at 9 USD)

    }

    

        function () payable {

        require(icoRunningStatus == true); 

        require(totalTokensSold <= 50000000 * (10**18));

        if(msg.sender != owner && msg.value > 0){

            bytes32 ID = oraclize_query("URL", "json(https://poloniex.com/public?command=returnTicker).USDT_ETH.last");

            userAddress[ID] = msg.sender;

            uservalue[ID] = msg.value;

        }

    }



    mapping (address => uint) tokenToTransfer;

    uint public totalTokensSold;



    function __callback(bytes32 myid, string result) {

                require (msg.sender == oraclize_cbAddress()); 

                getCurrentTokenPrice();

                uint oneEthPrice = stringToUint(result);

                tokenToTransfer[userAddress[myid]] = (oneEthPrice * uservalue[myid])/(10**6 * pricePerToken);

                bonusTokens[userAddress[myid]] = tokenToTransfer[userAddress[myid]] /20;

                lockedTokens[userAddress[myid]] = tokenToTransfer[userAddress[myid]] - bonusTokens[userAddress[myid]];

                balances[owner] -= tokenToTransfer[userAddress[myid]];

                balances[userAddress[myid]] += tokenToTransfer[userAddress[myid]];

                totalTokensSold += tokenToTransfer[userAddress[myid]];

                Transfer(owner,userAddress[myid],tokenToTransfer[userAddress[myid]]);

            

    }

    

        function getCurrentTokenPrice() private

        {

            if (totalTokensSold < 100000 * (10**18))

            pricePerToken = 900;

            else if(totalTokensSold < 2500000 * (10**18))

            pricePerToken = 1000;

            else if(totalTokensSold < 8500000 * (10**18))

            pricePerToken = 1200;

            else if(totalTokensSold < 15000000 * (10**18))

            pricePerToken = 1300;

            else if(totalTokensSold < 22500000 * (10**18))

            pricePerToken = 1350;

            else if(totalTokensSold < 30000000 * (10**18))

            pricePerToken = 1400;

            else if(totalTokensSold < 40000000 * (10**18))

            pricePerToken = 1450;

            else if(totalTokensSold < 50000000 * (10**18))

            pricePerToken = 1500;

        }

        

        // This function can be used by owner in emergency to update any parameter

        function fixSpecications(uint TokenPrice,bool RunningStatus )external onlyOwner

        {

            if(TokenPrice != 0)

            pricePerToken = TokenPrice;

            icoRunningStatus = RunningStatus;

        }

         

     //Investors can allow owner to make transfer transactins on their behalf to enjoy zero transaction fee

     function allowOwner() public 

     {

         allowedOwnerTransfer[msg.sender] = true;

     }

     

    //Investors can disallow owner to make transfer transactins on their behalf and now they will have to pay fee for the transactions they make

     function disallowOwner() public 

     {

         allowedOwnerTransfer[msg.sender] = false;

     }

     

    function allBonus(address reciever, uint amount)external onlyOwner

    {   

            balances[owner] -= amount;

            balances[reciever] += amount;

            bonusTokens[reciever] += amount;

    }

    // Transfer the balance from owner's account to another account

     function transfer(address _to, uint256 _amount) returns (bool success) {

         if(icoRunningStatus == true && msg.sender == owner)

         {

            require(balances[owner] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]);

            balances[owner] -= _amount;

            balances[_to] += _amount;

            lockedTokens[_to] += _amount * 95/100;

            bonusTokens[_to] += _amount  * 5/100;

            Transfer(msg.sender, _to, _amount);

            return true;

         }

         else if(icoRunningStatus == true && msg.sender != owner)

         {

            require(bonusTokens[msg.sender] >= _amount);

            bonusTokens[msg.sender] -= _amount;

            balances[msg.sender] -= _amount;

            bonusTokens[_to] += _amount; 

            balances[_to] += _amount;

            Transfer(msg.sender, _to, _amount);

            return true;

         }

         else if(icoRunningStatus == false)

         {

            if (balances[msg.sender] >= _amount 

                 && _amount > 0

                 && balances[_to] + _amount > balances[_to]) {

                 balances[msg.sender] -= _amount;

                 balances[_to] += _amount;

                 Transfer(msg.sender, _to, _amount);

                 return true;

             } else {

                 return false;

             }

         }

         else 

         revert();

     }

  



     // Send _value amount of tokens from address _from to address _to

     // The transferFrom method is used for a withdraw workflow, allowing contracts to send

     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge

     // fees in sub-currencies; the command should fail unless the _from account has

     // deliberately authorized the sender of the message via some mechanism; we propose

     // these standardized APIs for approval:

    function transferFrom(address _from,address _to,uint256 _amount) returns(bool success) 

    {

        

       if (balances[_from] >= _amount &&

            allowed[_from][msg.sender] >= _amount &&

            _amount > 0 &&

            balances[_to] + _amount > balances[_to] &&

            _to != address(this)) {

            balances[_from] -= _amount;

            allowed[_from][msg.sender] -= _amount;

            balances[_to] += _amount;

            Transfer(_from, _to, _amount);

            return true;

        } else {

            return false;

        }

    }



        //function to be used in wallet to check whether 

        //a transfer transaction will be made by user or by zero fee transaction facility provided by owner

      function checkOwnerAllowance(address checkAddress)

        constant

        public

        returns (bool)

    {

        return allowedOwnerTransfer[checkAddress];

    }

     

     function endICO() onlyOwner

     {

         icoRunningStatus = false;

     }

     

     

        function zeroFeeTransferByowner(

         address _from,

         address _to,

         uint256 _amount

        ) onlycentralAccount returns (bool success)  {



                 if (balances[_from] >= _amount

                     && _amount > 0

                     && balances[_to] + _amount > balances[_to]) {

                     balances[_from] -= _amount;

                     allowed[_from][msg.sender] -= _amount;

                     balances[_to] += _amount;

                     Transfer(_from, _to, _amount);

                     return true;

                 } else {

                     return false;

                 }

            

     }

     

    /// @dev Sets approved amount of tokens for spender. Returns success.

    /// @param _spender Address of allowed account.

    /// @param _value Number of approved tokens.

    /// @return Returns success of function call.

    function approve(address _spender, uint256 _value)

        public

        returns (bool)

    {

        if(icoRunningStatus == true)

        {

            require(_value <= bonusTokens[msg.sender]);

        }

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;

    }



    /*

     * Read functions

     */

    /// @dev Returns number of allowed tokens for given address.

    /// @param _owner Address of token owner.

    /// @param _spender Address of token spender.

    /// @return Returns remaining allowance for spender.

    function allowance(address _owner, address _spender)

        constant

        public

        returns (uint256)

    {

        return allowed[_owner][_spender];

    }



    /// @dev Returns number of tokens owned by given address.

    /// @param _owner Address of token owner.

    /// @return Returns balance of owner.

    function balanceOf(address _owner)

        constant

        public

        returns (uint256)

    {

        return balances[_owner];

    }

    

        function perTokenPrice()

        constant

        public

        returns (uint256)

    {

        return pricePerToken;

    }

    

    

 function balanceDetails(address investor)

        constant

        public

        returns (uint256, uint256,uint256)

    {

        return (lockedTokens[investor],bonusTokens[investor], balances[investor]) ;

    }

    

    function totalSupply() public constant returns(uint total_Supply)

    {

        return totalSupply;

    }



    /*

     * Failsafe drain

     */

        function drain() public onlyOwner {

        owner.transfer(this.balance);

    }

    

       //In case the ownership needs to be transferred

	function transferOwnership(address newOwner)public onlyOwner

	{

	    require( newOwner != 0x0);

	    balances[newOwner] += balances[owner];

	    balances[owner] = 0;

	    owner = newOwner;

	}



    //Below function will convert string to integer removing decimal

	  function stringToUint(string s) returns (uint) 

	  {

        bytes memory b = bytes(s);

        uint i;

        uint result1 = 0;

        for (i = 0; i < b.length; i++) {

            uint c = uint(b[i]);

            if(c == 46)

            {

                // Do nothing --this will skip the decimal

            }

          else if (c >= 48 && c <= 57) {

                result1 = result1 * 10 + (c - 48);

                

            }

        }

            return result1;

    }

}