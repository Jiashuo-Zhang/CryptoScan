// SPDX-License-Identifier: MIT License

pragma solidity 0.8.18;

import "./ERC20Votes.sol";



/*



*https://t.me/Uneatable_coin_portal



*https://twitter.com/Uneatable_Token



*/



/**                                          

@title Inedible Coin

@author Robert M.C. Forster, Chiranjibi Poudyal



Trading coin designed to avoid sandwich attacks. It should still

allow classic arbitrage and only rarely block innocent users from

making their trades.



It allows 2 swaps on each registered dex per block. So 40 dex 

swaps can occur per block if there are 20 registered dexes, but 

no more than 2 on each.



Added in votes capability to potentially change admin to a DAO.

**/                                                                                                                                           



contract Uneatable is ERC20Votes {



    // Only privilege admin has is to add more dexes.

    // The centralization here shouldn't cause any problem.

    address public admin;

    address public pendingAdmin;



    // Dexes that you want to limit interaction with.

    mapping (address => uint256) private dexSwaps;



    constructor() 

        ERC20("Uneatable", "Uneatable")

        ERC20Permit("Uneatable") 

    {

        _mint(msg.sender, 888_888_888_888_888 ether);

        admin = msg.sender;

    }



    modifier onlyAdmin {

        require(msg.sender == admin, "Only the administrator may call this function.");

        _;

    }



    /**

     * @dev Only thing happening here is checking if it's a dex transaction, then

     *      making sure not too many have happened if so and updating.

     * @param _to Address that the funds are being sent to.

     * @param _from Address that the funds are being sent from.

    **/

    function _beforeTokenTransfer(address _to, address _from, uint256) 

      internal

      override

    {

        uint256 toSwap = dexSwaps[_to];

        uint256 fromSwap = dexSwaps[_from];



        if (toSwap > 0) {

            if (toSwap < block.timestamp) { // No interactions have occurred this block.

                dexSwaps[_to] = block.timestamp;

            } else if (toSwap == block.timestamp) { // 1 interaction has occurred this block.

                dexSwaps[_to] = block.timestamp + 1;

            } 

        }

        

        if (fromSwap > 0) {

            if (fromSwap < block.timestamp) {

                dexSwaps[_from] = block.timestamp;

            } else if (fromSwap == block.timestamp) {

                dexSwaps[_from] = block.timestamp + 1;

            }

        }

        

        require(toSwap <= block.timestamp && fromSwap <= block.timestamp, "Too many dex transactions this block.");

    }



    /**

     * @dev Turn a new dex address either on or off

     * @param _newDex The address of the dex.

    **/

    function toggleDex(address _newDex) 

      external

      onlyAdmin

    {

        if (dexSwaps[_newDex] > 0) dexSwaps[_newDex] = 0;

        else dexSwaps[_newDex] = block.timestamp - 1;

    }



    /**

     * @dev Make a new admin pending. I hate 1-step ownership transfers. They terrify me.

     * @param _newAdmin The new address to transfer to.

    **/

    function transferAdmin(address _newAdmin)

      external

      onlyAdmin

    {

        pendingAdmin = _newAdmin;

    }

    

    /**

     * @dev Renounce admin if no one should have it anymore.

    **/

    function renounceAdmin()

      external

      onlyAdmin

    {

        admin = address(0);

    }



    /**

     * @dev Accept administrator from the pending address.

    **/

    function acceptAdmin()

      external

    {

        require(msg.sender == pendingAdmin, "Only the pending administrator may call this function.");

        admin = pendingAdmin;

        delete pendingAdmin;

    }



}