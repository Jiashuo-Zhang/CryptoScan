// Okami Labs
//
//        ______________________________________
//       /  ____________________________________ \
//      / /  ________                 __  .__    \ \
//     / /   \______ \   ____ _____ _/  |_|  |__  \ \
//    / /     |    |  \_/ __ \\__  \\   __\  |  \  \ \
//   / /      |    `   \  ___/ / __ \|  | |   Y  \  \ \
//   | |      /_______  /\___  >____  /__| |___|  /  | |
//   | |              \/     \/     \/          \/   | |
//   | |        _______             .___             | |
//   | |        \      \   ____   __| _/____         | |
//   | |        /   |   \ /  _ \ / __ |/ __ \        | |
//    \ \      /    |    (  <_> ) /_/ \  ___/       / /
//     \ \     \____|__  /\____/\____ |\___  >     / /
//      \ \           \/            \/    \/      / /
//       \ \_____________________________________/ /
//        \_______________________________________/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

contract DeathNode is Ownable, ERC721A, DefaultOperatorFilterer {
    using Strings for uint256;
    struct Prices {
        uint256 tier1;
        uint256 tier2;
        uint256 tier3;
    }

    struct Limits {
        uint64 tier1;
        uint64 tier2;
        uint64 tier3;
        uint64 max;
    }

    event Mint(uint256 amount);

    uint64 public MAX_PER_WALLET = 3;
    bool public isSaleActive;

    Limits public supplies;
    Prices public prices;

    mapping(address => uint256) public minted;
    string private baseURI;
    address payable private releaseWallet;

    constructor(
        address payable releaseAddress,
        string memory uri
    ) ERC721A("Death Node", "NODE") {
        baseURI = uri;
        releaseWallet = releaseAddress;

        prices.tier1 = 0.0033 ether;
        supplies.tier1 = 3333;

        prices.tier2 = 0.0066 ether;
        supplies.tier2 = 2222;

        prices.tier3 = 0.0099 ether;
        supplies.tier3 = 1111;

        supplies.max = 6666;
    }

    function mint(uint256 quantity) external payable {
        require(isSaleActive, "Mint has not started yet");
        require(tx.origin == _msgSender(), "No contracts");
        require(
            minted[msg.sender] + quantity <= MAX_PER_WALLET,
            "Per wallet limit exceeded"
        );
        if (totalSupply() < supplies.tier1) {
            require(
                totalSupply() + quantity <= supplies.tier1,
                "Tier 1 supply exceeded"
            );
            uint256 requiredValue = quantity * prices.tier1;
            if (minted[msg.sender] == 0) requiredValue -= prices.tier1;
            require(msg.value >= requiredValue, "Incorrect ETH amount");
        } else if (totalSupply() < supplies.tier1 + supplies.tier2) {
            require(
                totalSupply() + quantity <= supplies.tier1 + supplies.tier2,
                "Tier 2 supply exceeded"
            );
            require(
                msg.value >= quantity * prices.tier2,
                "Incorrect ETH amount"
            );
        } else {
            require(
                totalSupply() + quantity <= supplies.max,
                "Max supply exceeded"
            );
            require(
                msg.value >= quantity * prices.tier3,
                "Incorrect ETH amount"
            );
        }

        minted[msg.sender] += quantity;
        _mint(msg.sender, quantity);
        emit Mint(quantity);
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        require(_exists(tokenId), "URI query for nonexistent token");
        return
            bytes(baseURI).length != 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner {
        baseURI = baseURI_;
    }

    function setMaxPerWallet(uint64 limit) external onlyOwner {
        MAX_PER_WALLET = limit;
    }

    function flipSaleState() external onlyOwner {
        isSaleActive = !isSaleActive;
    }

    function changePrices(
        uint256 tier1,
        uint256 tier2,
        uint256 tier3
    ) external onlyOwner {
        prices.tier1 = tier1;
        prices.tier2 = tier2;
        prices.tier3 = tier3;
    }

    function cutSupply(
        uint64 max,
        uint64 tier1,
        uint64 tier2,
        uint64 tier3
    ) external onlyOwner {
        require(
            max < supplies.max,
            "New max supply should be lower than current max supply"
        );
        require(
            max > totalSupply(),
            "New max supply should be higher than current number of minted tokens"
        );
        require(
            tier1 + tier2 + tier3 == max,
            "Tiers do not add up to max supply"
        );
        supplies.max = max;
        supplies.tier1 = tier1;
        supplies.tier2 = tier2;
        supplies.tier3 = tier3;
    }

    function airdrop(uint256 quantity, address receiver) external onlyOwner {
        require(
            totalSupply() + quantity <= supplies.max,
            "Max supply exceeded"
        );
        _safeMint(receiver, quantity);
    }

    function releaseFunds() external onlyOwner {
        (bool success, ) = releaseWallet.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
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
}