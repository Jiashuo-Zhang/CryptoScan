//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC721 {
    function ownerMint(address _receiver, uint256 _amount) external;

    function transferOwnership(address newOwner) external;

    function cost() external returns (uint256);
}

contract OwnerRouter is Ownable {
    // 対象のNFTのコントラクトアドレス
    address public contractAddress;

    // 支払い先のアドレス
    address public payAddress;

    // マークルルート
    bytes32 public merkleRoot;

    bool public isPublic;

    constructor(address _contractAddress, address _payAddress) {
        contractAddress = _contractAddress;
        payAddress = _payAddress;
        merkleRoot = 0x95bd05ddaa0a6653bc08f5024e18255f966e5e31790eeab2a25bd2a8eed538dd;
        isPublic = false;
    }

    // プレセールのミント関数
    function mint(
        uint256 _mintAmount,
        uint256 _maxMintAmount,
        bytes32[] calldata _merkleProof
    ) public payable {
        bytes32 _leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender, _maxMintAmount)))
        );
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, _leaf),
            "user is not allowlisted"
        );
        uint256 _cost = IERC721(contractAddress).cost();
        require(msg.value >= _cost * _mintAmount, "not enough ether sent");
        IERC721(contractAddress).ownerMint(msg.sender, _mintAmount);
        payable(payAddress).transfer(msg.value);
    }

    // パブリックセールのミント関数
    function publicMint(uint256 _mintNum) public payable {
        require(isPublic, "public sale is not started");
        uint256 _cost = IERC721(contractAddress).cost();
        require(msg.value >= _cost * _mintNum, "not enough ether sent");
        IERC721(contractAddress).ownerMint(msg.sender, _mintNum);
        payable(payAddress).transfer(msg.value);
    }

    // オーナーのみ実行可能なミント関数
    function ownerMint(address _receiver, uint256 _amount) public onlyOwner {
        IERC721(contractAddress).ownerMint(_receiver, _amount);
    }

    // 対象のコントラクトアドレスの変更関数
    function setContractAddress(address _contractAddress) public onlyOwner {
        contractAddress = _contractAddress;
    }

    // マークルルートの変更関数
    function setMerkleRoot(bytes32 _newMerkleRoot) external onlyOwner {
        merkleRoot = _newMerkleRoot;
    }

    // 支払い先の変更関数
    function setOwnership(address _newOwner) external onlyOwner {
        IERC721(contractAddress).transferOwnership(_newOwner);
    }

    // パブリックセールの開始関数
    function setIsPublic(bool _newIsPublic) external onlyOwner {
        isPublic = _newIsPublic;
    }
}