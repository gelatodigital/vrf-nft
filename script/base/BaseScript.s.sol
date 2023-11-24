// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";

interface IOpsProxyFactory {
    /**
     * @return address Proxy address owned by account.
     * @return bool Whether if proxy is deployed
     */
    function getProxyOf(address account) external view returns (address, bool);
}

abstract contract BaseScript is Script {
    uint256 private privateKey;
    address internal broadcaster;
    address internal dedicatedMsgSender;

    constructor() {
        privateKey = vm.envUint("PRIVATE_KEY");
        broadcaster = vm.rememberKey(privateKey);
        console.log("Broadcaster: ", broadcaster);

        _initDedicatedMsgSender();
    }

    modifier broadcast() {
        vm.startBroadcast(broadcaster);
        _;
        vm.stopBroadcast();
    }

    function _initDedicatedMsgSender() private {
        address opsProxyFactoryAddress = block.chainid == 324
            ? address(0xB675ce934431e42Fd3daE03e3a385b7e24ae7257)
            : block.chainid == 43114
                ? address(0x2807B4aE232b624023f87d0e237A3B1bf200Fd99)
                : address(0x44bde1bccdD06119262f1fE441FBe7341EaaC185);

        (dedicatedMsgSender,) = IOpsProxyFactory(opsProxyFactoryAddress).getProxyOf(broadcaster);
    }
}
