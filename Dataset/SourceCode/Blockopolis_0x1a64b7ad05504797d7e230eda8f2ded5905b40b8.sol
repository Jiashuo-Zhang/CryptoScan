/*

 ________  ___       ________  ________  ___  __    ________  ________  ________  ___       ___  ________      
|\   __  \|\  \     |\   __  \|\   ____\|\  \|\  \ |\   __  \|\   __  \|\   __  \|\  \     |\  \|\   ____\     
\ \  \|\ /\ \  \    \ \  \|\  \ \  \___|\ \  \/  /|\ \  \|\  \ \  \|\  \ \  \|\  \ \  \    \ \  \ \  \___|_    
 \ \   __  \ \  \    \ \  \\\  \ \  \    \ \   ___  \ \  \\\  \ \   ____\ \  \\\  \ \  \    \ \  \ \_____  \   
  \ \  \|\  \ \  \____\ \  \\\  \ \  \____\ \  \\ \  \ \  \\\  \ \  \___|\ \  \\\  \ \  \____\ \  \|____|\  \  
   \ \_______\ \_______\ \_______\ \_______\ \__\\ \__\ \_______\ \__\    \ \_______\ \_______\ \__\____\_\  \ 
    \|_______|\|_______|\|_______|\|_______|\|__| \|__|\|_______|\|__|     \|_______|\|_______|\|__|\_________\
                                                                                                   \|_________|
                                              blockopolis.xyz
                                              @BlockopolisNFT                                                                                                               

*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "erc721a/contracts/ERC721A.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

contract Blockopolis is Ownable, ERC721A, ReentrancyGuard {
    uint256 public constant MAX_SUPPLY = 3456;
    uint256 public constant PRICE = 0.003456 ether;

    bytes32 public merkleRootWL;
    mapping(address => uint256) public wlClaimed;

    string public baseURI;
    uint256 public phase; // 0 = INIT, 1 = XZEROS/WL, 2 = PUBLIC

    constructor(string memory _initBaseURI) ERC721A("Blockopolis", "BLOPO") {
        baseURI = _initBaseURI;
    }

    /** OWNER */

    function setBaseURI(string memory _uri) external onlyOwner {
        baseURI = _uri;
    }

    function setPhase(uint256 _phase) external onlyOwner {
        phase = _phase;
    }

    function setMerkleRootWL(bytes32 _merkleRoot) external onlyOwner {
        merkleRootWL = _merkleRoot;
    }

    function withdrawETH() external onlyOwner nonReentrant {
        uint256 amount = address(this).balance;

        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    function withdrawERC20(address erc20) external onlyOwner {
        uint256 amount = IERC20(erc20).balanceOf(address(this));

        IERC20(erc20).transfer(owner(), amount);
    }

    /** PUBLIC */

    function mint(uint256 quantity) external payable {
        require(_totalMinted() + quantity <= MAX_SUPPLY, "EXCEEDS SUPPLY");
        require(msg.value >= PRICE * quantity, "NOT ENOUGH ETH");
        require(phase == 2, "PUBLIC SALE NOT STARTED");

        _mint(msg.sender, quantity);
    }

    function wlMint(
        bytes32[] calldata _merkleProof,
        uint256 maxAmount,
        uint256 quantity
    ) external {
        require(phase >= 1, "WL MINT NOT STARTED YET");
        require(_totalMinted() + quantity <= MAX_SUPPLY, "EXCEEDS SUPPLY");
        require(
            wlClaimed[msg.sender] + quantity <= maxAmount,
            "EXCEEDS MAX WL MINT AMOUNT"
        );

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, maxAmount));
        require(
            MerkleProof.verify(_merkleProof, merkleRootWL, leaf),
            "NOT IN WHITELIST"
        );

        wlClaimed[msg.sender] += quantity;

        _mint(msg.sender, quantity);
    }

    function totalMinted() external view returns (uint256) {
        return _totalMinted();
    }

    /** INTERNAL / OVERRIDES */

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }
}