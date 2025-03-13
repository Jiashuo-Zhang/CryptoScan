// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "./HinkalBase.sol";
import "./VerifierFacade.sol";
import "./types/IHinkal.sol";
import "./types/IExternalAction.sol";
import "./types/ITransactHook.sol";

///@title Hinkal Contract
///@notice Entrypoint for all Hinkal Transactions.
contract Hinkal is IHinkal, VerifierFacade, HinkalBase {
    mapping(uint256 => address) internal externalActionMap;

    constructor(
        IMerkle.MerkleConstructorArgs memory constructorArgs,
        address _hinkalHelper,
        address _accessToken,
        address _hinkalHelperManager
    )
        HinkalBase(
            constructorArgs,
            _hinkalHelper,
            _accessToken,
            _hinkalHelperManager
        )
    {}

    function registerExternalAction(
        uint256 externalActionId,
        address externalActionAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        externalActionMap[externalActionId] = externalActionAddress;
        emit ExternalActionRegistered(externalActionAddress);
    }

    ///@notice Stop allowing smart contract to be called by Hinkal.
    ///@param externalActionId Id of this contract
    function removeExternalAction(
        uint256 externalActionId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        address externalActionAddress = externalActionMap[externalActionId];
        delete externalActionMap[externalActionId];
        emit ExternalActionRemoved(externalActionAddress);
    }

    function transact(
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        Dimensions calldata dimensions,
        CircomData calldata circomData
    ) public payable nonReentrant {
        _transact(a, b, c, dimensions, circomData);
    }

    function transactWithExternalAction(
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        Dimensions calldata dimensions,
        CircomData calldata circomData
    ) public payable nonReentrant {
        require(circomData.externalActionId != 0, "externalAddress is missing");
        _transact(a, b, c, dimensions, circomData);
    }

    function transactWithHook(
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        Dimensions calldata dimensions,
        CircomData calldata circomData
    ) public payable nonReentrant {
        require(
            circomData.hookData.hookContract != address(0) ||
                circomData.hookData.preHookContract != address(0),
            "hookContract is missing"
        );
        _transact(a, b, c, dimensions, circomData);
    }

    function transactWithExternalActionAndHook(
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        Dimensions calldata dimensions,
        CircomData calldata circomData
    ) public payable nonReentrant {
        require(circomData.externalActionId != 0, "externalAddress is missing");

        require(
            circomData.hookData.hookContract != address(0) ||
                circomData.hookData.preHookContract != address(0),
            "hookContract is missing"
        );
        _transact(a, b, c, dimensions, circomData);
    }

    function _transact(
        uint256[2] calldata a,
        uint256[2][2] calldata b,
        uint256[2] calldata c,
        Dimensions calldata dimensions,
        CircomData calldata circomData
    ) internal {
        {
            uint256[] memory inputForCircom = hinkalHelper.performHinkalChecks(
                circomData,
                dimensions
            );
            require(
                verifyProof(
                    a,
                    b,
                    c,
                    inputForCircom,
                    buildVerifierId(dimensions, circomData.externalActionId)
                ),
                "Invalid Proof"
            );
            // Root Hash Validation
            require(
                rootHashExists(circomData.rootHashHinkal),
                "Hinkal Root Hash is Incorrect"
            );
            require(
                accessToken.checkForRootHash(
                    circomData.rootHashAccessToken,
                    msg.sender
                ),
                "Access Token Root Hash is Incorrect"
            );

            // if you are forking/develop a netork the next statement should be commented
            require(
                circomData.timeStamp > block.timestamp - 7 * 60 &&
                    circomData.timeStamp < block.timestamp + 7 * 60,
                "Timestamp provided does not align with current time"
            );
        }

        {
            // function variables to store commitments created on-chain
            UTXO[] memory utxoSet;

            if (circomData.hookData.preHookContract != address(0)) {
                IPreTransactHook transactHook = IPreTransactHook(
                    circomData.hookData.preHookContract
                );
                transactHook.preTransact(
                    circomData,
                    circomData.hookData.preHookMetadata
                );
            }

            uint256[] memory oldBalances = getBalancesForArray(
                circomData.erc20TokenAddresses,
                circomData.tokenIds
            );

            if (circomData.externalActionId == 0) {
                _internalTransact(circomData);
            } else {
                utxoSet = _internalRunExternalAction(circomData);
            }

            uint256[] memory newBalances = getBalancesForArray(
                circomData.erc20TokenAddresses,
                circomData.tokenIds
            );

            OnChainCommitment[]
                memory onChainCommitments = new OnChainCommitment[](
                    utxoSet.length
                );
            uint256 onChainCommitmentCounter = 0;
            for (uint64 i; i < circomData.erc20TokenAddresses.length; i++) {
                int256 balanceDif;

                if (circomData.erc20TokenAddresses[i] == address(0)) {
                    balanceDif =
                        int256(newBalances[i]) +
                        int256(msg.value) -
                        int256(oldBalances[i]);
                } else {
                    balanceDif =
                        int256(newBalances[i]) -
                        int256(oldBalances[i]);
                }
                // balance inequality to check that minimum amount of token is received
                require(
                    balanceDif >= circomData.amountChanges[i],
                    "Inbalance in token detected"
                );

                uint256 utxoAmount = 0;
                for (uint j = 0; j < utxoSet.length; j++) {
                    if (
                        utxoSet[j].erc20Address ==
                        circomData.erc20TokenAddresses[i]
                    ) {
                        utxoAmount = utxoSet[j].amount;
                        onChainCommitments[
                            onChainCommitmentCounter++
                        ] = createCommitment(utxoSet[j]);
                        break;
                    }
                }
                // balance equation to check that we create utxo equal exactly to balance increase
                require(
                    balanceDif ==
                        int256(utxoAmount) +
                            int256(identity(circomData.outCommitments[i][0])) *
                            circomData.amountChanges[i],
                    "Balance Diff Should be equal to sum of onchain and offchain created commitments"
                );
            }
            if (circomData.hookData.hookContract != address(0)) {
                ITransactHook transactHook = ITransactHook(
                    circomData.hookData.hookContract
                );
                transactHook.afterTransact(
                    circomData,
                    circomData.hookData.postHookMetadata
                );
            }

            insertNullifiers(circomData.inputNullifiers);

            insertCommitments(
                circomData.outCommitments,
                circomData.encryptedOutputs,
                onChainCommitments
            );
        }
    }

    ///@notice private internal function for transaction
    ///@param circomData circom dara
    function _internalTransact(CircomData calldata circomData) private {
        for (uint64 i = 0; i < circomData.erc20TokenAddresses.length; i++) {
            if (circomData.amountChanges[i] > 0) {
                require(
                    circomData.externalAddress == msg.sender,
                    "Deposit should come from the sender"
                );
                transferTokenFrom(
                    circomData.erc20TokenAddresses[i],
                    circomData.externalAddress,
                    address(this),
                    uint256(circomData.amountChanges[i]),
                    circomData.tokenIds[i]
                );
            } else if (circomData.amountChanges[i] < 0) {
                uint256 relayFee = 0;
                if (circomData.relay != address(0)) {
                    relayFee = hinkalHelper.calculateRelayFee(
                        uint256(-circomData.amountChanges[i]),
                        circomData.erc20TokenAddresses[i],
                        circomData.flatFees[i],
                        circomData.externalActionId
                    );
                    require(
                        relayFee <= uint256(-circomData.amountChanges[i]),
                        "Relay Fee is over withdraw amount"
                    );
                    if (circomData.tokenIds[i] == 0)
                        transferERC20TokenOrETH(
                            circomData.erc20TokenAddresses[i],
                            circomData.relay,
                            relayFee
                        );
                }
                transferToken(
                    circomData.erc20TokenAddresses[i],
                    circomData.externalAddress,
                    uint256(-circomData.amountChanges[i]) - relayFee,
                    circomData.tokenIds[i]
                );
            }
        }
    }

    ///@notice internal function to use Hinkal with external contracts.
    ///@param circomData circom data.
    function _internalRunExternalAction(
        CircomData calldata circomData
    ) internal returns (UTXO[] memory) {
        require(
            externalActionMap[circomData.externalActionId] ==
                circomData.externalAddress &&
                circomData.externalAddress != address(0),
            "Unknown externalAddress"
        );

        for (uint64 i = 0; i < circomData.erc20TokenAddresses.length; i++) {
            if (circomData.amountChanges[i] < 0) {
                transferToken(
                    circomData.erc20TokenAddresses[i],
                    circomData.externalAddress,
                    uint256(-circomData.amountChanges[i]),
                    circomData.tokenIds[i]
                );
            }
        }
        return
            IExternalAction(circomData.externalAddress).runAction(circomData);
    }
}