// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

//
//  ::::::::  :::    :::     :::     :::::::::      :::      :::::::: ::::::::::: :::::::::: :::::::::       :::::::::      :::      ::::::::  
// :+:    :+: :+:    :+:   :+: :+:   :+:    :+:   :+: :+:   :+:    :+:    :+:     :+:        :+:    :+:      :+:    :+:   :+: :+:   :+:    :+: 
// +:+        +:+    +:+  +:+   +:+  +:+    +:+  +:+   +:+  +:+           +:+     +:+        +:+    +:+      +:+    +:+  +:+   +:+  +:+    +:+ 
// +#+        +#++:++#++ +#++:++#++: +#++:++#:  +#++:++#++: +#+           +#+     +#++:++#   +#++:++#:       +#+    +:+ +#++:++#++: +#+    +:+ 
// +#+        +#+    +#+ +#+     +#+ +#+    +#+ +#+     +#+ +#+           +#+     +#+        +#+    +#+      +#+    +#+ +#+     +#+ +#+    +#+ 
// #+#    #+# #+#    #+# #+#     #+# #+#    #+# #+#     #+# #+#    #+#    #+#     #+#        #+#    #+#      #+#    #+# #+#     #+# #+#    #+# 
//  ########  ###    ### ###     ### ###    ### ###     ###  ########     ###     ########## ###    ###      #########  ###     ###  ########  
// 
// :::::::::: :::::::::: :::::::: ::::::::::: ::::::::::: :::     :::     :::     :::              ::::::::  ::::::::: :::::::::::             
// :+:        :+:       :+:    :+:    :+:         :+:     :+:     :+:   :+: :+:   :+:             :+:    :+: :+:    :+:    :+:                 
// +:+        +:+       +:+           +:+         +:+     +:+     +:+  +:+   +:+  +:+             +:+        +:+    +:+    +:+                 
// :#::+::#   +#++:++#  +#++:++#++    +#+         +#+     +#+     +:+ +#++:++#++: +#+             +#++:++#++ +#++:++#+     +#+                 
// +#+        +#+              +#+    +#+         +#+      +#+   +#+  +#+     +#+ +#+                    +#+ +#+    +#+    +#+                 
// #+#        #+#       #+#    #+#    #+#         #+#       #+#+#+#   #+#     #+# #+#             #+#    #+# #+#    #+#    #+#                 
// ###        ########## ########     ###     ###########     ###     ###     ### ##########       ########  #########     ###                 
//

/// @title: CharacterDAOFestivalSBT
/// @author: Ichiro

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./libs/ERC5192/IERC5192.sol";

contract CharacterDAOFestivalSBT is
    ERC1155,
    ERC1155Supply,
    IERC5192,
    Ownable,
    AccessControl
{

    using Strings for uint256;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Contract name
    string public name;
    // Contract symbol
    string public symbol;

    string constant private BASE_EXTENSION = ".json";

    error ErrLocked();
    error ErrNotFound();

    mapping(uint256 => uint256) public maxSupply;

    bool public mintable;
    uint256 public mintTokenId;
    uint256 public cost;


    constructor(string memory _name, string memory _symbol, string memory _uri) ERC1155(_uri) {
        name = _name;
        symbol = _symbol;

        maxSupply[1] = 300;

        mintable = false;
        mintTokenId = 1;
        cost = 0.007 ether;

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(MINTER_ROLE, _msgSender());
    }


    //
    // mint
    // 

    modifier whenMintable() {
        require(mintable == true, "Mintable: paused");
        _;
    }

    function mint(uint256 _mintAmount)
        public
        payable
        whenMintable
    {
        supplyCheck(mintTokenId, _mintAmount);

        // cost check
        uint256 nowCost = _mintAmount * cost;
        require(msg.value >= nowCost, "Not enough funds");

        _mint(msg.sender, mintTokenId, _mintAmount, "");
    }

    function mintTo(
        address _to,
        uint256 _assetType,
        uint256 _amount
    ) public onlyRole(MINTER_ROLE) {
        require(_to != address(0), "Invalid address");
        require(_assetType > 0, "Invalid asset type");
        supplyCheck(_assetType, _amount);

        _mint(_to, _assetType, _amount, "");
    }

    function mintToBatch(
        address _to,
        uint256[] memory _assetTypes,
        uint256[] memory _amounts
    ) public onlyRole(MINTER_ROLE) {
        require(_to != address(0), "Invalid address");
        for (uint i = 0; i < _assetTypes.length; i++) {
            supplyCheck(_assetTypes[i], _amounts[i]);
        }

        _mintBatch(_to, _assetTypes, _amounts, "");
    }

    function supplyCheck(
        uint256 _assetType,
        uint256 _mintAmount
    ) private view {
        require(_mintAmount > 0, "Mint amount cannot be zero");
        require(
            totalSupply(_assetType) + _mintAmount <= maxSupply[_assetType],
            "MAX SUPPLY OVER"
        );
    }


    //
    // ERC1155
    //

    function uri(uint256 tokenId) public view override returns (string memory) {
        require(exists(tokenId));
        return string(abi.encodePacked(super.uri(tokenId), tokenId.toString(), BASE_EXTENSION));
    }

    function setURI(string memory _uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(_uri);
    }


    //
    // ERC1155Supply
    //

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }


    //
    // ERC5192 for SBT
    //

    modifier checkLock() {
        // Always locked.
        revert ErrLocked();
        _;
    }

    function locked(uint256 tokenId) external view returns (bool) {
        // All existing tokenIds are always locked.
        if (!exists(tokenId)) revert ErrNotFound();
        return true;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)
        public
        override
        checkLock
    {
        super.safeTransferFrom(from, to, tokenId, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override checkLock {
        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function setApprovalForAll(address operator, bool approved) public override checkLock {
        super.setApprovalForAll(operator, approved);
    }


    //
    // mint setting
    //

    function setCost(uint256 _cost) public onlyRole(DEFAULT_ADMIN_ROLE) {
        cost = _cost;
    }

    function setMintTokenId(uint256 _mintTokenId) public onlyRole(DEFAULT_ADMIN_ROLE) {
        mintTokenId = _mintTokenId;
    }

    function setMintable(bool _state) public onlyRole(DEFAULT_ADMIN_ROLE) {
        mintable = _state;
    }

    function setMaxSupply(uint256 _tokenId, uint256 _maxSupply) public onlyRole(DEFAULT_ADMIN_ROLE) {
        maxSupply[_tokenId] = _maxSupply;
    }


    //
    // others
    //

    function setName(string memory _name) public onlyRole(DEFAULT_ADMIN_ROLE) {
        name = _name;
    }

    function setSymbol(string memory _symbol) public onlyRole(DEFAULT_ADMIN_ROLE) {
        symbol = _symbol;
    }

    function withdraw() external onlyRole(DEFAULT_ADMIN_ROLE) {
        Address.sendValue(payable(owner()), address(this).balance);
    }


    //
    // supportsInterface
    //

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return (ERC1155.supportsInterface(interfaceId) ||
            interfaceId == type(IERC5192).interfaceId ||
            AccessControl.supportsInterface(interfaceId) ||
            super.supportsInterface(interfaceId));
    }

}