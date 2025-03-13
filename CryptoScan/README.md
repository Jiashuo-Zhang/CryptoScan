# CryptoScan

## Description

This directory contains the source code for CryptoScan, a static analyzer designed to detect cryptographic defects in Ethereum smart contracts before deployment.

## Installation

**Environment: CryptoScan is tested on Python 3.10 and Ubuntu 22.04.2 LTS.**

**Installation steps for CryptoScan:**

```bash
cd CryptoScan
pip install -r requirements.txt
```

CryptoScan is built on Slither.



## Usage

Once initialization is complete, CryptoScan is ready to analyze smart contracts.

For detailed usage information, execute the help command below:

```bash
cd CryptoScan
python3 -m CryptoScan -h
```



### Analyze Smart Contracts

#### Analyze On-Chain Contracts

CryptoScan can analyze deployed Ethereum on-chain contracts using the following command (the contract must have a Verified Contract Address on Etherscan). Here, `CONTRACT_ADDRESS` is the on-chain contract address, `ETHERSCAN-API-KEY` is the Etherscan API Key used to retrieve the source code of the on-chain smart contract, and `DETECTOR` specifies the type of detection. If not specified, all cryptographic defects will be detected by default.

```bash
python3 -m CryptoScan CONTRACT_ADDRESS --etherscan-apikey ETHERSCAN-API-KEY --detect DETECTOR
```

**Example: ** You can analyze an on-chain smart contract at `0xDD5A649fC076886Dfd4b9Ad6aCFC9B5eb882e83c` using the following command, which will yield the following result:

```bash
python3 -m CryptoScan 0xDD5A649fC076886Dfd4b9Ad6aCFC9B5eb882e83c --etherscan-apikey ETHERSCAN-API-KEY --detect single-sig-replay
```

```solidity
The_Association_Sales.mint_approved(dusty.vData,uint256,uint16) (contracts/The_Association_Sales.sol#233-249)->dusty.verify(dusty.vData) (contracts/ssp/dusty.sol#100-136)allows single-contract signature replay:recovered = ecrecover(bytes32,uint8,bytes32,bytes32)(data,sigV,sigR,sigS) (contracts/ssp/dusty.sol#134)
Reference:
INFO:Slither:0xDD5A649fC076886Dfd4b9Ad6aCFC9B5eb882e83c analyzed (26 contracts with 1 detectors), 1 result(s) found
```



#### Analyze Off-Chain Contracts

CryptoScan can analyze off-chain contracts/projects that have not yet been deployed using the following command. Here, `FILE-PATH` is the path to the off-chain contract/project. Because CryptoScan inherits Slither's functionality, it can analyze not only single Solidity files but also projects managed by frameworks such as Foundry and Truffle. `DETECTOR` specifies the type of detection, with all cryptographic defects being detected by default if not specified.

```bash
python3 -m CryptoScan FILE-PATH --detect DETECTOR
```



### Reproduce the Experiment Results

The following commands can be used to reproduce the experiment results from our paper. For each `CONTRACT_ADDRESS` listed in `Dataset/contract-list.txt`, execute the command below. The results will be stored in `OUTPUT_FOLDER`.

```bash
cd CryptoScan
python3 -m CryptoScan CONTRACT_ADDRESS --etherscan-apikey ETHERSCAN-API-KEY --json OUTPUT_FOLDER
```

The `Experiments/AnalysisResult` folder stores the raw results from executing these commands.