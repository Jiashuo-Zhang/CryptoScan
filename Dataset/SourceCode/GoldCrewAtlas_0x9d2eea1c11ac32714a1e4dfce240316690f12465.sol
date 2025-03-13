// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "erc721a/contracts/ERC721A.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "./ERC2891/ERC2981ContractWideRoyalties.sol";

contract GoldCrewAtlas is
    ERC721A,
    Ownable,
    DefaultOperatorFilterer,
    ERC2981ContractWideRoyalties
{
    using SafeMath for uint256;
    string public baseURI;
    string public prerevealURI;
    address[3] private gcaTeam;
    uint256[3] private gcaAlloc;
    address private teamMinter;
    uint256 private teamReserve = 400;
    uint256 public constant TXN_MAX = 50;
    uint256 public constant price = 0.0369 ether;
    uint256 public constant vipPrice = 0.029 ether;
    uint256 public maxSupply;
    bytes32 public vipRoot;
    bytes32 public prelistRoot;
    bool public isRevealed;

    enum MinterGroup {
        closed,
        vipPrelist,
        prelist,
        openToPublic
    }
    MinterGroup public minterGroup = MinterGroup.closed;

    modifier onlyGcaOrOwner() {
        bool isAllowed;
        isAllowed = (_msgSender() == owner());

        if (!isAllowed) {
            // check if address belongs to GCA team
            for (uint i = 0; i < gcaTeam.length; i++) {
                if (_msgSender() == gcaTeam[i]) {
                    isAllowed = true;
                    break;
                }
            }
        }
        require(
            isAllowed,
            "You do not have authorization to access this function!"
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        address _teamMinter,
        address[3] memory _gcaTeam,
        uint256[3] memory _gcaAlloc
    ) ERC721A(_name, _symbol) {
        maxSupply = _maxSupply;
        teamMinter = _teamMinter;
        gcaTeam = _gcaTeam;
        gcaAlloc = _gcaAlloc;
        require(
            gcaAlloc[0] + gcaAlloc[1] + gcaAlloc[2] == 10000,
            "GCA allocation must add up to 10000!"
        );
    }

    function setMinterGroup(MinterGroup _minterGroup) external onlyOwner {
        minterGroup = _minterGroup;
    }

    function setVipRoot(bytes32 _vipRoot) external onlyOwner {
        vipRoot = _vipRoot;
    }

    function setPrelistRoot(bytes32 _prelistRoot) external onlyOwner {
        prelistRoot = _prelistRoot;
    }

    function _verify(
        bytes32 leaf,
        bool isVip,
        bytes32[] memory proof
    ) internal view returns (bool) {
        return MerkleProof.verify(proof, isVip ? vipRoot : prelistRoot, leaf);
    }

    function reserveMint(uint256 quantity) external {
        require(
            _msgSender() == teamMinter || _msgSender() == gcaTeam[0],
            "You are not authorized claim reserve mints!"
        );
        require(
            quantity < teamReserve + 1,
            "You have already met your reserve mint limit!"
        );
        teamReserve = teamReserve - quantity;
        mint(quantity);
    }

    function mintPrelist(
        uint256 quantity,
        bytes32[] calldata proof
    ) external payable {
        require(
            minterGroup == MinterGroup.prelist,
            "Prelist mint is not yet open!"
        );
        require(
            _verify(keccak256(abi.encodePacked(_msgSender())), false, proof),
            "You are not in the prelist!"
        );
        require(
            msg.value >= price.mul(quantity),
            "You need to pay more ether!"
        );
        mint(quantity);
    }

    function mintVipPrelist(
        uint256 quantity,
        bytes32[] calldata proof
    ) external payable {
        require(
            minterGroup == MinterGroup.vipPrelist,
            "VIP Prelist mint is not yet open!"
        );
        require(
            _verify(keccak256(abi.encodePacked(_msgSender())), true, proof),
            "You are not in the VIP prelist!"
        );
        require(
            msg.value >= vipPrice.mul(quantity),
            "You need to pay more ether!"
        );
        mint(quantity);
    }

    function mintOpenToPublic(uint256 quantity) external payable {
        require(
            minterGroup == MinterGroup.openToPublic,
            "Public mint is not yet open!"
        );
        require(
            msg.value >= price.mul(quantity),
            "You need to pay more ether!"
        );
        mint(quantity);
    }

    function mint(uint256 quantity) private {
        require(
            quantity < TXN_MAX + 1,
            "You can only mint up to 50 tokens at a time!"
        );
        require(
            totalMinted() + quantity < maxSupply + 1,
            "Max supply reached!"
        );
        _mint(_msgSender(), quantity);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    function totalMinted() public view returns (uint256) {
        return _totalMinted();
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(tokenId), "This token ID does not exist!");
        if (!isRevealed) {
            return
                string(
                    abi.encodePacked(
                        prerevealURI,
                        "/",
                        _toString(tokenId),
                        ".json"
                    )
                );
        }
        return
            bytes(_baseURI()).length > 0
                ? string(
                    abi.encodePacked(
                        _baseURI(),
                        "/",
                        _toString(tokenId),
                        ".json"
                    )
                )
                : string(
                    abi.encodePacked(
                        prerevealURI,
                        "/",
                        _toString(tokenId),
                        ".json"
                    )
                );
    }

    function setPrerevealURI(string calldata _prerevealURI) external onlyOwner {
        prerevealURI = _prerevealURI;
    }

    function setBaseURI(string calldata _URI) external onlyOwner {
        baseURI = _URI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function revealCollection() external onlyOwner {
        isRevealed = true;
    }

    function withdraw() external payable onlyGcaOrOwner {
        uint balance = address(this).balance;
        uint totalPayout = 0;

        for (uint i = 0; i < gcaTeam.length - 1; i++) {
            uint payout = balance.mul(gcaAlloc[i]).div(10000);
            totalPayout = totalPayout.add(payout);
            payable(gcaTeam[i]).transfer(payout);
        }
        payable(gcaTeam[gcaTeam.length - 1]).transfer(balance.sub(totalPayout));
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(
        address operator,
        uint256 tokenId
    ) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    /// @inheritdoc	ERC165
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981Base) returns (bool) {
        return
            interfaceId == type(IERC2981Royalties).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /// @notice Allows to set the royalties on the contract as a percentage of sale price
    /// @param recipient the royalties recipient
    /// @param value royalties value (between 0 and 10000)
    function setRoyalties(address recipient, uint256 value) external onlyOwner {
        _setRoyalties(recipient, value);
    }

    receive() external payable {}
}