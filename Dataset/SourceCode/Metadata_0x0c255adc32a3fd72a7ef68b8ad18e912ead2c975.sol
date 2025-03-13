{{

  "language": "Solidity",

  "sources": {

    "contracts/Metadata.sol": {

      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.10;\n\n/*\n\n       .\n      \":\"\n    ___:____     |\"\\/\"|\n  ,'        `.    \\  /\n  |  O        \\___/  |\n~^~^~^~^~^~^~^~^~^~^~^~^~\n\nWhales Game | Generative Yield NFTs\nMint tokens and earn KRILL with this new blockchain based game! Battle it out to see who can generate the most yield.\n\nWebsite: https://whales.game/\n\n*/\n\ninterface WhalesGameInterface {\n\tfunction getToken(uint256 _tokenId) external view returns (address tokenOwner, address approved, bytes32 seed, bool isWhale);\n}\n\n\ncontract Metadata {\n\n\tstring public name = \"Whales Game\";\n\tstring public symbol = \"WG\";\n\n\tstring constant private TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';\n\n\tstruct Trait {\n\t\tstring trait;\n\t\tstring[] names;\n\t\tstring[] imgs;\n\t}\n\n\tstruct Traits {\n\t\tstring base;\n\t\tTrait[] traits;\n\t}\n\t\n\tstruct Info {\n\t\taddress owner;\n\t\tWhalesGameInterface wg;\n\t\tTraits whaleTraits;\n\t\tTraits fishermanTraits;\n\t\tstring[] colors;\n\t}\n\tInfo private info;\n\t\n\t\n\tmodifier _onlyOwner() {\n\t\trequire(msg.sender == owner());\n\t\t_;\n\t}\n\n\n\tconstructor(string memory _whaleBase, string memory _fishermenBase, string[] memory _colors) {\n\t\tinfo.owner = msg.sender;\n\t\tinfo.whaleTraits.base = _whaleBase;\n\t\tinfo.fishermanTraits.base = _fishermenBase;\n\t\tinfo.colors = _colors;\n\t}\n\n\tfunction createTrait(bool _isWhale, string memory _trait, string[] memory _names, string[] memory _imgs) external _onlyOwner {\n\t\trequire(_names.length > 0 && _names.length == _imgs.length);\n\t\tTraits storage _traits = _isWhale ? info.whaleTraits : info.fishermanTraits;\n\t\t_traits.traits.push(Trait(_trait, _names, _imgs));\n\t}\n\n\tfunction setOwner(address _owner) external _onlyOwner {\n\t\tinfo.owner = _owner;\n\t}\n\n\tfunction setWhalesGame(WhalesGameInterface _wg) external _onlyOwner {\n\t\tinfo.wg = _wg;\n\t}\n\n\tfunction deploySetWhalesGame(WhalesGameInterface _wg) external {\n\t\trequire(tx.origin == owner() && whalesGameAddress() == address(0x0));\n\t\tinfo.wg = _wg;\n\t}\n\n\n\tfunction whalesGameAddress() public view returns (address) {\n\t\treturn address(info.wg);\n\t}\n\n\tfunction owner() public view returns (address) {\n\t\treturn info.owner;\n\t}\n\t\n\tfunction tokenURI(uint256 _tokenId) external view returns (string memory) {\n\t\t( , , bytes32 _seed, bool _isWhale) = info.wg.getToken(_tokenId);\n\t\tstring memory _json = string(abi.encodePacked('{\"name\":\"', _isWhale ? 'Whale' : 'Fisherman', ' #', _uint2str(_tokenId), '\",\"description\":\"Some description content...\",'));\n\t\t_json = string(abi.encodePacked(_json, '\"image\":\"data:image/svg+xml;base64,', _encode(bytes(getRawSVG(_seed, _isWhale))), '\",\"attributes\":['));\n\t\t_json = string(abi.encodePacked(_json, '{\"trait_type\":\"Type\",\"value\":\"', _isWhale ? 'Whale' : 'Fisherman', '\"}'));\n\t\t(string[] memory _traits, string[] memory _values, ) = getRawTraits(_seed, _isWhale);\n\t\tfor (uint256 i = 0; i < _traits.length; i++) {\n\t\t\tif (keccak256(bytes(_values[i])) != keccak256(bytes(\"None\"))) {\n\t\t\t\t_json = string(abi.encodePacked(_json, ',{\"trait_type\":\"', _traits[i], '\",\"value\":\"', _values[i], '\"}'));\n\t\t\t}\n\t\t}\n\t\t_json = string(abi.encodePacked(_json, ']}'));\n\t\treturn string(abi.encodePacked(\"data:application/json;base64,\", _encode(bytes(_json))));\n\t}\n\n\tfunction getSVG(uint256 _tokenId) public view returns (string memory) {\n\t\t( , , bytes32 _seed, bool _isWhale) = info.wg.getToken(_tokenId);\n\t\treturn getRawSVG(_seed, _isWhale);\n\t}\n\n\tfunction getRawSVG(bytes32 _seed, bool _isWhale) public view returns (string memory svg) {\n\t\tsvg = string(abi.encodePacked('<svg xmlns=\"http://www.w3.org/2000/svg\" version=\"1.1\" preserveAspectRatio=\"xMidYMid meet\" viewBox=\"0 0 44 44\">'));\n\t\tuint256 _colorIndex = uint256(keccak256(abi.encodePacked('color:', _seed))) % info.colors.length;\n\t\tsvg = string(abi.encodePacked(svg, '<rect width=\"100%\" height=\"100%\" fill=\"#', info.colors[_colorIndex], '\" />'));\n\t\tTraits storage _traits = _isWhale ? info.whaleTraits : info.fishermanTraits;\n\t\tsvg = string(abi.encodePacked(svg, '<image x=\"6\" y=\"6\" width=\"32\" height=\"32\" image-rendering=\"pixelated\" href=\"data:image/png;base64,', _traits.base, '\"/>'));\n\t\t( , , uint256[] memory _indexes) = getRawTraits(_seed, _isWhale);\n\t\tfor (uint256 i = 0; i < _indexes.length; i++) {\n\t\t\tsvg = string(abi.encodePacked(svg, '<image x=\"6\" y=\"6\" width=\"32\" height=\"32\" image-rendering=\"pixelated\" href=\"data:image/png;base64,', _traits.traits[i].imgs[_indexes[i]], '\"/>'));\n\t\t}\n\t\tsvg = string(abi.encodePacked(svg, '</svg>'));\n\t}\n\n\tfunction getTraits(uint256 _tokenId) public view returns (string[] memory traits, string[] memory values) {\n\t\t( , , bytes32 _seed, bool _isWhale) = info.wg.getToken(_tokenId);\n\t\t(traits, values, ) = getRawTraits(_seed, _isWhale);\n\t}\n\n\tfunction getRawTraits(bytes32 _seed, bool _isWhale) public view returns (string[] memory traits, string[] memory values, uint256[] memory indexes) {\n\t\tbytes32 _last = _seed;\n\t\tTraits storage _traits = _isWhale ? info.whaleTraits : info.fishermanTraits;\n\t\tuint256 _length = _traits.traits.length;\n\t\ttraits = new string[](_length);\n\t\tvalues = new string[](_length);\n\t\tindexes = new uint256[](_length);\n\t\tfor (uint256 i = 0; i < _length; i++) {\n\t\t\t_last = keccak256(abi.encodePacked(_last));\n\t\t\tuint256 _index = uint256(_last) % _traits.traits[i].names.length;\n\t\t\ttraits[i] = _traits.traits[i].trait;\n\t\t\tvalues[i] = _traits.traits[i].names[_index];\n\t\t\tindexes[i] = _index;\n\t\t}\n\t}\n\n\n\tfunction _uint2str(uint256 _value) internal pure returns (string memory) {\n\t\tuint256 _digits = 1;\n\t\tuint256 _n = _value;\n\t\twhile (_n > 9) {\n\t\t\t_n /= 10;\n\t\t\t_digits++;\n\t\t}\n\t\tbytes memory _out = new bytes(_digits);\n\t\tfor (uint256 i = 0; i < _out.length; i++) {\n\t\t\tuint256 _dec = (_value / (10**(_out.length - i - 1))) % 10;\n\t\t\t_out[i] = bytes1(uint8(_dec) + 48);\n\t\t}\n\t\treturn string(_out);\n\t}\n\t\n\tfunction _encode(bytes memory _data) internal pure returns (string memory result) {\n\t\tif (_data.length == 0) return '';\n\t\tstring memory _table = TABLE;\n\t\tuint256 _encodedLen = 4 * ((_data.length + 2) / 3);\n\t\tresult = new string(_encodedLen + 32);\n\n\t\tassembly {\n\t\t\tmstore(result, _encodedLen)\n\t\t\tlet tablePtr := add(_table, 1)\n\t\t\tlet dataPtr := _data\n\t\t\tlet endPtr := add(dataPtr, mload(_data))\n\t\t\tlet resultPtr := add(result, 32)\n\n\t\t\tfor {} lt(dataPtr, endPtr) {}\n\t\t\t{\n\t\t\t\tdataPtr := add(dataPtr, 3)\n\t\t\t\tlet input := mload(dataPtr)\n\t\t\t\tmstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))\n\t\t\t\tresultPtr := add(resultPtr, 1)\n\t\t\t\tmstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))\n\t\t\t\tresultPtr := add(resultPtr, 1)\n\t\t\t\tmstore(resultPtr, shl(248, mload(add(tablePtr, and(shr( 6, input), 0x3F)))))\n\t\t\t\tresultPtr := add(resultPtr, 1)\n\t\t\t\tmstore(resultPtr, shl(248, mload(add(tablePtr, and(        input,  0x3F)))))\n\t\t\t\tresultPtr := add(resultPtr, 1)\n\t\t\t}\n\t\t\tswitch mod(mload(_data), 3)\n\t\t\tcase 1 { mstore(sub(resultPtr, 2), shl(240, 0x3d3d)) }\n\t\t\tcase 2 { mstore(sub(resultPtr, 1), shl(248, 0x3d)) }\n\t\t}\n\t\treturn result;\n\t}\n}"

    }

  },

  "settings": {

    "optimizer": {

      "enabled": false,

      "runs": 200

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

    "libraries": {}

  }

}}