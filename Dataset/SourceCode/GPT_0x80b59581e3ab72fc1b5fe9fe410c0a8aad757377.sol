// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

contract GPT is ERC20, AccessControl {
    bytes32 public constant MINT_BURNER_ROLE = keccak256("MINT_BURNER_ROLE");
    mapping(bytes32 => string[]) public compensatedData;
    string[] public cprLinks;

    event Generated(address indexed burned, bytes32 dataHash);

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        string[] memory _cprLinks
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINT_BURNER_ROLE, msg.sender);
        cprLinks = _cprLinks;
    }

    function mint(
        address to,
        uint256 amount
    ) public onlyRole(MINT_BURNER_ROLE) {
        _mint(to, amount);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function _generate(string[] memory data) internal returns (bytes32) {
        bytes32 _generatedHash = keccak256(abi.encode(data));
        compensatedData[_generatedHash] = data;
        return _generatedHash;
    }

    function _burnFrom(address from, uint256 amount) internal returns (bool) {
        _burn(from, amount);
        return true;
    }

    function compensate(
        address from,
        uint256 amount,
        string[] memory data
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        bytes32 _generatedHash = _generate(data);
        _burnFrom(from, amount);
        emit Generated(from, _generatedHash);
        return (true);
    }

    function burn(
        address from,
        uint256 amount
    ) public onlyRole(MINT_BURNER_ROLE) returns (bool) {
        return _burnFrom(from, amount);
    }

    function giveMintBurnRole(
        address to
    ) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        _grantRole(MINT_BURNER_ROLE, to);
        return (true);
    }
}