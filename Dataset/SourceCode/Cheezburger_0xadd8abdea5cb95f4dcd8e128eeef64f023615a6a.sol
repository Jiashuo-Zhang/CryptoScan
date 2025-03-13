// SPDX-License-Identifier: UNLICENSED
//
//           ████████████████████
//         ██                    ██
//       ██    ██          ██      ██
//     ██      ████        ████      ██
//     ██            ████            ██
//     ██                            ██
//   ████████████████████████████████████
//   ██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██
//     ████████████████████████████████
//   ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██
//     ██░░██░░░░██████░░░░░░██░░░░████
//     ████  ████      ██████  ████  ██
//     ██                            ██
//       ████████████████████████████
//
// Cheezburger enables frictionless creation of tokens for a wide
// range of use cases, including DAOs, utility tokens, community projects,
// memecoins, and more. It presents three revolutionary concepts:
//
// - Social Tokens:          Enables permissionless, one-click launches for social profiles.
// - Liquidity-Less Tokens:  Auto-generated liquidity removes the need for initial capital.
// - Factory Model:          Enables free, fast, and gas-efficient deployments with configurable
//                           settings, such as wallet caps, decaying premiums, and highly
//                           customizable tokenomics for fair launches.
//
// Social and Liquidity-Less tokens will be available when the V3 pool is opened.
//
// ATTENTION: The only genuine deployer is chzb.eth.
// Beware of scammers and follow official channels for more information.
//
// Read more on Cheezburger: https://cheezburger.lol
//                           https://documentation.cheezburger.lol
//
pragma solidity ^0.8.22;

import {SafeTransferLib} from "./SafeTransferLib.sol";

import {CheezburgerDeployerKit} from "./CheezburgerDeployerKit.sol";
import {ICheezburgerFactory} from "./ICheezburgerFactory.sol";

