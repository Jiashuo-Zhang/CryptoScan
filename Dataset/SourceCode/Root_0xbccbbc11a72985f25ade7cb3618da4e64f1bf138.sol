/*
    Copyright 2020 Zero Collateral Devs, standing on the shoulders of the Empty Set Squad <[email protected]>. Fixed & Forced by arct1c_team.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "@openzeppelin/upgrades/contracts/upgradeability/UpgradeabilityProxy.sol";

contract Root is UpgradeabilityProxy {
    constructor(address implementation)
        public
        UpgradeabilityProxy(
            implementation,
            abi.encodeWithSignature("initialize()")
        )
    {}
}