// SPDX-License-Identifier: MIT
pragma solidity =0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { AbstractDAO } from "./AbstractDAO.sol";

contract WrappedLYX is ERC20, AbstractDAO {
    event Unwrapped(
        address indexed recipient,
        uint256 indexed amount,
        uint256 indexed nonce
    );

    uint256 public _chainID;
    address internal _contractAddress;

    constructor(uint256 thresholdLevel) ERC20("Wrapped LYX", "wLYX") Ownable(msg.sender) {
        _thresholdLevel = thresholdLevel;
        _threshold = thresholdLevel;
        _operator = owner();
        _queueOrder = 1;
        _votesSent = 0;
        _votingInProgress = 0;
        _bps = 6666;
        _requiredVoteThreshold = 2 * _bps;
        _authorizedAddressesCount = 2;
        uint256 id;
        assembly {
            id := chainid()
        }
        _chainID = id;
        _contractAddress = address(this);
    }

    function mint(
        uint256 value,
        uint256 bridgeNonce,
        address recipient,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(_nonces[bridgeNonce] == false, "Nonce already used");
        require(
            ECDSA.recover(
                keccak256(abi.encodePacked(value, recipient, bridgeNonce, _chainID, _contractAddress)),
                v,
                r,
                s
            ) == _operator,
            "Signature verification failure"
        );
        require(_threshold >= value, "Value exceeds current threshold");
        _nonces[bridgeNonce] = true;
        _mint(recipient, value);
        _threshold -= value;
    }

    function burn(uint256 value) external {
        burnFor(msg.sender, value);
    }

    function burnFor(address recipient, uint256 value) public {
        _burn(msg.sender, value);
        emit Unwrapped(recipient, value, _burnNonce++);
    }
}