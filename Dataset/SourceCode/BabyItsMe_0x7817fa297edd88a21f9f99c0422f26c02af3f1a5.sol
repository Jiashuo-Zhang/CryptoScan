{{

  "language": "Solidity",

  "sources": {

    "src/BabyItsMe.sol": {

      "content": "// SPDX-License-Identifier: GPL-3\npragma solidity ^0.8.20;\n\nimport \"src/Verifier.sol\";\n\ncontract BabyItsMe is Verifier {\n    // This is the BabyJubjub public key A = (x, y) we want to impersonate.\n    uint256 constant PK_X = 4342719913949491028786768530115087822524712248835451589697801404893164183326;\n    uint256 constant PK_Y = 4826523245007015323400664741523384119579596407052839571721035538011798951543;\n\n    mapping(address => uint256) public solved;\n\n    // Make sure you first call `verifyProof` with the actual proof,\n    // and then use your solving address as the solution.\n    function verify(uint256 _start, uint256 _solution) external view returns (bool) {\n        return solved[address(uint160(_solution))] == _start;\n    }\n\n    // The zkSNARK verifier expects as public inputs the BabyJubjub public key\n    // A that is signing the message M and the message itself.\n    // The zero knowledge proof shows that the msg.sender knows a valid\n    // signature (s, R) for public key A and message M, without revealing the\n    // signature.\n    function verifyProof(Proof memory _proof) external returns (bool) {\n        uint256 start = generate(msg.sender);\n        bool user_solved = 0 == verify([PK_X, PK_Y, start, uint256(uint160(msg.sender))], _proof);\n        if (user_solved) {\n            solved[msg.sender] = start;\n            return true;\n        }\n\n        return false;\n    }\n\n    // Specific message that the challenger has to sign.\n    // We remove the 3 LSB to make the number fit in the used prime field.\n    function generate(address _who) public pure returns (uint256) {\n        return uint256(keccak256(abi.encode(\"Baby it's me, \", _who))) >> 3;\n    }\n}\n"

    },

    "src/Verifier.sol": {

      "content": "// This file is MIT Licensed.\n//\n// Copyright 2017 Christian Reitwiessner\n// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n// THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.\npragma solidity ^0.8.0;\n\nlibrary Pairing {\n    struct G1Point {\n        uint256 X;\n        uint256 Y;\n    }\n    // Encoding of field elements is: X[0] * z + X[1]\n\n    struct G2Point {\n        uint256[2] X;\n        uint256[2] Y;\n    }\n    /// @return the generator of G1\n\n    function P1() internal pure returns (G1Point memory) {\n        return G1Point(1, 2);\n    }\n    /// @return the generator of G2\n\n    function P2() internal pure returns (G2Point memory) {\n        return G2Point(\n            [\n                10857046999023057135944570762232829481370756359578518086990519993285655852781,\n                11559732032986387107991004021392285783925812861821192530917403151452391805634\n            ],\n            [\n                8495653923123431417604973247489272438418190587263600148770280649306958101930,\n                4082367875863433681332203403145435568316851327593401208105741076214120093531\n            ]\n        );\n    }\n    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.\n\n    function negate(G1Point memory p) internal pure returns (G1Point memory) {\n        // The prime q in the base field F_q for G1\n        uint256 q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;\n        if (p.X == 0 && p.Y == 0) {\n            return G1Point(0, 0);\n        }\n        return G1Point(p.X, q - (p.Y % q));\n    }\n    /// @return r the sum of two points of G1\n\n    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {\n        uint256[4] memory input;\n        input[0] = p1.X;\n        input[1] = p1.Y;\n        input[2] = p2.X;\n        input[3] = p2.Y;\n        bool success;\n        assembly {\n            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)\n            // Use \"invalid\" to make gas estimation work\n            switch success\n            case 0 { invalid() }\n        }\n        require(success);\n    }\n\n    /// @return r the product of a point on G1 and a scalar, i.e.\n    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.\n    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {\n        uint256[3] memory input;\n        input[0] = p.X;\n        input[1] = p.Y;\n        input[2] = s;\n        bool success;\n        assembly {\n            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)\n            // Use \"invalid\" to make gas estimation work\n            switch success\n            case 0 { invalid() }\n        }\n        require(success);\n    }\n    /// @return the result of computing the pairing check\n    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1\n    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should\n    /// return true.\n\n    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {\n        require(p1.length == p2.length);\n        uint256 elements = p1.length;\n        uint256 inputSize = elements * 6;\n        uint256[] memory input = new uint[](inputSize);\n        for (uint256 i = 0; i < elements; i++) {\n            input[i * 6 + 0] = p1[i].X;\n            input[i * 6 + 1] = p1[i].Y;\n            input[i * 6 + 2] = p2[i].X[1];\n            input[i * 6 + 3] = p2[i].X[0];\n            input[i * 6 + 4] = p2[i].Y[1];\n            input[i * 6 + 5] = p2[i].Y[0];\n        }\n        uint256[1] memory out;\n        bool success;\n        assembly {\n            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)\n            // Use \"invalid\" to make gas estimation work\n            switch success\n            case 0 { invalid() }\n        }\n        require(success);\n        return out[0] != 0;\n    }\n    /// Convenience method for a pairing check for two pairs.\n\n    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2)\n        internal\n        view\n        returns (bool)\n    {\n        G1Point[] memory p1 = new G1Point[](2);\n        G2Point[] memory p2 = new G2Point[](2);\n        p1[0] = a1;\n        p1[1] = b1;\n        p2[0] = a2;\n        p2[1] = b2;\n        return pairing(p1, p2);\n    }\n    /// Convenience method for a pairing check for three pairs.\n\n    function pairingProd3(\n        G1Point memory a1,\n        G2Point memory a2,\n        G1Point memory b1,\n        G2Point memory b2,\n        G1Point memory c1,\n        G2Point memory c2\n    ) internal view returns (bool) {\n        G1Point[] memory p1 = new G1Point[](3);\n        G2Point[] memory p2 = new G2Point[](3);\n        p1[0] = a1;\n        p1[1] = b1;\n        p1[2] = c1;\n        p2[0] = a2;\n        p2[1] = b2;\n        p2[2] = c2;\n        return pairing(p1, p2);\n    }\n    /// Convenience method for a pairing check for four pairs.\n\n    function pairingProd4(\n        G1Point memory a1,\n        G2Point memory a2,\n        G1Point memory b1,\n        G2Point memory b2,\n        G1Point memory c1,\n        G2Point memory c2,\n        G1Point memory d1,\n        G2Point memory d2\n    ) internal view returns (bool) {\n        G1Point[] memory p1 = new G1Point[](4);\n        G2Point[] memory p2 = new G2Point[](4);\n        p1[0] = a1;\n        p1[1] = b1;\n        p1[2] = c1;\n        p1[3] = d1;\n        p2[0] = a2;\n        p2[1] = b2;\n        p2[2] = c2;\n        p2[3] = d2;\n        return pairing(p1, p2);\n    }\n}\n\ncontract Verifier {\n    using Pairing for *;\n\n    struct VerifyingKey {\n        Pairing.G1Point alpha;\n        Pairing.G2Point beta;\n        Pairing.G2Point gamma;\n        Pairing.G2Point delta;\n        Pairing.G1Point[] gamma_abc;\n    }\n\n    struct Proof {\n        Pairing.G1Point a;\n        Pairing.G2Point b;\n        Pairing.G1Point c;\n    }\n\n    function verifyingKey() internal pure returns (VerifyingKey memory vk) {\n        vk.alpha = Pairing.G1Point(\n            uint256(0x0284c469d8eaf677e29635e18886312bd0c6ba2a632674a2703a8d9a5d5a48db),\n            uint256(0x19b4d4d74797c3307e59c683ccad9119397c90f76ad28c043ec9671a95502e76)\n        );\n        vk.beta = Pairing.G2Point(\n            [\n                uint256(0x0319296206e25c6e7ea35492e825fcdbea39b0980b72f18b3f7385d6d46352b0),\n                uint256(0x10bc74487c379aad3a10da56c479ae5db4e4b3faeb354f4aa57ed4524a3e4527)\n            ],\n            [\n                uint256(0x2971943778693059384530140201f76e29adf7a4222921b744f09045f2011e1d),\n                uint256(0x21099f091b01503caab27b87ee9769840d27963846e35613d26190bc5c4d0cef)\n            ]\n        );\n        vk.gamma = Pairing.G2Point(\n            [\n                uint256(0x2cd9c9e8f055f3663213f71c1c3f99c6b363b35f50e0fe2e8405d029deb1e295),\n                uint256(0x0fdcd887987c8e156d574ee4e97cf66bf36e7a8539b8c4bd578ff7bced1a601c)\n            ],\n            [\n                uint256(0x2d96d4c9dcf6ff4da92c433beb2749c86fff05bfd2d83c3da9a7d531903ec942),\n                uint256(0x13fb1bdc1b558571d6ba4944428eeb52aa0d69378072aa64cf543d4189b8af78)\n            ]\n        );\n        vk.delta = Pairing.G2Point(\n            [\n                uint256(0x122757890c3f43309334e26258842bb8e8ab0450d387ddf7bc20fc5e01619d92),\n                uint256(0x00593e12fef04367a7d771cc137c7a3f0f245584f4a40e44c6281ca51e610027)\n            ],\n            [\n                uint256(0x11b21f2409f28092f35b9cd195ee93ee5d0e11aca3e1a432c007243e186dec7c),\n                uint256(0x1bcf98b5bbd114064cf46447c90092bbf9384056f13c9487d8021f73d92ac452)\n            ]\n        );\n        vk.gamma_abc = new Pairing.G1Point[](5);\n        vk.gamma_abc[0] = Pairing.G1Point(\n            uint256(0x2fc73b5bbb85acbd703828a3df8ee04ef648832b3bbf2c9fd5bb51d4ab0ef984),\n            uint256(0x197f3e6cf0bde2d74a7c29bbabe7ea80928b45b23478309ea671a2b973a7edf2)\n        );\n        vk.gamma_abc[1] = Pairing.G1Point(\n            uint256(0x1b723ed82a7478e39551e2ab9346eda38a1c000cdd5f8ade3ccf6685f9d37b1e),\n            uint256(0x26ad983f9927d8414cddfe79a4eda6717a8e82a0e85450e7ca745cd15af62c77)\n        );\n        vk.gamma_abc[2] = Pairing.G1Point(\n            uint256(0x262988545555095a281b0c6ac183626fd44094e1cc230aa38a705030d69124f3),\n            uint256(0x1f248dcfb5baf7962c1c481b9d52110825710ace9b94ef387f78651cb9d3335b)\n        );\n        vk.gamma_abc[3] = Pairing.G1Point(\n            uint256(0x2b17ccfb2bf38f9ed35f4cb962b705028429e1e66679bff2d13a0f31049a2b3a),\n            uint256(0x1abe95f952ab1cd0a71f61d4304c8e85a777cf5afcb1936b9113a6c8acf22c68)\n        );\n        vk.gamma_abc[4] = Pairing.G1Point(\n            uint256(0x2d476a4fc5d6e7900b821ac91bc179164787f4c1532bd3b91facf951788f40af),\n            uint256(0x2a45d903c16fe8f0d0a14b36ae3ff7252075a266a0c749d3215352f175c1c8f1)\n        );\n    }\n\n    function verify(uint256[4] memory input, Proof memory proof) internal view returns (uint256) {\n        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;\n        VerifyingKey memory vk = verifyingKey();\n        require(input.length + 1 == vk.gamma_abc.length);\n        // Compute the linear combination vk_x\n        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);\n        for (uint256 i = 0; i < input.length; i++) {\n            require(input[i] < snark_scalar_field);\n            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));\n        }\n        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);\n        if (\n            !Pairing.pairingProd4(\n                proof.a,\n                proof.b,\n                Pairing.negate(vk_x),\n                vk.gamma,\n                Pairing.negate(proof.c),\n                vk.delta,\n                Pairing.negate(vk.alpha),\n                vk.beta\n            )\n        ) return 1;\n        return 0;\n    }\n}\n"

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

    "viaIR": true,

    "libraries": {}

  }

}}