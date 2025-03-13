{{

  "language": "Solidity",

  "sources": {

    "SolvencyContract.sol": {

      "content": "// SPDX-License-Identifier: MIT\n// solc --bin --abi SolvencyContract.sol -o ./SolvencyContract --overwrite\n\npragma solidity ^0.8.0;\n\nimport \"Pairing.sol\";\n\ncontract SolvencyProtocol {\n\n    struct VerifyingKey {\n        Pairing.G1Point alpha1;\n        Pairing.G2Point beta2;\n        Pairing.G2Point gamma2;\n        Pairing.G2Point delta2;\n        Pairing.G1Point IC0;\n        Pairing.G1Point IC1;\n    }\n\n    struct Proof {\n        Pairing.G1Point A;\n        Pairing.G2Point B;\n        Pairing.G1Point C;\n    }\n\n    event ProofPublished(bool verificationOutcome, string metadata, uint timestamp, uint vKeyId,\n        uint[2] proofG1A, uint[4] proofG2B, uint[2] proofG1C, uint256 publicInput);\n\n    address private owner;\n    mapping (address => bool) public admins;\n    mapping (uint => VerifyingKey) public verifyingKeys;\n    mapping (uint => bool) public verifyingKeyIds;\n\n    constructor() {\n        admins[msg.sender] = true;\n    }\n\n    function addAdmin(address newAdmin) public {\n        require (admins[msg.sender], \"You must be an admin to add a new admin\");\n        admins[newAdmin] = true;\n    }\n\n    function delAdmin(address oldAdmin) public {\n        require (admins[msg.sender], \"You must be an admit to delete an admin\");\n        admins[oldAdmin] = false;\n    }\n\n    function addVerifyingKey(uint[2] memory alpha1,\n        uint[4] memory beta2,\n        uint[4] memory gamma2,\n        uint[4] memory delta2,\n        uint[4] memory IC,\n        uint vKeyId\n    ) public {\n        require(admins[msg.sender], \"You must be an admin to add a new verifying key!\");\n        require(!verifyingKeyIds[vKeyId], \"This verifying key ID is already in use!\");\n        Pairing.G1Point memory _alpha1 = Pairing.G1Point(alpha1[0], alpha1[1]);\n        Pairing.G2Point memory _beta2 = Pairing.G2Point([beta2[0], beta2[1]], [beta2[2], beta2[3]]);\n        Pairing.G2Point memory _gamma2 = Pairing.G2Point([gamma2[0], gamma2[1]], [gamma2[2], gamma2[3]]);\n        Pairing.G2Point memory _delta2 = Pairing.G2Point([delta2[0], delta2[1]], [delta2[2], delta2[3]]);\n\n        assert(IC.length == 4);\n        Pairing.G1Point memory IC0 = Pairing.G1Point(IC[0], IC[1]);\n        Pairing.G1Point memory IC1 = Pairing.G1Point(IC[2], IC[3]);\n\n        verifyingKeys[vKeyId] = VerifyingKey({\n        alpha1: _alpha1,\n        beta2: _beta2,\n        gamma2: _gamma2,\n        delta2: _delta2,\n        IC0: IC0,\n        IC1: IC1\n        });\n        verifyingKeyIds[vKeyId] = true;\n    }\n\n    function publishSolvencyProof(uint[2] memory a,\n        uint[4] memory b,\n        uint[2] memory c,\n        uint256 publicInput,\n        string calldata metadata,\n        uint vKeyId) public returns (bool)\n    {\n\n        Proof memory proof = Proof({\n        A: Pairing.G1Point(a[0], a[1]),\n        B: Pairing.G2Point([b[0],b[1]], [b[2], b[3]]),\n        C: Pairing.G1Point(c[0], c[1])\n        });\n\n\n        require(verifyingKeyIds[vKeyId], \"Invalid verifying key ID\");\n\n        // copy function arguments to local memory to avoid \"stack too deep\" error\n        uint256 _publicInput = publicInput;\n        uint256 _vKeyId = vKeyId;\n\n        uint[2] memory proofG1A = [proof.A.X, proof.A.Y];\n        uint[4] memory proofG1B;\n        proofG1B[0] = proof.B.X[0];\n        proofG1B[1] = proof.B.X[1];\n        proofG1B[2] = proof.B.Y[0];\n        proofG1B[3] = proof.B.Y[1];\n\n        uint[2] memory proofG1C = [proof.C.X,proof.C.Y];\n        bool verified = verifyProof(proof, publicInput, vKeyId);\n\n        emit ProofPublished(verified, metadata, block.timestamp, _vKeyId,\n            proofG1A, proofG1B, proofG1C, _publicInput);\n\n        return verified;\n    }\n\n    function verify(uint256 input, Proof memory proof, VerifyingKey memory verifyingKey) internal view returns (bool) {\n        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;\n\n        Pairing.G1Point memory vk_x = verifyingKey.IC0;\n\n        require(input < snark_scalar_field,\"verifier-gte-snark-scalar-field\");\n        vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(verifyingKey.IC1, input));\n\n        return Pairing.pairingProd4(\n            Pairing.negate(proof.A), proof.B,\n            verifyingKey.alpha1, verifyingKey.beta2,\n            vk_x, verifyingKey.gamma2,\n            proof.C, verifyingKey.delta2\n        );\n    }\n    /// @return r  bool true if proof is valid\n    function verifyProof(\n        Proof memory proof,\n        uint256 input,\n        uint vKeyId\n    ) public view returns (bool r) {\n        VerifyingKey memory verifyingKey = verifyingKeys[vKeyId];\n        return verify(input, proof, verifyingKey);\n    }\n\n}\n"

    },

    "Pairing.sol": {

      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nlibrary Pairing {\n    \n    struct G1Point {\n        uint X;\n        uint Y;\n    }\n    // Encoding of field elements is: X[0] * z + X[1]\n    struct G2Point {\n        uint[2] X;\n        uint[2] Y;\n    }\n    \n    /// @return r the negation of p, i.e. p.addition(p.negate()) should be zero.\n    function negate(G1Point memory p) internal pure returns (G1Point memory r) {\n        // The prime q in the base field F_q for G1\n        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;\n        if (p.X == 0 && p.Y == 0)\n            return G1Point(0, 0);\n        return G1Point(p.X, q - (p.Y % q));\n    }\n    /// @return r the sum of two points of G1\n    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {\n        uint[4] memory input;\n        input[0] = p1.X;\n        input[1] = p1.Y;\n        input[2] = p2.X;\n        input[3] = p2.Y;\n        bool success;\n        // solium-disable-next-line security/no-inline-assembly\n        assembly {\n            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)\n            // Use \"invalid\" to make gas estimation work\n            //switch success case 0 { invalid() }\n        }\n        require(success,\"pairing-add-failed\");\n    }\n    /// @return r the product of a point on G1 and a scalar, i.e.\n    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.\n    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {\n        uint[3] memory input;\n        input[0] = p.X;\n        input[1] = p.Y;\n        input[2] = s;\n        bool success;\n        // solium-disable-next-line security/no-inline-assembly\n        assembly {\n            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)\n            // Use \"invalid\" to make gas estimation work\n           // switch success case 0 { invalid() }\n        }\n        require (success,\"pairing-mul-failed\");\n    }\n    /// @return the result of computing the pairing check\n    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1\n    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should\n    /// return true.\n    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {\n        require(p1.length == p2.length,\"pairing-lengths-failed\");\n        uint elements = p1.length;\n        uint inputSize = elements * 6;\n        uint256[] memory input = new uint[](inputSize);\n        for (uint i = 0; i < elements; i++)\n        {\n            input[i * 6 + 0] = p1[i].X;\n            input[i * 6 + 1] = p1[i].Y;\n            input[i * 6 + 2] = p2[i].X[0];\n            input[i * 6 + 3] = p2[i].X[1];\n            input[i * 6 + 4] = p2[i].Y[0];\n            input[i * 6 + 5] = p2[i].Y[1];\n        }\n        uint[1] memory out;\n        bool success;\n\n        uint gas_cost = (80000 * 3 + 100000) * 2;\n\n        // solium-disable-next-line security/no-inline-assembly\n        assembly {\n            success := staticcall(gas_cost, 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)\n            // Use \"invalid\" to make gas estimation work\n            //switch success case 0 { invalid() }\n        }\n        require(success,\"pairing-opcode-failed\");\n        return out[0] != 0;\n    }\n    /// Convenience method for a pairing check for two pairs.\n    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {\n        G1Point[] memory p1 = new G1Point[](2);\n        G2Point[] memory p2 = new G2Point[](2);\n        p1[0] = a1;\n        p1[1] = b1;\n        p2[0] = a2;\n        p2[1] = b2;\n        return pairing(p1, p2);\n    }\n    /// Convenience method for a pairing check for three pairs.\n    function pairingProd3(\n            G1Point memory a1, G2Point memory a2,\n            G1Point memory b1, G2Point memory b2,\n            G1Point memory c1, G2Point memory c2\n    ) internal view returns (bool) {\n        G1Point[] memory p1 = new G1Point[](3);\n        G2Point[] memory p2 = new G2Point[](3);\n        p1[0] = a1;\n        p1[1] = b1;\n        p1[2] = c1;\n        p2[0] = a2;\n        p2[1] = b2;\n        p2[2] = c2;\n        return pairing(p1, p2);\n    }\n    /// Convenience method for a pairing check for four pairs.\n    function pairingProd4(\n            G1Point memory a1, G2Point memory a2,\n            G1Point memory b1, G2Point memory b2,\n            G1Point memory c1, G2Point memory c2,\n            G1Point memory d1, G2Point memory d2\n    ) internal view returns (bool) {\n        G1Point[] memory p1 = new G1Point[](4);\n        G2Point[] memory p2 = new G2Point[](4);\n        p1[0] = a1;\n        p1[1] = b1;\n        p1[2] = c1;\n        p1[3] = d1;\n        p2[0] = a2;\n        p2[1] = b2;\n        p2[2] = c2;\n        p2[3] = d2;\n        return pairing(p1, p2);\n    }\n}\n"

    }

  },

  "settings": {

    "evmVersion": "istanbul",

    "optimizer": {

      "enabled": true,

      "runs": 200

    },

    "libraries": {

      "SolvencyContract.sol": {}

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

    }

  }

}}