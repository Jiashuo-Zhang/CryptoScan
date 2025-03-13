# Dataset

This directory specifically contains the following contents:

* `./contract-list.txt` contains a list of 79,598 Ethereum crypto-related smart contracts, with each line containing a different contract address. We collected this dataset to evaluate the effectiveness of CryptoScan (Section 5).

* `./ContractStatistic/` contains statistics for these 79,598 contracts, including the address, transaction count, balance, creation block number, and ABI. This statistical information is collected from Etherscan. Each file (named after the contract address) contains the information for one contract.

* `./SourceCode/` contains the source codes of these 79,598 smart contracts, with each file containing the source code of one smart contract.

* `./SecurityReports/` contains the security reports collected for defining cryptographic defects.