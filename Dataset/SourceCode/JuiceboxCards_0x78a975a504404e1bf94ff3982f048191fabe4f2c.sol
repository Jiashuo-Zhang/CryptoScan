// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @title Juicebox Cards v1.2
/// @notice Juicebox Cards gives every Juicebox project it's own Open Edition NFT that renders the Juicebox Project's own NFT metadata to every holder's wallet.
/// @author @nnnnicholas

import {IERC1155, ERC1155, IERC165} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IJBDirectory} from "@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBDirectory.sol";
import {IJBTiered721Delegate} from "@jbx-protocol/juice-721-delegate/contracts/interfaces/IJBTiered721Delegate.sol";
import {JBTokens} from "@jbx-protocol/juice-contracts-v3/contracts/libraries/JBTokens.sol";
import {IJBPaymentTerminal} from "@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBPaymentTerminal.sol";
import {Config} from "src/Structs/Config.sol";

/*//////////////////////////////////////////////////////////////
                             CONTRACT 
 //////////////////////////////////////////////////////////////*/

contract JuiceboxCards is ERC1155, Ownable, AccessControl, ReentrancyGuard {
    using Strings for uint256;
    /*//////////////////////////////////////////////////////////////
                             ERRORS 
    //////////////////////////////////////////////////////////////*/

    /// @notice Insufficient funds to mint a Card
    error JBCards_TXValueBelowMintPrice();

    /// @notice Cannot pay the project
    /// @param _projectId The ID of the project that cannot be paid
    error JBCards_ProjectRefusedPayment(uint256 _projectId);

    /// @notice Function access is restricted to the dev minter role
    error JBCards_MsgSenderDoesNotHaveDevMinterRole();

    /// @notice Input arrays must be of equal length
    error JBCards_DevMintArgumentArraysMustBeEqualLength();

    /// @notice The project must have a payment terminal configured on the active JBDirectory
    error JBCards_ProjectMustHaveAnETHPaymentTerminalConfiguredOnTheActiveJBDirectory();

    /*//////////////////////////////////////////////////////////////
                             EVENTS 
    //////////////////////////////////////////////////////////////*/

    /// @dev Emitted when the price of the NFT is set
    event JBCards_PriceSet(uint256 _price);

    /// @dev Emitted when the JBProjects contract address is set
    event JBCards_JBProjectsSet(address indexed _JBProjects);

    /// @dev Emitted when the contract metadata URI is set
    event JBCards_ContractUriSet(string _contractUri);

    /// @dev Emitted when a project is paid with `pay` while minting a Card.
    event JBCards_ProjectPaySucceeded(
        uint256 indexed _projectId,
        uint256 _amountPaid
    );

    /// @dev Emitted when a project is paid with `addToBalance` while minting a Card.
    event JBCards_ProjectAddToBalanceSucceeded(
        uint256 indexed _projectId,
        uint256 _amountPaid
    );

    /// @dev Emitted when a `pay` call fails for a given project
    event JBCards_ProjectPayFailed(uint256 indexed _projectId, uint256 _amount);

    /// @dev Emitted when a `addToBalance` call fails for a given project
    event JBCards_ProjectAddToBalanceFailed(
        uint256 indexed _projectId,
        uint256 _amount
    );

    /// @dev Emitted when the tip project is tipped with `pay` while minting a Card.
    event JBCards_TipPaySucceeded(
        uint256 indexed _projectId,
        uint256 _amountPaid
    );

    /// @dev Emitted when the tip project is tipped with `addToBalance` while minting a Card.
    event JBCards_TipAddToBalanceSucceeded(
        uint256 indexed _projectId,
        uint256 _amountPaid
    );

    /// @dev Emitted when a tip `pay` fails
    event JBCards_TipPayFailed(uint256 indexed _projectId, uint256 _amount);

    /// @dev Emitted when a tip `addToBalance` fails
    event JBCards_TipAddToBalanceFailed(
        uint256 indexed _projectId,
        uint256 _amount
    );

    /// @dev Emitted when the directory address is set
    event JBCards_DirectorySet(address indexed _directory);

    /// @dev Emited when the tip recipient project ID is set
    event JBCards_TipProjectSet(uint256 indexed _tipProject);

    /// @dev Emitted when the tip terminal is set
    event JBCards_TipTerminalSet(address indexed newTerminal);

    /*//////////////////////////////////////////////////////////////
                                 ACCESS
    //////////////////////////////////////////////////////////////*/

    bytes32 public constant DEV_MINTER_ROLE = keccak256("DEV_MINTER_ROLE");

    modifier onlyDevMinter() {
        if (!hasRole(DEV_MINTER_ROLE, msg.sender)) {
            revert JBCards_MsgSenderDoesNotHaveDevMinterRole();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                           STORAGE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @dev The address of the JBProjects contract
    IERC721Metadata public jbProjects;

    /// @dev The address of the JBDirectory contract
    IJBDirectory public directory;

    /// @dev The project that receives tips
    uint256 public tipProject;

    /// @dev The price to buy a Card in wei
    uint256 public price;

    /// @dev The URI of the contract metadata
    string private contractUri;

    /// @dev The tip project's primary eth terminal of the
    IJBPaymentTerminal public ethTipTerminal;

    /*//////////////////////////////////////////////////////////////
                             CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(Config memory _config) ERC1155("") {
        _setupRole(DEV_MINTER_ROLE, msg.sender);
        setJBProjects(_config.jbProjects); // Set the JBProjects contract that is the metadata source
        setDirectory(_config.directory); // Set the JBDirectory contract
        setPrice(_config.price); // Set the Card price
        setContractUri(_config.contractUri); // Set the contract metadata URI
        setTipProject(_config.tipProject); // Set the project that receives tips and the tip terminal
    }

    /*//////////////////////////////////////////////////////////////
                       EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Mints a Card to the beneficiary, pays the project the price, sends any excess msg.value to the tip project, and sends any tip project tokens to the tipBeneficiary.
     * @dev Projects must have a primary ETH terminal on the current JBDirectory, or else mints will revert.
     * @dev Sensible default: pass the msg.sender as both beneficiary and tipBeneficiary.
     * @param projectId The ID of the project to mint a Card for
     * @param beneficiary The address to mint the Card to
     * @param tipBeneficiary The address that receives tokens from the tip project
     */
    function mint(
        uint256 projectId,
        address beneficiary,
        address tipBeneficiary
    ) external payable nonReentrant {
        if (msg.value < price) {
            revert JBCards_TXValueBelowMintPrice();
        }

        // Mint the NFT.
        _mint(beneficiary, projectId, 1, bytes(""));

        // Get the payment terminal the project currently prefers to accept ETH through.
        IJBPaymentTerminal _ethTerminal = directory.primaryTerminalOf(
            projectId,
            JBTokens.ETH
        );

        // If the project doesn't have a payment terminal configured, revert.
        if (_ethTerminal == IJBPaymentTerminal(address(0))) {
            revert JBCards_ProjectMustHaveAnETHPaymentTerminalConfiguredOnTheActiveJBDirectory();
        }

        // Create the metadata for the payment
        bytes memory _payMetadata = abi.encode(
            bytes32(tipProject), // Referral project ID.
            bytes32(0),
            bytes4(0)
        );

        // Pay the project.
        try
            _ethTerminal.pay{value: price}(
                projectId,
                price,
                JBTokens.ETH,
                beneficiary,
                0,
                false,
                "Juicebox Card minted",
                _payMetadata
            )
        {
            emit JBCards_ProjectPaySucceeded(projectId, price); // If pay succeeds, emit success
        } catch {
            // If pay fails, emit failure and try addToBalance
            emit JBCards_ProjectPayFailed(projectId, price);
            try
                _ethTerminal.addToBalanceOf{value: price}(
                    projectId,
                    price,
                    JBTokens.ETH,
                    "Juicebox Card minted",
                    _payMetadata
                )
            {
                emit JBCards_ProjectAddToBalanceSucceeded(projectId, price); // If addToBalance succeeds, emit success
            } catch {
                // If addToBalance fails, emit failure and revert
                emit JBCards_ProjectAddToBalanceFailed(projectId, price);
                revert JBCards_ProjectRefusedPayment(projectId);
            }
        }

        // If the msg.value is greater than the price, pay the tip to the tip project.
        if (msg.value > price) {
            // Pay the tip project.
            uint256 tipAmount = address(this).balance;
            try
                ethTipTerminal.pay{value: tipAmount}(
                    tipProject,
                    tipAmount,
                    JBTokens.ETH,
                    tipBeneficiary,
                    0,
                    false,
                    "Juicebox Card tip",
                    _payMetadata // reuse the same metadata
                )
            {
                // If pay succeeds, emit success
                emit JBCards_TipPaySucceeded(tipProject, tipAmount);
            } catch {
                // If pay fails, emit failure and try addToBalance
                emit JBCards_TipPayFailed(tipProject, tipAmount);
                try
                    ethTipTerminal.addToBalanceOf{value: tipAmount}(
                        tipProject,
                        tipAmount,
                        JBTokens.ETH,
                        "Juicebox Card tip",
                        _payMetadata // reuse the same metadata
                    )
                {
                    // If addToBalance succeeds, emit success
                    emit JBCards_TipAddToBalanceSucceeded(
                        tipProject,
                        tipAmount
                    );
                } catch {
                    // If addToBalanceOf returns an error, leave the ETH in the contract. It will be paid to the tip project with the next successful mint.
                    emit JBCards_TipAddToBalanceFailed(tipProject, tipAmount);
                }
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            PUBLIC FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the tip project's primary ETH terminal
     * @dev Callable by anyone, but only updates the primary terminal based on the configured directory, which is set by the owner.
     */
    function setTipTerminal() public {
        // Get the payment terminal the project currently prefers to accept ETH through.
        ethTipTerminal = directory.primaryTerminalOf(tipProject, JBTokens.ETH);

        emit JBCards_TipTerminalSet(address(ethTipTerminal));
    }

    /**
     * @notice Returns the URI of the NFT
     * @dev Returns the corresponding URI on the JBProjects contract
     * @param projectId The ID of the project to get the NFT URI for
     * @return string The URI of the NFT
     */
    function uri(
        uint256 projectId
    ) public view virtual override returns (string memory) {
        return jbProjects.tokenURI(projectId);
    }

    /**
     * @notice Returns the contract URI
     * @return string The contract URI
     */
    function contractURI() public view returns (string memory) {
        return contractUri;
    }

    /**
     * @notice Returns whether or not the contract supports an interface
     * @param interfaceId The ID of the interface to check
     * @return bool Whether or not the contract supports the interface
     * @inheritdoc IERC165
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            type(AccessControl).interfaceId == interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Sets the Card price
     * @param _price The Card price in wei
     */
    function setPrice(uint64 _price) public onlyOwner {
        price = uint256(_price);
        emit JBCards_PriceSet(_price);
    }

    /**
     * @notice Sets the project that receives tips and updates the tip terminal
     * @param _tipProject The address that receives mint tips
     */
    function setTipProject(uint16 _tipProject) public onlyOwner {
        tipProject = uint256(_tipProject);
        emit JBCards_TipProjectSet(_tipProject);
        setTipTerminal();
    }

    /**
     * @notice Sets the address of the JBProjects contract from which to get the NFT URI
     * @param _JBProjects The address of the JBProjects contract
     */
    function setJBProjects(address _JBProjects) public onlyOwner {
        jbProjects = IERC721Metadata(_JBProjects);
        emit JBCards_JBProjectsSet(_JBProjects);
    }

    /**
     * @notice Sets the address of the JBDirectory contract from which to get the payment terminal
     * @param _directory The address of the JBDirectory contract
     */
    function setDirectory(address _directory) public onlyOwner {
        directory = IJBDirectory(_directory);
        emit JBCards_DirectorySet(_directory);
    }

    /**
     * @notice Sets the contract URI
     * @param _contractUri The URI of the contract metadata
     */
    function setContractUri(string memory _contractUri) public onlyOwner {
        contractUri = _contractUri;
        emit JBCards_ContractUriSet(_contractUri);
    }

    /**
     * @notice Mints multiple NFTs to any addresses without fee
     * @param to The addresses to mint the NFTs to
     * @param projectIds The IDs of the projects to mint the NFTs for
     * @param amounts The amounts of each NFTs to mint
     */
    function devMint(
        address[] calldata to,
        uint256[] calldata projectIds,
        uint256[] calldata amounts
    ) external onlyDevMinter {
        if (
            to.length != projectIds.length ||
            projectIds.length != amounts.length
        ) {
            revert JBCards_DevMintArgumentArraysMustBeEqualLength();
        }
        for (uint256 i = 0; i < to.length; i++) {
            _mint(to[i], projectIds[i], amounts[i], bytes(""));
        }
    }
}