// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./operatorfilterer/DefaultOperatorFilterer.sol";


contract MallCard is ERC1155, ERC2981, DefaultOperatorFilterer, Ownable {
    struct ClaimDefinition {
        bytes32 merkleRootHash;
        uint256 startTime;
        uint256 endTime;
        bool revoked;
    }
    struct ClaimData {
        uint256 claimRecordIndex;
        uint256 silverAmount;
        uint256 goldAmount;
        uint256 diamondAmount;
        uint256 userExpireDate;
        bytes32[] merkleProof;
    }
    struct ReflinkUsage {
        address from;
        address to;
        uint256 token;
        uint256 amount;
        uint256 price;
        uint256 discount;
        string refCode;
    }
    struct Token {
        uint256 maxSupply;
        uint256 totalClaim;
        uint256 totalSale;
        mapping(uint256 => uint256) tierSales;
        uint256[] limits;
        uint256[] prices;
    }
    struct TokenSummary {
        uint256 token;
        uint256 currentPrice;
        uint256 discount;
        uint256 currentTier;
        uint256 maxSupply;
        uint256 totalClaim;
        uint256 totalSale;
        uint256[] tierSales;
        uint256[] limits;
        uint256[] prices;
    }
    struct TokenAmount {
        uint256 token;
        uint256 amount;
    }

    ClaimDefinition[] public claimDefinitions;
    mapping(uint256 => mapping(address => bool)) public claimRecords;

    uint256 public constant SILVER = 0;
    uint256 public constant GOLD = 1;
    uint256 public constant DIAMOND = 2;

    uint private constant TOKEN_LEN = 3;

    IERC20 public tokenContract;
    ReflinkUsage[] public reflinkRecords;
    mapping(uint256 => bool) public paused;
    mapping(uint256 => Token) public tokens;
    mapping(uint256 => uint256) public discountRates;
    mapping(address => uint256[]) public reflinkSourceRecords;
    mapping(uint256 => string) public tokenURIs;

    bool public useTicketBasedDiscountRates;

    uint256 public publicSaleStart;
    uint256 public transferOpenDate;
    uint256 public discountRate;

    address public mintIncomeWaletContract;

    string public name = "MallCard Genesis Edition";
    string public symbol = "mCard";

    event Claim(address indexed owner, TokenAmount[] claimed);

    event TokenMint(
        address indexed owner,
        uint256 token,
        uint256 amount,
        uint256 price,
        uint256 discount,
        address reflinkOwner,
        string refCode
    );

    event SetPrices(uint256[][] prices, uint256[][] limits);

    event Pause(uint256[] ids);

    event UnPause(uint256[] ids);

    event SetURI(uint256 indexed id, string uri);

    event SetTokenContract(address tokenContract);

    event SetDiscountRate(uint256 discountRate);

    event SetPublicSaleStart(uint256 transferOpenDate);

    event SetTransferOpenDate(uint256 publicSaleStart);

    event SetMaxSupplies(uint256 silver, uint256 gold, uint256 diamond);

    event SetMintIncomeWalletContract(address mintIncomeWaletContract);

    event SetRoyaltyInfo(address receiver, uint96 feeNumerator);

    event CreateClaim(ClaimDefinition claims);

    event RevokeClaim(uint256 indexed index);

    constructor(
        address _tokenContract,
        address _royaltyWaletContract,
        address _mintIncomeWalletContract,
        uint256 _publicSaleStart,
        uint96 _royalty,
        uint256 _discountRate
    ) ERC1155("") {
        require(_tokenContract != address(0), "MallCard: tokenContract zero address");
        require(_royaltyWaletContract != address(0), "MallCard: royaltyWaletContract zero address");
        require(_mintIncomeWalletContract != address(0), "MallCard: mintIncomeWalletContract zero address");
        if (_publicSaleStart == 0) {
            setPublicSaleStart(block.timestamp);
        } else {
            setPublicSaleStart(_publicSaleStart);
        }
        discountRate = _discountRate;
        mintIncomeWaletContract = _mintIncomeWalletContract;
        _setDefaultRoyalty(_royaltyWaletContract, _royalty);

        tokenContract = IERC20(_tokenContract);
    }

    // Modifiers
    modifier salesOpen(uint256 _id) {
        require(!paused[_id], "Sale is currently closed, please try again later");
        require(block.timestamp > publicSaleStart, "Public sale not started, please try again on the public sale date");
        _;
    }

    // Write Functions
    function setURI(uint256 _id, string calldata _uri) public onlyOwner {
        require(bytes(_uri).length > 0, "MallCard: uri empty");
        require(_id < TOKEN_LEN, "MallCard: invalid id");
        tokenURIs[_id] = _uri;
        emit SetURI(_id, _uri);
    }

    function setURIs(string[] calldata _uris) external onlyOwner {
        for (uint256 i = 0; i < _uris.length; i++) {
            setURI(i, _uris[i]);
        }
    }

    function setTokenContract(address _tokenContract) external onlyOwner {
        require(address(0) != _tokenContract, "MallCard: zero _tokenContract");
        tokenContract = IERC20(_tokenContract);
        emit SetTokenContract(_tokenContract);
    }

    function setDiscountRate(uint256 _discountRate) external onlyOwner {
        discountRate = _discountRate;
        emit SetDiscountRate(_discountRate);
    }

    function setTicketBasedDiscountRates(uint256[] calldata _discountRates, bool _enabled) external onlyOwner {
        require(_discountRates.length == TOKEN_LEN, "MallCard: _discountRates length mismatch");
        useTicketBasedDiscountRates = _enabled;
        for (uint256 r = 0; r < _discountRates.length; r++) {
            discountRates[r] = _discountRates[r];
        }
    }

    function setTransferOpenDate(uint256 _transferOpenDate) external onlyOwner {
        require(_transferOpenDate > block.timestamp, "MallCard: invalid _transferOpenDate");
        transferOpenDate = _transferOpenDate;
        emit SetTransferOpenDate(_transferOpenDate);
    }

    function setPublicSaleStart(uint256 _publicSaleStart) public onlyOwner {
        require(_publicSaleStart >= block.timestamp, "MallCard: invalid _publicSaleStart");
        publicSaleStart = _publicSaleStart;
        emit SetPublicSaleStart(_publicSaleStart);
    }

    function setMaxSupplies(uint256 _silver, uint256 _gold, uint256 _diamond) external onlyOwner {
        tokens[SILVER].maxSupply = _silver;
        tokens[GOLD].maxSupply = _gold;
        tokens[DIAMOND].maxSupply = _diamond;
        emit SetMaxSupplies(_silver, _gold, _diamond);
    }

    function setMintIncomeWalletContract(address _mintIncomeWaletContract) external onlyOwner {
        require(_mintIncomeWaletContract != address(0), "MallCard: to zero mintIncomeWaletContract");

        mintIncomeWaletContract = _mintIncomeWaletContract;
        emit SetMintIncomeWalletContract(_mintIncomeWaletContract);
    }

    function setRoyaltyInfo(address _receiver, uint96 _feeNumerator) external onlyOwner {
        _setDefaultRoyalty(_receiver, _feeNumerator);
        emit SetRoyaltyInfo(_receiver, _feeNumerator);
    }

    function setPrices(uint256[][] calldata _prices, uint256[][] calldata _limits) external onlyOwner {
        require(_prices.length == TOKEN_LEN, "MallCard: _prices length mismatch");
        require(_limits.length == TOKEN_LEN, "MallCard: _limits length mismatch");

        for (uint256 r = 0; r < _prices.length; r++) {
            require(_limits[r].length == _prices[r].length, "MallCard: _limit and _price length mismatch");
            tokens[r].prices = _prices[r];
            tokens[r].limits = _limits[r];
        }
        emit SetPrices(_prices, _limits);
    }

    function pause(uint256[] calldata _ids) external onlyOwner {
        require(_ids.length <= TOKEN_LEN, "MallCard: claim _ids length mismatch");
        for (uint256 r = 0; r < _ids.length; r++) {
            paused[_ids[r]] = true;
        }
        emit Pause(_ids);
    }

    function unPause(uint256[] calldata _ids) external onlyOwner {
        require(_ids.length <= TOKEN_LEN, "MallCard: claim _ids length mismatch");
        for (uint256 i = 0; i < _ids.length; i++) {
            paused[_ids[i]] = false;
        }
        emit UnPause(_ids);
    }

    function createClaim(bytes32 _merkleRootHash, uint256 _startTime, uint256 _endTime) external onlyOwner {
        require(_merkleRootHash.length > 0, "MallCard: invalid merkle root hash");
        require(_startTime > block.timestamp, "MallCard: start time must be in the future");
        require(_endTime > _startTime, "MallCard: end time must be later then start time");
        ClaimDefinition memory _claimRecord = ClaimDefinition({
            merkleRootHash: _merkleRootHash,
            startTime: _startTime,
            endTime: _endTime,
            revoked: false
        });
        claimDefinitions.push(_claimRecord);
        emit CreateClaim(_claimRecord);
    }

    function revokeClaim(uint256 _index) external onlyOwner {
        require(_index >= 0 && _index < claimDefinitions.length, "MallCard: invalid claim definition index");
        require(!claimDefinitions[_index].revoked, "MallCard: already revoked");
        require(claimDefinitions[_index].endTime > block.timestamp, "MallCard: already expired");
        claimDefinitions[_index].revoked = true;
        emit RevokeClaim(_index);
    }

    function mint(uint256 _id) external salesOpen(_id) {
        (uint256 _price, , uint256 _tier) = getCurrentPrice(_id, address(0));
        require(_hasTokenSupply(_id, _tier));
        require(
            tokenContract.transferFrom(msg.sender, mintIncomeWaletContract, _price),
            "Sorry, your wallet does not have enough balance to complete this transaction"
        );
        _mint(msg.sender, _id, 1, "");
        tokens[_id].totalSale = tokens[_id].totalSale + 1;
        tokens[_id].tierSales[_tier] = tokens[_id].tierSales[_tier] + 1;

        emit TokenMint(msg.sender, _id, 1, _price, 0, address(0), "");
    }

    function mintWithReflink(address _referral, uint256 _id, string calldata _refCode) external salesOpen(_id) {
        require(_referral != address(0), "Invalid referral code, your transaction could not be completed. Try again");
        require(
            bytes(_refCode).length > 0,
            "Referral code is required, your transaction could not be processed. Try again"
        );
        (uint256 _price, uint256 _discount, uint256 _tier) = getCurrentPrice(_id, _referral);
        require(_hasTokenSupply(_id, _tier));
        require(
            tokenContract.transferFrom(msg.sender, mintIncomeWaletContract, _price - _discount),
            "Sorry, your wallet does not have enough balance to complete this transaction"
        );
        _mint(msg.sender, _id, 1, bytes(_refCode));
        tokens[_id].totalSale = tokens[_id].totalSale + 1;
        tokens[_id].tierSales[_tier] = tokens[_id].tierSales[_tier] + 1;
        if (_discount > 0) {
            ReflinkUsage memory _reflinkRecord = ReflinkUsage({
                from: _referral,
                to: msg.sender,
                token: _id,
                refCode: _refCode,
                amount: 1,
                price: _price,
                discount: _discount
            });
            reflinkSourceRecords[_reflinkRecord.from].push(reflinkRecords.length);
            reflinkRecords.push(_reflinkRecord);
        }
        emit TokenMint(msg.sender, _id, 1, _price, _discount, _referral, _refCode);
    }

    function claim(ClaimData[] calldata _claimDatas) external {
        require(_claimDatas.length > 0, "MallCard: empty claim parameter data");
        uint256 _claimedSilverAmount = 0;
        uint256 _claimedGoldAmount = 0;
        uint256 _claimedDiamondAmount = 0;
        for (uint i = 0; i < _claimDatas.length; i++) {
            ClaimData memory _claimData = _claimDatas[i];
            uint256 _claimRecordIndex = _claimData.claimRecordIndex;
            require(claimRecords[_claimRecordIndex][msg.sender] == false, "MallCard: already claimed");
            claimRecords[_claimRecordIndex][msg.sender] = true;

            require(claimDefinitions[_claimRecordIndex].startTime < block.timestamp, "MallCard: claim not started");
            require(claimDefinitions[_claimRecordIndex].endTime > block.timestamp, "MallCard: claim expired");
            require(!claimDefinitions[_claimRecordIndex].revoked, "MallCard: claim definition revoked");

            uint256 _userExpireDate = _claimData.userExpireDate;
            require(_userExpireDate > block.timestamp, "MallCard: user claim definition expired");

            uint256 _silverAmount = _claimData.silverAmount;
            uint256 _goldAmount = _claimData.goldAmount;
            uint256 _diamondAmount = _claimData.diamondAmount;
            bytes32[] memory _merkleProof = _claimData.merkleProof;

            bytes32 _leaf = keccak256(
                abi.encodePacked(
                    msg.sender,
                    _claimRecordIndex,
                    _silverAmount,
                    _goldAmount,
                    _diamondAmount,
                    _userExpireDate
                )
            );
            require(
                MerkleProof.verify(_merkleProof, claimDefinitions[_claimRecordIndex].merkleRootHash, _leaf),
                "MallCard: invalid claim data or no allocation"
            );
            _claimedSilverAmount += _silverAmount;
            _claimedGoldAmount += _goldAmount;
            _claimedDiamondAmount += _diamondAmount;
        }
        _claimedSilverAmount = _minSupply(SILVER, _claimedSilverAmount);
        _claimedGoldAmount = _minSupply(GOLD, _claimedGoldAmount);
        _claimedDiamondAmount = _minSupply(DIAMOND, _claimedDiamondAmount);

        uint256 _totalClaim = _claimedSilverAmount + _claimedGoldAmount + _claimedDiamondAmount;
        require(
            _totalClaim > 0,
            "Sorry, no valid claim allocation was found for your wallet address. The expiration date may have passed or you may have already claimed all your tokens."
        );
        uint256[] memory _amounts = new uint256[](TOKEN_LEN);
        uint256[] memory _ids = new uint256[](TOKEN_LEN);

        _amounts[0] = _claimedSilverAmount;
        _amounts[1] = _claimedGoldAmount;
        _amounts[2] = _claimedDiamondAmount;

        TokenAmount[] memory _claimed = new TokenAmount[](TOKEN_LEN);
        for (uint256 i = 0; i < TOKEN_LEN; i++) {
            require(tokens[i].maxSupply == 0 || _amounts[i] <= _remainingToken(i), "MallCard: exceeds max supply");
            _ids[i] = i;
            _claimed[i] = TokenAmount({token: i, amount: _amounts[i]});
            tokens[i].totalClaim = tokens[i].totalClaim + _amounts[i];
        }

        _mintBatch(msg.sender, _ids, _amounts, "");

        emit Claim(msg.sender, _claimed);
    }

    // View Functions
    function getClaimRecordCount() public view returns (uint256) {
        return claimDefinitions.length;
    }

    function getTokenInfo(
        uint256 _id
    )
        public
        view
        returns (
            uint256 maxSupply,
            uint256 totalClaim,
            uint256 totalSale,
            uint256[] memory tierSales,
            uint256[] memory limits,
            uint256[] memory prices
        )
    {
        maxSupply = tokens[_id].maxSupply;
        totalClaim = tokens[_id].totalClaim;
        totalSale = tokens[_id].totalSale;
        tierSales = new uint256[](tokens[_id].limits.length);
        limits = new uint256[](tokens[_id].limits.length);
        prices = new uint256[](tokens[_id].limits.length);
        for (uint256 i = 0; i < limits.length; i++) {
            tierSales[i] = tokens[_id].tierSales[i];
            limits[i] = tokens[_id].limits[i];
            prices[i] = tokens[_id].prices[i];
        }
    }

    function getTokenSummary(address _referral) public view returns (TokenSummary[] memory total) {
        total = new TokenSummary[](TOKEN_LEN);
        for (uint256 i = 0; i < TOKEN_LEN; i++) {
            (uint256 _price, uint256 _discount, uint256 _tier) = getCurrentPrice(i, _referral);
            (
                uint256 _maxSupply,
                uint256 _totalClaim,
                uint256 _totalSale,
                uint256[] memory _tierSales,
                uint256[] memory _limits,
                uint256[] memory _prices
            ) = getTokenInfo(i);
            TokenSummary memory _s = TokenSummary({
                token: i,
                currentPrice: _price,
                discount: _discount,
                currentTier: _tier,
                maxSupply: _maxSupply,
                totalClaim: _totalClaim,
                totalSale: _totalSale,
                tierSales: _tierSales,
                limits: _limits,
                prices: _prices
            });

            total[i] = _s;
        }
    }

    function getBalanceInfo(address _address) public view returns (TokenAmount[] memory amounts) {
        amounts = new TokenAmount[](TOKEN_LEN);
        for (uint256 i = 0; i < TOKEN_LEN; i++) {
            amounts[i] = TokenAmount({token: i, amount: balanceOf(_address, i)});
        }
    }

    function uri(uint256 _id) public view virtual override returns (string memory) {
        return tokenURIs[_id];
    }

    function reflinkUsageCount() external view returns (uint256) {
        return reflinkRecords.length;
    }

    function userReflinkRecords(address _referral) external view returns (uint256[] memory) {
        return reflinkSourceRecords[_referral];
    }

    function userReflinkCount(address _referral) external view returns (uint256) {
        return reflinkSourceRecords[_referral].length;
    }

    function getCurrentPrice(
        uint256 _id,
        address _referral
    ) public view returns (uint256 price, uint256 discount, uint256 tier) {
        tier = _currentTier(_id);
        price = tokens[_id].prices[tier];

        // discount can only be appliable for public sale prices
        if (_referral != address(0) && tier == (tokens[_id].limits.length - 1)) {
            discount = _getReflinkDiscount(_referral, price);
        }
    }

    function _minSupply(uint256 _id, uint256 _requested) private view returns (uint256 _min) {
        if (_requested > 0) {
            uint256 _max = tokens[_id].maxSupply > 0 ? _remainingToken(_id) : _requested;
            _min = _requested < _max ? _requested : _max;
        }
    }

    function _remainingToken(uint256 _id) private view returns (uint256 _remaining) {
        if (tokens[_id].maxSupply > 0 && tokens[_id].maxSupply > (tokens[_id].totalClaim + tokens[_id].totalSale)) {
            _remaining = tokens[_id].maxSupply - tokens[_id].totalClaim - tokens[_id].totalSale;
        }
    }

    function _hasTokenSupply(uint256 _id, uint256 _tier) private view returns (bool) {
        require(
            tokens[_id].maxSupply == 0 || _remainingToken(_id) > 0,
            "Sorry, insufficient NFT supply, your transaction cannot be completed"
        );
        require(
            tokens[_id].limits[_tier] == 0 || tokens[_id].limits[_tier] > (tokens[_id].tierSales[_tier]),
            "Sorry, insufficient NFT supply, your transaction cannot be completed"
        );
        return true;
    }

    function _getReflinkDiscount(address _from, uint256 _price) private view returns (uint256) {
        require(_from != msg.sender, "You cannot refer yourself, the transaction has been rejected");
        uint256 _discountRate = 0;
        if (useTicketBasedDiscountRates) {
            for (uint256 r = TOKEN_LEN; r > 0; r--) {
                uint256 _balance = balanceOf(_from, r - 1);
                if (_balance > 0) {
                    _discountRate = discountRates[r - 1];
                    break;
                }
            }
        } else {
            _discountRate = discountRate;
        }

        return (_price * _discountRate) / _feeDenominator();
    }

    function _currentTier(uint256 _id) private view returns (uint256 _tier) {
        _tier = tokens[_id].limits.length - 1;
        for (uint256 i = 0; i < tokens[_id].limits.length; i++) {
            if (tokens[_id].limits[i] == 0 || tokens[_id].tierSales[i] < tokens[_id].limits[i]) {
                _tier = i;
                break;
            }
        }
    }

    function _beforeTokenTransfer(
        address,
        address from,
        address,
        uint256[] memory ids,
        uint256[] memory,
        bytes memory
    ) internal virtual override(ERC1155) {
        if (from != address(0)) {
            require(transferOpenDate > 0, "MallCard: ticket transfer not open!");
            require(transferOpenDate < block.timestamp, "MallCard: ticket transfer not open!");
            for (uint256 i = 0; i < ids.length; i++) {
                require(ids[i] != SILVER, "MallCard: transfer not allowed for SILVER ticket!");
            }
        }
    }

    //Royaltı registry
    function setOperatorFiltering(bool enabled) public onlyOwner {
        _operatorFiltering = enabled;
    }

    function registerOperatorFilter(
        address registry,
        address subscriptionOrRegistrantToCopy,
        bool subscribe
    ) public onlyOwner {
        _registerOperatorFilter(registry, subscriptionOrRegistrantToCopy, subscribe);
    }

    function unregisterOperatorFilter(address registry) public onlyOwner {
        _unregisterOperatorFilter(registry);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override(ERC1155) onlyAllowedOperatorApproval(operator) {
        ERC1155.setApprovalForAll(operator, approved);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override(ERC1155) onlyAllowedOperator(from) {
        ERC1155.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override(ERC1155) onlyAllowedOperator(from) {
        ERC1155.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    //royalty support
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981) returns (bool) {
        return ERC1155.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
    }
}