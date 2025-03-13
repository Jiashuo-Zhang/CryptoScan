// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/*
██████╗ ██████╗ ██╗  ██╗ ██████╗ ███████╗███╗   ██╗███████╗███████╗██╗███████╗
██╔══██╗██╔══██╗██║ ██╔╝██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔════╝██║██╔════╝
██║  ██║██████╔╝█████╔╝ ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ███████╗██║███████╗
██║  ██║██╔══██╗██╔═██╗ ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ╚════██║██║╚════██║
██████╔╝██║  ██║██║  ██╗╚██████╔╝███████╗██║ ╚████║███████╗███████║██║███████║
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝╚══════╝
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ERC721A/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IWhitelist.sol";
import "./AccessControlUpgradeable.sol";

/// 🅓🅡🅚🅖🅔🅝🅔🅢🅘🅢
/// @author DarkadeNFT Solidity Engineers
/// @title DarkadeNFT Genesis 3333 Collection
contract DRKGENESIS is
    Ownable,
    ERC721A,
    ReentrancyGuard,
    AccessControlUpgradeable
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant NFT_CHANGER_ROLE = keccak256("NFT_CHANGER_ROLE");
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");
    uint256 public constant nftMaxAmount = 3333;
    bool public _listingEnabled = false;
    bool public _revealed = false;
    bool public _priceChanged = false;
    address public withdrawerAddress;
    string public _revealBaseUri = "https://ipfs.io/ipfs/";
    string public _baseUri =
        "https://3333genesis.darkadenft.com/ipfs/QmNjXVBUNPJrLiEJGbR9kpzqbxuGnrLX68Cx3Swmojo5jV";
    bool public _mintEnabledGlobal;
    mapping(uint256 => bool) public _mintEnabled;
    mapping(uint256 => IWhitelist) public _whitelists;
    mapping(uint256 => uint256) public tierMinted;
    uint256[] public _price = [0.15 ether, 0.42 ether, 0.65 ether];

    event GenesisMint(address buyer, uint256 amount);
    event NftChangedUri(string uri);

    constructor(
        address _admin,
        IWhitelist[] memory initWL
    ) ERC721A("DRKGENESIS", "DRKG", nftMaxAmount, nftMaxAmount) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, _admin);
        _grantRole(NFT_CHANGER_ROLE, _admin);
        _grantRole(WITHDRAWER_ROLE, _admin);

        withdrawerAddress = _admin;
        (_mintEnabled[0], _mintEnabled[1], _mintEnabled[2], _mintEnabled[3]) = (
            true,
            true,
            true,
            true
        );
        (_whitelists[1], _whitelists[2], _whitelists[3]) = (
            initWL[0],
            initWL[1],
            initWL[2]
        );
    }

    /// @param wlTier the index
    /// @param _wl the whitelist address
    /// @notice store Whitelist contract address to mapping with index
    function setWhitelist(
        uint256 wlTier,
        IWhitelist _wl
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _whitelists[wlTier] = _wl;
    }

    /// @param proof your Merkle proof
    /// @param _amount the amount of NFT you want to mint
    /// @param _targetPhase the phase/tier at you want to mint
    /// @notice mint init function for both public and whitelist users
    function mint(
        bytes32[] memory proof,
        uint256 _amount,
        uint8 _targetPhase
    ) public payable nonReentrant {
        bool isMintEnabled = _mintEnabledGlobal == true &&
            _mintEnabled[_targetPhase] == true;
        require(isMintEnabled, "Mint is not enabled");

        require(
            isAllocationLimit(_amount, _targetPhase),
            "Nfts for this phase are out of stock"
        );

        require(_targetPhase < 4, "Incorrect Target Phase");

        require(
            isValidProof(proof, _targetPhase, msg.sender),
            "Proof is not valid for this phase"
        );

        require(isValidAmount(_amount, _targetPhase), "Amount not valid");

        uint256 priceToPay = getPriceToPay(_amount, _targetPhase);
        require(msg.value >= priceToPay, "Invalid Price");

        tierMinted[_targetPhase] = tierMinted[_targetPhase] + _amount;
        emit GenesisMint(msg.sender, _amount);
        _safeMint(msg.sender, _amount);
    }

    /// @dev Returns the price to pay for a given amount during a specific token sale phase. 
    /// @param _amount The number of tokens to purchase 
    /// @param _targetPhase The token sale phase (0-3) 
    /// @return _priceToPay The price in wei to pay for the given amount during the specific phase 
    function getPriceToPay(
        uint256 _amount,
        uint8 _targetPhase
    ) internal view returns (uint256 _priceToPay) {
        return
            _targetPhase == 0
                ? (
                    _amount == 1 ? _price[0] : _amount == 3
                        ? _price[1]
                        : _price[2]
                )
                : _targetPhase == 3
                ? _whitelists[3].cost(_amount)
                : _targetPhase == 2
                ? _whitelists[2].cost(_amount)
                : _whitelists[1].cost(1) * _amount;
    }

    /// @dev Checks if the amount is valid for the given target phase 
    /// @param _amount The amount to validate 
    /// @param _targetPhase The target phase 
    /// @return _isValidAmount True if the amount is valid, false otherwise 
    function isValidAmount(
        uint256 _amount,
        uint8 _targetPhase
    ) internal pure returns (bool _isValidAmount) {
        return
            _targetPhase == 1 || (_amount == 1 || _amount == 3 || _amount == 5);
    }

     /// @dev Checks if the provided proof is valid for the given target phase and user address 
    ///  @param proof An array of bytes32 elements representing the proof 
    ///  @param _targetPhase The target phase (0-3) 
    ///  @param _user The user address 
    ///  @return _isValidProof bool Whether the proof is valid for the given inputs
    function isValidProof(
        bytes32[] memory proof,
        uint8 _targetPhase,
        address _user
    ) internal view returns (bool _isValidProof) {
        return
            _targetPhase == 0 ||
            (proof.length != 0 &&
                ((_targetPhase == 1 &&
                    _whitelists[1].addressIsInWL(proof, _user)) ||
                    (_targetPhase == 2 &&
                        _whitelists[2].addressIsInWL(proof, _user)) ||
                    (_targetPhase == 3 &&
                        _whitelists[3].addressIsInWL(proof, _user))));
    }

    /// @notice Checks if allocating `_amount` of NFTs for `_targetPhase` will exceed the allocation limit. 
    /// @param _amount The number of NFTs to allocate for `_targetPhase`.
    /// @param _targetPhase The phase number to allocate NFTs for. Can be 0, 1, 2 or 3.
    /// @return _isAllocationLimit true` if the allocation limit will not be exceeded, `false` otherwise.
    function isAllocationLimit(
        uint256 _amount,
        uint8 _targetPhase
    ) internal view returns (bool _isAllocationLimit) {
        return
            totalSupply() + _amount <= nftMaxAmount &&
            (_targetPhase == 0 ||
                _targetPhase == 3 ||
                (_targetPhase == 1 &&
                    (tierMinted[_targetPhase] + _amount) <=
                    _whitelists[1].allocationLimit()) ||
                (_targetPhase == 2 &&
                    tierMinted[_targetPhase] + _amount <=
                    _whitelists[2].allocationLimit()));
    }

    /// @param uri target revealed uri for NFTs
    function setRevealBaseUri(
        string memory uri
    ) public onlyRole(NFT_CHANGER_ROLE) {
        _revealBaseUri = uri;
        emit NftChangedUri(uri);
    }

    /// @return the revealed base URI
    function getRevealBaseUri()
        public
        view
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (string memory)
    {
        return _revealBaseUri;
    }

    /// @param uri target base uri for NFTs
    function setBaseUri(string memory uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseUri = uri;
    }

    /// @notice @dev retrieve baseURI internal function
    function _baseURI() internal view override returns (string memory) {
        return _baseUri;
    }

    /// @param phaseIndex phase of WL index
    /// @param enable true of false state
    /// @notice @dev [0] index is public - [1, 2, 3] Tier 1, 2, 3
    function enableMint(
        uint256 phaseIndex,
        bool enable
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(phaseIndex < 4);
        _mintEnabled[phaseIndex] = enable;
    }

    /// @param enable true of false state
    /// @notice @dev enabled / disable global mint state
    function enableMintGlobal(bool enable) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _mintEnabledGlobal = enable;
    }

    /// @notice reveal function - can only set true the reveal variable
    function reveal() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _revealed = true;
    }

    /// @notice enableListingEnable function - can set true or false the _listingEnabled variable
    function enableListingEnable() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _listingEnabled = true;
    }

    /// @notice withdraw mint fund only from owner
    function withdraw() public onlyRole(WITHDRAWER_ROLE) {
        payable(withdrawerAddress).transfer(address(this).balance);
    }

    /// @param price price NFT will have in public sale
    function setPrice(
        uint256[] memory price
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!_priceChanged, "Price already changed once");
        _priceChanged = true;
        _price = price;
    }

    /// @param _owner address
    /// @return tokens id list of owner
    function getUserTokens(
        address _owner
    ) public view returns (uint256[] memory tokens) {
        uint256 _balance = balanceOf(_owner);
        uint256[] memory _tokens = new uint256[](_balance);
        for (uint256 i = 0; i < balanceOf(_owner); i += 1) {
            _tokens[i] = super.tokenOfOwnerByIndex(_owner, i);
        }
        return _tokens;
    }

    /// @param tokenId index target of NFT
    /// @return URI string of target NFT index
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return
            _revealed == false
                ? _baseURI()
                : string(
                    abi.encodePacked(
                        _revealBaseUri,
                        string.concat(
                            StringsUpgradeable.toString(tokenId),
                            ".json"
                        )
                    )
                );
    }

    function approve(address to, uint256 tokenId) public virtual override {
        require(_listingEnabled, "Not allowed approval");
        super.approve(to, tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public virtual override {
        require(_listingEnabled, "Not allowed approval");
        super.setApprovalForAll(operator, approved);
    }

    /// @notice @dev interface support function must have
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721A, AccessControlUpgradeable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context, ContextUpgradeable)
        returns (address)
    {
        return msg.sender;
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ContextUpgradeable)
        returns (bytes calldata)
    {
        return msg.data;
    }

    /// @notice @dev receive standard function
    receive() external payable {}
}