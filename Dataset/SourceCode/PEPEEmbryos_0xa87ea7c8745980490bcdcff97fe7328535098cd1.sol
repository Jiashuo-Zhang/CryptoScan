// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./lib/ERC721A.sol";
import "./interfaces/IERC6551Registry.sol";
import "./interfaces/IERC2981.sol";
import "./lib/ERC2981.sol";
import "./lib/ERC721Royalty.sol";

contract PEPEEmbryos is ERC721A, Ownable, ERC721Royalty {
    bool public paused;
    bool public saleIsActive;
    uint256 private _salt = 490;
    string private _baseURIextended;

    uint256 public MAX_SUPPLY;
    /// @custom:precision 18
    uint256 public wlPrice;
    bool public isWLMintOn;

    uint256 public currentPrice;
    uint256 public walletLimit;

    address public erc6551Registry;
    address public accountImplementation;

    bool public isFreeMintOn;
    uint256 public freeMintLimit;
    mapping(address => uint256) public freeMintedByUser;
    mapping(address => bool) public isWhitelistedUser;

    /**
     * @param _name NFT Name
     * @param _symbol NFT Symbol
     * @param _uri Token URI used for metadata
     * @param limit Wallet Limit
     * @param price Initial Price | precision:18
     * @param maxSupply Maximum # of NFTs
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        uint256 limit,
        uint256 price,
        uint256 maxSupply,
        address _receiver,
        uint96 feeNumerator
    ) payable ERC721A(_name, _symbol) {
        _baseURIextended = _uri;
        currentPrice = price;
        walletLimit = limit;
        MAX_SUPPLY = maxSupply;

        isFreeMintOn = true;
        freeMintLimit = 10;

        _setDefaultRoyalty(_receiver, feeNumerator);
    }

    /**
     * @dev An external method for users to purchase and mint NFTs. Requires that the sale
     * is active, that the minted NFTs will not exceed the `MAX_SUPPLY`, and that a
     * sufficient payable value is sent.
     * @param amount The number of NFTs to mint.
     */
    function publicMint(uint256 amount) external payable {
        uint256 ts = totalSupply();
        // uint256 minted = _numberMinted(msg.sender);

        require(saleIsActive, "Sale must be active to mint tokens");
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(
            currentPrice * amount == msg.value,
            "Sent value is not correct"
        );

        _mint(amount, ts);
    }

    /**
     * @dev An external method for users to mint NFTs in free phase.
     * @param amount The number of NFTs to mint.
     */
    function freeMint(uint256 amount) external {
        uint256 ts = totalSupply();

        require(isFreeMintOn, "Free mint is diabled.");
        require(
            amount + freeMintedByUser[msg.sender] <= freeMintLimit,
            "Exceeds free limit"
        );
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");

        _mint(amount, ts);
        freeMintedByUser[msg.sender] += amount;
    }

    /**
     * @dev An external method for whilteliste users to mint NFTs.
     * @param amount The number of NFTs to mint.
     */
    function wlMint(uint256 amount) external payable {
        uint256 ts = totalSupply();

        require(isWLMintOn, "WL mint is disabled.");
        require(isWhitelistedUser[msg.sender], "Address != whitelisted");
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");
        require(wlPrice * amount == msg.value, "Sent value is not correct");

        _mint(amount, ts);
    }

    function _mint(uint256 _amount, uint256 _ts) internal {
        require(!paused, "MINTING: Paused!");
        _safeMint(msg.sender, _amount);

        for (uint256 i = 0; i < _amount; i++) {
            IERC6551Registry(erc6551Registry).createAccount(
                accountImplementation,
                getChainID(),
                address(this),
                _ts + i,
                _salt,
                ""
            );
        }
    }

    function burn(uint256 tokenId) external {
        require(_exists(tokenId), "Invalid Id!");
        require(ownerOf(tokenId) == msg.sender, "Not a NFT Owner");
        _burn(tokenId);
    }

    /**
     * @dev A way for the owner to reserve a specifc number of NFTs without having to
     * interact with the sale.
     * @param to The address to send reserved NFTs to.
     * @param amount The number of NFTs to reserve.
     */
    function reserve(address to, uint256 amount) external onlyOwner {
        uint256 ts = totalSupply();
        require(ts + amount <= MAX_SUPPLY, "Purchase would exceed max tokens");
        _safeMint(to, amount);
    }

    /**
     * @dev A way for the owner to withdraw all proceeds from the sale.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /**
     * @dev Sets whether or not the NFT sale is active.
     * @param isActive Whether or not the sale will be active.
     */
    function setSaleIsActive(bool isActive) external onlyOwner {
        saleIsActive = isActive;
    }

    function setFreeMintLimit(uint256 _limit) external onlyOwner {
        freeMintLimit = _limit;
    }

    function setPauseStatus(bool _status) external onlyOwner {
        paused = _status;
    }

    function setWhitelistUsersStatus(
        address[] memory _users,
        bool _status
    ) external onlyOwner {
        for (uint256 i; i < _users.length; i++) {
            isWhitelistedUser[_users[i]] = _status;
        }
    }

    /**
     * @dev Sets the price of each NFT during the initial sale.
     * @param price The price of each NFT during the initial sale | precision:18
     */
    function setCurrentPrice(uint256 price) external onlyOwner {
        currentPrice = price;
    }

    /**
     * @dev Sets the price of each NFT for whitelisted users.
     * @param price The price of each NFT precision:18
     */
    function setWLPrice(uint256 price) external onlyOwner {
        wlPrice = price;
    }

    /**
     * @dev Sets the address of erc6551 registry contract
     * @param _addr new address of ERC6551 Registry contract
     */
    function setRegistryAddress(address _addr) external onlyOwner {
        erc6551Registry = _addr;
    }

    /**
     * @dev Sets the address of erc6551 Implementation contract
     * @param _addr new address of implementation contract
     */
    function setImplementationAddress(address _addr) external onlyOwner {
        accountImplementation = _addr;
    }

    /**
     * @dev Sets the maximum number of NFTs that can be sold to a specific address.
     * @param limit The maximum number of NFTs that be bought by a wallet.
     */
    function setWalletLimit(uint256 limit) external onlyOwner {
        walletLimit = limit;
    }

    /**
     * @dev Updates the Roaylaty fee for NFT.
     * @param _receiver New Receiver of royalty.
     * @param feeNumerator Roaylaty Fee.
     */
    function setFeeInfo(
        address _receiver,
        uint96 feeNumerator
    ) external onlyOwner {
        _setDefaultRoyalty(_receiver, feeNumerator);
    }

    /**
     * @dev Updates the baseURI that will be used to retrieve NFT metadata.
     * @param baseURI_ The baseURI to be used.
     */
    function setBaseURI(string memory baseURI_) external onlyOwner {
        _baseURIextended = baseURI_;
    }

    function updateFreeMintStatus(bool status) external onlyOwner {
        isFreeMintOn = status;
    }

    function updateWLMintStatus(bool status) external onlyOwner {
        isWLMintOn = status;
    }

    function updateAccountSalt(uint256 _slt) external onlyOwner {
        _salt = _slt;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721A, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function getChainID() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }
}