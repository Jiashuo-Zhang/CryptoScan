// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import { IERC721A } from "erc721a/contracts/IERC721A.sol";
import { NonblockingLzApp } from "@layerzerolabs/solidity-examples/contracts/lzApp/NonblockingLzApp.sol";

import { IReplicatorController } from "./interfaces/IReplicatorController.sol";
import { ICassette } from "./interfaces/ICassette.sol";

error ReplicatorController_SenderNotAllowed();
error ReplicatorController_InvalidValue();

/**
                        .             :++-
                       *##-          +####*          -##+
                       *####-      :%######%.      -%###*
                       *######:   =##########=   .######*
                       *#######*-#############*-*#######*
                       *################################*
                       *################################*
                       *################################*
                       *################################*
                       *################################*
                       :*******************************+.

                .:.
               *###%*=:
              .##########+-.
              +###############=:
              %##################%+
             =######################
             -######################++++++++++++++++++=-:
              =###########################################*:
               =#############################################.
  +####%#*+=-:. -#############################################:
  %############################################################=
  %##############################################################
  %##############################################################%=----::.
  %#######################################################################%:
  %##########################################+:    :+%#######################:
  *########################################*          *#######################
   -%######################################            %######################
     -%###################################%            #######################
       =###################################-          :#######################
     ....+##################################*.      .+########################
  +###########################################%*++*%##########################
  %#########################################################################*.
  %#######################################################################+
  ########################################################################-
  *#######################################################################-
  .######################################################################%.
     :+#################################################################-
         :=#####################################################:.....
             :--:.:##############################################+
   ::             +###############################################%-
  ####%+-.        %##################################################.
  %#######%*-.   :###################################################%
  %###########%*=*####################################################=
  %####################################################################
  %####################################################################+
  %#####################################################################.
  %#####################################################################%
  %######################################################################-
  .+*********************************************************************.
 * @title Replicator Controller
 * @notice See https://origins.kaijukingz.io/ for more details.
 * @author Augminted Labs, LLC
 */
