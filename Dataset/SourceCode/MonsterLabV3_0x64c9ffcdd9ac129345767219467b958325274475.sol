// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/cryptography/ECDSA.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './MonsterNFT.sol';
import './MonsterStorageV2.sol';

interface IUniswapV2Router02 {
    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
}

contract MonsterLabV3 is Pausable, Ownable {
    MonsterNFT public nftContract;
    MonsterStorageV2 public storageContract;

    IUniswapV2Router02 private uniswapRouter;
    mapping(address => address[]) public tokens;

    address public M2;

    uint256 public monsterFee;
    /// @dev centralized public key (MUST be the public key of the private key used to sign)
    address signer;
    /// @dev wallet address to automatically transfer funds to
    address escrow;

    event MonsterCreated(
        uint256 indexed nftID,
        uint256 attributes,
        uint256 background,
        uint256 donationUSD,
        uint256 donationToken,
        string tokenName
    );
    //event MonsterUpdated(uint256 indexed nftID, uint256 attributes, uint256 background);
    event FundsTransferred(address to, uint256 balance);

    using ECDSA for bytes32; // for signature
    error NotOwnerNftError(uint256 id);
    error InvalidHashError(); // somedata in signature is not correct
    error MonsterExistsError(uint256 value);
    error InvalidDataError(); // <= signer is not expected signer
    error InsufficientTotalAmount(uint256 received, uint256 expected);
    error InsufficientFeeAmount(uint256 received, uint256 expected);

    constructor() {
        uniswapRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    }

    function init(
        address[] memory _path1,
        address[] memory _path2,
        MonsterNFT _nft,
        MonsterStorageV2 _storageContract,
        address _m2Address,
        address _signer,
        address _escrow
    ) external onlyOwner {
        tokens[_path1[_path1.length - 1]] = _path1;
        tokens[_path2[_path2.length - 1]] = _path2;
        nftContract = _nft;
        storageContract = _storageContract;
        M2 = _m2Address;
        signer = _signer;
        escrow = _escrow;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    function setEscrow(address _address) external onlyOwner {
        escrow = _address;
    }

    function setMonsterFee(uint256 _newFee) external onlyOwner {
        monsterFee = _newFee; // Change the fee
    }

    function storeMonsterEth(
        uint256 _nftId,
        uint256 _packedValue, // sets background to zero to validate unique attributes
        uint256 _packed2,
        bytes32 _digestedCode,
        uint256 _donationUSD,
        uint256 _cost,
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint256 _backgound
    ) external payable whenNotPaused {
        if (!verifyData(_digestedCode, _nftId, _packedValue, _packed2, _cost, _v, _r, _s)) revert InvalidDataError();
        if (storageContract.getMonster(_packedValue) != 0) revert MonsterExistsError(_packedValue);

        if (msg.value < _cost + monsterFee) revert InsufficientTotalAmount(msg.value, _cost + monsterFee);
        payable(escrow).transfer(msg.value);

        storageContract.addMonster(_packedValue, _nftId);
        storageContract.addMonsterMisc(_nftId, _packed2);

        emit MonsterCreated(_nftId, _packedValue, _backgound, _donationUSD, _cost, 'ETH');
    }

    function storeMonsterM2(
        uint256 _nftId,
        uint256 _packedValue,
        uint256 _packed2,
        bytes32 _digestedCode,
        uint256 _donationUSD,
        uint256 _cost, //In M2
        uint8 _v,
        bytes32 _r,
        bytes32 _s,
        uint256 _backgound
    ) external payable whenNotPaused {
        if (!verifyData(_digestedCode, _nftId, _packedValue, _packed2, _cost, _v, _r, _s)) revert InvalidDataError();
        if (storageContract.getMonster(_packedValue) != 0) revert MonsterExistsError(_packedValue);

        IERC20 token = IERC20(M2);

        if (token.balanceOf(msg.sender) < _cost) revert InsufficientTotalAmount(token.balanceOf(msg.sender), _cost);
        token.transferFrom(msg.sender, escrow, _cost); // send amount to escrow address
        if (msg.value < monsterFee && monsterFee == 0) {
            revert InsufficientFeeAmount(msg.value, monsterFee);
        } else {
            payable(escrow).transfer(monsterFee);
        }

        storageContract.addMonster(_packedValue, _nftId);
        storageContract.addMonsterMisc(_nftId, _packed2);

        emit MonsterCreated(_nftId, _packedValue, _backgound, _donationUSD, _cost, 'M2');
    }

    function verifyData(
        bytes32 _digestedCode,
        uint256 _monsterId,
        uint256 _attributes,
        uint256 _packed2,
        uint256 _cost,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view returns (bool) {
        bytes32 prefix = '\x19Ethereum Signed Message:\n32';
        bytes32 message = keccak256(abi.encodePacked(msg.sender, _monsterId, _attributes, _cost, _packed2));
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, message));

        if (prefixedHashMessage != _digestedCode) revert InvalidHashError();

        bytes32 messageHash = prefixedHashMessage.toEthSignedMessageHash();
        address _signer = ecrecover(messageHash, _v, _r, _s);

        if (nftContract.ownerOf(_monsterId) != msg.sender) revert NotOwnerNftError(_monsterId);

        if (signer == _signer) {
            return true;
        }

        return false;
    }

    function setTokenPaths(address[] memory path) external onlyOwner {
        tokens[path[path.length - 1]] = path;
    }

    function convertUsdToToken(uint256 usdAmount, address token) public view returns (uint256) {
        uint256[] memory amounts = uniswapRouter.getAmountsOut(usdAmount * 10 ** 18, tokens[token]);
        return amounts[amounts.length - 1];
    }

    function transferFundsTo(address payable _to) external onlyOwner {
        require(_to != address(0), '!address');
        uint256 balance = address(this).balance;

        require(balance > 0, '!funds');

        (bool success, ) = _to.call{value: balance}('');
        require(success, '!transfer');

        emit FundsTransferred(_to, balance);
    }

    function getUserNfts(address _user) public view returns (uint256[] memory) {
        uint256[] memory _data = new uint256[](nftContract.balanceOf(_user));
        for (uint256 i = 0; i < nftContract.balanceOf(_user); i++) {
            _data[i] = nftContract.tokenOfOwnerByIndex(_user, i);
        }
        return _data;
    }
}