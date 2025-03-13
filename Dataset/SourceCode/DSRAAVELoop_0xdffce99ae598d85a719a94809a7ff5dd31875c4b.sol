// SPDX-License-Identifier: BSL-1.1
// Business Source License 1.1

// License text copyright (c) 2017 MariaDB Corporation Ab, All Rights Reserved.
// "Business Source License" is a trademark of MariaDB Corporation Ab.

// -----------------------------------------------------------------------------

// Parameters

// Licensor:             TheRealHedgeLord

// Licensed Work:        dsr-aave-loop
//                       The Licensed Work is (c) 2023 TheRealHedgeLord

// Additional Use Grant: You may make production use of the licensed Work in a
//                       non commercial setting


// Change Date:          2027-09-14


// Change License:       GNU General Public License v2.0 or later

// -----------------------------------------------------------------------------

// Terms

// The Licensor hereby grants you the right to copy, modify, create derivative
// works, redistribute, and make non-production use of the Licensed Work. The
// Licensor may make an Additional Use Grant, above, permitting limited
// production use.

// Effective on the Change Date, or the fourth anniversary of the first publicly
// available distribution of a specific version of the Licensed Work under this
// License, whichever comes first, the Licensor hereby grants you rights under
// the terms of the Change License, and the rights granted in the paragraph
// above terminate.

// If your use of the Licensed Work does not comply with the requirements
// currently in effect as described in this License, you must purchase a
// commercial license from the Licensor, its affiliated entities, or authorized
// resellers, or you must refrain from using the Licensed Work.

// All copies of the original and modified Licensed Work, and derivative works
// of the Licensed Work, are subject to this License. This License applies
// separately for each version of the Licensed Work and the Change Date may vary
// for each version of the Licensed Work released by Licensor.

// You must conspicuously display this License on each original or modified copy
// of the Licensed Work. If you receive the Licensed Work in original or
// modified form from a third party, the terms and conditions set forth in this
// License apply to your use of that work.

// Any use of the Licensed Work in violation of this License will automatically
// terminate your rights under this License for the current and all other
// versions of the Licensed Work.

// This License does not grant you any right in any trademark or logo of
// Licensor or its affiliates (provided that you may use a trademark or logo of
// Licensor as expressly required by this License).

// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE LICENSED WORK IS PROVIDED ON
// AN "AS IS" BASIS. LICENSOR HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS,
// EXPRESS OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND
// TITLE.

// MariaDB hereby grants you permission to use this License’s text to license
// your works, and to refer to it using the trademark "Business Source License",
// as long as you comply with the Covenants of Licensor below.

// -----------------------------------------------------------------------------

// Covenants of Licensor

// In consideration of the right to use this License’s text and the "Business
// Source License" name and trademark, Licensor covenants to MariaDB, and to all
// other recipients of the licensed work to be provided by Licensor:

// 1. To specify as the Change License the GPL Version 2.0 or any later version,
//    or a license that is compatible with GPL Version 2.0 or a later version,
//    where "compatible" means that software provided under the Change License can
//    be included in a program with software provided under GPL Version 2.0 or a
//    later version. Licensor may specify additional Change Licenses without
//    limitation.

// 2. To either: (a) specify an additional grant of rights to use that does not
//    impose any additional restriction on the right granted in this License, as
//    the Additional Use Grant; or (b) insert the text "None".

// 3. To specify a Change Date.

// 4. Not to modify this License in any other way.

// -----------------------------------------------------------------------------

// Notice

// The Business Source License (this document, or the "License") is not an Open
// Source license. However, the Licensed Work will eventually be made available
// under an Open Source License, as stated in this License.
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC3156FlashBorrower.sol";
import "./IERC3156FlashLender.sol";
import "./IsDAI.sol";
import "./IDssPsm.sol";
import "./IAavePool.sol";
import "./governance.sol";

