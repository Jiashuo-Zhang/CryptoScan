pragma solidity 0.7.6;

import "@openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol";

contract xU3LPStableProxy is TransparentUpgradeableProxy {
    constructor(address _logic, address _proxyAdmin)
        TransparentUpgradeableProxy(_logic, _proxyAdmin, "")
    {}
}