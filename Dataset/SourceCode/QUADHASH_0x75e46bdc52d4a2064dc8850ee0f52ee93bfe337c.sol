// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract QUADHASH is ERC721, Pausable, ERC721Burnable, AccessControl, DefaultOperatorFilterer {

    using Strings for uint256;

    bytes32 public constant TEAM_ROLE = keccak256("TEAM_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 private _totalSupply;
    string  private _currentBaseURI;

    mapping(uint256 => bool) private _restrictedToken;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TEAM_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function _baseURI() internal view override returns (string memory) {
        return _currentBaseURI;
    }

    function setBaseURI(string calldata baseURI) external onlyRole(ADMIN_ROLE) {
        _currentBaseURI = baseURI;
    }

    function restrict(uint256 tokenId) external onlyRole(TEAM_ROLE) {
        _restrictedToken[tokenId] = true;
    }

    function unrestrict(uint256 tokenId) external onlyRole(ADMIN_ROLE) {
        _restrictedToken[tokenId] = false;
    }

    function restricted(uint256 tokenId) external view returns (bool) {
        return _restrictedToken[tokenId];
    }

    function pause() public onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 tokenId) public onlyRole(ADMIN_ROLE) {
        _mint(to, tokenId);
    }

    //NFTs involved in crimes, such as hacking, can be burned through a community report.
    function burnByAdmin(uint256 tokenId) public onlyRole(ADMIN_ROLE) {
        _burn(tokenId);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Invalid token ID");

        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function _mint(address to, uint256 tokenId) internal override {
        _totalSupply += 1;
        super._mint(to, tokenId);
    }

    function _burn(uint256 tokenId) internal override {
        _totalSupply -= 1;
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
        if (from != address(0) && to != address(0)) {
            require(!_restrictedToken[tokenId], "Restrict: restricted");
            require(!paused(), "Pausable: paused");
        }
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Operator Filter
    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}