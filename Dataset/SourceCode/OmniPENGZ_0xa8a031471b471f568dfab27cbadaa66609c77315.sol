// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import "./onft/ONFT721.sol";

/// @title Interface of the OmniPENGZ standard
contract OmniPENGZ is ONFT721 {

    string private _baseURIExtended;

    /// @notice Constructor for the UniversalONFT
    /// @param _name the name of the token
    /// @param _symbol the token symbol
    /// @param _layerZeroEndpoint handles message transmission across chains
    constructor(string memory _name, string memory _symbol, uint256 _minGasToTransfer, address _layerZeroEndpoint) ONFT721(_name, _symbol, _minGasToTransfer, _layerZeroEndpoint) {
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIExtended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIExtended;
    }

    function totalSupply() public view virtual returns (uint256) {
        return 3333;
    }
}