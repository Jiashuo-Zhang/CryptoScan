// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import 'erc721a/contracts/ERC721A.sol';
import 'operator-filter-registry/src/DefaultOperatorFilterer.sol';
import './TMAs.sol';

contract TMAsMinter is Ownable {
    enum Phase {
        BeforeMint,
        PreMint1
    }
    TMAs public immutable tmas;

    uint256 public maxSupply = 7000;

    Phase public phase = Phase.BeforeMint;

    mapping(Phase => mapping(address => uint256)) public minted;
    mapping(Phase => uint256) public limitedPerWL;
    mapping(Phase => bytes32) public merkleRoot;

    constructor(TMAs _tmas) {
        tmas = _tmas;
        limitedPerWL[Phase.PreMint1] = 1;
    }

    // internal
    function _mintCheck(uint256 _mintAmount) internal view {
        require(_mintAmount > 0, 'Mint amount cannot be zero');
        require(tmas.totalSupply() + _mintAmount <= maxSupply, 'Total supply cannot exceed maxSupply');
    }

    // public
    function preMint(
        uint256 _mintAmount,
        uint256 _wlCount,
        bytes32[] calldata _merkleProof
    ) public {
        require(phase == Phase.PreMint1, 'PreMint is not active.');
        _mintCheck(_mintAmount);

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _wlCount));
        require(MerkleProof.verify(_merkleProof, merkleRoot[phase], leaf), 'Invalid Merkle Proof');

        require(
            minted[phase][msg.sender] + _mintAmount <= _wlCount * limitedPerWL[phase],
            'Address already claimed max amount'
        );

        minted[phase][msg.sender] += _mintAmount;
        tmas.minterMint(msg.sender, _mintAmount);
    }

    // external (only owner)
    function setmaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function setPhase(Phase _newPhase) external onlyOwner {
        phase = _newPhase;
    }

    function setLimitedPerWL(Phase _phase, uint256 _number) external onlyOwner {
        limitedPerWL[_phase] = _number;
    }

    function setMerkleRoot(Phase _phase, bytes32 _merkleRoot) external onlyOwner {
        merkleRoot[_phase] = _merkleRoot;
    }
}