// SPDX-License-Identifier: MIT



pragma solidity >=0.8.17;



import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "@openzeppelin/contracts/token/common/ERC2981.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/access/AccessControl.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "contract-allow-list/contracts/proxy/interface/IContractAllowListProxy.sol";

import {UpdatableOperatorFilterer} from "operator-filter-registry/src/UpdatableOperatorFilterer.sol";

import {RevokableDefaultOperatorFilterer} from "operator-filter-registry/src/RevokableDefaultOperatorFilterer.sol";



contract NAGOMIHappyBirthday is

    ERC1155,

    ERC1155Supply,

    ERC2981,

    Ownable,

    AccessControl,

    RevokableDefaultOperatorFilterer

{

    bytes32 public constant ADMIN = keccak256("ADMIN");

    bytes32 public constant MINTER = keccak256("MINTER");



    using Strings for uint256;



    string public name;

    string public symbol;

    string public baseURI = "ipfs://bafybeifpwewtpsu4xo5enxw6he3bipkxxp2rm3qx5jegu75iwduckysitm/";

    string public baseExtension = ".json";



    constructor() ERC1155("") {

        name = "NAGOMI Happy Birthday";

        symbol = "NHB";



        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _grantRole(ADMIN, msg.sender);

        _grantRole(MINTER, msg.sender);



        //CAL initialization

        setCALLevel(1);

        //Ethereum mainnet proxy

        setCAL(0xdbaa28cBe70aF04EbFB166b1A3E8F8034e5B9FC7); 

        //OpenSea

        addLocalContractAllowList(0x1E0049783F008A0085193E00003D00cd54003c71); 



        //Royalty

        setDefaultRoyalty(0x445513cd8ECA1E98b0C70f1Cdc52C4d986dDC987, 1000);

    }



    /**

     * ミント関数

     */

    /// @dev MINTERによるミント関数

    function externalMint(address _to, uint256 _id, uint256 _amount) external onlyRole(MINTER) {

        _mint(_to, _id, _amount, "");

    }



    /**

     * URI関係

     */

    function uri(uint256 _id) public view override returns (string memory) {

        return string(abi.encodePacked(baseURI, _id.toString(), baseExtension));

    }



    /// @dev メタデータフォルダーのsetter（..../まで）

    function setBaseURI(string memory _value) external onlyRole(ADMIN) {

        baseURI = _value;

    }



    /// @dev メタデータファイル拡張子のsetter（デフォルトは.json）

    function setBaseExtension(string memory _value) external onlyRole(ADMIN) {

        baseExtension = _value;

    }



    /**

     * @dev totalSupplyのgetter

     *      See {ERC1155Supply-totalSupply}.

     */

    function sumOfTotalSupply() public view returns (uint256) {

        return totalSupply(0) + totalSupply(1) + totalSupply(2);

    }



    /**

     * OVERRIDES OperatorFilter functions

     */

    function setApprovalForAll(address operator, bool approved)

        public

        virtual

        override

        onlyAllowedOperatorApproval(operator)

    {

        require(_isAllowed(operator) || approved == false, "RestrictApprove: operatror not approved");

        super.setApprovalForAll(operator, approved);

    }



    function safeTransferFrom(address from, address to, uint256 tokenId, uint256 amount, bytes memory data)

        public

        override

        onlyAllowedOperator(from)

    {

        super.safeTransferFrom(from, to, tokenId, amount, data);

    }



    function safeBatchTransferFrom(

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) public virtual override onlyAllowedOperator(from) {

        super.safeBatchTransferFrom(from, to, ids, amounts, data);

    }



    /**

     * OVERRIDES required by Solidity

     */

    function _beforeTokenTransfer(

        address operator,

        address from,

        address to,

        uint256[] memory ids,

        uint256[] memory amounts,

        bytes memory data

    ) internal override(ERC1155, ERC1155Supply) {

        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

    }



    function owner() public view virtual override(Ownable, UpdatableOperatorFilterer) returns (address) {

        return Ownable.owner();

    }



    /**

     * ERC2981のSetter関数

     */

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyRole(ADMIN) {

        _setDefaultRoyalty(receiver, feeNumerator);

    }



    function deleteDefaultRoyalty() external onlyRole(ADMIN) {

        _deleteDefaultRoyalty();

    }



    // ==================================================================

    // Restrict Approve

    // ==================================================================

    using EnumerableSet for EnumerableSet.AddressSet;



    IContractAllowListProxy public cal;

    EnumerableSet.AddressSet localAllowedAddresses;

    uint256 public calLevel = 1;

    bool public enableRestrict = true;



    function setEnableRestrict(bool _enableRestrict) external onlyRole(ADMIN) {

        enableRestrict = _enableRestrict;

    }



    function addLocalContractAllowList(address transferer) public onlyRole(ADMIN) {

        localAllowedAddresses.add(transferer);

    }



    function removeLocalContractAllowList(address transferer) external onlyRole(ADMIN) {

        localAllowedAddresses.remove(transferer);

    }



    function getLocalContractAllowList() external view returns (address[] memory) {

        return localAllowedAddresses.values();

    }



    function _isLocalAllowed(address transferer) internal view virtual returns (bool) {

        return localAllowedAddresses.contains(transferer);

    }



    function _isAllowed(address transferer) internal view virtual returns (bool) {

        if (enableRestrict == false) {

            return true;

        }



        return _isLocalAllowed(transferer) || cal.isAllowed(transferer, calLevel);

    }



    function setCAL(address value) public onlyRole(ADMIN) {

        cal = IContractAllowListProxy(value);

    }



    function setCALLevel(uint256 value) public onlyRole(ADMIN) {

        calLevel = value;

    }



    /**

     * supportsInterface override

     */

    function supportsInterface(bytes4 interfaceId)

        public

        view

        override(ERC2981, ERC1155, AccessControl)

        returns (bool)

    {

        return ERC2981.supportsInterface(interfaceId) || AccessControl.supportsInterface(interfaceId)

            || ERC1155.supportsInterface(interfaceId);

    }

}