contract ReplicatorController is NonblockingLzApp, IReplicatorController {
    uint16 public constant FUNCTION_TYPE_REPLICATE = uint16(uint256(keccak256("REPLICATE")));

    ICassette public cassette;
    IERC721A public replicator;
    mapping(uint256 => uint256) public pagesMinted;
    mapping(uint16 => uint256) public dstChainIdToTransferGas;

    event Replicate(
        address indexed receiver,
        uint256 indexed startPage,
        uint256 indexed amount
    );

    constructor(
        address _cassette,
        address _replicator,
        address _lzEndpoint
    )
        NonblockingLzApp(_lzEndpoint)
    {
        cassette = ICassette(_cassette);
        replicator = IERC721A(_replicator);
    }

    /**
     * @notice Modifier validating the replicate transaction
     * @param _replicatorId Replicator used to mint the next pages in the series from
     * @param _amount Amount of next pages in the series to mint
     */
    modifier validateReplicate(uint256 _replicatorId, uint256 _amount) {
        if (
            pagesMinted[_replicatorId] + _amount > cassette.currentMaxPage() ||
            _amount == 0
        ) revert ReplicatorController_InvalidValue();
        _;
    }

    /**
     * @notice Set the address of the replicator contract
     * @param _replicator Address of the replicator contract
     */
    function setReplicator(address _replicator) public payable onlyOwner {
        replicator = IERC721A(_replicator);
    }

    /**
     * @notice Set the address of the cassette contract
     * @param _cassette Address of the cassette contract
     */
    function setCassette(address _cassette) public payable onlyOwner {
        cassette = ICassette(_cassette);
    }

    /*
     * @notice Estimate the cost of performing a specified cross-chain function on a token
     * @param _functionType Cross-chain function to perform
     * @param _dstChainId Destination chain's LayerZero ID
     * @param _toAddress Address to receive the tokens
     * @param _replicatorId Replicator to use to mint
     * @param _amount Amount of pages to mint
     * @param _useZro Flag indicating whether to use $ZRO for payment
     * @param _adapterParams Parameters for custom functionality
     */
    function estimateFee(
        uint16 _functionType,
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint256 _replicatorId,
        uint256 _amount,
        bool _useZro,
        bytes memory _adapterParams
    ) public view override returns (uint256 nativeFee, uint256 zroFee) {
        return estimateBatchFee(
            _functionType,
            _dstChainId,
            _toAddress,
            _toSingletonArray(_replicatorId),
            _toSingletonArray(_amount),
            _useZro,
            _adapterParams
        );
    }

    /*
     * @notice Estimate the cost of performing a specified cross-chain function on a batch of tokens
     * @param _functionType Cross-chain function to perform
     * @param _dstChainId Destination chain's LayerZero ID
     * @param _toAddress Address to receive the tokens
     * @param _replicatorIds Replicators to use to mint
     * @param _amounts Amounts of pages to mint
     * @param _useZro Flag indicating whether to use $ZRO for payment
     * @param _adapterParams Parameters for custom functionality
     */
    function estimateBatchFee(
        uint16 _functionType,
        uint16 _dstChainId,
        bytes memory _toAddress,
        uint256[] memory _tokenIds,
        uint256[] memory _amounts,
        bool _useZro,
        bytes memory _adapterParams
    ) public view override returns (uint256 nativeFee, uint256 zroFee) {
        bytes memory payload = abi.encode(_functionType, _toAddress, _tokenIds, _amounts);
        return lzEndpoint.estimateFees(_dstChainId, address(this), payload, _useZro, _adapterParams);
    }

    /*
     * @notice Ensures enough gas in adapter params to handle batch transfer gas amounts on the dst
     * @param _dstChainId Destination chain's LayerZero ID
     * @param _dstChainIdToTransferGas Per transfer amount of gas required to mint/transfer on the dst
     */
    function setDstChainIdToTransferGas(uint16 _dstChainId, uint256 _dstChainIdToTransferGas) external onlyOwner {
        if(_dstChainIdToTransferGas == 0) revert ReplicatorController_InvalidValue();

        dstChainIdToTransferGas[_dstChainId] = _dstChainIdToTransferGas;
    }

    /**
     * @notice Mint a specified amount of next pages in the series using a replicator
     * @param _replicatorId Replicator to use to mint the next pages in the series
     * @param _amount Amount of next pages in the series to mint
     */
    function replicate(
        uint256 _replicatorId,
        uint256 _amount
    )
        public
        validateReplicate(_replicatorId, _amount)
    {
        address owner = replicator.ownerOf(_replicatorId);

        if (msg.sender != address(replicator) && msg.sender != owner)
            revert ReplicatorController_SenderNotAllowed();

        uint256 nextPage = pagesMinted[_replicatorId] + 1;
        pagesMinted[_replicatorId] += _amount;

        _replicate(owner, nextPage, _amount);
    }

    /**
     * @notice Mint a specified amount of the next pages in the series to a destination chain using a replicator
     * @dev For more details see https://layerzero.gitbook.io/docs/evm-guides/master
     * @param _replicatorId Replicator to use to mint the next pages in the series from
     * @param _amount Amount of next pages in the series to mint
     * @param _dstChainId Destination chain's LayerZero ID
     * @param _toAddress Address to receive the tokens
     * @param _refundAddress Address to send refund to if transaction is cheaper than expected
     * @param _zroPaymentAddress Address of $ZRO token holder that will pay for the transaction
     * @param _adapterParams Parameters for custom functionality
     */
    function replicateFrom(
        uint256 _replicatorId,
        uint256 _amount,
        uint16 _dstChainId,
        bytes memory _toAddress,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes memory _adapterParams
    )
        public
        payable
        validateReplicate(_replicatorId, _amount)
    {
        if (msg.sender != address(replicator) && msg.sender != replicator.ownerOf(_replicatorId))
            revert ReplicatorController_SenderNotAllowed();

        uint256 nextPage = pagesMinted[_replicatorId] + 1;
        pagesMinted[_replicatorId] += _amount;

        bytes memory payload = abi.encode(
            FUNCTION_TYPE_REPLICATE,
            _toAddress,
            _toSingletonArray(nextPage),
            _toSingletonArray(_amount)
        );

        _checkGasLimit(_dstChainId, FUNCTION_TYPE_REPLICATE, _adapterParams, dstChainIdToTransferGas[_dstChainId]);
        _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
    }

    /**
     * @notice Mint a specified amount of the next pages in the series using a replicator
     * @param _receiver Address to receive the pages
     * @param _startPage Starting page to mint from
     * @param _amount Amount of next pages in the series to mint
     */
    function _replicate(address _receiver, uint256 _startPage, uint256 _amount) internal {
        for (uint256 i; i < _amount;) {
            uint256 nextPage = _startPage + i;

            cassette.replicatorMint(_receiver, nextPage, 1);
            emit Replicate(_receiver, nextPage, 1);

            unchecked { ++i; }
        }
    }

    /**
     * @notice Override `NonblockingLzApp` function that processes a payload from a source chain
     * @dev For more details see https://layerzero.gitbook.io/docs/evm-guides/master
     * @param _payload Payload to process
     */
    function _nonblockingLzReceive(
        uint16, // _srcChainId,
        bytes memory, // _srcAddress,
        uint64, // _nonce
        bytes memory _payload
    )
        internal
        override
    {
        (
            uint16 functionType,
            bytes memory toAddressBytes,
            uint256[] memory startPage,
            uint256[] memory amounts
        ) = abi.decode(_payload, (uint16, bytes, uint256[], uint256[]));
        address toAddress;
        assembly {
            toAddress := mload(add(toAddressBytes, 20))
        }

        if (functionType == FUNCTION_TYPE_REPLICATE) {
            _replicate(toAddress, startPage[0], amounts[0]);
        }
    }

    /**
     * @notice Utility function to convert a single uint to a singleton array
     * @param element Element to convert to a singleton array
     */
    function _toSingletonArray(uint element) internal pure returns (uint[] memory) {
        uint[] memory array = new uint[](1);
        array[0] = element;
        return array;
    }
}