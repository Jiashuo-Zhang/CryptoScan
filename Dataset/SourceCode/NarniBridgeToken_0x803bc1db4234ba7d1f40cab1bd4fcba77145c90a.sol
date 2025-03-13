pragma solidity ^0.8.18;



import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";



contract NarniBridgeToken is ERC20PresetMinterPauser {

    

    constructor(uint256 initial_supply) ERC20PresetMinterPauser("Narni Bridge Token", "NARNI") {

        _mint(msg.sender, initial_supply);

    }



}