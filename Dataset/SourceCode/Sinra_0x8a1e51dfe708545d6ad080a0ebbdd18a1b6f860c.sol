// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "./libraries/Utils.sol";
import "./Types.sol";
import "./Authorizable.sol";

contract Sinra is Authorizable, ERC2981, ERC721A, ERC721AQueryable, ReentrancyGuard {
    // =============================================================
    //                            STORAGE
    // =============================================================

    /**
     * @notice Maximum amount for each batch
     */
    uint256 public maxBatch;

    /**
     * @notice Base token URI
     */
    string public baseURI;

    // -------------Organization-------

    /**
     * @notice Mapping project ID => organization ID
     */
    mapping(uint256 => uint256) public organizationIdOf;

    /**
     * @notice Mapping organization ID => organization address
     */
    mapping(uint256 => address) public organizationAddressOf;

    /**
     * @notice Mapping organization ID => royalty receipt address
     */
    mapping(uint256 => address) public receiptAddressOf;

    // -------------Project------------

    /**
     * @notice Mapping monitoring cycle ID => project ID
     */
    mapping(uint256 => uint256) public projectIdOf;

     /**
     * @notice Mapping project ID => project code
     */
    mapping(uint256 => string) private _projectCodeOf;

    /**
     * @notice Mapping project ID => royalty percent
     */
    mapping(uint256 => uint96) public royaltyPercentOf;


    // -----------Monitoring Cycle----------

    /**
     * @notice Mapping token ID => monitoring cycle ID
     */
    mapping(uint256 => uint256) public monitoringCycleIdOf;

    /**
     * @notice Mapping project ID => (monitoring cycle ID => monitoring cycle code mapping)
     */
    mapping(uint256 => mapping(uint256 => string)) public monitoringCodeOf;

    // ---------Token-----------

    /**
     * @notice Mapping token ID => purchased amount
     */
    mapping(uint256 => uint256) public purchasedVolumeOf;

    /**
     * @notice Mapping token ID => token status
     */
    mapping(uint256 => TokenStatus) private _statusOf;

     /**
     * @notice Mapping signature => is used
     */
    mapping(bytes => bool) public isUsedSignature;

    // =============================================================
    //                     EVENTS
    // =============================================================

    /**
     * @notice Emit event when contract is deployed
     */
    event Deployed(address owner, string tokenName, string symbol);

    /**
     * @notice Emit event when minting a token
     */
    event Mint(address to, uint256 tokenId, bytes signature);

    /**
     * @notice Emit event when minting batch of tokens
     */
    event MintBatch(uint256[] tokenIds);

    /**
     * @notice Emit event when setting base URI
     */
    event SetBaseURI(string oldBaseURI, string newBaseURI);

    /**
     * @notice Emit event when setting status of a token
     */
    event SetStatus(uint256 indexed tokenId, TokenStatus previousStatus, TokenStatus status);

    /**
     * @notice Emit event when setting batch of token statuses
     */
    event SetBatchOfStatuses(uint256[] tokenIds, TokenStatus[] previousStatues, TokenStatus[] statuses);

    /**
     * @notice Emit event when setting new max batch
     */
    event SetMaxBatch(uint256 oldMaxBatch, uint256 newMaxBatch);

    /**
     * @notice Emit event when setting organization information
     */
    event SetOrganizationInfo(uint256 organizationId, address organizationAddress, address receiptAddress);

    /**
     * @notice Emit event when updating organization information
     */
    event UpdateOrganizationInfo(uint256 organizationId, address previousReceiptAddress, address newReceiptAddress);

    /**
     * @notice Emit event when setting project information
     */
    event SetProjectInfo(
        uint256 organizationId,
        uint256 projectId,
        uint96 feeNumerator,
        string code
    );

    /**
     * @notice Emit event when setting monitoring cycle information
     */
    event SetMonitoringCycleInfo(
        uint256 projectId,
        uint256 monitoringCycleId,
        string code
    );

    /**
     * @notice Emit event when burning a token
     */
    event Burn(address owner, uint256 tokenId);

    // =============================================================
    //                          CONSTRUCTOR
    // =============================================================

    /**
     *  @notice Init contract
     *
     *  @dev    Setting states initial when deploying contract and only be called once
     *
     *          Name                            Meaning
     *  @param  _owner                          Contract owner address
     *  @param  _tokenName                      Token name
     *  @param  _symbol                         Token symbol
     *  @param  _maxBatch                       Maximum amout of each minting batch
     *
     *  Emit event {Deployed}
     */
    constructor(
        address _owner,
        string memory _tokenName,
        string memory _symbol,
        uint256 _maxBatch
    ) ERC721A(_tokenName, _symbol) {
        maxBatch = _maxBatch;
        transferOwnership(_owner);
        
        emit Deployed(_owner, _tokenName, _symbol);
    }

    // =============================================================
    //                          OVERRIDE FUNCTIONS
    // =============================================================

    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30000 gas.
     * 
     * Due to removal of OpenZeppelin, using super.supportsInterface in the function override may not work.
     * Source: https://chiru-labs.github.io/ERC721A/#/migration?id=supportsinterface
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC2981, IERC721A, ERC721A) returns (bool) {
        // Supports the following `interfaceId`s:
        // - IERC165: 0x01ffc9a7
        // - IERC721: 0x80ac58cd
        // - IERC721Metadata: 0x5b5e139f
        // - IERC2981: 0x2a55205a
        return 
            ERC721A.supportsInterface(interfaceId) || 
            ERC2981.supportsInterface(interfaceId);
    }

    /**
     * @dev Hook that is called before a set of serially-ordered token IDs
     * are about to be transferred. This includes minting.
     * And also called before burning one token.
     *
     * `startTokenId` - the first token ID to be transferred.
     * `quantity` - the amount to be transferred.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, `from`'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, `tokenId` will be burned by `from`.
     * - `from` and `to` are never both zero.
     */
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) override internal virtual {
        if (from != address(0) && to != address(0)) {
            require(_statusOf[startTokenId] == TokenStatus.Valid, "Invalid status");
        }
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

     /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, it can be overridden in child contracts.
     */
    function _baseURI() override internal view virtual returns (string memory) {
        return baseURI;
    }

    // =============================================================
    //                      SETTING STORAGE OPERATIONS
    // =============================================================

    /**
     *  @notice Set new maximum amout for each batch
     *
     *  @dev    Only admin can call this function
     *
     *          Name            Meaning
     *  @param  _maxBatch       New maximum amount for each patch that want to set
     * 
     *     Emit event {SetMaxBatch}
     */
    function setMaxBatch(uint256 _maxBatch) external onlyAdmin {
        require(_maxBatch > 0, "Invalid max batch");
        uint256 oldMaxBatch = maxBatch;
        maxBatch = _maxBatch;
        emit SetMaxBatch(oldMaxBatch, maxBatch);
    }

     /**
     *  @notice Set base token URI
     *
     *  @dev    Only admin can call this function
     *
     *            Name            Meaning
     *  @param    _baseUri        New base URI
     */
    function setBaseURI(string memory _baseUri) external onlyAdmin {
        string memory oldBaseURI = baseURI;
        baseURI = _baseUri;
        emit SetBaseURI(oldBaseURI, baseURI);
    }

    // =============================================================
    //                        REFLECT DATA OPERATIONS
    // =============================================================

    /**
     *  @notice Set organization information when publishing a organization
     *
     *  @dev    Anyone can call this function
     * 
     *  Requirements:
     * - `_signature` is signed by verifier
     *
     *          Name                    Meaning
     *  @param  _organizationId         Organization ID
     *  @param  _organizationAddress    Organization address
     *  @param  _receiptAddress         Royalty receipt address
     *  @param  _nonce                  Unique parameter
     *  @param  _signature              Signature that signed by verifier
     * 
     *  emit event {SetOrganizationInfo}
     */
    function setOrganizationInfo(
        uint256 _organizationId,
        address _organizationAddress,
        address _receiptAddress,
        string memory _nonce,
        bytes memory _signature
    ) external {
        require(!isUsedSignature[_signature], "Invalid signature");
        require(_receiptAddress != address(0), "Invalid address");
        bytes32 _hash = keccak256(abi.encodePacked(
            _organizationId,
            _organizationAddress,
            _receiptAddress,
            _nonce
        ));
        require(Utils.verifySignature(_hash, _signature, verifier), "Invalid signature");

        receiptAddressOf[_organizationId] = _receiptAddress;
        organizationAddressOf[_organizationId] = _organizationAddress;
        isUsedSignature[_signature] = true;

        emit SetOrganizationInfo(_organizationId, _organizationAddress, _receiptAddress);
    }

    /**
     *  @notice Update organization info
     *
     *  @dev    Caller is `_organizationId` organization can call this function
     * 
     *          Name                    Meaning
     *  @param  _organizationId         Organization ID
     *  @param  _receiptAddress         Royalty receipt address
     * 
     *  emit event {UpdateOrganizationInfo}
     */
    function updateOrganizationInfo(uint256 _organizationId, address _receiptAddress) external {
        require(
            organizationAddressOf[_organizationId] == _msgSender(), 
            "Caller is not organization"
        );
        require(_receiptAddress != address(0), "Invalid address");

        address previousReceiptAddress = receiptAddressOf[_organizationId];
        receiptAddressOf[_organizationId] = _receiptAddress;

        emit UpdateOrganizationInfo(_organizationId, previousReceiptAddress, _receiptAddress);
    }

    /**
     *  @notice Set project information when publishing a project
     *
     *  @dev    Only `_organizationId` organization can call this function
     *
     *          Name                    Meaning
     *  @param  _organizationId         Organization ID
     *  @param  _projectId              Project ID
     *  @param  _code                   Organization code - Project code
     *  @param  _royaltyPercent         Royalty percent
     * 
     *  emit event {SetProjectInfo}
     */
    function setProjectInfo(
        uint256 _organizationId,
        uint256 _projectId,
        string memory _code,
        uint96 _royaltyPercent
    ) external {
        require(organizationAddressOf[_organizationId] == _msgSender(), "Caller is not organization");

        organizationIdOf[_projectId] = _organizationId;
        _projectCodeOf[_projectId] = _code;
        royaltyPercentOf[_projectId] = _royaltyPercent;

        emit SetProjectInfo(
            _organizationId ,
            _projectId,
            _royaltyPercent,
            _code
        );
    }

    /**
     *  @notice Set monitoring cycle information when selling a monitoring cycle
     *
     *  @dev    Only organization who belongs to `_projectId` project can call this function
     *
     *          Name                    Meaning
     *  @param  _projectId              Project ID
     *  @param  _monitoringCycleId      Monitoring cycle ID
     *  @param  _code                   Monitoring cycle code
     * 
     *  Emit event {SetMonitoringCycleInfo}
     */
    function setMonitoringCycleInfo(
        uint256 _projectId,
        uint256 _monitoringCycleId,
        string memory _code
    ) external {
        uint256 organizationId = organizationIdOf[_projectId];
        require(
            _msgSender() == organizationAddressOf[organizationId],
            "Caller is not organization"
        );

        monitoringCodeOf[_projectId][_monitoringCycleId] = _code;
        projectIdOf[_monitoringCycleId] = _projectId;

        emit SetMonitoringCycleInfo(_projectId, _monitoringCycleId, _code);
    }

    // =============================================================
    //                        SETTING TOKEN OPERATIONS
    // =============================================================

    /**
     *  @notice Set status of token by token ID
     * 
     *  Requirements:
     *  - Caller is organization which the `_tokenId` token belongs to
     *
     *          Name        Meaning
     *  @param  _tokenId    Token ID
     *  @param  _status     New token status
     * 
     *  emit event {SetStatus}
     */
    function setStatus(uint256 _tokenId, TokenStatus _status) external {
        require(_exists(_tokenId), "Nonexistent token");
        uint256 organizationId = organizationIdOf[projectIdOf[monitoringCycleIdOf[_tokenId]]];
        require(
            _msgSender() == organizationAddressOf[organizationId], 
            "Caller is not organization"
        );

        TokenStatus previousStatus = _statusOf[_tokenId];
        _statusOf[_tokenId] = _status;

        emit SetStatus(_tokenId, previousStatus, _status);
    }

    /**
     *  @notice Set batch of token statuses
     *
     *  @dev    Only organization which the `_tokenIds` token belongs to
     *
     *  Requirements:
     * - Length of `_tokenIds` and `_statuses` are less than or equal `maxBatch` and consistent
     * 
     *          Name                Meaning
     *  @param  _tokenIds           Token IDs
     *  @param  _statuses           Token statuses
     * 
     *  Emit event {SetBatchOfStatuses}
     */
    function setBatchOfTokenStatuses(uint256[] memory _tokenIds, TokenStatus[] memory _statuses) external {
        uint256 length = _tokenIds.length;

        require(length > 0 && length <= maxBatch, "Invalid length");
        require(length == _statuses.length, "Inconsistent length");

        uint256 _organizationId = organizationIdOf[projectIdOf[monitoringCycleIdOf[_tokenIds[0]]]];
        require(
            _msgSender() == organizationAddressOf[_organizationId], 
            "Caller is not organization"
        );
        
        TokenStatus[] memory previousStatuses = new TokenStatus[](length);

        for (uint256 i = 0; i < length; i++) {
            require(_exists(_tokenIds[i]), "Nonexistent token");

            previousStatuses[i] = _statusOf[_tokenIds[i]];
            _statusOf[_tokenIds[i]] = _statuses[i];
        }

        emit SetBatchOfStatuses(_tokenIds, previousStatuses, _statuses);
    }

    // =============================================================
    //                        MINT OPERATIONS
    // =============================================================

    /**
     *  @notice Store token information and mint a token
     * 
     *  @dev    Save token information and mint a token
     *
     *          Name                            Meaning
     *  @param  _params.to                      Recipient address
     *  @param  _params.volume                  Purchased volume
     *  @param  _params.monitoringCycleId       Monitoring cycle ID
     */
    function _handleMint(MintParams memory _params) private {
        uint256 nextId = _nextTokenId();
        monitoringCycleIdOf[nextId] = _params.monitoringCycleId;
        purchasedVolumeOf[nextId] = _params.volume;

        _safeMint(_params.to, 1);
    }

    /**
     *  @notice Mint a token with ETH by an organization admin
     *
     *  @dev    Caller is organization who belongs to `_params.monitoringCycleId` monitoring cycle
     *
     *          Name                    Meaning
     *  @param  _to                     Recipient address
     *  @param  _monitoringCycleId      Monitoring cycle ID
     *  @param  _price                  Amount of money that need to mint token
     *  @param  _volume                 Purchased volume
     *
     *  Emit event {Mint}
     */
    function mintWithEthByAdmin(
        address _to, 
        uint256 _monitoringCycleId,
        uint256 _price,
        uint256 _volume
    ) external payable nonReentrant {
        uint256 organizationId = organizationIdOf[projectIdOf[_monitoringCycleId]];
        require(
            _msgSender() == organizationAddressOf[organizationId],
            "Caller is not organization"
        );
        require(msg.value == _price, "Invalid value");

        uint256 nextId = _nextTokenId();
        monitoringCycleIdOf[nextId] = _monitoringCycleId;
        purchasedVolumeOf[nextId] = _volume;

        _safeMint(_to, 1);

        Utils.transferEth(receiptAddressOf[organizationId], _price);

        emit Mint(_to, currentId(), "");
    }

    /**
     *  @notice Mint a token with ERC-20 by an organization admin
     *
     *  @dev    Caller is organization who belongs to `_params.monitoringCycleId` monitoring cycle
     *
     *          Name                    Meaning
     *  @param  _to                     Recipient address
     *  @param  _paymentToken           Payment token address
     *  @param  _monitoringCycleId      Monitoring cycle ID
     *  @param  _price                  Amount of money that need to mint token
     *  @param  _volume                 Purchased volume
     *
     *  Emit event {Mint}
     */
    function mintWithErc20ByAdmin(
        address _to,
        address _paymentToken,
        uint256 _monitoringCycleId,
        uint256 _price,
        uint256 _volume
    ) external nonReentrant {
        uint256 organizationId = organizationIdOf[projectIdOf[_monitoringCycleId]];
        require(
            _msgSender() == organizationAddressOf[organizationId], 
            "Caller is not organization"
        );

        uint256 tokenId = _nextTokenId();
        monitoringCycleIdOf[tokenId] = _monitoringCycleId;
        purchasedVolumeOf[tokenId] = _volume;

        _safeMint(_to, 1);

        Utils.transferErc20(
            _msgSender(), 
            receiptAddressOf[organizationId], 
            _paymentToken, 
            _price
        );

        emit Mint(_to, currentId(), "");
    }

    /**
     *  @notice Mint a token by an admin without payment
     *
     *  @dev    
     * - Caller is organization who belongs to `_monitoringCycleId` monitoring cycle
     * - No need to transfer NFT price to receipt address
     *
     *          Name                    Meaning
     *  @param  _to                     Recipient address
     *  @param  _volume                 Purchased volume
     *  @param  _monitoringCycleId      Monitoring cycle ID
     *
     *  Emit event {Mint}
     */
    function mintWithoutPayment(
        address _to,
        uint256 _volume,
        uint256 _monitoringCycleId
    ) external nonReentrant {
        uint256 organizationId = organizationIdOf[projectIdOf[_monitoringCycleId]];
        require(
            _msgSender() == organizationAddressOf[organizationId],
            "Caller is not organization"
        );

        uint256 tokenId = _nextTokenId();
        monitoringCycleIdOf[tokenId] = _monitoringCycleId;
        purchasedVolumeOf[tokenId] = _volume;

        _safeMint(_to, 1);

        emit Mint(_to, tokenId, "");
    }

    /**
     *  @notice Mint a token with ETH by a user
     *
     *  @dev    Anyone can call this function
     * 
     *  Requirements
     * - `_signature` is signed by verifier
     *
     *          Name                            Meaning
     *  @param  _params.to                      Recipient address
     *  @param  _params.price                   Amount of money that need to mint token
     *  @param  _params.volume                  Purchased volume
     *  @param  _params.nonce                   Unique param
     *  @param  _params.monitoringCycleId       Monitoring cycle ID
     *  @param  _params.expiredTime             Expired time of signature
     *  @param  _signature                      Signature
     *
     *  Emit event {Mint}
     */
    function mintWithEthByUser(
        MintParams memory _params,
        bytes memory _signature
    ) external payable nonReentrant {
        uint256 organizationId = organizationIdOf[projectIdOf[_params.monitoringCycleId]];
        require(!isUsedSignature[_signature], "Invalid signature");
        require(msg.value == _params.price, "Invalid value");
        require(_params.expiredTime >= block.timestamp, "Expired signature");
        bytes32 _message = keccak256(abi.encodePacked(
            _params.to,
            _params.paymentToken,
            _params.nonce,
            _params.monitoringCycleId,
            _params.price,
            _params.volume,
            _params.expiredTime
        ));
        require(Utils.verifySignature(_message, _signature, verifier), "Invalid signature");

        isUsedSignature[_signature] = true;

        _handleMint(_params);
        Utils.transferEth(
            receiptAddressOf[organizationId], 
            _params.price
        );

        emit Mint(_params.to, currentId(), _signature);
    }

    /**
     *  @notice Mint a token with ERC-20 by a user
     *
     *  @dev    Anyone can call this function
     * 
     *  Requirements
     * - `_signature` is signed by verifier
     *
     *          Name                            Meaning
     *  @param  _params.to                      Recipient address
     *  @param  _params.paymentToken            Payment token address 
     *  @param  _params.price                   Amount of money that need to mint token
     *  @param  _params.volume                  Purchased volume
     *  @param  _params.nonce                   Unique param
     *  @param  _params.monitoringCycleId       Monitoring cycle ID
     *  @param  _params.expiredTime             Expired time of signature
     *  @param  _signature                      Signature
     *
     *  Emit event {Mint}
     */
    function mintWithErc20ByUser(
        MintParams memory _params, 
        bytes memory _signature
    ) external nonReentrant {
        require(!isUsedSignature[_signature], "Invalid signature");
        require(_params.expiredTime >= block.timestamp, "Expired signature");
        bytes32 _message = keccak256(abi.encodePacked(
            _params.to,
            _params.paymentToken,
            _params.nonce,
            _params.monitoringCycleId,
            _params.price,
            _params.volume,
            _params.expiredTime
        ));
        require(Utils.verifySignature(_message, _signature, verifier), "Invalid signature");

        isUsedSignature[_signature] = true;

        _handleMint(_params);
        Utils.transferErc20(
            _params.to, 
            receiptAddressOf[organizationIdOf[projectIdOf[_params.monitoringCycleId]]],
            _params.paymentToken, 
            _params.price
        );

        emit Mint(_params.to, currentId(), _signature);
    }

    /**
     *  @notice Mint batch of tokens with ETH
     *
     *  @dev    Caller is organization who belongs to `_params[].monitoringCycleId` monitoring cycle
     *
     *          Name                            Meaning
     *  @param  _params[].to                    Recipient address
     *  @param  _params[].price                 Amount of money that need to mint token
     *  @param  _params[].volume                Purchased volume
     *  @param  _params[].monitoringCycleId     Monitoring cycle ID
     *
     *  Emit event {MintBatch}
     */
    function mintBatchWithEth(
        MintBatchParams[] memory _params
    ) external payable nonReentrant {
        uint256 length = _params.length;
        require(length > 0 && length <= maxBatch, "Invalid length");

        uint256 _organizationId = organizationIdOf[projectIdOf[_params[0].monitoringCycleId]];
        require(
            _msgSender() == organizationAddressOf[_organizationId], 
            "Caller is not organization"
        );

        uint256 totalPrice = 0;
        uint256[] memory tokenIds = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            totalPrice += _params[i].price;

            uint256 tokenId = _nextTokenId();
            tokenIds[i] = tokenId;
            monitoringCycleIdOf[tokenId] = _params[i].monitoringCycleId;
            purchasedVolumeOf[tokenId] = _params[i].volume;

            _safeMint(_params[i].to, 1);
        }
        
        require(msg.value == totalPrice, "Invalid value");

        Utils.transferEth(receiptAddressOf[_organizationId], totalPrice);

        emit MintBatch(tokenIds);
    }

    /**
     *  @notice Mint batch of tokens with ERC-20
     *
     *  @dev    Caller is organization who belongs to `_params[].monitoringCycleId` monitoring cycle
     *
     *          Name                            Meaning
     *  @param  _paymentToken                   Payment token address
     *  @param  _params[].to                    Recipient address
     *  @param  _params[].price                 Amount of money that need to mint token
     *  @param  _params[].volume                Purchased volume
     *  @param  _params[].monitoringCycleId     Monitoring cycle ID
     *
     *  Emit event {MintBatch}
     */
    function mintBatchWithErc20(
        address _paymentToken,
        MintBatchParams[] memory _params
    ) external nonReentrant {
        uint256 length = _params.length;
        require(length > 0 && length <= maxBatch, "Invalid length");

        uint256 _organizationId = organizationIdOf[projectIdOf[_params[0].monitoringCycleId]];
        require(
            _msgSender() == organizationAddressOf[_organizationId], 
            "Caller is not organization"
        );

        uint256 totalPrice = 0;
        uint256[] memory tokenIds = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            totalPrice += _params[i].price;

            uint256 tokenId = _nextTokenId();
            tokenIds[i] = tokenId;
            monitoringCycleIdOf[tokenId] = _params[i].monitoringCycleId;
            purchasedVolumeOf[tokenId] = _params[i].volume;

            _safeMint(_params[i].to, 1);
        }

        Utils.transferErc20(
            _msgSender(),
            receiptAddressOf[_organizationId], 
            _paymentToken, 
            totalPrice
        );

        emit MintBatch(tokenIds);
    }

    /**
     *  @notice Mint batch of tokens without payment
     *
     *  @dev    
     * - Caller is organization who belongs to `_params[].monitoringCycleId` monitoring cycles
     * - No need to transfer NFTs price to receipt wallet
     *
     *          Name                            Meaning
     *  @param  _params[].to                    Recipient address
     *  @param  _params[].volume                Purchased volume
     *  @param  _params[].monitoringCycleId     Monitoring cycle ID
     *
     *  Emit event {MintBatch}
     */
    function mintBatchWithoutPayment(MintBatchParams[] memory _params) external nonReentrant {
        uint256 length = _params.length;
        require(length > 0 && length <= maxBatch, "Invalid length");

        uint256 _organizationId = organizationIdOf[projectIdOf[_params[0].monitoringCycleId]];
        require(
            _msgSender() == organizationAddressOf[_organizationId], 
            "Caller is not organization"
        );

        uint256[] memory tokenIds = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = _nextTokenId();
            tokenIds[i] = tokenId;
            monitoringCycleIdOf[tokenId] = _params[i].monitoringCycleId;
            purchasedVolumeOf[tokenId] = _params[i].volume;

            _safeMint(_params[i].to, 1);
        }

        emit MintBatch(tokenIds);
    }

    // =============================================================
    //                   TOKEN COUNTING OPERATIONS
    // =============================================================

    /**
     * @dev See {ERC721A-_startTokenId}.
     */
    function _startTokenId() override internal view virtual returns (uint256) {
        return 1;
    }

    /**
     * @dev Returns the latest token ID
     */
    function currentId() public view returns (uint256) {
        return _nextTokenId() - _startTokenId();
    }

    // =============================================================
    //                   GETTING TOKEN INFORMATION OPERATIONS
    // =============================================================

    /**
     * @inheritdoc IERC2981
     */
    function royaltyInfo(uint256 tokenId, uint256 salePrice) override public view virtual returns (address, uint256) {
        uint256 projectId = projectIdOf[monitoringCycleIdOf[tokenId]];

        uint96 percent = royaltyPercentOf[projectId];
        address receiver = receiptAddressOf[organizationIdOf[projectId]];

        uint256 royaltyAmount = (salePrice * percent) / _feeDenominator();

        return (receiver, royaltyAmount);
    }

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `_tokenId` token.
     */
    function tokenURI(
        uint256 _tokenId
    ) public view virtual override(IERC721A, ERC721A) returns (string memory) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();

        string memory _baseUri = _baseURI();

        return bytes(_baseUri).length != 0 
            ? string(abi.encodePacked(_baseUri, _toString(_tokenId), ".json")) 
            : "";
    }

    /**
     * @dev Returns status of `_tokenId` token
     */
    function statusOf(uint256 _tokenId) public view returns (TokenStatus) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();

        return _statusOf[_tokenId];
    }

    /**
     * @dev Returns NFT code of `_tokenId` token (Organization code - Project code - Monitoring cycle code)
     */
    function projectCodeOf(uint256 _tokenId) public view returns (string memory) {
        if (!_exists(_tokenId)) revert URIQueryForNonexistentToken();

        uint256 monitoringCycleId = monitoringCycleIdOf[_tokenId];
        uint256 projectId = projectIdOf[monitoringCycleId];

        return string(
            abi.encodePacked(
                _projectCodeOf[projectIdOf[monitoringCycleId]],
                "-",
                monitoringCodeOf[projectId][monitoringCycleId]
            )
        );
    }

    // =============================================================
    //                   BURN OPERATIONS
    // =============================================================

    /**
     *  @notice Burn (destroy) a token
     *
     *  Requirements: 
     *  - `tokenId` must exist
     *
     *          Name          Meaning
     *  @param  tokenId       Token ID
     *
     *  Emit {Burn}
     */
    function burn(uint256 tokenId) external {
        delete monitoringCycleIdOf[tokenId];
        delete purchasedVolumeOf[tokenId];
        delete _statusOf[tokenId];

        _burn(tokenId, true);
        
        emit Burn(_msgSender(), tokenId);
    }
}