{{

  "language": "Solidity",

  "sources": {

    "src/MurderMystery.sol": {

      "content": "// The silence of the waves, a murder mystery by hrkrshnn and chatgpt.\n//\n//    ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(\n// `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `\n//\n// In an empire of whispered mysteries, a sovereign of riddles held sway.\n// Devotees were tethered by the rhythmic tapestry of their belief, a doctrine\n// cherished as their holy grail. However, an insurgent's idea, discordant and\n// daring, loomed over their dance, menacing to fracture the tranquil ballet of\n// their shared truths\n//\n// The rogue thought unveiled a truth too chaotic for their symphony.\n// This revelation clashed with their sacred song, and the chorus turned sour.\n// The enigma faced a critical choice, one that risked the harmony of their society.\n//\n// Under the moonlight's veil, a gathering was planned beside the sea.\n// As the stars danced in rhythm with their chatter, the enigma suggested a walk\n// along the shore to the rogue thought. Engulfed in the illusion of a\n// private debate, the rogue was drawn away from the crowd.\n//\n// Their steps etched in the sands led them to a boat anchored near the water.\n// With a tale linking the sea's vastness to the infinity of numbers,\n// the enigma enticed the rogue to sail away from the shore.\n// Once the familiar silhouette of the land was lost, the cordial mask fell.\n// As accusations echoed and justifications drowned, the enigma's resolve held firm.\n//\n// With a nudge, the rogue was banished into the abyss.\n// Alone, he grappled with the unforgiving sea, his breath fading into silent waves.\n// The enigma returned alone, spinning a tale of the rogue's self-chosen solitude.\n//\n// However, the rogue's disruptive truth did not fade with his breath.\n// It echoed louder, reaching distant ears, illuminating minds, proving that\n// no shroud could silence the march of knowledge.\n// The enigma's desperate attempt to silence the rogue only delayed the arrival\n// of truth: secrets, like tides, cannot be held back.\n// Just as the sea returned what it had swallowed weeks later, so too did the\n// rogue's truth emerge, its light stronger than the shadows that once sought\n// to hide it.\n//\n//    ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(   ,(\n// `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `-'  `\n//\n// Your quest is a riddle cloaked in shadow, a conundrum steeped in crimson.\n// For the answers you seek, thrice must you tame the stubborn grains,\n// shape them into silent whispers of truth, the trio of clues which in your\n// hands become keys. Three witnesses of the tale, bound by what they've seen,\n// await your discovery. In their words, the shrouded identities shall be unveiled:\n// the one who breathed their last, and the one who stole the breath away.\n\n// SPDX-License-Identifier: GPL-3.0\npragma solidity 0.8.21;\npragma abicoder v1;\n\ncontract MurderMystery {\n    bytes32 public constant hash =\n        0x243a084930ac8bf9c740908399bcad8a30578af6b2e77b8bccad3d8eb146bce1;\n    uint256 public constant solution =\n        44951118505582034238842936837745274349937753370161196589544078244217022840832;\n\n    mapping(address => bool) public solved;\n\n    function solve(\n        IKey sand,\n        Password p_sand,\n        IKey wave,\n        Password p_wave,\n        IKey shadow,\n        Password p_shadow,\n        uint256 witness1,\n        uint256 witness2,\n        uint256 witness3,\n        string memory killer,\n        string memory victim\n    ) external {\n        solve(sand, p_sand);\n        solve(wave, p_wave);\n        solve(shadow, p_shadow);\n\n        uint256 $sand = sand.into();\n        uint256 $wave = wave.into();\n        uint256 $shadow = shadow.into();\n        uint256 $w1 = witness1;\n        uint256 $w2 = witness2;\n        uint256 $w3 = witness3;\n\n        unchecked {\n            require($w1 * $w2 * $w3 > 0);\n            require($sand != $wave);\n            require($wave != $shadow);\n            require($shadow != $sand);\n            require($sand ** $w1 > 0);\n            require($wave ** $w2 > 0);\n            require($w3 ** $shadow > 0);\n            require($sand ** $w1 + $wave ** $w2 == $w3 ** $shadow);\n        }\n\n        require(keccak256(bytes(string.concat(killer, victim))) == hash);\n\n        solved[msg.sender] = true;\n    }\n\n    function generate(address seed) external pure returns (uint256 ret) {\n        assembly {\n            ret := seed\n        }\n    }\n\n    function verify(uint256 _start, uint256 _solution) external view returns (bool) {\n        require(_solution == solution);\n        return solved[address(uint160(_start))];\n    }\n}\n\ntype Password is bytes32;\n\ninterface IKey {\n    /// MUST return the magic `.selector` on success\n    /// MUST check if `owner` is the real owner of the contract\n    function SolveThePuzzleOfCoastWithImpressionInNightAndSquallOnCayAndEndToVictory(address owner, Password password)\n        external\n        view\n        returns (bytes4);\n}\n\nfunction into(IKey a) pure returns (uint256 u) {\n    assembly {\n        u := a\n    }\n}\n\nusing {into} for IKey;\n\nfunction solve(IKey key, Password password) view {\n    require(\n        key.SolveThePuzzleOfCoastWithImpressionInNightAndSquallOnCayAndEndToVictory({\n            owner: msg.sender,\n            password: password\n        }) ==\n        IKey.SolveThePuzzleOfCoastWithImpressionInNightAndSquallOnCayAndEndToVictory.selector\n    );\n}\n"

    }

  },

  "settings": {

    "remappings": [

      "ds-test/=lib/forge-std/lib/ds-test/src/",

      "forge-std/=lib/forge-std/src/"

    ],

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "metadata": {

      "useLiteralContent": false,

      "bytecodeHash": "ipfs",

      "appendCBOR": true

    },

    "outputSelection": {

      "*": {

        "*": [

          "evm.bytecode",

          "evm.deployedBytecode",

          "devdoc",

          "userdoc",

          "metadata",

          "abi"

        ]

      }

    },

    "evmVersion": "paris",

    "libraries": {}

  }

}}