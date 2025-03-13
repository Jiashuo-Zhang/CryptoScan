// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./dependencies/AllowedOperations.sol";

/// @title A proxy that executes operations on behalf of a user
/// @author Tomas A. Puricelli

struct OperationsWithNonce {
    Operation[] operations;
    uint256 nonce;
    string intention;
}

contract BotoSmartProxy is AccessControl, AllowedOperations, EIP712, Pausable {
    /// @notice Emitted when the contract is shutdown.
    /// @param account the account that shutdown the contract
    event Shutdown(address account);

    /// @notice Emitted when the contract is initialized.
    event Initialized();

    /// @notice Deployer role. Assigned to the smart contract deployer.
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");

    /// @notice Super operator role. Can execute any operation without restrictions.
    bytes32 public constant SUPER_OPERATOR_ROLE =
        keccak256("SUPER_OPERATOR_ROLE");

    /// @notice Keeper role. Can pause and unpause the contract.
    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

    /// @notice Basic scope manager role. Can add and remove allowed operations with no user context.
    bytes32 public constant BASIC_SCOPE_MANAGER_ROLE =
        keccak256("BASIC_SCOPE_MANAGER_ROLE");

    /// @notice Extended scope manager role. Can add and remove allowed operations with user context.
    bytes32 public constant EXTENDED_SCOPE_MANAGER_ROLE =
        keccak256("EXTENDED_SCOPE_MANAGER_ROLE");

    /// @notice Executor role. Can execute operations from both the basic and extended scope.
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    bytes32 public constant NONCE_VIEWER_ROLE = keccak256("NONCE_VIEWER_ROLE");

    bytes32 public constant OPERATIONS_WITH_NONCE_SCHEMA_HASH =
        keccak256(
            abi.encodePacked(
                "OperationsWithNonce(Operation[] operations,uint256 nonce,string intention)Operation(address contractAddress,bytes4 functionSelector)"
            )
        );

    mapping(address => uint256) private _nonces;
    bool private _unsafeAllowAll;
    bool private _isShutdown;
    bool private _isInitialized;
    error AlreadyInitialized();
    error AlreadyShutdownError();
    error MismatchedArrayLengthsError();
    error NotAuthorizedError();

    constructor() EIP712("BotoProxy", "1.0.0") {
        _setupRole(DEPLOYER_ROLE, msg.sender);
    }

    function initialize(address newOwner) external onlyRole(DEPLOYER_ROLE) {
        if (_isInitialized) revert AlreadyInitialized();
        _isInitialized = true;

        // Ownership transfer
        _setupRole(DEFAULT_ADMIN_ROLE, newOwner);
        _setupRole(KEEPER_ROLE, newOwner);
        _setupRole(SUPER_OPERATOR_ROLE, newOwner);

        _revokeRole(DEPLOYER_ROLE, msg.sender);
        emit Initialized();
    }

    /// @notice Modifier to make a function callable only when the contract is not shutdown.
    /// Requirements:
    /// - The contract must not be shutdown.
    modifier whenNotShutdown() {
        if (_isShutdown) revert AlreadyShutdownError();
        _;
    }

    /// @notice View function to check if a set of operations are allowed. Returns true if all operations are allowed.
    /// @param userAddress The address of the user.
    /// @param operations The operations to check.
    function isAllowed(
        address userAddress,
        Operation[] calldata operations
    ) external view returns (bool) {
        bool isOpAllowed = true;
        for (uint256 i = 0; i < operations.length && isOpAllowed;) {
            bytes32 operationHash = _hashOperation(operations[i]);
            isOpAllowed = allowedOperations[operationHash] || allowedOperations[keccak256(abi.encode(operationHash, userAddress))];
            unchecked { ++i; }
        }
        return isOpAllowed;
    }

    function getNonce(
        address user
    ) public view onlyRole(NONCE_VIEWER_ROLE) returns (uint256) {
        return _nonces[user];
    }

    /// @notice Function to add a set of operations to the allowed list with no user context.
    /// Requirements:
    /// - The caller must have the `BASIC_SCOPE_MANAGER_ROLE` role.
    /// - The contract must not be paused.
    /// @param _operations The operations to add to the allowed list.
    function addAllowedOperationBasicScope(
        // bytes memory signature,
        Operation[] calldata _operations
    ) external onlyRole(BASIC_SCOPE_MANAGER_ROLE) whenNotPaused {
        Operations memory operations = Operations(_operations);

        // Encode operations as EIP-712 typed data and compute the hash
        (, bytes32[] memory operationHashes) = _hashOperations(operations);

        // Add each operation hash individually
        uint length = operationHashes.length;
        for (uint i = 0; i < length;) {
            _addAllowedOperation(operationHashes[i], _operations[i]);
            unchecked { ++i; }
        }
    }

    /// @notice Function to remove a set of operations from the allowed list with no user context.
    /// Requirements:
    /// - The caller must have the `BASIC_SCOPE_MANAGER_ROLE` role.
    /// @param _operations The operations to remove from the allowed list.
    function removeAllowedOperationBasicScope(
        Operation[] calldata _operations
    ) external onlyRole(BASIC_SCOPE_MANAGER_ROLE) {
        Operations memory operations = Operations(_operations);

        // Encode operations as EIP-712 typed data and compute the hash
        (, bytes32[] memory operationHashes) = _hashOperations(operations);

        // Remove allowed operations
        uint length = operationHashes.length;
        for (uint i = 0; i < length;) {
            _removeAllowedOperation(operationHashes[i], _operations[i]);
            unchecked { ++i; }
        }
    }

    /// @notice Function to add a set of operations to the allowed list with user context.
    /// Requirements:
    /// - The caller must have the `EXTENDED_SCOPE_MANAGER_ROLE` role.
    /// - The contract must not be paused.
    /// @param signature Message signed by the user.
    /// @param _operations Set of operations to add to the allowed list.s
    function addAllowedOperationExtendedScope(
        bytes calldata signature,
        Operation[] calldata _operations,
        address user
    ) external onlyRole(EXTENDED_SCOPE_MANAGER_ROLE) whenNotPaused {
        Operations memory operations = Operations(_operations);

        // Encode operations as EIP-712 typed data and compute the hash
        (
            bytes32 hash,
            bytes32[] memory operationHashes
        ) = _hashOperationsWithNonce(operations, _nonces[user], "add");

        // Verify the signature
        address signer = ECDSA.recover(_hashTypedDataV4(hash), signature);
        require(signer == user, "Signer does not match user");

        // Add each operation hash individually
        uint length = operationHashes.length;
        for (uint i = 0; i < length;) {
            bytes32 hashWithUser = keccak256(
                abi.encode(operationHashes[i], signer)
            );
            _addAllowedOperation(hashWithUser, _operations[i]);
            unchecked { ++i; }
        }
        // Increment nonce
        ++_nonces[user];
    }

    /// @notice Function to remove a set of operations from the allowed list with user context.
    /// Requirements:
    /// - The caller must have the `EXTENDED_SCOPE_MANAGER_ROLE` role.
    /// @param signature Message signed by the user.
    /// @param _operations Set of operations to remove from the allowed list.
    function removeAllowedOperationExtendedScope(
        bytes calldata signature,
        Operation[] calldata _operations,
        address user
    ) external onlyRole(EXTENDED_SCOPE_MANAGER_ROLE) {
        Operations memory operations = Operations(_operations);

        // Encode operations as EIP-712 typed data and compute the hash
        (
            bytes32 hash,
            bytes32[] memory operationHashes
        ) = _hashOperationsWithNonce(operations, _nonces[user], "remove");
        address signer = ECDSA.recover(_hashTypedDataV4(hash), signature);
        require(signer == user, "Signer does not match user");

        // Remove allowed operations
        uint length = operationHashes.length;
        for (uint i = 0; i < length;) {
            bytes32 hashWithUser = keccak256(
                abi.encode(operationHashes[i], signer)
            );
            _removeAllowedOperation(hashWithUser, _operations[i]);
            unchecked { ++i; }
        }
        // Increment nonce
        ++_nonces[user];
    }

    ///@notice Function to execute a set of operations bypassing the allowed list.
    ///Requirements:
    /// - The caller must have the `SUPER_OPERATOR_ROLE` role.
    /// - The contract must not be paused.
    ///@param operations The operations to execute.
    ///@param arguments The arguments for each operation.

    function executeWithSuperOperator(
        Operation[] calldata operations,
        bytes[] calldata arguments
    ) external onlyRole(SUPER_OPERATOR_ROLE) whenNotPaused {
        if (operations.length != arguments.length) revert MismatchedArrayLengthsError();
        bytes[] memory functionCallData = new bytes[](operations.length);
        for (uint256 i = 0; i < operations.length;) {
            functionCallData[i] = abi.encodePacked(
                operations[i].functionSelector,
                arguments[i]
            );
            (bool success, bytes memory data) = operations[i]
                .contractAddress
                .call(functionCallData[i]);
            if (!success) {
                // if the call fails and the data returned is empty, revert with a generic message
                if (data.length == 0) revert("Function call failed");
                // else, revert with the message returned
                assembly {
                    revert(add(32, data), mload(data))
                }
            }
            unchecked { ++i; }
        }
    }

    /// @notice Function to execute a set of operations.
    /// Requirements:
    /// - The caller must have the `EXECUTER_ROLE` role.
    /// - The contract must not be paused.
    /// @param operations The operations to execute.
    /// @param arguments The arguments for each operation.
    function execute(
        Operation[] calldata operations,
        bytes[] calldata arguments,
        address user
    ) external onlyRole(EXECUTOR_ROLE) whenNotPaused {
        if (operations.length != arguments.length) revert MismatchedArrayLengthsError();


        bytes[] memory functionCallData = new bytes[](operations.length);
        bool unsafeAllowAll_ = _unsafeAllowAll;
        for (uint256 i = 0; i < operations.length;) {
            if (!unsafeAllowAll_) {
                bytes32 operationHash = _hashOperation(operations[i]);
                // first check if it is included in the basic scope
                bool allowed = _isAllowed(operationHash);
                if (!allowed) {
                    // if it isn't, check if it is included in the extended scope
                    allowed = _isAllowed(
                        keccak256(abi.encode(operationHash, user))
                    );
                }

                if (!allowed) revert NotAuthorizedError();
            }
            functionCallData[i] = abi.encodePacked(
                operations[i].functionSelector,
                arguments[i]
            );
            (bool success, bytes memory data) = operations[i]
                .contractAddress
                .call(functionCallData[i]);
            if (!success) {
                // if the call fails and the data returned is empty, revert with a generic message
                if (data.length == 0) revert("Function call failed");
                // else, revert with the message returned
                assembly {
                    revert(add(32, data), mload(data))
                }
            }
            unchecked { ++i; }
        }
    }

    function toggleUnsafeAllowAll(bool unsafeAllowAll_)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
        whenNotPaused
    {
        _unsafeAllowAll = unsafeAllowAll_;
    }

    function pause() external onlyRole(KEEPER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(KEEPER_ROLE) whenNotShutdown {
        _unpause();
    }

    function shutdown() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _isShutdown = true;
        _pause();
        emit Shutdown(msg.sender);
    }

    /// @notice Function to hash operation following the EIP-712 standard.
    /// @param _operation Operation to hash.s
    function _hashOperation(
        Operation memory _operation
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    OPERATION_SCHEMA_HASH,
                    // consider removing the contract address from the hash
                    _operation.contractAddress,
                    _operation.functionSelector
                )
            );
    }

    function _hashOperations(
        Operations memory _operations
    ) internal pure returns (bytes32, bytes32[] memory) {
        bytes32[] memory operationHashes = new bytes32[](
            _operations.operations.length
        );

        for (uint256 i = 0; i < _operations.operations.length;) {
            operationHashes[i] = _hashOperation(_operations.operations[i]);
            unchecked { ++i; }
        }

        return (
            keccak256(
                abi.encode(
                    OPERATIONS_SCHEMA_HASH,
                    keccak256(abi.encodePacked(operationHashes))
                )
            ),
            operationHashes
        );
    }

    function _hashOperationsWithNonce(
        Operations memory _operations,
        uint256 nonce,
        string memory intention
    ) internal pure returns (bytes32, bytes32[] memory) {
        bytes32[] memory operationHashes = new bytes32[](
            _operations.operations.length
        );
        uint length = _operations.operations.length;
        for (uint256 i = 0; i < length;) {
            operationHashes[i] = _hashOperation(_operations.operations[i]);
            unchecked { ++i; }
        }
        return (
            keccak256(
                abi.encode(
                    OPERATIONS_WITH_NONCE_SCHEMA_HASH,
                    keccak256(abi.encodePacked(operationHashes)),
                    nonce,
                    keccak256(abi.encodePacked(intention))
                )
            ),
            operationHashes
        );
    }

    fallback() external {
        revert("This contract does not accept Ether transfers.");
    }
}