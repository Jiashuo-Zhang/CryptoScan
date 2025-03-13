// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "./lzApp/NonblockingLzApp.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/WETH.sol";

/// @title A LayerZero example sending a cross chain message from a source chain to a destination chain to increment a counter
contract MintDeposit is NonblockingLzApp, ReentrancyGuard {
    using SafeERC20 for IERC20;

    ISwapRouter public immutable swapRouter;
    IERC20 internal immutable WNATIVE;
    IERC20 internal immutable WETH;
    uint16 internal immutable dstChainId;

    bool public publicSaleIsActive;
    bool public whitelistSaleIsActive;
    uint192 public whitelistSalePrice;
    uint256 public publicSalePrice;


    struct SwapParams {
        bytes path;
        address tokenIn;
        uint256 amountIn;
        bool payWithNative;
    }

    constructor(
        address _lzEndpoint,
        IERC20 _WNATIVE,
        IERC20 _WETH,
        ISwapRouter _exchange,
        uint16 _dstChainId,
        uint192 _whitelistSalePrice,
        uint256 _publicSalePrice
    ) NonblockingLzApp(_lzEndpoint) {
        swapRouter = _exchange;
        WNATIVE = _WNATIVE;
        WETH = _WETH;
        dstChainId = _dstChainId;

        whitelistSalePrice = _whitelistSalePrice;
        publicSalePrice = _publicSalePrice;
    }

    // EVENTS
    event PublicSaleStatus(bool _active);
    event WhitelistSaleStatus(bool _active);

    // @notice LayerZero endpoint will invoke this function to deliver the message on the destination
    // @param _srcChainId - the source endpoint identifier
    // @param _srcAddress - the source sending contract address from the source chain
    // @param _nonce - the ordered message nonce
    // @param _payload - the signed payload is the UA bytes has encoded to be sent

    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal override {}

    /*
     *  @title Adjust Settings
     *  @param each NFT price
     *  @param maximum amount of NFTs per wallet
     *  @dev caller must be contract owner
     */
    function adjustSettings(
        uint256 _publicSalePrice,
        uint192 _whitelistSalePrice
    ) external onlyOwner {
        publicSalePrice = _publicSalePrice;
        whitelistSalePrice = _whitelistSalePrice;
    }

    /*
     *  @title Flip sale is active
     *  @dev Caller must be contract owner
     */
    function togglePublicSaleIsActive() external onlyOwner {
        publicSaleIsActive = !publicSaleIsActive;
        emit PublicSaleStatus(publicSaleIsActive);
    }

    /*
     *  @title Flip whitelist sale is active
     *  @dev Caller must be contract owner
     */
    function toggleWhitelistSaleIsActive()
        external
        onlyOwner
    {
        whitelistSaleIsActive = !whitelistSaleIsActive;
        emit WhitelistSaleStatus(whitelistSaleIsActive);
    }

    function crossChainPublicMint(
        uint256 _numberOfTokens,
        bytes memory adapterParams,
        SwapParams memory swapParams,
        uint256 reservedForGas
    ) public payable nonReentrant {
        require(_numberOfTokens > 0, "Incorrect amount");
        require(publicSaleIsActive, "Public Sale Not Active");

        _swapToWETH(publicSalePrice * _numberOfTokens, swapParams, reservedForGas);

        _lzSend(
            dstChainId,
            encodePublicMintPaypoad(_numberOfTokens, msg.sender),
            payable(msg.sender),
            address(0x0),
            adapterParams,
            reservedForGas
        );
    }

    function encodePublicMintPaypoad(
        uint256 _numberOfTokens,
        address _minterAddress
    ) internal pure returns (bytes memory) {
        bool _isWhitelistMint = false;

        return abi.encodePacked(_isWhitelistMint, _numberOfTokens, _minterAddress);
    }

    function crossChainWhitelistMint(
        uint256 _numberOfTokens,
        bytes memory adapterParams,
        SwapParams memory swapParams,
        bytes32[] calldata _merkleProof,
        uint256 reservedForGas
    ) public payable nonReentrant {
        require(_numberOfTokens > 0, "Incorrect amount");
        require(whitelistSaleIsActive, "Whitelist Not Active");

        _swapToWETH(whitelistSalePrice * _numberOfTokens, swapParams, reservedForGas);

        _lzSend(
            dstChainId,
            encodeWhitelistMintPayload(_numberOfTokens, msg.sender, _merkleProof),
            payable(msg.sender),
            address(0x0),
            adapterParams,
            reservedForGas
        );
    }

    function encodeWhitelistMintPayload(
        uint256 _numberOfTokens,
        address _minterAddress,
        bytes32[] calldata _merkleProof
    ) internal pure returns (bytes memory output) {
        bool _isWhitelistMint = true;
        uint256 merkleProofLength = _merkleProof.length;

        output = abi.encodePacked(_isWhitelistMint, _numberOfTokens, _minterAddress, merkleProofLength);

        for (uint256 i = 0; i < merkleProofLength; i++) {
            output = abi.encodePacked(output, _merkleProof[i]);
        }

        return output;
    }

    function _swapToWETH(
        uint256 amountEthForMinting,
        SwapParams memory swapParams,
        uint256 reservedForGas
    ) internal {
        uint256 beforeSwapWETHBalance = WETH.balanceOf(address(this));

        if (swapParams.payWithNative && address(WNATIVE) == address(WETH)) {
            IWETH(address(WNATIVE)).deposit{
                value: msg.value - reservedForGas
            }();
        } else if (
            swapParams.payWithNative && address(WNATIVE) != address(WETH)
        ) {
            IWETH(address(WNATIVE)).deposit{
                value: msg.value - reservedForGas
            }();
            swapTokenForEth(
                swapParams.path,
                swapParams.tokenIn,
                swapParams.amountIn,
                amountEthForMinting
            );
        } else {
            IERC20(swapParams.tokenIn).safeTransferFrom(
                msg.sender,
                address(this),
                swapParams.amountIn
            );
            if (swapParams.tokenIn != address(WETH)) {
                swapTokenForEth(
                    swapParams.path,
                    swapParams.tokenIn,
                    swapParams.amountIn,
                    amountEthForMinting
                );
            }
        }

        require(
            WETH.balanceOf(address(this)) >=
                (beforeSwapWETHBalance + amountEthForMinting),
            "Not Enough"
        );
    }

    function swapTokenForEth(
        bytes memory path,
        address tokenIn,
        uint256 amountIn,
        uint256 amountOutMinimum
    ) internal {
        // The user needs to approve this contract to spend tokens on their behalf
        IERC20(tokenIn).approve(address(swapRouter), type(uint256).max);

        swapRouter.exactInput(
            ISwapRouter.ExactInputParams({
                path: path,
                recipient: address(this),
                deadline: block.timestamp + 15, // 15 seconds from now
                amountIn: amountIn,
                amountOutMinimum: amountOutMinimum
            })
        );
    }

    function withdrawNativeAsset(
        address payable recipient,
        uint256 amount
    ) external onlyOwner {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    function withdrawERC20(
        IERC20 token,
        address recipient,
        uint256 amount
    ) external onlyOwner {
        token.safeTransfer(recipient, amount);
    }
}