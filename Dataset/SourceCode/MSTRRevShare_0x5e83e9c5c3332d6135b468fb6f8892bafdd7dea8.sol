//SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MSTRRevShare is Ownable(msg.sender) {
    using SafeERC20 for IERC20;
    using MerkleProof for bytes32[];

    bytes32 public MERKLE_ROOT;
    IERC20 public immutable TOKEN;

    mapping(address claimant => bool flag) public claimed;

    error EtherTransferFail();
    error MerkleVerificationFail();

    /**
     * @dev You can cut out 10 opcodes in the creation-time EVM bytecode
     * if you declare a constructor `payable`.
     *
     * For more in-depth information see here:
     * https://forum.openzeppelin.com/t/a-collection-of-gas-optimisation-tricks/19966/5.
     */
    constructor(bytes32 merkleRoot_, IERC20 token_) payable {
        MERKLE_ROOT = merkleRoot_;
        TOKEN = token_;
    }

    function updateRoot(bytes32 newRoot) external onlyOwner {
        MERKLE_ROOT = newRoot;
    }

    function retrieveFundsETH(address to) external onlyOwner {
        // We don't care about a potential reentrancy in this case.
        (bool sent, ) = to.call{value: address(this).balance}("");
        if (!sent) revert EtherTransferFail();
    }

    function retrieveFunds(
        IERC20 tokenFrom,
        address to,
        uint256 amount
    ) external onlyOwner {
        tokenFrom.safeTransfer(to, amount);
    }

    /**
     * @dev There are some issues with Merkle trees such as pre-image attacks or
     * possibly duplicated leaves on unbalanced trees, but here we protect against
     * them by checking against `msg.sender` and only allowing each account to claim once.
     *
     * For more in-depth information see here:
     * https://github.com/miguelmota/merkletreejs#notes.
     */
    function claim(bytes32[] calldata proof, uint256 amount) public {
        require(!claimed[msg.sender], "Already claimed");

        require(
            MerkleProof.verifyCalldata(
                proof,
                MERKLE_ROOT,
                keccak256(abi.encode(msg.sender, amount))
            ),
            "Invalid proof"
        );
        claimed[msg.sender] = true;
        TOKEN.safeTransfer(msg.sender, amount);
    }
}