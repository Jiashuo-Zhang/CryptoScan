// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import "erc721a/contracts/ERC721A.sol";
import '@openzeppelin/contracts/token/common/ERC2981.sol';
import "./interfaces/IMutariuumNFT.sol";

contract MutariuumLand is ERC721A, Ownable, AccessControl, ERC2981, IMutariuumNFT {

    bytes32 private constant MINTER_ROLE = keccak256('MINTER_ROLE');

    uint256 private _royaltyAmount = 750;
    address private _royaltyRecipient;
    address private _stakingContract;
    string private __baseURI = "https://api.land.mutariuum.com/metadata/";

    uint256 private _supply = 333;

    constructor(address minter, address staking) ERC721A("MU Land", "MUL") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, minter);
        _royaltyRecipient = address(this);
        _stakingContract = staking;
    }

    function mint(
        uint256 value,
        uint256 quantity,
        uint256 blockNumber,
        bytes calldata signature
    ) public payable {
        _verifyMintSignature(value, quantity, blockNumber, signature);
        if (_totalMinted() + quantity > _supply) {
            revert SoldOut();
        }

        _mint(msg.sender, quantity);
    }

    function refund(
        uint256 startTokenId,
        uint256 quantity,
        uint256 blockNumber,
        uint256 value,
        bytes calldata signature
    ) public payable {
        _verifyRefundSignature(startTokenId, quantity, blockNumber, value, signature);

        require(balance() >= value, 'Insufficient contract balance');

        uint256 max = startTokenId + quantity;

        for (uint256 i = startTokenId; i < max; i++) {
            if (msg.sender != ownerOf(i)) {
                revert TransferFromIncorrectOwner();
            }
            _burn(i);
        }

        (bool success, ) = msg.sender.call{ value: value }("");
        if (!success) {
            revert PaymentFailed();
        }
        emit Refund(msg.sender, startTokenId, quantity);
    }

    event Received(address, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(AccessControl, ERC721A, ERC2981)
    returns (bool)
    {
        return AccessControl.supportsInterface(interfaceId) ||
            ERC721A.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }

    function withdraw(uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 bal = balance();
        if(bal < amount) {
            revert InsufficientBalance();
        }
        (bool success, ) = msg.sender.call{value:bal}("");
        if (!success) {
            revert PaymentFailed();
        }
    }

    function setBaseURI(string memory uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        __baseURI = uri;
    }

    function setRoyalties(address recipient, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _royaltyAmount = amount;
        _royaltyRecipient = recipient;
    }

    function setStakingContract(address staking) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _stakingContract = staking;
    }

    function setSupply(uint256 supply) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _supply = supply;
    }

    function balance() private view returns (uint256) {
        return (address(this)).balance;
    }

    function contractURI() external view returns (string memory) {
        return string(abi.encodePacked(__baseURI, 'contract.json'));
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return string(abi.encodePacked(baseURI, _toString(tokenId), '.json'));
    }

    function getMintCount(address minter) external view onlyRole(MINTER_ROLE) returns (uint256) {
        return _numberMinted(minter);
    }

    function getBurnCount(address minter) external view onlyRole(MINTER_ROLE) returns (uint256) {
        return _numberBurned(minter);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }

    function royaltyInfo(
        uint256,
        uint256 salePrice
    ) public view override returns (address receiver, uint256 royaltyAmount) {
        return (_royaltyRecipient, (salePrice * _royaltyAmount) / 10000);
    }

    function _verifyRefundSignature(
        uint256 startTokenId,
        uint256 quantity,
        uint256 blockNumber,
        uint256 value,
        bytes calldata signature
    ) internal view {
        address signer = _getSigner(
            keccak256(
                abi.encodePacked(
                    msg.sender, _numberBurned(msg.sender), value, startTokenId, quantity, blockNumber
                )
            ), signature
        );
        if (!hasRole(MINTER_ROLE, signer)) {
            revert InvalidSignature();
        }
        if (block.number > blockNumber + 10) {
            revert Timeout();
        }
        uint256 max = startTokenId + quantity;
        for (uint256 i = startTokenId; i < max; i++) {
            if (ownerOf(i) != msg.sender) {
            }
        }
    }

    function _verifyMintSignature(
        uint256 value,
        uint256 quantity,
        uint256 blockNumber,
        bytes calldata signature
    ) internal view {
        address signer = _getSigner(
            keccak256(
                abi.encodePacked(
                    msg.sender, _numberMinted(msg.sender), value, quantity, blockNumber
                )
            ), signature
        );
        if (!hasRole(MINTER_ROLE, signer)) {
            revert InvalidSignature();
        }
        if (value != msg.value) {
            revert WrongAmount();
        }
        if (block.number > blockNumber + 10) {
            revert Timeout();
        }
    }

    function _getSigner(bytes32 message, bytes calldata signature) internal pure returns(address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                message
            )
        );
        return ECDSA.recover(hash, signature);
    }

    function _startTokenId() internal pure override(ERC721A) returns (uint256) {
        return 1;
    }

    function isApprovedForAll(address owner, address operator) public view virtual override(ERC721A) returns (bool) {
        if (operator == _stakingContract) {
            return true;
        }
        return super.isApprovedForAll(owner, operator);
    }
}