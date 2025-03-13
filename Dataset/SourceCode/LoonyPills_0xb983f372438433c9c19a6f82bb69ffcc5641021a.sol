// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

struct PhaseSettings {
    uint64 maxSupply;
    uint64 maxPerWallet;
    uint64 freePerWallet;
    uint64 holderExtraPerWallet;
    uint256 price;
    uint256 holderPrice;
}

struct Pills {
    uint64 green;
    uint64 blue;
    uint64 yellow;
    uint64 purple;
    uint64 red;
}

contract LoonyPills is
    ERC721AQueryable,
    DefaultOperatorFilterer,
    Ownable,
    ReentrancyGuard
{
    using Strings for uint256;

    string public baseTokenURI;
    string[5] public unrevealedTokenURI;

    PhaseSettings public currentPhase;
    Pills public pillsLeft;

    bool public revealed = false;

    mapping(uint256 => uint256) public pillPerTokenId;

    bytes32 private _root;

    address t1 = 0x402351069CFF2F0324A147eC0a138a1C21491591;
    address t2 = 0x0566c0574c86d4826B16FCBFE01332956e3cf3aD;

    constructor() ERC721A("loony pills", "pill") {
        pillsLeft = Pills(2500, 2000, 2000, 1800, 1200);
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function numberMinted(address _owner) public view returns (uint256) {
        return _numberMinted(_owner);
    }

    function nonFreeAmount(
        address _owner,
        uint256 _amount
    ) public view returns (uint256) {
        uint256 _freeAmountLeft = _numberMinted(_owner) >=
            currentPhase.freePerWallet
            ? 0
            : currentPhase.freePerWallet - _numberMinted(_owner);

        return _freeAmountLeft >= _amount ? 0 : _amount - _freeAmountLeft;
    }

    function holderNonFreeAmount(
        address _owner,
        uint256 _freeAmount,
        uint256 _amount
    ) public view returns (uint256) {
        uint256 _freeAmountLeft = _numberMinted(_owner) >= _freeAmount
            ? 0
            : _freeAmount - _numberMinted(_owner);

        return _freeAmountLeft >= _amount ? 0 : _amount - _freeAmountLeft;
    }

    function pillOf(uint256 _tokenId) public view returns (uint256) {
        return pillPerTokenId[_tokenId];
    }

    /**
     * @notice _pills Array of pills to mint where
     *  _pills[0] - green,
     *  _pills[1] - blue,
     *  _pills[2] - yellow,
     *  _pills[3] - purple,
     *  _pills[4] - red
     */
    function holderMint(
        uint8[] memory _pills,
        uint256 _freeAmount,
        bytes32[] memory _proof
    ) public payable {
        verify(_freeAmount, _proof);

        uint256 _amount = _totalAmount(_pills);
        uint256 _nonFreeAmount = holderNonFreeAmount(
            msg.sender,
            _freeAmount,
            _amount
        );

        require(
            _nonFreeAmount == 0 ||
                msg.value >= currentPhase.holderPrice * _nonFreeAmount,
            "Ether value sent is not correct"
        );

        require(
            _numberMinted(msg.sender) + _amount <=
                currentPhase.holderExtraPerWallet + _freeAmount,
            "Exceeds maximum tokens at address"
        );

        mint(_pills);
    }

    /**
     * @notice _pills Array of pills to mint where
     *  _pills[0] - green,
     *  _pills[1] - blue,
     *  _pills[2] - yellow,
     *  _pills[3] - purple,
     *  _pills[4] - red
     */
    function publicMint(uint8[] memory _pills) public payable {
        uint256 _amount = _totalAmount(_pills);
        uint256 _nonFreeAmount = nonFreeAmount(msg.sender, _amount);

        require(
            _nonFreeAmount == 0 ||
                msg.value >= currentPhase.price * _nonFreeAmount,
            "Ether value sent is not correct"
        );

        require(
            _numberMinted(msg.sender) + _amount <= currentPhase.maxPerWallet,
            "Exceeds maximum tokens at address"
        );

        mint(_pills);
    }

    function mint(uint8[] memory _pills) private {
        uint256 _amount = _totalAmount(_pills);

        require(
            _totalMinted() + _amount <= currentPhase.maxSupply,
            "Exceeds maximum supply"
        );

        require(
            pillsLeft.green >= _pills[0] &&
                pillsLeft.blue >= _pills[1] &&
                pillsLeft.yellow >= _pills[2] &&
                pillsLeft.purple >= _pills[3] &&
                pillsLeft.red >= _pills[4],
            "Exceeds maximum supply of pill"
        );

        _safeMint(msg.sender, _amount);
        _reducePillsLeft(_pills);
        _setPillPerTokenId(_pills);
    }

    /**
     * @notice _pills Array of pills to mint where
     *  _pills[0] - green,
     *  _pills[1] - blue,
     *  _pills[2] - yellow,
     *  _pills[3] - purple,
     *  _pills[4] - red
     */
    function airdrop(uint8[] memory _pills, address _to) public onlyOwner {
        uint256 _amount = _totalAmount(_pills);

        require(
            _totalMinted() + _amount <= currentPhase.maxSupply,
            "Exceeds maximum supply"
        );

        require(
            pillsLeft.green >= _pills[0] &&
                pillsLeft.blue >= _pills[1] &&
                pillsLeft.yellow >= _pills[2] &&
                pillsLeft.purple >= _pills[3] &&
                pillsLeft.red >= _pills[4],
            "Exceeds maximum supply of pill"
        );

        _safeMint(_to, _amount);

        _reducePillsLeft(_pills);
        _setPillPerTokenId(_pills);
    }

    function _totalAmount(
        uint8[] memory _pills
    ) private pure returns (uint256) {
        uint256 _amount = 0;

        for (uint8 i = 0; i < _pills.length; i++) {
            _amount += _pills[i];
        }

        return _amount;
    }

    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function setUnrevealedTokenURI(
        string memory _green,
        string memory _blue,
        string memory _yellow,
        string memory _purple,
        string memory _red
    ) public onlyOwner {
        unrevealedTokenURI = [_green, _blue, _yellow, _purple, _red];
    }

    function setPhase(
        uint64 _maxSupply,
        uint64 _maxPerWallet,
        uint64 _freePerWallet,
        uint64 _holderPerWallet,
        uint256 _price,
        uint256 _holderPrice
    ) public onlyOwner {
        currentPhase = PhaseSettings(
            _maxSupply,
            _maxPerWallet,
            _freePerWallet,
            _holderPerWallet,
            _price,
            _holderPrice
        );
    }

    function setPillsLeft(
        uint64 _green,
        uint64 _blue,
        uint64 _yellow,
        uint64 _purple,
        uint64 _red
    ) public onlyOwner {
        pillsLeft = Pills(_green, _blue, _yellow, _purple, _red);
    }

    function setRoot(bytes32 root) public onlyOwner {
        _root = root;
    }

    function setRevealed(bool _revealed) public onlyOwner {
        revealed = _revealed;
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 _balance = address(this).balance / 100;

        require(payable(t1).send(_balance * 8));
        require(payable(t2).send(_balance * 92));
    }

    function _reducePillsLeft(uint8[] memory _pills) private {
        pillsLeft = Pills(
            pillsLeft.green - _pills[0],
            pillsLeft.blue - _pills[1],
            pillsLeft.yellow - _pills[2],
            pillsLeft.purple - _pills[3],
            pillsLeft.red - _pills[4]
        );
    }

    function _setPillPerTokenId(uint8[] memory _pills) private {
        uint256 _startId = _nextTokenId() - _totalAmount(_pills);

        for (uint8 i = 0; i < _pills.length; i++) {
            for (uint8 j = 0; j < _pills[i]; j++) {
                pillPerTokenId[_startId + j] = i;
            }
            _startId += _pills[i];
        }
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC721A, IERC721A) onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(
        address operator,
        uint256 tokenId
    )
        public
        payable
        override(ERC721A, IERC721A)
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override(ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override(ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override(ERC721A, IERC721A) onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function verify(uint256 _freeAmount, bytes32[] memory _proof) private view {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender, _freeAmount)))
        );
        require(MerkleProof.verify(_proof, _root, leaf), "Invalid proof");
    }

    function pillNumberToString(
        uint256 _number
    ) public pure returns (string memory) {
        if (_number == 0) {
            return "Green";
        } else if (_number == 1) {
            return "Blue";
        } else if (_number == 2) {
            return "Yellow";
        } else if (_number == 3) {
            return "Purple";
        } else if (_number == 4) {
            return "Red";
        } else {
            revert();
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override(ERC721A, IERC721A) returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        if (revealed) {
            return
                bytes(baseTokenURI).length != 0
                    ? string(abi.encodePacked(baseTokenURI, _toString(tokenId)))
                    : "";
        }

        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "pill #',
            tokenId.toString(),
            '",',
            '"image": "',
            unrevealedTokenURI[pillPerTokenId[tokenId]],
            '",',
            '"attributes": [{"trait_type": "Color", "value": "',
            pillNumberToString(pillPerTokenId[tokenId]),
            '"}]',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }
}