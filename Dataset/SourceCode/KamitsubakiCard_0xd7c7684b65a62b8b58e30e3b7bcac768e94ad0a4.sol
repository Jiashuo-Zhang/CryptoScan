// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import "paper-key-manager-contract/keyManager/IPaperKeyManager.sol";
import "openzeppelin-contracts/access/AccessControl.sol";
import { IKamitsubakiToken } from "./IKamitsubakiToken.sol";
import "openzeppelin-contracts/utils/Strings.sol";

contract KamitsubakiCard is AccessControl {
    address private constant FUND_ADDRESS = 0xe8b9110CA629e2222D9503718eB9e7B954827A2D;

    bool public publicPhase = false;
    uint256 public publicCost = 0.125 ether;

    bool public mintable = false;

    uint256 public constant MAX_SUPPLY = 5000;
    uint256 private constant PUBLIC_MAX_PER_TX = 5;
    uint256 public presaleCost = 0.125 ether;
    uint256 public minted = 0;
    bool public presalePhase;

    IKamitsubakiToken public kamiToken;
    IPaperKeyManager public paperKeyManager;

    mapping(address => uint256) public whiteLists;

    constructor(address _tokenAddress, address _paperKeyManagerAddress) {
        kamiToken = IKamitsubakiToken(_tokenAddress);
        paperKeyManager = IPaperKeyManager(_paperKeyManagerAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    modifier whenMintable() {
        require(mintable == true, "Mintable: paused");
        _;
    }

    modifier onlyPaper(
        bytes32 _hash,
        bytes32 _nonce,
        bytes calldata _signature
    ) {
        bool success = paperKeyManager.verify(_hash, _nonce, _signature);
        require(success, "Failed to verify signature.");
        _;
    }

    function registerPaperKeyManagerToken(address _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(paperKeyManager.register(_token), "Error registering PaperKeyManager token.");
    }

    function registerKamitsubakiToken(address _token) external onlyRole(DEFAULT_ADMIN_ROLE) {
        kamiToken = IKamitsubakiToken(_token);
    }

    function pushMultiWL(address[] memory list) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < list.length; i++) {
            whiteLists[list[i]]++;
        }
    }

    function _mint(address _to, uint256 _mintAmount, bool _presale) internal {
        for (uint256 i = 1; i <= _mintAmount; i++) {
            kamiToken.mint(_to, 1);
            if (_presale == true) {
                whiteLists[_to]--;
            }
        }

        unchecked {
            minted = minted + _mintAmount;
        }
    }

    function publicMint(
        address _to,
        uint256 _mintAmount,
        bytes32 _nonce,
        bytes calldata _signature
    ) external payable whenMintable onlyPaper(keccak256(abi.encode(_to, _mintAmount)), _nonce, _signature) {
        uint256 cost = publicCost * _mintAmount;
        require(_mintAmount > 0, "Mint amount cannot be zero");
        require(minted + _mintAmount <= MAX_SUPPLY, "MAXSUPPLY over");
        require(msg.value >= cost, "Not enough funds");
        require(publicPhase, "PublicPhase is not Active.");
        require(_mintAmount <= PUBLIC_MAX_PER_TX, "Mint amount over");

        _mint(_to, _mintAmount, false);
    }

    function preMint(address _to, uint256 _mintAmount, bytes32 _nonce, bytes calldata _signature) external payable whenMintable onlyPaper(keccak256(abi.encode(_to, _mintAmount)), _nonce, _signature) {
        uint256 cost = presaleCost * _mintAmount;
        require(_mintAmount > 0, "Mint amount cannot be zero");
        require(minted + _mintAmount <= MAX_SUPPLY, "MAXSUPPLY over");
        require(msg.value >= cost, "Not enough funds");
        require(presalePhase, "PrePhase is not Active.");
        require(whiteLists[_to] >= _mintAmount, "you have no whitelist");

        _mint(_to, _mintAmount, true);
    }

    function checkClaimPre(address _wallet, uint256 quantity) external view returns (string memory) {
        if (mintable == false) {
            return "Sale period is not live.";
        } else if (presalePhase == false) {
            return "Sale period is not live.";
        } else if (quantity <= 0) {
            return "Quantity can not be 0";
        } else if (minted + quantity > MAX_SUPPLY) {
            return "Not enough supply";
        } else if (whiteLists[_wallet] == 0) {
            return "this wallet have no AllowList";
        } else if (whiteLists[_wallet] < quantity) {
            return string(abi.encodePacked("this wallet allowlist can mint ", Strings.toString(whiteLists[_wallet]), ". you can not mint ", Strings.toString(quantity)));
        }
        return "";
    }

    function checkClaimPublic(uint256 quantity) external view returns (string memory) {
        if (mintable == false) {
            return "Sale period is not live.";
        } else if (publicPhase == false) {
            return "Sale period is not live.";
        } else if (quantity <= 0) {
            return "Quantity can not be 0";
        } else if (quantity > PUBLIC_MAX_PER_TX) {
            return "Exceeded max mint amount per transaction.";
        } else if (minted + quantity > MAX_SUPPLY) {
            return "Not enough supply";
        }
        return "";
    }

    function setPresalePhase(bool _state) external onlyRole(DEFAULT_ADMIN_ROLE) {
        presalePhase = _state;
    }

    function setPresaleCost(uint256 _preCost) external onlyRole(DEFAULT_ADMIN_ROLE) {
        presaleCost = _preCost;
    }

    function setPublicCost(uint256 _publicCost) external onlyRole(DEFAULT_ADMIN_ROLE) {
        publicCost = _publicCost;
    }

    function setPublicPhase(bool _state) external onlyRole(DEFAULT_ADMIN_ROLE) {
        publicPhase = _state;
    }

    function setMintable(bool _state) external onlyRole(DEFAULT_ADMIN_ROLE) {
        mintable = _state;
    }

    function withdraw() external onlyRole(DEFAULT_ADMIN_ROLE) {
        payable(FUND_ADDRESS).transfer(address(this).balance);
    }
}