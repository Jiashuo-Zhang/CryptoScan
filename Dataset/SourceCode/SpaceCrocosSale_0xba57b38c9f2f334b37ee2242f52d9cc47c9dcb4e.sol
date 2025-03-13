// SPDX-License-Identifier: MIT
pragma solidity >=0.8.17;

import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";
import {SpaceCrocos} from "./SpaceCrocosToken.sol";

enum TicketID {
    AllowList,
    FamilySale
}

error PreMaxExceed(uint256 _presaleMax);
error MaxSupplyOver();
error NotEnoughFunds(uint256 balance);
error NotMintable();
error InvalidMerkleProof();
error AlreadyClaimedMax();
error MintAmountOver();

contract SpaceCrocosSale is AccessControl {
    uint256 private constant PUBLIC_MAX_PER_TX = 10;
    uint256 private constant PRE_MAX_CAP = 20;
    address private constant FUND_ADDRESS =
        0x4080412A60c30d547511A435d33e351F8Fe073EE;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bool public publicSale = false;
    bool public callerIsUserFlg = false;
    bool public mintable = false;
    uint256 public MAX_SUPPLY = 7700;

    SpaceCrocos nft;

    uint256 public publicCost = 0.01 ether;

    mapping(TicketID => bool) public presalePhase;
    mapping(TicketID => uint256) public presaleCost;
    mapping(TicketID => bytes32) public merkleRoot;
    mapping(TicketID => mapping(address => uint256)) public whiteListClaimed;

    constructor(address _space_crocos, bool _callerIsUserFlg, address _owner) {
        nft = SpaceCrocos(_space_crocos);
        callerIsUserFlg = _callerIsUserFlg;
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _grantRole(MINTER_ROLE, _owner);

        presaleCost[TicketID.AllowList] = 0.01 ether;
        presaleCost[TicketID.FamilySale] = 0.01 ether;
    }

    modifier whenMintable() {
        if (mintable == false) revert NotMintable();
        _;
    }

    /**
     * @dev The modifier allowing the function access only for real humans.
     */
    modifier callerIsUser() {
        if (callerIsUserFlg == true) {
            require(tx.origin == msg.sender, "The caller is another contract");
        }
        _;
    }

    /**
     * @notice Set the merkle root for the allow list mint
     */
    function setMerkleRoot(
        bytes32 _merkleRoot,
        TicketID ticket
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        merkleRoot[ticket] = _merkleRoot;
    }

    function setCallerIsUserFlg(
        bool flg
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        callerIsUserFlg = flg;
    }

    function publicMint(
        address _to,
        uint256 _mintAmount
    ) external payable callerIsUser whenMintable {
        if (nft.totalSupply() + _mintAmount > MAX_SUPPLY)
            revert MaxSupplyOver();
        if (msg.value < publicCost * _mintAmount)
            revert NotEnoughFunds(msg.value);
        if (!publicSale) revert NotMintable();
        if (_mintAmount > PUBLIC_MAX_PER_TX) revert MintAmountOver();

        nft.mint(_to, _mintAmount);
    }

    function preMint(
        uint256 _mintAmount,
        uint256 _presaleMax,
        bytes32[] calldata _merkleProof,
        TicketID ticket
    ) external payable whenMintable {
        if (_presaleMax > PRE_MAX_CAP) revert PreMaxExceed(_presaleMax);
        if (nft.totalSupply() + _mintAmount > MAX_SUPPLY)
            revert MaxSupplyOver();
        if (msg.value == 0 || msg.value < presaleCost[ticket] * _mintAmount)
            revert NotEnoughFunds(msg.value);
        if (!presalePhase[ticket]) revert NotMintable();
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _presaleMax));
        if (!MerkleProof.verifyCalldata(_merkleProof, merkleRoot[ticket], leaf))
            revert InvalidMerkleProof();
        if (whiteListClaimed[ticket][msg.sender] + _mintAmount > _presaleMax)
            revert AlreadyClaimedMax();

        nft.mint(msg.sender, _mintAmount);
        whiteListClaimed[ticket][msg.sender] += _mintAmount;
    }

    function setPresalePhase(
        bool _state,
        TicketID ticket
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        presalePhase[ticket] = _state;
    }

    function setMaxSupply(
        uint256 _supply
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        MAX_SUPPLY = _supply;
    }

    function setPresaleCost(
        uint256 _cost,
        TicketID ticket
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        presaleCost[ticket] = _cost;
    }

    function setPublicCost(
        uint256 _publicCost
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        publicCost = _publicCost;
    }

    function setPublicPhase(bool _state) external onlyRole(DEFAULT_ADMIN_ROLE) {
        publicSale = _state;
    }

    function setMintable(bool _state) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintable = _state;
    }

    function totalSupply() public view virtual returns (uint256) {
        return nft.totalSupply();
    }

    function withdraw() external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        payable(FUND_ADDRESS).transfer(balance);
    }
}