# Experiment

This directory contains the results of the experiment in our paper (Section 5). Specifically, it contains the following files:

* `./contract-list.txt` contains 79,598 smart contracts used in the experiment.
* `./AnalysisResult/` stores the raw results outputted by CryptoScan during the experiment.
* ``./Dataset1/``  is a directory containing all datasets used in Section 5.2. It includes 12`.csv` files named by nine types of defects. Each file contains a list of contracts that reported to have that defects. For example, the `./Dataset1/Single_Contract_Signature_Replay.csv` file contains 93 contracts. The first column in this file is the contract address reported by CryptoScan to have the single-contract-signature-replay defect, while the second column is "TP" (True Positive) or "FP" (False Positive), representing the manual labeling results that verify whether the defect reported by CryptoScan is a true positive or a false positive.
* ``./Dataset2/ `` contains the manually annotated dataset  in Section 5.3. The ``./Dataset2/Dataset2.csv`` file includes 96 smart contracts. Each row represents a contract, and each column represents a type of defect. The meaning of each cell is whether CryptoScan's analysis result for the contract in that row and the defect in that column is a "TP" (True Positive) or "FP" (False Positive) or "TN" (True Negative) or "FN" (False Negative) .
* `./Case.md` studies several defective cases reported by CryptoScan.



### Reproduce the Experiment Results

The following commands can be used to reproduce the experiment results from our paper. For each `CONTRACT_ADDRESS` listed in `Dataset/contract-list.txt`, execute the command below. The results will be stored in `OUTPUT_FOLDER`.

```bash
cd CryptoScan
python3 -m CryptoScan CONTRACT_ADDRESS --etherscan-apikey ETHERSCAN-API-KEY --json OUTPUT_FOLDER
```

The `Experiments/AnalysisResult` folder stores the raw results from executing these commands.