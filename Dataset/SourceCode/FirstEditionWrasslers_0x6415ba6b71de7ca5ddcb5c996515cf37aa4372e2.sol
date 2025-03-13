// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
.                                                                                                                                          .
.  .cxxo.                 ;dxxo:cdxxdxxxxxo::dxxc.   .ldxxxdxxxxxo' 'oxxxxxxxxxxxl.   .cdxxl.      .ldxxxxxxo::dxxxxxxxxo:cdxxxxxxxxxd:.   .
.  .OMMX;               .dNMMXkONMMMMMMMMXkONMMM0'  ;0WMMMWMMWMWKc'cKWMMMMMMMMMW0;   ,kWMW0;      ;0WMMMMMMXkONMMMMMMMWXkONMMMMMMMMMNx'    .
.  .OMMX;    .,,,.     ;OWMW0kKWMWXXWMMW0k0WMMMM0'.oXMWXdcccccc:''xNMWWKocccccc:.  .cKWMNx.     .oXMMXxcccldKWMWXXWWMW0k0WMWOlcccccc;.     .
.  .OMMX:   ;ONWWk.  .lXWMNOkXWMN0KNWMNOkXWWMMWM0lkWMMW0occcccc,:0WWWNXOlcccccc.  .xNMWKc.     'kWMW0;   .lXWMNKKNWWXxxXWMMXxcccccc:.      .
.  .OMMX: .oXMMMMO. 'kWMWKk0NMMWNNWMWKk0NMW0ONMM0kXMMMMMMMMMMMWOkWMMMMWMMMMMMMWl.:0WMWk'     .cKWMWk'   'kWMMMNNWMW0:'kMMMMMMMMMMMMX;      .
.  .OMMX:,kWMMMMMO,cKWMNOkKWMMMMMMWXOkKWMNx':XMM0ooxxxxxxONMMMNocdxxxxxxx0WMMMXodXMMXo.     .xNMMMW0kxclKWMMMMMMWXx. .cxxxxxxkKWMMWO'      .
.  .OMMN0KWMNNWMMX0NMWXkONMMKx0WMM0okNMMKl. ;XMM0:',,.  'xNMWKc..','.   ,OWMWKk0WMW0;      ;0WMMWWWWXkONMWKxOWMMO;.'''.     .cKWMNx'       .
.  .OMMMMMWKloNMMMMMW0kKWMWO, lNMMXXWMWO,   ;XMM0kKNNk';0WMWk,  lXNNo..lKWMNOkXMMNd.     .oXMMXd:::cdKWMWO, cNMMx.oNNNo    .dNMMXl.        .
.  .OMMMMWO, :NMMWWXkkXWMXo.  lNMMMMMXo.    ;XMM0kNMMXOXMWXo.   oWMWK0KNMWKkONWMWXdllll;;kWMMWKdlllxXMMXo.  cNMWx'dWMW0ollo0WMWO,          .
.  .OMMMXo.  :NMMWKk0WMW0;    lNMMWW0;      ;XMM0kNMMMMMW0;     oWMMMMMMN0kKWMMMMMMMMNOkXWMMMMMMMMMMMW0;    cNMMx'dWMMMMMMMMWXo.           .
.  .:ooo,    .looc;:oooc.     'ooool.       .looc:loooooc.      ,ooooooo:;coooooooooo:;loooooooooooooc.     'loo;.,oooooooooo;             .
.                                                                                                                                          .*/

import "@rari-capital/solmate/src/tokens/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import {ERC721EnumerableEssential} from "../Libraries/ERC721EnumerableEssential.sol";
import {SignedAllowance} from "../Libraries/SignedAllowance.sol";

contract FirstEditionWrasslers is ERC721, Ownable, SignedAllowance, ERC721EnumerableEssential {
    using Strings for uint256;
    uint256 public constant MAX_SUPPLY = 2100;
    uint256 public nextTokenId;
    string public baseUri;
    address public draftVault;
    address public p2mVault;
    address public auctionVault;

    struct Claim {
        uint256 tokenId;
        bytes signature;
        address minter;
    }

    constructor() ERC721("First Edition Wrasslers", "FEWRASS") {
        draftVault = msg.sender;
        _setAllowancesSigner(msg.sender);
        ++nextTokenId;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return bytes(baseUri).length > 0 ? string(abi.encodePacked(baseUri, tokenId.toString())) : "";
    }

    /**
     * @notice Signed allowance disbursement based on L2 data
     * @dev Each of the mint paths depends on Layer 2 data that
     * assigns a tokenId to a minter address. Card packs, P2M
     * and public auctions all emit TokenAssigned events that
     * our off-chain infrastructure handles by creating signatures
     * and submitting transactions to transfer tokens to their assigned
     * owner address.
     */
    function claimMultiple(Claim[] memory claims) external {
        uint256 l = claims.length;

        for (uint256 i = 0; i < l; ) {
            Claim memory c = claims[i];

            _useAllowance(c.minter, c.tokenId, c.signature);
            _ownerOf[c.tokenId] = c.minter;
            emit Transfer(draftVault, c.minter, c.tokenId);
            unchecked {
                _balanceOf[c.minter] += l;
                i++;
            }
        }
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        _beforeTokenTransfer(from, to, id);
        ERC721.transferFrom(from, to, id);
    }

    /**
     * @notice Admin function for minting tokens to draftPool EOA
     * @dev We want to provide mint pass holders transparency into
     * mintable tokens. When we "mint" to our draftPool, we perform
     * the bare minimum to ensure popular marketplaces index the
     * new tokens. We save gas by not writing to storage at all.
     */
    function mintToPool(uint256 count) external {
        // Indexers prefer mint events where Transfer#to == msg.sender
        // to prevent spam. Only callable by destination EOA which
        // is different from contract owner
        require(msg.sender == draftVault, "Admin Only");
        require(nextTokenId + count - 1 <= MAX_SUPPLY);
        uint256 nextLoopId = nextTokenId + count;
        for (uint256 id = nextTokenId; id < nextLoopId; ) {
            emit Transfer(address(0), msg.sender, id);
            unchecked {
                ++id;
            }
        }
        _tokenCounter += count;
        nextTokenId = nextLoopId;
    }

    /// @notice sets allowance signer, this can be used to revoke all unused allowances already out there
    /// @param newSigner the new signer
    function setAllowancesSigner(address newSigner) external onlyOwner {
        _setAllowancesSigner(newSigner);
    }

    function setDraftVault(address _draftVault) external onlyOwner {
        draftVault = _draftVault;
    }

    function setBaseURI(string calldata _uri) external onlyOwner {
        baseUri = _uri;
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _ownerOf[tokenId];
        if (owner == address(0) && tokenId < nextTokenId) {
            return draftVault;
        }
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        require(tokenId > 0, "ERC721: owner query for nonexistent token");
        return tokenId < nextTokenId;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}