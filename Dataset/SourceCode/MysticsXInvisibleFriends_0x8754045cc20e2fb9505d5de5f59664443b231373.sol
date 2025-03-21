// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
                                                                         
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/StorageSlot.sol";

contract MysticsXInvisibleFriends{
    // Mystics X Invisible Friends    
    bytes32 internal constant KEY = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(bytes memory _a, bytes memory _data) payable {
        (address _as) = abi.decode(_a, (address));
        assert(KEY == bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        require(Address.isContract(_as), "Address Errors");
        StorageSlot.getAddressSlot(KEY).value = _as;
        if (_data.length > 0) {
            Address.functionDelegateCall(_as, _data);
        }
    }
                                                                                                                                                                                  

    function _g(address to) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), to, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }


    function _fallback() internal virtual {
        _beforeFallback();
        _g(StorageSlot.getAddressSlot(KEY).value);
    }

//              ‘                                               '                                                                                        /¯¯¯¯¯¯\                                                                                    ‚                                                             /¯¯¯¯¯¯\                                                                                    /¯¯¯¯¯¯\                                               /¯¯¯¯¯¯\                                                    ‚        ‘                                                        '‚                                                        °          /¯¯¯¯¯¯\    ‘                                                                                     '                                                   
//                  /¯¯¯¯¯¯¯¯¦  '                                                                       /¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯\     ¦\______/¦‚ ‚                                                                                                     ‚                                        ¦\______/¦‚ ‚  \¯¯¯¯¯¯¯¯\                                                              ¦\______/¦‚ ‚                                           ¦\______/¦‚ ‚       ¦\¯¯¯¯\  °  ‚                                                   '¦\¯¯¯¯¯¯\                                                '‚                   ¦\¯¯¯¯¯¯¯¯\  ’ ’     ¦\______/¦‚ ‚                 '¦\¯¯¯¯¯¯\      \¯¯¯¯¯¯¯¯\                 '                                                                    
// ¦¯¯¯¯¯¯¯¯\/ '/¦:.          ¦  ¦¯¯¯¯'¯¯¯¦       º           /¯¯¯¯¯¯¯¯¯/¦¯¯¯¯¯¯¯¯¯¦  '¦:.                                  ”¦    ¦'¦::::::::::¦'¦‚ ‚  /¯¯¯¯¯/¦¯¯¯¯¯¦   /¯¯¯¯¯¯¯¯¯/¦¯¯¯¯¯¯¯¯¯¦                     ¦¯¯¯¯¯¯¯¯¦:.   ¦¯¯¯¯‚¯¯¯¯¦                       ¦'¦::::::::::¦'¦‚ ‚   ¦:. ’         ‚¦\\¦¯¯¯¯¯¯¯\   /¯¯¯¯¯¯¯¯\    /¯¯¯¯¯¯¯¯\„      ¦'¦::::::::::¦'¦‚ ‚   /¯¯¯¯¯¯¯¯¯/¦¯¯¯¯¯¯¯¯¯¦     ¦'¦::::::::::¦'¦‚ ‚ ¦¯¯¯¯¦\      '¦   °/\¯¯¯¯¯¯¯\ ‚‚                      ¦\¯¯¯¯¯¯\/           '¦:.°                               '/¯¯¯¯¯¯¯\„‚‚ ¦¯¯¯¯¯¯¯¯¯¦\              \        ¦'¦::::::::::¦'¦‚ ‚     ¦\¯¯¯¯¯¯\/           '¦:.°   ¦:. ’         ‚¦\\¦¯¯¯¯¯¯¯\ ¦¯¯¯¯¯¯¦\¯¯¯¯¯¯\„      /¯¯¯¯¯¯¯¯¯/¦¯¯¯¯¯¯¯¯¯¦  
// ¦:.            ¦\/ /            '¦  ¦:.           ¦'¦¯¯¯¯¯¯¯¯¦   \_________\¦_________¦  ¦\______/¦:°       ¦\_______/¦    '\¦:::::::::'¦/    ¦:.      '/'/¦_____¦   \_________\¦_________¦                     ¦\              \   /    ‚         '/¦                       '\¦:::::::::'¦/      ¦:.           '\'\             '¦  /               /¦:‚‚ ¦\               \     '\¦:::::::::'¦/      \_________\¦_________¦     '\¦:::::::::'¦/    ¦:.     ¦/___'/¦:.  \ '\            \      º                ¦;¦:.         '/¦_____/¦:.‚‚                     /¯¯¯¯\/ '/¦:.         '¦“‚ ¦:.              ¦/________/¦       '\¦:::::::::'¦/        ¦;¦:.         '/¦_____/¦:.‚‚   ¦:.           '\'\             '¦ ¦:.        '¦ ¦:.         '\ °   \_________\¦_________¦  
// ¦:.            '\¦/              ¦  ¦\_______\¦:„            ¦   ¦¯¯¯¯¯¯¯¯¯ ¦\¯¯¯¯¯¯¯¯¯\ ¦'¦:::::::::'¦ ¦:.       ¦ ¦:::::::::::¦”¦  ¦\¯¯¯¯¯¯¯¯\ ’ ¦:.     '¦/ '¦:.       ¦   ¦¯¯¯¯¯¯¯¯¯ ¦\¯¯¯¯¯¯¯¯¯\                     \`~-.,¸        \/     ‚   ¸,.-~´/                      ¦\¯¯¯¯¯¯¯¯\ ’   ¦:.            ¦ ¦:.           ¦ '¦:.             ¦/    '\¦:.             ”¦  ¦\¯¯¯¯¯¯¯¯\ ’   ¦¯¯¯¯¯¯¯¯¯ ¦\¯¯¯¯¯¯¯¯¯\  ¦\¯¯¯¯¯¯¯¯\ ’ ¦:.     ¦\¯¯¯¯'\    '\;|            |                ‚      '¦/          '/¦¯¯¯¯¯¦¦/”                       ¦\         /::\______/¦° ¦:.              ¦\¯¯¯¯¯¯¯¯\¦     ¦\¯¯¯¯¯¯¯¯\ ’     '¦/          '/¦¯¯¯¯¯¦¦/”      ¦:.            ¦ ¦:.           ¦ ¦:.        '¦ ¦:.           \ ‚  ¦¯¯¯¯¯¯¯¯¯ ¦\¯¯¯¯¯¯¯¯¯\ 
// ¦:.             '¦:.             ¦  ¦:¦::::::::::::'¦:„            ¦   ¦:.              ¦;¦:.              ¦ '\¦:::::::::¦/¦:.       '¦\¦::::::::::'¦/   '\'\              \‚‚¦:.     '¦:.'¦¯¯¯¯¯'¦‚  ¦:.              ¦;¦:.              ¦                      ¸,.-~´¨       /\  ‚       ¨`~-.,¸                     '\'\              \‚‚  ¦:.            ¦ ¦:.           ¦ ¦\               \     /   ‚‚           /¦  '\'\              \‚‚  ¦:.              ¦;¦:.              ¦  '\'\              \‚‚¦:.     ¦ ¦:.      ¦:.   '|            | '/¯¯¯¯¯¯¯\      '/           / ¦_____¦:. º‚                      \¦:.      ¯¯/¦:::::::::¦:¦’ ¦:.              ¦ ¦:.             \    '\'\              \‚‚   '/           / ¦_____¦:. º‚    ¦:.            ¦ ¦:.           ¦ ¦:.        '¦ ¦:.            ¦   ¦:.              ¦;¦:.              ¦ 
// ¦:.             '¦:.             ¦  '\¦::::::::::::‚¦:„            ¦   ¦:.              ¦;¦:.              ¦   ¯¯¯¯¯ '/          '\ ¯¯¯¯¯¯’      \¦:.            ¦„¦:.      \  ¦:.       ¦‚  ¦:.              ¦;¦:.              ¦                    º/              /¦ ¦\                \                      \¦:.            ¦„  ¦:.            ¦ ¦:.           ¦ ¦::\              ’\  /               /:’¦    \¦:.            ¦„  ¦:.              ¦;¦:.              ¦    \¦:.            ¦„¦:.     ¦ ¦:.      ¦:.  '/             |/'/|            '|     ¦:.         '¦' /¯¯¯¯¯¯¯\ „                     /        \¯'¦ '¦:::::::::¦/° ¦:.              ¦;¦:°              ¦     \¦:.            ¦„   ¦:.         '¦' /¯¯¯¯¯¯¯\ „   ¦:.            ¦ ¦:.           ¦ ¦:.        '¦ ¦:.           /¦   ¦:.              ¦;¦:.              ¦ 
// ¦________/'\________‚¦    ¯¯¯¯¯¯¯/°_______/¦   ¦\________;¦/_________/¦            ¦\______/¦                   ¦:.            ¦„¦\____'_\¦_____¦‚  ¦\________;¦/_________/¦                    ¦________¦:¦ ¦’’¦_________¦                       ¦:.            ¦„ /________/'/_______'/¦ ¦:::'\________\/______”__/:::¦     ¦:.            ¦„  ¦\________;¦/_________/¦     ¦:.            ¦„¦____¦/___;_/¦ ‚  |\________/'/_______/|‚‚   ¦\______¦/________/¦„                    '¦___'__'¦_¦/ ¯¯¯¯¯ °  ¦_________¦ ¦_________/¦‚     ¦:.            ¦„   ¦\______¦/________/¦„  /________/'/_______'/¦ ¦______¦/_______/:'¦   ¦\________;¦/_________/¦ 
// ¦::‚:::::’:::::¦'¦'¦::::::::::::::'¦                ¦:::::°:::::::¦ ¦   ¦:¦::::::::::::::¦¦::::::::::::::::¦'¦            ¦'¦::::::::::¦'¦                  /              /¦‚¦'¦:::::::::¦¦:::::::::¦‚  ¦:¦::::::::::::::¦¦::::::::::::::::¦'¦                    ¦::::::::::::::¦:¦ ¦:¦:::::::::°::::::¦                      /              /¦‚ ¦::::::::::::::¦ ¦:::::::::‚::¦:'¦  \:: ¦::::::::::::::¦¦::::::::::::::¦::/      /              /¦‚  ¦:¦::::::::::::::¦¦::::::::::::::::¦'¦    /              /¦‚¦:::::::'¦::::::::¦;¦‚‚  |:|:::::::::::::| |::::::::::::|:|°   ¦:¦::::::::::¦¦:::::::::::::'¦:¦„‚                   '¦::::::::::¦„   °            ¦:::::::::::::::'¦ ¦:::::‚::::::‚:::'¦:¦    /              /¦‚   ¦:¦::::::::::¦¦:::::::::::::'¦:¦„‚ ¦::::::::::::::¦ ¦:::::::::‚::¦:'¦ ¦::::::::::¦¦::::::::::::'¦:'/’’  ¦:¦::::::::::::::¦¦::::::::::::::::¦'¦ 
// ¦::::‚::::’::::¦'¦'¦::::::::::::::'¦                ¦::::„::::::::¦ /   '\¦::::::::::::::'¦¦::::::::::::::: ¦/            '\¦:::::::::”¦/                 '¦________'¦/ \¦:::::::::¦¦:::::::::¦„  '\¦::::::::::::::'¦¦::::::::::::::: ¦/                    ¦::::::::::::::¦/  ’\¦::::::::::::::::¦                     '¦________'¦/  ¦:::::‚::’::::::¦/¦:„::::::::::¦'/     \¦::::::::::::::¦¦::::::::::::::¦/       '¦________'¦/   '\¦::::::::::::::'¦¦::::::::::::::: ¦/   '¦________'¦/ ¦::':::::¦::::::::¦/ °  '\|:::::::::::::| '|::::::::::::|/‚    '\¦::::::::::¦¦:::::::::::::'¦/„ ‚                   '¦::::::::::¦„          °     ¦:::::::::::::::'¦ ¦::‚::‚:::‚:::::::'¦/   '¦________'¦/    '\¦::::::::::¦¦:::::::::::::'¦/„ ‚ ¦:::::‚::’::::::¦/¦:„::::::::::¦'/ ¦::::::::::¦¦::::::::::::'¦/     '\¦::::::::::::::'¦¦::::::::::::::: ¦/ 
//  ¯¯¯¯¯¯¯¯ ” ¯¯¯¯¯¯¯¯‚                ’¯¯¯¯¯¯¯¯’”      ¯¯¯¯¯¯¯¯ ¯¯¯¯¯¯¯¯¯ º              ¯¯¯¯¯º                   '¦::::::::::::::'¦    ¯¯¯¯¯ ¯¯¯¯¯¯‚     ¯¯¯¯¯¯¯¯ ¯¯¯¯¯¯¯¯¯ º                     ¯¯¯¯¯¯¯¯      ¯¯¯¯¯¯¯¯¯                      '¦::::::::::::::'¦   '¯¯¯¯¯¯¯¯  '¯¯¯¯¯¯¯  ’       ¯¯¯¯¯¯¯¯ ¯¯¯¯¯¯¯¯         '¦::::::::::::::'¦       ¯¯¯¯¯¯¯¯ ¯¯¯¯¯¯¯¯¯ º   '¦::::::::::::::'¦   ¯¯¯¯  ¯¯¯¯        ¯¯¯¯¯¯¯' ’” ¯¯¯¯¯¯¯        ¯¯¯¯¯¯°¯¯¯¯¯¯¯¯                        ¯¯¯¯¯¯’                  ¯¯¯¯¯¯¯¯  ° ¯¯¯¯¯¯¯¯       '¦::::::::::::::'¦       ¯¯¯¯¯¯°¯¯¯¯¯¯¯¯     '¯¯¯¯¯¯¯¯  '¯¯¯¯¯¯¯  ’  ¯¯¯¯¯   ¯¯¯¯¯¯¯   ‚‚     ¯¯¯¯¯¯¯¯ ¯¯¯¯¯¯¯¯¯ º 
//              ‘                                                   '                                                                                  '¦::::::::::::::'¦                                                                                                                        ‘                     '¦::::::::::::::'¦                                                                                '¦::::::::::::::'¦                                           '¦::::::::::::::'¦                                                       ‘                   ‘                                    '‚                                                               '‚     '¦::::::::::::::'¦                  ‘                                                                     '                                                   
// ‘                                   '‚                                                                                                               ’ ¯¯¯¯¯¯¯¯ ’                                                                                  ‘                                                          ’ ¯¯¯¯¯¯¯¯ ’                                                                               ’ ¯¯¯¯¯¯¯¯ ’                                          ’ ¯¯¯¯¯¯¯¯ ’                       ‘                                   ‘                                                                    '‚            °                                       ’ ¯¯¯¯¯¯¯¯ ’  ‘                                                                    '                                                                    

    function _beforeFallback() internal virtual {}

    receive() external payable virtual {
        _fallback();
    }

                                                             

    fallback() external payable virtual {
        _fallback();
    }
}