contract DSRAAVELoop is IERC3156FlashBorrower, Governance {
    enum Action {OPEN, CLOSE}

    address public immutable DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public immutable SDAI = 0x83F20F44975D03b1b09e64809B757c47f942BEeA;
    address public immutable USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public immutable DSS_FLASH = 0x60744434d6339a6B27d73d9Eda62b6F66a0a04FA;
    address public immutable DSS_PSM = 0x89B78CfA322F6C5dE0aBcEecab66Aee45393cC5A;
    address public immutable DSS_PSM_EXEC = 0x0A59649758aa4d66E25f08Dd01271e891fe52199;
    address public immutable AAVE_POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address public immutable SDAI_A_TOKEN = 0x4C612E3B15b96Ff9A6faED838F8d07d479a8dD4c;
    address public immutable USDC_VARIABLE_DEBT_TOKEN = 0x72E95b8931767C79bA4EeE721354d6E99a61D004;
    uint256 public immutable DAI_USDC_FACTOR = 1000000000000;

    function _openPosition(
        uint256 positionAmount,
        uint256 flashLoanAmount,
        address sender
    ) internal {
        IsDAI(SDAI).transferFrom(sender, address(this), positionAmount);
        IERC20(DAI).approve(SDAI, flashLoanAmount);
        uint256 mintedAmount = IsDAI(SDAI).deposit(flashLoanAmount, address(this));
        uint256 feeAmount = (positionAmount/10000)*getFee(sender);
        uint256 collateralAmount = positionAmount+mintedAmount-feeAmount;
        uint256 debtAmount = flashLoanAmount/DAI_USDC_FACTOR;
        IERC20(SDAI).approve(AAVE_POOL, collateralAmount);
        IAavePool(AAVE_POOL).supply(SDAI, collateralAmount, sender, 0);
        IAavePool(AAVE_POOL).borrow(USDC, debtAmount, 2, 0, sender);
        IERC20(USDC).approve(DSS_PSM_EXEC, debtAmount);
        IDssPsm(DSS_PSM).sellGem(address(this), debtAmount);
    }

    function _closePosition(
        uint256 withdrawAmount,
        uint256 flashLoanAmount,
        address sender
    ) internal {
        IERC20(DAI).approve(DSS_PSM, flashLoanAmount);
        uint256 repayAmount = flashLoanAmount/DAI_USDC_FACTOR;
        IDssPsm(DSS_PSM).buyGem(address(this), repayAmount);
        IERC20(USDC).approve(AAVE_POOL, repayAmount);
        IAavePool(AAVE_POOL).repay(USDC, repayAmount, 2, sender);
        IERC20(SDAI_A_TOKEN).transferFrom(sender, address(this), withdrawAmount);
        IERC20(SDAI_A_TOKEN).approve(AAVE_POOL, withdrawAmount);
        IAavePool(AAVE_POOL).withdraw(SDAI, withdrawAmount, address(this));
        uint256 burntAmount = IsDAI(SDAI).withdraw(flashLoanAmount, address(this), address(this));
        uint256 returnAmount = withdrawAmount-burntAmount;
        uint256 feeAmount = (returnAmount/10000)*getFee(sender);
        IERC20(SDAI).transfer(sender, returnAmount-feeAmount);
    }

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) {
        require(
            msg.sender == DSS_FLASH,
            "FlashBorrower: Untrusted lender"
        );
        require(
            initiator == address(this),
            "FlashBorrower: Untrusted loan initiator"
        );
        require(
            IERC20(token).balanceOf(address(this)) >= amount,
            "CustomBorrower: Loan not recieved"
        );
        require(
            fee == 0,
            "CustomBorrower: Non zero fee"
        );
        require(
            token == DAI,
            "CustomBorrower: Incorrect dai address"
        );
        (Action action, uint256 userAmount, address sender) = abi.decode(data, (Action, uint256, address));
        if (action == Action.OPEN) {
            _openPosition(userAmount, amount, sender);
        } else if (action == Action.CLOSE) {
            _closePosition(userAmount, amount, sender);
        }
        IERC20(DAI).approve(DSS_FLASH, amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    function openPosition(
        uint256 positionAmount,
        uint256 flashLoanAmount,
        uint256 maxFee
    ) public whitelistedOnly {
        require(
            getFee(msg.sender) <= maxFee,
            "DSRAAVELoop: Max fee exceeded"
        );
        bytes memory data = abi.encode(Action.OPEN, positionAmount, msg.sender);
        IERC3156FlashLender(DSS_FLASH).flashLoan(this, DAI, flashLoanAmount, data);
    }

    function closePosition(
        uint256 withdrawAmount,
        uint256 repayAmount,
        uint256 maxFee
    ) public whitelistedOnly {
        require(
            getFee(msg.sender) <= maxFee,
            "DSRAAVELoop: Max fee exceeded"
        );
        uint256 flashLoanAmount;
        if (withdrawAmount == 0) {
            withdrawAmount = IERC20(SDAI_A_TOKEN).balanceOf(msg.sender);
        }
        if (repayAmount == 0) {
            flashLoanAmount = IERC20(USDC_VARIABLE_DEBT_TOKEN).balanceOf(msg.sender)*DAI_USDC_FACTOR;
        } else {
            flashLoanAmount = repayAmount*DAI_USDC_FACTOR;
        }
        bytes memory data = abi.encode(Action.CLOSE, withdrawAmount, msg.sender);
        IERC3156FlashLender(DSS_FLASH).flashLoan(this, DAI, flashLoanAmount, data);
    }
}