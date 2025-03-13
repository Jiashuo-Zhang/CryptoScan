// SPDX-License-Identifier: MIT

// Copyright (c) 2021 TrinityLabDAO



// Permission is hereby granted, free of charge, to any person obtaining a copy

// of this software and associated documentation files (the "Software"), to deal

// in the Software without restriction, including without limitation the rights

// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell

// copies of the Software, and to permit persons to whom the Software is

// furnished to do so, subject to the following conditions:



// The above copyright notice and this permission notice shall be included in all

// copies or substantial portions of the Software.



// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,

// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE

// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER

// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,

// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE

// SOFTWARE.

pragma solidity 0.8.7;



import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./libraries/TransferKey.sol";

import "./libraries/Converter.sol";

import "./libraries/ECDSA.sol";

import {Bridge, Storage} from "./libraries/Struct.sol";

import "./interfaces/IVault.sol";

import "./interfaces/ISpaceStorage.sol";

import "./security/OnlyGovernance.sol";



contract SpaceBridge is ReentrancyGuard,

                        OnlyGovernance {

    using SafeERC20 for IERC20;



    IVault public vault;

    ISpaceStorage public spaceStorage;

    

    uint24 immutable public network_id;

    

    event Lock(

        bytes dst_address, 

        uint24 dst_network,

        uint256 amount, 

        address hash,

        address src_address,

        uint256 nonce

    );



    event Burn(

        bytes dst_address, 

        uint24 dst_network,

        uint256 amount, 

        address hash,

        address src_address,

        uint256 nonce

    );



    event Unlock(

        address dst_address,

        uint256 amount

    );



    event Mint(

        address token_address,

        address dst_address,

        uint256 amount

    );



    //@param id - network id

    constructor(uint24 id){

        network_id = id;

    }



    function setVault(address _vault) onlyGovernance external {

        vault = IVault(_vault);

    }



    function setStorage(address _storage) onlyGovernance external {

        spaceStorage = ISpaceStorage(_storage);

    }



    function getChannelNonce(string memory src_address, string memory src_hash, uint256 src_network, string memory dst_address, uint256 dst_network) external view returns (uint256) {

        bytes32 id = TransferKey.compute(src_address, src_hash, src_network, dst_address, dst_network);

        return spaceStorage.transfers(id);

    }



    function getChannelId(string memory src_address, string memory src_hash, uint256 src_network, string memory dst_address, uint256 dst_network) external pure returns (bytes32) {

        return TransferKey.compute(src_address, src_hash, src_network, dst_address, dst_network);

    }



    //

    // MODIFIER

    //

    modifier checkSetup() {

        require(

                address(vault) != address(0), 

                "Vault not found"

            );

        require(

                address(spaceStorage) != address(0), 

                "Storage not found"

            );

        _;

    }





    //

    // LOCK

    //

    function lock(bytes memory dst_address, uint24 dst_network, uint256 amount, address hash, uint256 nonce) checkSetup nonReentrant external {

        require(

            spaceStorage.known_networks(dst_network).valid,

            "Unknown dst_network"

        );



        require(

            nonce == (spaceStorage.transfers(TransferKey.compute(Converter.toAsciiString(msg.sender), Converter.toAsciiString(hash), network_id, string(abi.encodePacked(dst_address)), dst_network)) + 1),

            "Invalid nonce"

        );



        uint8 src_decimals;

        uint8 dst_decimals;



        src_decimals = ERC20(hash).decimals();

        dst_decimals = spaceStorage.known_networks(dst_network).decimals;

        

        if (dst_decimals < src_decimals)

        require(

            amount % (10 ** (src_decimals - dst_decimals)) == 0,

            "Fraction too low"

        );

        

        require(

                amount <= IERC20(hash).balanceOf(msg.sender), 

                "Token balance is too low"

            );



        require(

                IERC20(hash).allowance(msg.sender, address(vault)) >= amount,

                "Token allowance to Vault too low"

            );



        string memory t = Converter.toAsciiString(hash);

        spaceStorage.addLockMap(t, hash);



        if(bytes(spaceStorage.minted(hash).origin_hash).length == 0){

            vault.deposit(hash, msg.sender, amount);

            emit Lock(dst_address, dst_network, amount, hash, msg.sender, nonce);

        }else{

            vault.burn(hash, msg.sender, amount);

            emit Burn(dst_address, dst_network, amount, hash, msg.sender, nonce);

        }



        spaceStorage.incrementNonce(TransferKey.compute(Converter.toAsciiString(msg.sender), Converter.toAsciiString(hash), network_id, string(abi.encodePacked(dst_address)), dst_network));



    }



    //

    // CLAIM

    //

    function claim(Bridge.TICKET memory ticket, ECDSA.SIGNATURES[] memory signatures) checkSetup nonReentrant external {

        require(

            ticket.dst_network == network_id,

            "Invalid destination network id"

        );

        require(

            ticket.nonce == (spaceStorage.transfers(TransferKey.compute(ticket.src_address, ticket.src_hash, ticket.src_network, Converter.toAsciiString(ticket.dst_address), ticket.dst_network)) + 1),

            "Invalid nonce"

        );

        bytes32 data_hash = Converter.ethMessageHash(

            Converter.ethTicketHash(ticket)

        );

        require(

            ECDSA.verify(data_hash, signatures, spaceStorage), 

            "Invalid signature"

        );



        if((ticket.origin_network == ticket.src_network) || ((ticket.origin_network != ticket.src_network) && (ticket.origin_network != network_id))) {

            address token_address = spaceStorage.getAddressFromOriginHash(ticket.origin_hash);

            if(token_address == address(0x0)){

                bytes memory bytes_hash = bytes(ticket.origin_hash);

                token_address = vault.deploy(

                    string(abi.encodePacked(ticket.name)), 

                    string(abi.encodePacked(ticket.symbol)), 

                    ticket.origin_network, 

                    bytes_hash,

                    ticket.origin_decimals);

                spaceStorage.addMinted(

                    token_address, 

                    ticket.origin_hash, 

                    Storage.TKN({

                        origin_network: ticket.origin_network, 

                        origin_hash: ticket.origin_hash,

                        origin_decimals: ticket.origin_decimals})

                );

            }

            vault.mint(token_address, ticket.dst_address, ticket.amount);

            emit Mint(token_address, ticket.dst_address, ticket.amount);

        } else {

            vault.withdraw(spaceStorage.lock_map(ticket.origin_hash), ticket.dst_address, ticket.amount);

            emit Unlock(ticket.dst_address, ticket.amount);

        }

        spaceStorage.incrementNonce(TransferKey.compute(ticket.src_address, ticket.src_hash, ticket.src_network, Converter.toAsciiString(ticket.dst_address), ticket.dst_network));

    }

}