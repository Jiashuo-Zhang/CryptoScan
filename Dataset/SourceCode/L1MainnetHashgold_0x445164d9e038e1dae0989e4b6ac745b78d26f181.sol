pragma solidity 0.7.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "../ICustomGateway.sol";
import "../ICustomToken.sol";
import "../IGatewayRouter.sol";

import "../IArbTokenL1.sol";

contract L1MainnetHashgold is IArbTokenL1, ICustomToken, ERC20, Ownable {
    address private bridge;
    address private router;
    
    bool private shouldRegisterGateway;

    address private l2Address;

    mapping(address => uint256) private _noncecount;
    
    uint256 public immutable _genesisBlockNum;

    event NonceAccepted(address _fromHashMaxxer, bytes32 _nonce, bytes32 _newHash);
    event NonceRejected(address _fromHashMaxxer, bytes32 _nonce, bytes32 _newHash);
    event TargetHashChanged(bytes32 oldTargetHash, bytes32 newTargetHash);

    uint16 private constant _expinc = 8;

    bytes32 private _targetHash = hex"ffffff000000000000000000000000000000000000000000000000000b00b1e5";
    uint256 private _chainid;

    uint256 private _terminalTimestamp;

    uint256 private _noncesAccepted = 0;
    uint256 private constant _incrementPeriodNonces = 10000;
    uint256 private constant _rewardPerNonce = 100 ether;

    bool private bridgeEnabled = true;
    

    constructor(
        address _bridge,
        address _router
    ) public ERC20("Hashgold", "HGOLD") {
        bridge = _bridge;
        router = _router;

        _genesisBlockNum = block.number;

        _terminalTimestamp = block.timestamp + 5 * 365 days;

        // Set chain id
        assembly {
            sstore(_chainid.slot, chainid())
        }
    }

    function getL2Address() public view returns (address) {
        return l2Address;
    }

    function getNonceCount(address a) public view returns (uint256) {
        return _noncecount[a];
    }

    function getNonceCountHash(address a) public view returns (bytes32) {
        return keccak256(abi.encode(_noncecount[a]));
    }

    function getTargetHash() public view returns (bytes32) {
        return _targetHash;
    }

    function genesisBlockNum() public view returns (uint256) {
        return _genesisBlockNum;
    }

    function getTerminalTimestamp() public view returns (uint256) {
        return _terminalTimestamp;
    }

    function getChainId() public returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }

    function getChainIdHash() public returns (bytes32) {
        return keccak256(abi.encode(_chainid));
    }

    function increment_target_hash() private {
        bytes memory tmp = new bytes(32);

        // Load target hash into a temporary bytearray
        assembly {
            mstore(add(tmp, 32), sload(_targetHash.slot))
        }

        // Increment the temporary bytes according to the increment rule
        for (uint8 i = 0; i < 32; i++) {
            if (uint16(uint8(tmp[i])) != 255 && uint16(uint8(tmp[i])) + uint16(_expinc) <= 255) {
                tmp[i] = bytes1( uint8(tmp[i]) + uint8(_expinc) );
                break;
            } else if (uint8(tmp[i]) != 255)  {
                tmp[i] = bytes1( uint8(255) );
                break;
            }
        }

        bytes32 newTargetHash;
        assembly {
            newTargetHash := mload(add(tmp, 32))
        }

        emit TargetHashChanged(_targetHash, newTargetHash);

        // write incremented target hash to the storage
        assembly {
            sstore(_targetHash.slot, mload(add(tmp,32)))
        }

    }

    function hashmaxx(address beneficiary, bytes32 nonce) public {
        require(block.timestamp < _terminalTimestamp, "Hashmaxxing is oooveeeer. It's over.");
        //
        // Computes new hash. includes beneficiary which ensures that a nonce is valid for a single beneficiary address only.
        // Also includes chainid, which ensures that a given nonce is valid on a single chain only. This prevents replay attacks
        // for multi-chain contracts.
        //
        bytes32 _newHash = keccak256(
            abi.encode(
                keccak256(
                    abi.encodePacked(
                        // Ensures that the nonce cannot be reused for the same beneficiary
                        keccak256(abi.encode(_noncecount[beneficiary])), 

                        // Ensures that the nonce cannot be reused on a different chain
                        keccak256(abi.encode(_chainid)),

                        // Ensures that the nonce cannot be reused for a different beneficiary
                        bytes20(uint160(address(beneficiary))),

                        nonce
                    )
                )
            )
        );

        // Increase nonce count even if the nonce is possibly incorrect
        _noncecount[beneficiary]++;
        
        // the new hash must be strictly larger than the target hash
        if (_newHash > _targetHash) {
            emit NonceAccepted(address(msg.sender), nonce, _newHash);
            
            _noncesAccepted = _noncesAccepted + 1;
            
            if ( _noncesAccepted % _incrementPeriodNonces  == 0 ) {
                increment_target_hash();
            }

            _mint(beneficiary, _rewardPerNonce);

        } else {
            emit NonceRejected(address(msg.sender), nonce, _newHash);
        }
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override(ERC20, ICustomToken) returns (bool) {
        return ERC20.transferFrom(sender, recipient, amount);
    }

    function balanceOf(address account)
        public
        view
        override(ERC20, ICustomToken)
        returns (uint256)
    {
        return ERC20.balanceOf(account);
    }

    /// @dev we only set shouldRegisterGateway to true when in `registerTokenOnL2`
    function isArbitrumEnabled() external view override returns (uint8) {
        require(shouldRegisterGateway, "NOT_EXPECTED_CALL");
        return uint8(uint16(0xa4b1));
    }

    function registerTokenOnL2(
        address l2CustomTokenAddress,
        uint256 maxSubmissionCostForCustomBridge,
        uint256 maxSubmissionCostForRouter,
        uint256 maxGasForCustomBridge,
        uint256 maxGasForRouter,
        uint256 gasPriceBid,
        uint256 valueForGateway,
        uint256 valueForRouter,
        address creditBackAddress
    ) public payable override onlyOwner{
        // we temporarily set `shouldRegisterGateway` to true for the callback in registerTokenToL2 to succeed
        bool prev = shouldRegisterGateway;
        shouldRegisterGateway = true;

        ICustomGateway(bridge).registerTokenToL2{ value: valueForGateway }(
            l2CustomTokenAddress,
            maxGasForCustomBridge,
            gasPriceBid,
            maxSubmissionCostForCustomBridge,
            creditBackAddress
        );

        IGatewayRouter(router).setGateway{ value: valueForRouter }(
            bridge,
            maxGasForRouter,
            gasPriceBid,
            maxSubmissionCostForRouter,
            creditBackAddress
        );

        l2Address = l2CustomTokenAddress;

        shouldRegisterGateway = prev;
    }

    /**
     * @notice Security function: if bridge contract gets compromised, we can disable bridgeMint and bridgeBurn until 
     * security issues get resolved
     */
    function disableBridge() public onlyOwner {
        bridgeEnabled = false;
    }

    /**
    * @notice Security function: we can re-enable bridgeMint and bridgeBurn after security issues get resolved
    */
    function enableBridge() public onlyOwner {
        bridgeEnabled = true;
    }

    modifier onlyL1Gateway() {
        require(msg.sender == bridge, "NOT_GATEWAY");
        _;
    }

    modifier onlyWhenBridgeEnabled() {
        require(bridgeEnabled, "Bridge disabled");
        _;
    }

    /**
     * @notice should increase token supply by amount, and should (probably) only be callable by the L1 bridge.
     */
    function bridgeMint(address account, uint256 amount) external override onlyL1Gateway onlyWhenBridgeEnabled {
        _mint(account, amount);
    }

    /**
     * @notice should decrease token supply by amount, and should (probably) only be callable by the L1 bridge.
     */
    function bridgeBurn(address account, uint256 amount) external override onlyL1Gateway onlyWhenBridgeEnabled {
        _burn(account, amount);
    }
}