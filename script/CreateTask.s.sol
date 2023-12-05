//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./vendor/AutomateTaskCreator.s.sol";
import {IGelatoVRFConsumer} from "../src/vendor/IGelatoVRFConsumer.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract CreateTask is AutomateTaskCreator {
    constructor() AutomateTaskCreator(address(0x2A6C106ae13B558BB9E2Ec64Bd2f1f7BEFF3A5E0)) {}

    function run() public payable broadcast {
        address consumerAddress = address(0);
        require(consumerAddress != address(0), "CreateTask.s.sol: Replace consumerAddress");

        ModuleData memory moduleData = ModuleData({modules: new Module[](3), args: new bytes[](3)});
        moduleData.modules[0] = Module.PROXY;
        moduleData.modules[1] = Module.WEB3_FUNCTION;
        moduleData.modules[2] = Module.TRIGGER;

        moduleData.args[0] = _proxyModuleArg();

        string memory web3FunctionHash = "QmWm8Uq2UYRAVwFyzWop2Hghj56WhJk7K8hGGC2Jy7rzDo";
        string memory consumerAddressStr = Strings.toHexString(consumerAddress);
        bytes memory web3FunctionArgsHex = abi.encode(consumerAddressStr);
        moduleData.args[1] = _web3FunctionModuleArg(web3FunctionHash, web3FunctionArgsHex);

        bytes32[][] memory topics = new bytes32[][](1);
        topics[0] = new bytes32[](1);
        topics[0][0] = keccak256("RequestedRandomness(uint256,bytes)");
        uint256 blockConfirmations = block.chainid == 1 ? 1 : 0;
        moduleData.args[2] = _eventTriggerModuleArg(consumerAddress, topics, blockConfirmations);

        bytes32 taskId = _createTask(
            dedicatedMsgSender, abi.encodePacked(IOpsProxyFactory.batchExecuteCall.selector), moduleData, address(0)
        );

        console.log("TaskId: ");
        console.logBytes32(taskId);
    }
}
