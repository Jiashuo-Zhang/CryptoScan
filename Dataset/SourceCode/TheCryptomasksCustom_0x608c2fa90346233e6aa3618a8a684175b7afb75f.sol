// SPDX-License-Identifier: MIT

// The Cryptomasks Custom
// author: sadat.eth

pragma solidity ^0.8.22;

import "ERC1155.sol";
import "ERC2981.sol";
import "ReentrancyGuard.sol";
import "MerkleProof.sol";
import "Ownable.sol";
import "OperatorFilterer.sol";

contract TheCryptomasksCustom is ERC1155, ERC2981, ReentrancyGuard, Ownable, OperatorFilterer {

    string public name = "The Cryptomasks Custom";
    string public symbol = "MASK";
    struct Drop {
        uint256 tokenId;
        uint256 price;
        uint256 supply;
        uint256 starts;
        uint256 ends;
        uint256 minted;
        string uri;
        bytes32 allowlist;
    }
    mapping(uint256 => Drop) public drops;
    mapping(address => mapping(uint256 => uint256)) public myMints;
    bool public operatorFilteringEnabled;

    error invalidSupply();
    error noSupply();
    error noDrop();
    error noFunds();
    error mintEnded();
    error notAllowed();
    error maxMinted();
    error dropExists();

    constructor(address deployer) ERC1155("") Ownable(deployer) {
        _registerForOperatorFiltering();
        operatorFilteringEnabled = true;
        _setDefaultRoyalty(0xB9aB0B590abC88037a45690a68e1Ee41c5ea7365, 700);
    }

    function createDrop(
        uint256 tokenId,
        uint256 price,
        uint256 supply,
        uint256 time,
        string calldata URI,
        bytes32 allowlist
    ) external onlyOwner {
        if (drops[tokenId].tokenId > 0) revert dropExists();
        drops[tokenId] = Drop(
            tokenId,
            price,
            supply,
            block.timestamp,
            block.timestamp + (time * 1 hours),
            0,
            URI,
            allowlist
        );
    }

    function updateDrop(
        uint256 tokenId,
        uint256 price,
        uint256 supply,
        uint256 time,
        string calldata URI,
        bytes32 allowlist
    ) external onlyOwner {
        if (drops[tokenId].tokenId == 0) revert noDrop();
        if (price != 0) { drops[tokenId].price = price; }
        if (supply != 0) { drops[tokenId].supply = supply; }
        if (time != 0) { drops[tokenId].ends = drops[tokenId].starts + (time * 1 hours); }
        if (bytes(URI).length != 0) { drops[tokenId].uri = URI; }
        if (allowlist != 0x0) { drops[tokenId].allowlist = allowlist; }
    }

    function mintDrop(
        uint256 tokenId,
        uint256 amount,
        uint256 mints,
        bytes32[] calldata proof
    ) external payable {
        Drop storage drop = drops[tokenId];
        if (drop.tokenId == 0) revert noDrop();
        if (block.timestamp > drop.ends) revert mintEnded();
        if (drop.price != 0 && msg.value < drop.price * amount) revert noFunds();
        if (drop.supply != 0 && drop.supply < drop.minted + amount) revert noSupply();
        if (drop.allowlist != 0x0 && myMints[msg.sender][drop.tokenId] + amount > mints) revert maxMinted();
        if (drop.allowlist != 0x0 && !allowed(tokenId, msg.sender, mints, proof)) revert notAllowed();
        _mint(msg.sender, tokenId, amount, "");
        drop.minted += amount;
        myMints[msg.sender][drop.tokenId] += amount;
    }

    function allowed(uint256 tokenId, address wallet, uint256 mints, bytes32[] memory proof) public view returns (bool verify_) {
        return MerkleProof.verify(proof,drops[tokenId].allowlist,keccak256(abi.encodePacked(wallet,mints)));
    }

    function burn(uint256 tokenId, uint256 amount) external {
        if (balanceOf(msg.sender, tokenId) < amount) revert invalidSupply();
        _burn(msg.sender, tokenId, amount);
    }

    function uri(uint256 tokenId) public view virtual override returns (string memory) {
        return drops[tokenId].uri;
    }

    function totalSupply(uint256 tokenId) public view virtual returns (uint256) {
        return drops[tokenId].minted;
    }
    
    function withdraw(address to) public onlyOwner nonReentrant {
        (bool success, ) = payable(to).call{value: address(this).balance}("");
        require(success);
    }

    function setApprovalForAll(address operator, bool approved)
        public
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    // Standard functions override for royalties enforcement

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override onlyAllowedOperator(from) {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC2981)
        returns (bool)
    {
        return ERC1155.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setOperatorFilteringEnabled(bool value) public onlyOwner {
        operatorFilteringEnabled = value;
    }

    function _operatorFilteringEnabled() internal view override returns (bool) {
        return operatorFilteringEnabled;
    }

    function _isPriorityOperator(address operator) internal pure override returns (bool) {
        return operator == address(0x1E0049783F008A0085193E00003D00cd54003c71);
    }
}