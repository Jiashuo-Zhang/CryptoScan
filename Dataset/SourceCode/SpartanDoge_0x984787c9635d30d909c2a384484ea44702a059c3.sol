// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @custom:security-contact https://www.projectlambo.io/contact-us

contract SpartanDoge is ERC1155, Ownable {
    uint16 mintedAmount;
    uint256 public deploymentTimestamp;
    uint256 public lockDuration = 11 days;
    uint public MAX_NFTS = 5000;

    constructor() ERC1155("https://api.projectlambo.com/metadata/") {
        deploymentTimestamp = block.timestamp;
    }

    modifier isTransferAllowed() {
        require(
            block.timestamp >= deploymentTimestamp + lockDuration,
            "Transfers are locked till 12th August, 2023"
        );
        _;
    }

    function mint(
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) external onlyOwner {
        require(
            _tokenId > 10000 && _tokenId <= 15000,
            "Token ID expected between 10K and 15K"
        );
        require(
            mintedAmount + 1 <= MAX_NFTS, // Max NFTs per collection is 5K
            "Amount expected up to 5K"
        );

        _mint(_to, _tokenId, 1, _data);
        mintedAmount += 1;
    }

    function mintBatch(
        address _to,
        uint256[] calldata _tokenIds,
        uint256[] calldata _supply,
        bytes memory _data
    ) external onlyOwner {
        require(_tokenIds.length == _supply.length, "Input lengths mismatch");
        require(
            mintedAmount + _tokenIds.length <= MAX_NFTS,
            "Amount expected up to 5K"
        );
        _mintBatch(_to, _tokenIds, _supply, _data);
    }

    function uri(
        uint256 _tokenId
    ) public pure override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "https://api.projectlambo.com/metadata/",
                    Strings.toString(_tokenId)
                )
            );
    }

    /** Override safeTransferFrom function of ERC1155 to restrict sale until release date i.e 15th august, 2023 */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount,
        bytes memory _data
    ) public override isTransferAllowed {
        super.safeTransferFrom(_from, _to, _id, _amount, _data);
    }

    /** Override safeBatchTransferFrom function of ERC1155 to restrict sale until release date i.e 15th august, 2023 */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _id,
        uint256[] memory _amount,
        bytes memory _data
    ) public override isTransferAllowed {
        super.safeBatchTransferFrom(_from, _to, _id, _amount, _data);
    }
}