// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;



import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

import {MintGate} from "@esportsplus/erc721/contracts/libraries/MintGate.sol";

import {Withdrawable} from "@esportsplus/erc721/contracts/utilities/Withdrawable.sol";

import {ERC20, ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

import {LOOTBOARD_MAX_TILES, LOOTBOARD_SIGNER, LOOTBOARD_TILE_PRICE} from './Constants.sol';



error ClaimFailed();

error InvalidMaxTile();

error InvalidSignature();

error PurchaseFailed();



contract Loot is ERC20Burnable, Ownable, Withdrawable {

    using BitMaps for BitMaps.BitMap;

    using ECDSA for bytes32;





    event Purchased(address indexed account, uint256[] tiles);





    BitMaps.BitMap private _claimed;



    BitMaps.BitMap private _purchased;





    uint256 public _i;



    uint256 public _maxTile = 22500;



    uint256 public _price = LOOTBOARD_TILE_PRICE;



    address public _signer = LOOTBOARD_SIGNER;





    constructor() ERC20("Loot", "LOOT") {}





    function _isValidSignature(bytes32 message, bytes memory signature) internal view returns (bool) {

        return message.toEthSignedMessageHash().recover(signature) == _signer;

    }



    function _isValidTile(uint256 tile) internal view returns (bool) {

        return tile > 0 && tile <= _maxTile;

    }





    function claim(bytes memory signature, uint256[] calldata tiles, uint256 tokens) external {

        address account = msg.sender;

        uint256[] memory available = claimable(tiles);

        uint256 i = available.length;



        if (i != tiles.length) {

            revert ClaimFailed();

        }



        while (i != 0) {

            unchecked {

                --i;

            }



            _claimed.set(tiles[i]);

        }



        if (!_isValidSignature(keccak256(abi.encodePacked(account, tiles, tokens)), signature)) {

            revert InvalidSignature();

        }



        _mint(account, tokens);

    }



    function claimable(uint256[] calldata tiles) public view returns(uint256[] memory) {

        uint256 i = tiles.length;

        uint256 quantity = 0;

        uint256[] memory unfiltered = new uint256[](i);



        while (i != 0) {

            unchecked {

                --i;

            }



            uint256 tile = tiles[i];



            if (!_isValidTile(tile) || _claimed.get(tile) || !_purchased.get(tile)) {

                continue;

            }



            unchecked {

                unfiltered[quantity++] = tile;

            }

        }



        if (quantity == unfiltered.length) {

            return unfiltered;

        }



        uint256[] memory filtered = new uint256[](quantity);



        while (quantity != 0) {

            unchecked {

                --quantity;

            }



            filtered[quantity] = unfiltered[quantity];

        }



        return filtered;

    }



    function decimals() public view virtual override returns (uint8) {

        return 0;

    }



    function purchase(uint256[] calldata tiles) external payable {

        uint256 i = tiles.length;

        uint256 quantity = 0;

        uint256[] memory unfiltered = new uint256[](i);



        while (i != 0) {

            unchecked {

                --i;

            }



            uint256 tile = tiles[i];



            if (!_isValidTile(tile) || _purchased.get(tile)) {

                continue;

            }



            _purchased.set(tile);



            unchecked {

                unfiltered[quantity++] = tile;

            }

        }



        if (quantity == 0) {

            revert PurchaseFailed();

        }



        MintGate.price(msg.sender, _price, quantity, msg.value);

        MintGate.supply(LOOTBOARD_MAX_TILES - _i, quantity);



        unchecked {

            _i += quantity;

        }



        uint256[] memory filtered = new uint256[](quantity);



        while (quantity != 0) {

            unchecked {

                --quantity;

            }



            filtered[quantity] = unfiltered[quantity];

        }



        emit Purchased(msg.sender, filtered);

    }



    function setMaxTile(uint256 max) external onlyOwner {

        if (max > LOOTBOARD_MAX_TILES) {

            revert InvalidMaxTile();

        }



        _maxTile = max;

    }



    function setPrice(uint256 price) public onlyOwner {

        _price = price;

    }



    function setSigner(address signer) public onlyOwner {

        _signer = signer;

    }



    function withdraw() external onlyOwner {

        uint256 balance = address(this).balance;



        _withdraw(0x976A1082fE55bF2ef50e62aedADA4ccDf4088191, (balance * 5000) / 10000);

        _withdraw(0x5c45aFc97acd8DF074F765507c5bD41A7ec7a8eA, (balance * 4000) / 10000);

        _withdraw(0x3BCe6a0C6d20C56A2942838187dEd2540B292B27, address(this).balance);

    }

}