// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

import "./RugPool.sol";

contract Rugbbit is ERC721, Ownable, DefaultOperatorFilterer {
    using Strings for uint;
    uint256 _currentTokenId;
    uint256 _metadataCount;
    RugPool _rugPool;
    address _trashCan;

    uint _mintStartTime = 1681027200;

    mapping(uint256 => uint256) _tokenURIById;
    mapping(uint256 => string) _metadataURI;

    uint _maxPrice = 0.03 ether;
    uint _minPrice = 0.01 ether;
    uint _costDownPrice = 0.01 ether;

    constructor(
        address trashCan,
        address receiver,
        uint mintStartTime
    ) ERC721("Rugbbit", "RUG") {
        _trashCan = trashCan;
        RugPool rugPool = new RugPool{salt: bytes32("ruggbits")}(address(this), receiver);
        _mintStartTime = mintStartTime;
        rugPool.transferOwnership(msg.sender);
        setRugPool(address(rugPool));
    }

    function mint(
        address inviteCode,
        address nftContract,
        uint256 nftTokenId
    ) public payable {
        require(block.timestamp >= _mintStartTime, "not started yet");
        require(
            inviteCode != address(0) && inviteCode != address(this),
            "Rugbbit: inviteCode error"
        );

        uint finalPrice = _maxPrice;
        if (inviteCode != msg.sender) {
            finalPrice = finalPrice - _costDownPrice;
        }

        if (nftContract != address(0)) {
            require(msg.sender == IERC721(nftContract).ownerOf(nftTokenId));
            require(
                IERC721(nftContract).getApproved(nftTokenId) == address(this),
                "Rugbbit: not approved"
            );
            IERC721(nftContract).transferFrom(
                msg.sender,
                _trashCan,
                nftTokenId
            );
            finalPrice = finalPrice - _costDownPrice;
        }
        require(msg.value == finalPrice, "Rugbbit: wrong price");
        uint256 tokenId = _currentTokenId + startTokenId();
        super._mint(msg.sender, tokenId);
        _rugPool.deposit{value: msg.value}(
            msg.sender,
            inviteCode,
            msg.value,
            tokenId
        );

        unchecked {
            _tokenURIById[tokenId] = getRandomMetadataIndex();
            ++_currentTokenId;
        }
    }

    function setMetadataCount(uint256 metadataCnt) public onlyOwner {
        _metadataCount = metadataCnt;
    }

    function setRugPool(address rugPool) public onlyOwner {
        _rugPool = RugPool(rugPool);
    }

    function setMintStartTime(uint newMintTime) public onlyOwner {
        require(
            newMintTime >= block.timestamp,
            "Rugbbit: cant earlier than now"
        );
        _mintStartTime = newMintTime;
    }

    function getMintStartTime() public view returns (uint) {
        return _mintStartTime;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        uint256 uriIndex = _tokenURIById[tokenId];
        uint idx;
        if (_rugPool.isWinnerToken(tokenId)) {
            idx = 14;
        } else {
            if (isRaffled()) {
                idx = 7;
            }
        }
        uint uri = uriIndex + idx;
        return string(abi.encodePacked(_baseURI(), uri.toString(), ".json"));
    }

    function getTokenUriIndex(uint tokenId) public view returns (uint256) {
        return _tokenURIById[tokenId];
    }

    function startTokenId() internal pure returns (uint256) {
        return 1;
    }

    function totalSupply() public view returns (uint256) {
        return _currentTokenId;
    }

    function getRandomMetadataIndex() internal view returns (uint) {
        return
            (uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp,
                        _currentTokenId
                    )
                )
            ) % _metadataCount) + 1;
    }

    function getMintPrice()
        public
        view
        returns (uint maxPrice, uint minPrice, uint costDown)
    {
        return (
            maxPrice = _maxPrice,
            minPrice = _minPrice,
            costDown = _costDownPrice
        );
    }

    function isRaffled() public view returns (bool) {
        (, , , uint winnerTokenId, , , ) = _rugPool.getPhaseInfo(
            _rugPool.getPhaseCount()
        );
        return winnerTokenId > 0;
    }

    function getRugPool() public view returns (address) {
        return address(_rugPool);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return
            "ipfs://bafybeic4fm4awjtq3bsicsw252vu5ev4c5pjurit7wil2tmexpwpocnnt4/";
    }
}