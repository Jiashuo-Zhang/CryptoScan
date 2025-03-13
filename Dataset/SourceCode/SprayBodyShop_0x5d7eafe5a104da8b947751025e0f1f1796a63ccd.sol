// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../pings/Pings.sol";
import "../Planes.sol";
import "../Structs.sol";
import "../enhance/ISprayData.sol";
import "./SprayData.sol";

contract SprayBodyShop is ReentrancyGuard, Ownable{
    Planes public _skies;
    Pings public _pings;
    ISprayData public _sprayData;

    address public _graveyard = address(0);
    bool public _paintshopOpen = false;

    function sprayPlane(uint skiesId, uint pingId) external nonReentrant {
        require(_paintshopOpen, "Shop closed");
        address owner = _skies.ownerOf(skiesId);
        require(msg.sender == owner || _skies.getApproved(skiesId) == msg.sender || _skies.isApprovedForAll(owner, msg.sender), "sky !owner");

        _sprayData.setPaintType(skiesId, uint8(PaintTypes.Solid));
        _sprayData.pushPingId(skiesId, pingId);

        _pings.transferFrom(msg.sender, _graveyard, pingId);
    }

    function setSkies(address addr) external onlyOwner {
        _skies = Planes(addr);
    }

    function setPings(address addr) external onlyOwner {
        _pings = Pings(addr);
    }

    function setSprayData(address addr) external onlyOwner {
        _sprayData = SprayData(addr);
    }

    function setGraveyard(address addr) external onlyOwner {
        _graveyard = addr;
    }

    function setOpen(bool opened) external onlyOwner {
        _paintshopOpen = opened;
    }

    function check() external view {
        require(address(_skies) != address(0), "skies addr");
        require(address(_pings) != address(0), "pings addr");
        require(address(_graveyard) != address(0), "grave addr");
        require(address(_sprayData) != address(0), "data addr");
        require(_sprayData.hasRole(_sprayData.getWriteRole(), address(this)), "!write");
    }

}