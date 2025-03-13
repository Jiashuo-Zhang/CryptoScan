//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import './ShurikenNFT.sol';
import './ShurikenStakedNFT.sol';
import './PassportNFT.sol';

contract CALMinterV4 is ReentrancyGuard, Ownable {
    enum Phase {
        BeforeMint,
        WLMint,
        PublicMint
    }

    ShurikenNFT public immutable shurikenNFT;
    PassportNFT public immutable passportNFT;

    Phase public phase = Phase.WLMint;
    bytes32 public merkleRoot = 0xd83055a93f1b0999437b2336ef3f7a502e159e266cf76a0c009ced7bdfd7c09f;

    uint256 public cardCost = 0.02 ether;
    uint256 public shurikenCost = 0.008 ether;
    uint256 public shurikenSupply = 50000;
    uint256 public maxShurikenMint = 100;

    constructor(ShurikenNFT _shurikenNFT, PassportNFT _passportNFT) {
        shurikenNFT = _shurikenNFT;
        passportNFT = _passportNFT;
    }

    function mint(
        bool _card,
        uint256 _shurikenAmount,
        uint256 _wlCount,
        bytes32[] calldata _merkleProof
    ) external payable nonReentrant {
        require(phase == Phase.WLMint, 'WLMint is not active.');
        require(_card || passportNFT.balanceOf(_msgSender()) == 1, 'Passport required.');
        uint256 card = _card ? cardCost : 0;
        uint256 shuriken = shurikenCost * _shurikenAmount;
        require(_card || _shurikenAmount > 0, 'Mint amount cannot be zero');
        if (_shurikenAmount != 0) {
            require(
                shurikenNFT.currentIndex() + _shurikenAmount - 1 <= shurikenSupply,
                'Total supply cannot exceed shurikenSupply'
            );
            require(_shurikenAmount <= maxShurikenMint, 'Address already claimed max amount');
        }
        require(msg.value >= (card + shuriken), 'Not enough funds provided for mint');

        bytes32 leaf = keccak256(abi.encodePacked(_msgSender(), _wlCount));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid Merkle Proof');

        if (_card) {
            require(passportNFT.balanceOf(_msgSender()) == 0, 'Address already claimed max amount');
            passportNFT.minterMint(_msgSender(), 1);
        }

        if (_shurikenAmount != 0) {
            shurikenNFT.minterMint(_msgSender(), _shurikenAmount);
        }
    }

    function publicMint(
        bool _card,
        uint256 _shurikenAmount
    ) external payable nonReentrant {
        require(phase == Phase.PublicMint, 'PublicMint is not active.');
        require(_card || passportNFT.balanceOf(_msgSender()) == 1, 'Passport required.');
        uint256 card = _card ? cardCost : 0;
        uint256 shuriken = shurikenCost * _shurikenAmount;
        require(_card || _shurikenAmount > 0, 'Mint amount cannot be zero');
        if (_shurikenAmount != 0) {
            require(
                shurikenNFT.currentIndex() + _shurikenAmount - 1 <= shurikenSupply,
                'Total supply cannot exceed shurikenSupply'
            );
            require(_shurikenAmount <= maxShurikenMint, 'Address already claimed max amount');
        }
        require(msg.value >= (card + shuriken), 'Not enough funds provided for mint');

        if (_card) {
            require(passportNFT.balanceOf(_msgSender()) == 0, 'Address already claimed max amount');
            passportNFT.minterMint(_msgSender(), 1);
        }

        if (_shurikenAmount != 0) {
            shurikenNFT.minterMint(_msgSender(), _shurikenAmount);
        }
    }

    function setPhase(Phase _newPhase) external onlyOwner {
        phase = _newPhase;
    }

    function setCardCost(uint256 _cardCost) external onlyOwner {
        cardCost = _cardCost;
    }

    function setShurikenCost(uint256 _shurikenCost) external onlyOwner {
        shurikenCost = _shurikenCost;
    }

    function setShurikenSupply(uint256 _shurikenSupply) external onlyOwner {
        shurikenSupply = _shurikenSupply;
    }

    function setMaxShurikenMint(uint256 _maxShurikenMint) external onlyOwner {
        maxShurikenMint = _maxShurikenMint;
    }

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function withdraw(address payable withdrawAddress) external onlyOwner {
        (bool os, ) = withdrawAddress.call{value: address(this).balance}('');
        require(os);
    }
}