contract Cheezburger is CheezburgerDeployerKit {
    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       CUSTOM ERRORS                        */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    error TransferToZeroAddress(address from, address to);
    error TransferToToken(address to);
    error CannotReceiveEtherDirectly();
    error EmptyAddressNotAllowed();
    error SupplyAllocationExceeded();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                           EVENTS                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    event GlobalSettingsChanged();
    event SettingsChanged();
    event PairingAmountsChanged();

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                          STORAGE                           */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    uint256 internal constant LIQUIDITY_FEE_WITHDRAWAL_ROLE = _ROLE_1;
    uint256 internal constant CREATION_FEE_WITHDRAWAL_ROLE = _ROLE_2;
    uint256 internal constant PAIRING_AMOUNT_SETTER_ROLE = _ROLE_3;
    uint256 internal constant SETTINGS_SETTER_ROLE = _ROLE_4;

    string private _name;
    string private _symbol;

    constructor(
        TokenCustomization memory _customization,
        address _factory,
        address _router
    ) {
        if (_factory == address(0) || _router == address(0)) {
            revert EmptyAddressNotAllowed();
        }

        _name = _customization.name;
        _symbol = _customization.symbol;
        _website = _customization.website;
        _social = _customization.social;

        _initializeOwner(msg.sender);
        _mint(msg.sender, _customization.supply * (10 ** decimals()));
        changeSettings(
            SocialSettings({
                pairingAmount: 0,
                leftSideSupply: 1_000_000, // 1 million supply for each social token
                openFeeWei: 0, // Zero fee at launch
                poolCreatorFeePercentage: 4, // 4% of the fees to pool creator at launch
                walletSettings: DynamicSettings({
                    duration: 14 days, // Max wallet duration 2 weeks for each Social token
                    percentStart: 300, // 3% starting wallet cap
                    percentEnd: 4900 // 49% ending wallet cap
                }),
                feeSettings: DynamicSettings({
                    duration: 1 days, // 1 day EAP duration for each Social token
                    percentStart: 500, // 5% starting fee
                    percentEnd: 200 // 2% ending fee
                })
            }),
            TokenSettings({pairingAmount: 0, openFeeWei: 0})
        );
        changeGlobalSettings(
            GlobalSettings({
                factory: ICheezburgerFactory(_factory),
                router: _router
            })
        );
        // Keep it disabled until launch
        // changePairingAmounts(totalSupply() / 33, totalSupply() / 33); // 3% mint for social and regular token launches
    }

    /// @dev Prevents direct Ether transfers to contract
    receive() external payable {
        revert CannotReceiveEtherDirectly();
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                       ERC20 METADATA                       */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function website() public view returns (string memory) {
        return _website;
    }

    function social() public view returns (string memory) {
        return _social;
    }

    /// @dev Returns the amount of tokens in existence minus liquidity pools burned tokens.
    /// The total supply with liquidity pools can be calculated with totalSupply() + outOfCirculationTokens.
    function totalSupply() public view override returns (uint256) {
        unchecked {
            return super.totalSupply() - outOfCirculationTokens;
        }
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                  PUBLIC UPDATE FUNCTIONS                   */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    /// @dev Burns `amount` tokens from the caller.
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /// @dev Burns `amount` tokens from `account`, deducting from the caller's allowance.
    function burnFrom(address account, uint256 amount) external {
        _spendAllowance(account, msg.sender, amount);
        _burn(account, amount);
    }

    /// @dev Allows to withdraw creation liquidity fees to a customized contract
    function withdrawFeesOf(
        uint256 _userId,
        address _to
    ) external onlyRoles(LIQUIDITY_FEE_WITHDRAWAL_ROLE) returns (uint256) {
        return _withdrawFeesOf(_userId, _to);
    }

    /// @dev Allows to withdraw creation fees to a customized contract
    function withdrawCreationFees()
        external
        onlyRoles(CREATION_FEE_WITHDRAWAL_ROLE)
    {
        return SafeTransferLib.forceSafeTransferAllETH(msg.sender);
    }

    /// @dev Allow to change global settings by the owner only
    function changeGlobalSettings(
        GlobalSettings memory _globalSettings
    ) public onlyOwner {
        globalSettings = _globalSettings;
        emit GlobalSettingsChanged();
    }

    /// @dev Allow to change settings by the owner only or an authorized address
    function changeSettings(
        SocialSettings memory _socialSettings,
        TokenSettings memory _tokenSettings
    ) public onlyOwnerOrRoles(SETTINGS_SETTER_ROLE) {
        // Pairing amounts cannot be changed here
        socialSettings.leftSideSupply = _socialSettings.leftSideSupply;
        socialSettings.openFeeWei = _socialSettings.openFeeWei;
        socialSettings.poolCreatorFeePercentage = _socialSettings
            .poolCreatorFeePercentage;
        socialSettings.walletSettings = _socialSettings.walletSettings;
        socialSettings.feeSettings = _socialSettings.feeSettings;
        tokenSettings.openFeeWei = _tokenSettings.openFeeWei;
        emit SettingsChanged();
    }

    /// @dev Allow to change pairing amounts for token and social settings by the owner only or an authorized address
    function changePairingAmounts(
        uint256 _socialPairingAmount,
        uint256 _tokenPairingAmount
    ) public onlyOwnerOrRoles(PAIRING_AMOUNT_SETTER_ROLE) {
        uint256 maxSupplyPerCreation = totalSupply() / 25; // Capped to 4% of the supply
        if (
            _socialPairingAmount > maxSupplyPerCreation ||
            _tokenPairingAmount > maxSupplyPerCreation
        ) {
            revert SupplyAllocationExceeded();
        }
        socialSettings.pairingAmount = _socialPairingAmount;
        tokenSettings.pairingAmount = _tokenPairingAmount;
        emit PairingAmountsChanged();
    }

    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/
    /*                     INTERNAL FUNCTIONS                     */
    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);

        // Don't allow token transfers to the contract
        if (from != address(0) && to == address(this)) {
            revert TransferToToken(to);
        }
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._afterTokenTransfer(from, to, amount);

        // Must use burn() to burn tokens
        if (to == address(0) && balanceOf(address(0)) > 0) {
            revert TransferToZeroAddress(from, to);
        }
    }
}