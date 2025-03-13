// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./CommonERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "./CryptoHomiesCommon.sol";

contract CryptoHomiesGenesis is PaymentSplitter, Ownable, CommonERC721, EIP712 {
    string private constant SIGNING_DOMAIN = "CryptoHomiesGenesis";
    string private constant SIGNATURE_VERSION = "1";

    bool public teamMinted;
    bool public allowlistOnly = false;
    address validSigner;

    struct Voucher {
        uint16 id;
        address recipient;
        bytes signature;
    }

    mapping(uint16 => bool) redeemedVouchers;

    CryptoHomiesCommon public commonContract;

    constructor(
        string memory _contractURI,
        address _validSigner,
        address[] memory _payees,
        uint256[] memory _shares
    )
        CommonERC721(
            "CryptoHomiesGenesis",
            "CHG",
            1998,
            0.1 ether,
            _contractURI
        )
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION)
        PaymentSplitter(_payees, _shares)
    {
        commonContract = new CryptoHomiesCommon(
            msg.sender,
            "ipfs://QmScp6Bk1VwksWni4nhWESTP8HMoMVMbPDMj4eHGjAbLCv/chc.json"
        );
        validSigner = _validSigner;
    }

    function mintTokensForOwner(
        uint16 _genesisTokens,
        uint16 _commonTokens
    ) public onlyOwner {
        // Mint Genesis tokens for free without platform fee
        for (uint16 i = 0; i < _genesisTokens; i++) {
            _mintWithoutFee(owner());
        }

        // Mint common tokens without checking mint limit
        CryptoHomiesCommon commonContractInstance = CryptoHomiesCommon(
            address(commonContract)
        );
        for (uint16 i = 0; i < _commonTokens; i++) {
            commonContractInstance.mintWithGenesis(owner());
        }
    }

    function _mintWithoutFee(address _recipient) internal {
        uint16 _tokenId = tokenIdCount + 1;
        require(saleActive, "Sale not active");
        require(_tokenId <= MAX_SUPPLY, "No more items left");

        _safeMint(_recipient, _tokenId);
        commonContract.mintWithGenesis(_recipient);

        tokenIdCount = _tokenId;
    }

    function mint(address _buyer, uint16 _desiredTokenAmount) public payable {
        require(!allowlistOnly, "Can only mint through allow list");
        _mintTokens(_buyer, _desiredTokenAmount);
    }

    function _mintTokens(address _buyer, uint16 _desiredTokenAmount) internal {
        require(
            _desiredTokenAmount >= 1 && _desiredTokenAmount <= 10,
            "Invalid token amount"
        );

        require(saleActive, "Sale not active");
        require(
            tokenIdCount + _desiredTokenAmount <= MAX_SUPPLY,
            "Not enough items left"
        );
        require(
            msg.value >= mintRate * _desiredTokenAmount,
            "Not enough ether sent"
        );
        require(!mintedUsers[currentStage][_buyer], "User has already minted");

        // Calculate the platform fee
        uint256 platformFee = (mintRate * _desiredTokenAmount) / 100; // 1% of the mint rate per token

        // Calculate the total amount to be paid by the user
        uint256 totalAmount = mintRate * _desiredTokenAmount + platformFee;

        require(msg.value >= totalAmount, "Insufficient payment");

        // Transfer the platform fee to the specified address
        Address.sendValue(
            payable(0xA2b8E073eA72E4b1b29C0A4E383138ABde571870),
            platformFee
        );

        uint256 refundAmount = msg.value - totalAmount;

        for (uint16 i = 0; i < _desiredTokenAmount; i++) {
            uint16 tokenId = tokenIdCount + i + 1;

            _safeMint(_buyer, tokenId);
            commonContract.mintWithGenesis(_buyer);
            mintedUsers[currentStage][_buyer] = true;
        }

        tokenIdCount += _desiredTokenAmount;

        // Refund any excess amount sent by the user
        if (refundAmount > 0) {
            Address.sendValue(payable(_buyer), refundAmount);
        }
    }

    function setAllowlistOnly(bool _allowlistOnly) public onlyOwner {
        allowlistOnly = _allowlistOnly;
    }

    function setValidSigner(address _validSigner) public onlyOwner {
        validSigner = _validSigner;
    }

    function _hash(Voucher calldata pass) internal view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        keccak256("Voucher(uint16 id,address recipient)"),
                        pass.id,
                        pass.recipient
                    )
                )
            );
    }

    function _verify(Voucher calldata pass) internal view returns (address) {
        bytes32 digest = _hash(pass);
        return ECDSA.recover(digest, pass.signature);
    }

    /**
     * @dev Release the contract's balance to the payees.
     */
    function release() public onlyOwner {
        super.release(payable(address(this)));
    }
}