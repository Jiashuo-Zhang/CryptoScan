// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;



import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

import "@openzeppelin/contracts/utils/Address.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";



pragma solidity ^0.8.0;



contract ERC721A is

    Context,

    ERC165,

    IERC721,

    IERC721Metadata,

    IERC721Enumerable,

    Ownable

{

    using Address for address;

    using Strings for uint256;



    struct TokenOwnership {

        address addr;

        uint64 startTimestamp;

    }



    struct AddressData {

        uint128 balance;

        uint128 numberMinted;

    }



    uint256 internal currentIndex = 1;



    // Token name

    string private _name;



    // Token symbol

    string private _symbol;



    // Mapping from token ID to ownership details

    // An empty struct value does not necessarily mean the token is unowned. See ownershipOf implementation for details.

    mapping(uint256 => TokenOwnership) internal _ownerships;



    // Mapping owner address to address data

    mapping(address => AddressData) private _addressData;



    // Mapping from token ID to approved address

    mapping(uint256 => address) private _tokenApprovals;



    // Mapping from owner to operator approvals

    mapping(address => mapping(address => bool)) private _operatorApprovals;



    constructor(string memory name_, string memory symbol_) {

        _name = name_;

        _symbol = symbol_;

    }



    /**

     * @dev See {IERC721Enumerable-totalSupply}.

     */

    function totalSupply() public view virtual override returns (uint256) {

        return currentIndex;

    }



    /**

     * @dev See {IERC721Enumerable-tokenByIndex}.

     */

    function tokenByIndex(

        uint256 index

    ) public view override returns (uint256) {

        require(index < totalSupply(), "ERC721A: global index out of bounds");

        return index;

    }



    /**

     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.

     * This read function is O(totalSupply). If calling from a separate contract, be sure to test gas first.

     * It may also degrade with extremely large collection sizes (e.g >> 10000), test for your use case.

     */

    function tokenOfOwnerByIndex(

        address owner,

        uint256 index

    ) public view override returns (uint256) {

        require(index < balanceOf(owner), "ERC721A: owner index out of bounds");

        uint256 numMintedSoFar = totalSupply();

        uint256 tokenIdsIdx;

        address currOwnershipAddr;



        // Counter overflow is impossible as the loop breaks when uint256 i is equal to another uint256 numMintedSoFar.

        unchecked {

            for (uint256 i; i < numMintedSoFar; i++) {

                TokenOwnership memory ownership = _ownerships[i];

                if (ownership.addr != address(0)) {

                    currOwnershipAddr = ownership.addr;

                }

                if (currOwnershipAddr == owner) {

                    if (tokenIdsIdx == index) {

                        return i;

                    }

                    tokenIdsIdx++;

                }

            }

        }



        revert("ERC721A: unable to get token of owner by index");

    }



    /**

     * @dev See {IERC165-supportsInterface}.

     */

    function supportsInterface(

        bytes4 interfaceId

    ) public view virtual override(ERC165, IERC165) returns (bool) {

        return

            interfaceId == type(IERC721).interfaceId ||

            interfaceId == type(IERC721Metadata).interfaceId ||

            interfaceId == type(IERC721Enumerable).interfaceId ||

            super.supportsInterface(interfaceId);

    }



    /**

     * @dev See {IERC721-balanceOf}.

     */

    function balanceOf(address owner) public view override returns (uint256) {

        require(

            owner != address(0),

            "ERC721A: balance query for the zero address"

        );

        return uint256(_addressData[owner].balance);

    }



    function _numberMinted(address owner) internal view returns (uint256) {

        require(

            owner != address(0),

            "ERC721A: number minted query for the zero address"

        );

        return uint256(_addressData[owner].numberMinted);

    }



    /**

     * Gas spent here starts off proportional to the maximum mint batch size.

     * It gradually moves to O(1) as tokens get transferred around in the collection over time.

     */

    function ownershipOf(

        uint256 tokenId

    ) internal view returns (TokenOwnership memory) {

        require(_exists(tokenId), "ERC721A: owner query for nonexistent token");



        unchecked {

            for (uint256 curr = tokenId; curr >= 0; curr--) {

                TokenOwnership memory ownership = _ownerships[curr];

                if (ownership.addr != address(0)) {

                    return ownership;

                }

            }

        }



        revert("ERC721A: unable to determine the owner of token");

    }



    /**

     * @dev See {IERC721-ownerOf}.

     */

    function ownerOf(uint256 tokenId) public view override returns (address) {

        return ownershipOf(tokenId).addr;

    }



    /**

     * @dev See {IERC721Metadata-name}.

     */

    function name() public view virtual override returns (string memory) {

        return _name;

    }



    /**

     * @dev See {IERC721Metadata-symbol}.

     */

    function symbol() public view virtual override returns (string memory) {

        return _symbol;

    }



    /**

     * @dev See {IERC721Metadata-tokenURI}.

     */

    function tokenURI(

        uint256 tokenId

    ) public view virtual override returns (string memory) {

        require(

            _exists(tokenId),

            "ERC721Metadata: URI query for nonexistent token"

        );



        string memory baseURI = _baseURI();

        return

            bytes(baseURI).length != 0

                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))

                : "";

    }



    /**

     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each

     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty

     * by default, can be overriden in child contracts.

     */

    function _baseURI() internal view virtual returns (string memory) {

        return "";

    }



    /**

     * @dev See {IERC721-approve}.

     */

    function approve(address to, uint256 tokenId) public override {

        address owner = ERC721A.ownerOf(tokenId);

        require(to != owner, "ERC721A: approval to current owner");



        require(

            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),

            "ERC721A: approve caller is not owner nor approved for all"

        );



        _approve(to, tokenId, owner);

    }



    /**

     * @dev See {IERC721-getApproved}.

     */

    function getApproved(

        uint256 tokenId

    ) public view override returns (address) {

        require(

            _exists(tokenId),

            "ERC721A: approved query for nonexistent token"

        );



        return _tokenApprovals[tokenId];

    }



    /**

     * @dev See {IERC721-setApprovalForAll}.

     */

    function setApprovalForAll(

        address operator,

        bool approved

    ) public override {

        require(operator != _msgSender(), "ERC721A: approve to caller");



        _operatorApprovals[_msgSender()][operator] = approved;

        emit ApprovalForAll(_msgSender(), operator, approved);

    }



    /**

     * @dev See {IERC721-isApprovedForAll}.

     */

    function isApprovedForAll(

        address owner,

        address operator

    ) public view virtual override returns (bool) {

        return _operatorApprovals[owner][operator];

    }



    /**

     * @dev See {IERC721-transferFrom}.

     */

    function transferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override {

        _transfer(from, to, tokenId);

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId

    ) public override {

        safeTransferFrom(from, to, tokenId, "");

    }



    /**

     * @dev See {IERC721-safeTransferFrom}.

     */

    function safeTransferFrom(

        address from,

        address to,

        uint256 tokenId,

        bytes memory _data

    ) public override {

        _transfer(from, to, tokenId);

        require(

            _checkOnERC721Received(from, to, tokenId, _data),

            "ERC721A: transfer to non ERC721Receiver implementer"

        );

    }



    /**

     * @dev Returns whether `tokenId` exists.

     *

     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.

     *

     * Tokens start existing when they are minted (`_mint`),

     */

    function _exists(uint256 tokenId) internal view returns (bool) {

        return tokenId < currentIndex;

    }



    function _safeMint(address to, uint256 quantity) internal {

        _safeMint(to, quantity, "");

    }



    /**

     * @dev Safely mints `quantity` tokens and transfers them to `to`.

     *

     * Requirements:

     *

     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called for each safe transfer.

     * - `quantity` must be greater than 0.

     *

     * Emits a {Transfer} event.

     */

    function _safeMint(

        address to,

        uint256 quantity,

        bytes memory _data

    ) internal {

        _mint(to, quantity, _data, true);

    }



    /**

     * @dev Mints `quantity` tokens and transfers them to `to`.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - `quantity` must be greater than 0.

     *

     * Emits a {Transfer} event.

     */

    function _mint(

        address to,

        uint256 quantity,

        bytes memory _data,

        bool safe

    ) internal {

        uint256 startTokenId = currentIndex;

        require(to != address(0), "ERC721A: mint to the zero address");

        require(quantity != 0, "ERC721A: quantity must be greater than 0");



        _beforeTokenTransfers(address(0), to, startTokenId, quantity);



        // Overflows are incredibly unrealistic.

        // balance or numberMinted overflow if current value of either + quantity > 3.4e38 (2**128) - 1

        // updatedIndex overflows if currentIndex + quantity > 1.56e77 (2**256) - 1

        unchecked {

            _addressData[to].balance += uint128(quantity);

            _addressData[to].numberMinted += uint128(quantity);



            _ownerships[startTokenId].addr = to;

            _ownerships[startTokenId].startTimestamp = uint64(block.timestamp);



            uint256 updatedIndex = startTokenId;



            for (uint256 i; i < quantity; i++) {

                emit Transfer(address(0), to, updatedIndex);

                if (safe) {

                    require(

                        _checkOnERC721Received(

                            address(0),

                            to,

                            updatedIndex,

                            _data

                        ),

                        "ERC721A: transfer to non ERC721Receiver implementer"

                    );

                }



                updatedIndex++;

            }



            currentIndex = updatedIndex;

        }



        _afterTokenTransfers(address(0), to, startTokenId, quantity);

    }



    /**

     * @dev Transfers `tokenId` from `from` to `to`.

     *

     * Requirements:

     *

     * - `to` cannot be the zero address.

     * - `tokenId` token must be owned by `from`.

     *

     * Emits a {Transfer} event.

     */

    function _transfer(address from, address to, uint256 tokenId) private {

        TokenOwnership memory prevOwnership = ownershipOf(tokenId);



        bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||

            getApproved(tokenId) == _msgSender() ||

            isApprovedForAll(prevOwnership.addr, _msgSender()));



        require(

            isApprovedOrOwner,

            "ERC721A: transfer caller is not owner nor approved"

        );



        require(

            prevOwnership.addr == from,

            "ERC721A: transfer from incorrect owner"

        );

        require(to != address(0), "ERC721A: transfer to the zero address");



        _beforeTokenTransfers(from, to, tokenId, 1);



        // Clear approvals from the previous owner

        _approve(address(0), tokenId, prevOwnership.addr);



        // Underflow of the sender's balance is impossible because we check for

        // ownership above and the recipient's balance can't realistically overflow.

        // Counter overflow is incredibly unrealistic as tokenId would have to be 2**256.

        unchecked {

            _addressData[from].balance -= 1;

            _addressData[to].balance += 1;



            _ownerships[tokenId].addr = to;

            _ownerships[tokenId].startTimestamp = uint64(block.timestamp);



            // If the ownership slot of tokenId+1 is not explicitly set, that means the transfer initiator owns it.

            // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.

            uint256 nextTokenId = tokenId + 1;

            if (_ownerships[nextTokenId].addr == address(0)) {

                if (_exists(nextTokenId)) {

                    _ownerships[nextTokenId].addr = prevOwnership.addr;

                    _ownerships[nextTokenId].startTimestamp = prevOwnership

                        .startTimestamp;

                }

            }

        }



        emit Transfer(from, to, tokenId);

        _afterTokenTransfers(from, to, tokenId, 1);

    }



    /**

     * @dev Approve `to` to operate on `tokenId`

     *

     * Emits a {Approval} event.

     */

    function _approve(address to, uint256 tokenId, address owner) private {

        _tokenApprovals[tokenId] = to;

        emit Approval(owner, to, tokenId);

    }



    /**

     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.

     * The call is not executed if the target address is not a contract.

     *

     * @param from address representing the previous owner of the given token ID

     * @param to target address that will receive the tokens

     * @param tokenId uint256 ID of the token to be transferred

     * @param _data bytes optional data to send along with the call

     * @return bool whether the call correctly returned the expected magic value

     */

    function _checkOnERC721Received(

        address from,

        address to,

        uint256 tokenId,

        bytes memory _data

    ) private returns (bool) {

        if (to.isContract()) {

            try

                IERC721Receiver(to).onERC721Received(

                    _msgSender(),

                    from,

                    tokenId,

                    _data

                )

            returns (bytes4 retval) {

                return retval == IERC721Receiver(to).onERC721Received.selector;

            } catch (bytes memory reason) {

                if (reason.length == 0) {

                    revert(

                        "ERC721A: transfer to non ERC721Receiver implementer"

                    );

                } else {

                    assembly {

                        revert(add(32, reason), mload(reason))

                    }

                }

            }

        } else {

            return true;

        }

    }



    /**

     * @dev Hook that is called before a set of serially-ordered token ids are about to be transferred. This includes minting.

     *

     * startTokenId - the first token id to be transferred

     * quantity - the amount to be transferred

     *

     * Calling conditions:

     *

     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be

     * transferred to `to`.

     * - When `from` is zero, `tokenId` will be minted for `to`.

     */

    function _beforeTokenTransfers(

        address from,

        address to,

        uint256 startTokenId,

        uint256 quantity

    ) internal virtual {}



    /**

     * @dev Hook that is called after a set of serially-ordered token ids have been transferred. This includes

     * minting.

     *

     * startTokenId - the first token id to be transferred

     * quantity - the amount to be transferred

     *

     * Calling conditions:

     *

     * - when `from` and `to` are both non-zero.

     * - `from` and `to` are never both zero.

     */

    function _afterTokenTransfers(

        address from,

        address to,

        uint256 startTokenId,

        uint256 quantity

    ) internal virtual {}

}



