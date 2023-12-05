// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../vendor/Types.sol";

abstract contract BaseScript is Script {
    uint256 private privateKey;
    address internal broadcaster;
    address internal dedicatedMsgSender;

    constructor(address _automate) {
        privateKey = vm.envUint("PRIVATE_KEY");
        broadcaster = vm.rememberKey(privateKey);
        console.log("Broadcaster: ", broadcaster);

        _initDedicatedMsgSender(_automate);
    }

    modifier broadcast() {
        vm.startBroadcast(broadcaster);
        _;
        vm.stopBroadcast();
    }

    function _constructorArgumentCheck() internal view {
        require(block.chainid == 0, "BaseScript.s.sol: Make sure the _automate address used is correct");
        /**
         * https://docs.gelato.network/developer-services/web3-functions/contract-addresses
         * zksync era - 0xF27e0dfD58B423b1e1B90a554001d0561917602F
         * all other networks - 0x2A6C106ae13B558BB9E2Ec64Bd2f1f7BEFF3A5E0
         */
    }

    function _initDedicatedMsgSender(address _automate) private {
        address proxyModuleAddress = IAutomate(_automate).taskModuleAddresses(Module.PROXY);

        address opsProxyFactoryAddress = IProxyModule(proxyModuleAddress).opsProxyFactory();

        (dedicatedMsgSender,) = IOpsProxyFactory(opsProxyFactoryAddress).getProxyOf(broadcaster);
    }
}
