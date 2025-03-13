// contracts/DeVontaSmithTradingCard.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EndstateMintableNFT.sol";

/**
 * @title DeVonta Smith Trading Card
 */
contract DeVontaSmithTradingCard is EndstateMintableNFT
{

   constructor()
        EndstateMintableNFT(
            "DeVonta Smith Trading Card"
        )
    {}
}