// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*                                                                                                      
                                @@@@@@@  @@@@@  .                                                                       
                            @@@@@@@@@* @@@@@  /@@@@@@@@@%                                                               
                          @ @@@      #@@@@&      @@@@@@@@@@@@@@                                                         
                          @@@       @@@@@          /@@@@@@@@@@@@@@@@                                                    
                        *@@       @@@@@           @@@@@@@     @@@@@   @@(                                               
                       @@/      @@@@@*          @@@@@@@             @@@@@@@@                                            
                       @@@                    *@@@@@@%            (@@@@@@@                                              
                      %@@@@                    @@@@@             @@@@@@@%                                               
                   @@@@ @@@@.                                  @@@@@@@@                                                 
                  @@@@@@ /@@@                                 @@@@@@@*                 .@&                              
                 @@@ @@@@@@@%  @                              &@@@@@@@@@              @@@@@@                            
                 @@@@ .@@@@  @@@@@                                @@@@@@@@@(         @@@@@@@@@*                         
                 *@@@@@@      .@@@@@                                  @@@@@@@@@    @@@@@@@%@@@@@&                       
                   @@@@@   @@@@  @@@@@/                                  *@@@@@   @@@@@@@@&  @@@@@%                     
                        @@  @@@@@  @@@@@@                                       @@@@@@@@@@@@@  @@@@                     
                       @@@@@, @@@@@@@@@                                         @@@@@@@  @@@@@@  @                      
                         @@@@@@ @@@@@&                                            /@@@@@@  @@@@   @@@@@                 
                           @@@@@@@@@              (                                  @@@@@@. .   @@@@@@@                
                              @@@@               @@@@@&                                @@@@@@   *@@@ @@@                
                                   @@@@(       @@@@@@   @@@                              &@@  @@ @@@/ @@                
                                    @@@@@@@   @@@@@@   @@@@@@@@@                             &@@@ @@@#@                 
                                       @@@@@@@@@@@         /@@@@@@@@@/                       %@@@  @@                   
                                          .@@@@@@          @@@@@@@@@@@@@  @@#                 @@@@#@                    
                                              /          %@@@@@          @@@@@  @@@@@@@@@@@@@@ @@@@                     
                                                        @@@@@@         @@@@@*  *@@@@@@@@@@@@@   @/                      
                                                       %@@@@          @@@@@        @@@@                                 
                                                                    &@@@@%       (@@@(                                  
                                                                   @@@@@        @@@@                                    
                                                                               @@@@                                                           
*/

import "./TitlesEditionV1.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import {ISplitMain} from "splits-utils/src/interfaces/ISplitMain.sol";

/**
 * @title TITLES Edition Publisher v1
 * @notice A deployer that is used to publish new TITLES Edition contracts
 * @dev A factory that deploys minimal proxies of `TitlesEditionV1.sol`
 */
contract TitlesPublisherV1 is Ownable {
    /// @notice Address of 0xSplits SplitMain contract to use to create new splits
    ISplitMain public immutable splitMain;

    /// @notice Default address used as Splits controller & Publisher admin
    address public controller;

    /// @notice Distributor fee on Splits to promote automated distribution, in BPS (scale 1_000_000)
    uint32 public splitDistributorFee;

    /// @notice Portion of secondary sales distributed as royalties, in BPS (scale 10_000) 
    uint96 public secondaryRoyalty;

    /// @notice Address of implementation of TitlesEditionV1 to clone
    address public immutable titlesEditionImplementation;

    /**
     * @notice Emitted when a remix is successfully published
     * @param creator Address of the publisher
     * @param remixContractAddress  Address of the published remix contract
     * @param creatorProceedRecipient Address of the recipient for primary and secondary royalty proceeds, typically a Split
     * @param derivativeFeeRecipient Address of the recipient of Derivative Fees, typically a Split
     */
    event EditionPublished(
        address indexed creator,
        address remixContractAddress,
        address creatorProceedRecipient,
        address derivativeFeeRecipient
    );

    /**
     * @notice Initializes the deployer with required addresses
     * @param _splitMainAddress Address of 0xSplits SplitMain contract
     * @param _controller Default address used as Splits controller and Publisher admin
     * @param _distributorFee Distributor fee on Splits to promote automated distribution, in BPS (scale 1_000_000)
     * @param _secondaryRoyalty Portion of secondary sales distributed as royalties, in BPS (scale 10_000) 
     * @param _implementation TitlesEditionV1 base implementation address
     */
    constructor(address _splitMainAddress, address _controller, uint32 _distributorFee, uint96 _secondaryRoyalty, address _implementation) {
        splitMain = ISplitMain(_splitMainAddress);
        controller = _controller;
        splitDistributorFee = _distributorFee;
        secondaryRoyalty = _secondaryRoyalty;
        titlesEditionImplementation = _implementation;

        transferOwnership(_controller);
    }

    /**
     * @notice Publishes a new TitlesEditionV1 clone, creating Splits for sample attribution
     * @param _creator Publisher of the remix
     * @param _name Contract name 
     * @param _symbol Contract symbol 
     * @param _uri Metadata URI 
     * @param creatorProceedAccounts Array of address to split proceeds with
     * @param creatorProceedAllocations Array of allocation amounts for proceeds split, in BPS (scale 1_000_000)
     * @param derivativeFeeAccounts Array of addresses to split Derivative Fee with
     * @param derivativeFeeAllocations Array of allocation amounts for Derivative Fee split, in BPS (scale 1_000_000)
     * @param _price Price of the edition in wei 
     * @param _maxSupply Maximum number of editions that can be minted for this contract, unbounded if zero 
     * @param _mintLimitPerWallet Maximum number of editions that can be minted per wallet, unbounded if zero
     * @param _saleEndTime Date that minting closes as a unix timestamp, unbounded if zero
     */
    function publishEdition(
        address _creator,
        string memory _name,
        string memory _symbol, 
        string memory _uri, 
        address[] memory creatorProceedAccounts, 
        uint32[] memory creatorProceedAllocations,
        address[] memory derivativeFeeAccounts, 
        uint32[] memory derivativeFeeAllocations,
        uint256 _price,
        uint256 _maxSupply,
        uint256 _mintLimitPerWallet,
        uint256 _saleEndTime
    ) external {
        // Check split configurations
        require(creatorProceedAccounts.length > 0, "Empty proceeds array");
        require(creatorProceedAccounts.length == creatorProceedAllocations.length, "Mismatched proceeds array lengths");
        require(derivativeFeeAccounts.length > 0, "Empty fee array");
        require(derivativeFeeAccounts.length == derivativeFeeAllocations.length, "Mismatched fee array lengths");

        // Create proceeds split if needed
        address proceedRecipient;
        if (creatorProceedAccounts.length == 1) {
            proceedRecipient = creatorProceedAccounts[0];
        } else {
            address creatorSplit = splitMain.createSplit({
                accounts: creatorProceedAccounts,
                percentAllocations: creatorProceedAllocations,
                distributorFee: splitDistributorFee,
                controller: controller
            });
            proceedRecipient = creatorSplit;
        }

        // Create Derivative Fee split if needed
        address feeRecipient;
        if (derivativeFeeAccounts.length == 1) {
            feeRecipient = derivativeFeeAccounts[0];
        } else {
            address derivativeFeeSplit = splitMain.createSplit({
                accounts: derivativeFeeAccounts,
                percentAllocations: derivativeFeeAllocations,
                distributorFee: splitDistributorFee,
                controller: controller
            });
            feeRecipient = derivativeFeeSplit;
        }
        
        // Publish TitlesEditionV1 clone contract
        address remixClone = Clones.clone(titlesEditionImplementation);
        TitlesEditionV1(payable(remixClone)).initialize(_creator, _name, _symbol, _uri, proceedRecipient, feeRecipient, _price, _maxSupply, _mintLimitPerWallet, _saleEndTime, secondaryRoyalty);

        // Emit Event
        emit EditionPublished({
            creator: msg.sender,
            remixContractAddress: remixClone,
            creatorProceedRecipient: proceedRecipient,
            derivativeFeeRecipient: feeRecipient
        });
    }

    /**
     * @notice Update the distributor fee set for Splits of new Editions
     * @param _distributorFee New fee in BPS
     */
    function setSplitDistributorFee(uint32 _distributorFee) external onlyOwner {
        splitDistributorFee = _distributorFee;
    }

    /**
     * @notice Update the secondary sale royalty percentage for new Editions
     * @param _secondaryRoyalty New secondary royalty, in BPS (scale 10_000)
     */
    function setSecondaryRoyalty(uint96 _secondaryRoyalty) external onlyOwner {
        secondaryRoyalty = _secondaryRoyalty;
    }

    /**
     * @notice Update the controller address set for Splits of new Editions
     * @param _controller New Split controller address
     */
    function setController(address _controller) external onlyOwner {
        controller = _controller;
    }
}