pragma solidity >=0.8.0 <0.9.0;



contract BabyMonkey is ERC721A {

    using Strings for uint256;



    // ================== VARAIBLES =======================

    bytes32 public merkleRootAl;

    mapping(address => bool) public allowlistClaimed;



    string private uriPrefix = "";

    string private uriSuffix = ".json";

    string private hiddenMetadataUri;



    bool public revealed = true;

    bool public paused = true;



    uint256 public salePrice = 0.001 ether;

    uint256 public plFree = 20;

    uint256 public alFree = 30;

    uint256 public maxTx = 50;

    uint256 public maxSupply = 7028;



    uint256 public FREE_MINTED = 0;

    mapping(address => uint256) public CLAIMED;



    // ================== CONTRUCTOR =======================



    constructor() ERC721A("Baby Monkey", "BM") {

        setHiddenMetadataUri("ipfs://__CID__/hidden.json");

    }



    // ================== MINT FUNCTIONS =======================



    /**

     * @notice Mint

     */

    function mint(uint256 _quantity) external payable {

        require(!paused, "The contract is paused!");

        require(

            _quantity > 0,

            "Minimum 1 NFT has to be minted per transaction"

        );

        require(_quantity + balanceOf(msg.sender) <= maxTx, "No more!");

        require(_quantity + totalSupply() <= maxSupply, "Sold out");



        if (msg.sender != owner()) {

            if (!(CLAIMED[msg.sender] >= plFree)) {

                if (_quantity <= plFree - CLAIMED[msg.sender]) {

                    require(msg.value >= 0, "Please send the exact amount.");

                } else {

                    require(

                        msg.value >=

                            salePrice *

                                (_quantity - (plFree - CLAIMED[msg.sender])),

                        "Please send the exact amount."

                    );

                }

                FREE_MINTED += _quantity;

                CLAIMED[msg.sender] += _quantity;

            } else {

                require(

                    msg.value >= salePrice * _quantity,

                    "Please send the exact amount."

                );

            }

        }

        _safeMint(msg.sender, _quantity);

    }



    /**

     * @notice Allowlist Mint

     */

    function allowlistMint(

        uint256 _quantity,

        bytes32[] calldata _merkleProof

    ) external payable {

        require(!paused, "The contract is paused!");

        require(

            _quantity > 0,

            "Minimum 1 NFT has to be minted per transaction"

        );

        require(_quantity + balanceOf(msg.sender) <= maxTx, "No more!");

        require(_quantity + totalSupply() <= maxSupply, "Sold out");

        require(isAllowlist(_merkleProof), "Address is not allowlisted!");

        if (msg.sender != owner()) {

            if (!(CLAIMED[msg.sender] >= alFree)) {

                if (_quantity <= alFree - CLAIMED[msg.sender]) {

                    require(msg.value >= 0, "Please send the exact amount.");

                } else {

                    require(

                        msg.value >=

                            salePrice *

                                (_quantity - (alFree - CLAIMED[msg.sender])),

                        "Please send the exact amount."

                    );

                }

                FREE_MINTED += _quantity;

                CLAIMED[msg.sender] += _quantity;

            } else {

                require(

                    msg.value >= salePrice * _quantity,

                    "Please send the exact amount."

                );

            }

        }

        _safeMint(msg.sender, _quantity);

    }



    /**

     * @notice Team Mint

     */

    function teamMint(uint256 _quantity) external onlyOwner {

        require(totalSupply() + _quantity <= maxSupply, "Sold out");

        _safeMint(msg.sender, _quantity);

    }



    /**

     * @notice airdrop

     */

    function airdrop(address _to, uint256 _quantity) external onlyOwner {

        require(!paused, "The contract is paused!");

        require(_quantity + totalSupply() <= maxSupply, "Sold out");

        _safeMint(_to, _quantity);

    }



    /**

     * @notice Check if the address is in the allowlist or not

     */

    function isAllowlist(

        bytes32[] calldata _merkleProof

    ) public view returns (bool) {

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));

        if (MerkleProof.verify(_merkleProof, merkleRootAl, leaf)) {

            return true;

        }

        return false;

    }



    function setRevealed(bool _state) public onlyOwner {

        revealed = _state;

    }



    function setPaused(bool _state) external onlyOwner {

        paused = _state;

    }



    function setAllowlist(bytes32 _merkleRoot) external onlyOwner {

        merkleRootAl = _merkleRoot;

    }



    function setSalePrice(uint256 _newPrice) external onlyOwner {

        salePrice = _newPrice;

    }



    function setPlFree(uint256 _plFree) external onlyOwner {

        plFree = _plFree;

    }



    function setAlFree(uint256 _alFree) external onlyOwner {

        alFree = _alFree;

    }



    function setMaxTx(uint256 _maxTx) external onlyOwner {

        maxTx = _maxTx;

    }



    function setMaxSupply(uint256 _maxSupply) public onlyOwner {

        maxSupply = _maxSupply;

    }



    function setHiddenMetadataUri(

        string memory _hiddenMetadataUri

    ) public onlyOwner {

        hiddenMetadataUri = _hiddenMetadataUri;

    }



    function setUriPrefix(string memory _uriPrefix) public onlyOwner {

        uriPrefix = _uriPrefix;

    }



    function setUriSuffix(string memory _uriSuffix) public onlyOwner {

        uriSuffix = _uriSuffix;

    }



    function _baseURI() internal view virtual override returns (string memory) {

        return uriPrefix;

    }



    function walletOfOwner(

        address _owner

    ) public view returns (uint256[] memory) {

        uint256 ownerTokenCount = balanceOf(_owner);

        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);

        uint256 currentTokenId = 1;

        uint256 ownedTokenIndex = 0;



        while (

            ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply

        ) {

            address currentTokenOwner = ownerOf(currentTokenId);

            if (currentTokenOwner == _owner) {

                ownedTokenIds[ownedTokenIndex] = currentTokenId;

                ownedTokenIndex++;

            }

            currentTokenId++;

        }

        return ownedTokenIds;

    }



    function tokenURI(

        uint256 _tokenId

    ) public view virtual override returns (string memory) {

        require(

            _exists(_tokenId),

            "ERC721Metadata: URI query for nonexistent token"

        );

        if (revealed == false) {

            return hiddenMetadataUri;

        }

        string memory currentBaseURI = _baseURI();

        return

            bytes(currentBaseURI).length > 0

                ? string(

                    abi.encodePacked(

                        currentBaseURI,

                        _tokenId.toString(),

                        uriSuffix

                    )

                )

                : "";

    }



    function withdraw() external onlyOwner {

        (bool success, ) = payable(msg.sender).call{

            value: address(this).balance

        }("");

        require(success, "Transfer failed.");

    }

}