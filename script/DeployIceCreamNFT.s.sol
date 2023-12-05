//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/IceCreamNFT.sol";
import "./base/BaseScript.s.sol";

contract DeployIceCreamNFT is BaseScript {
    IceCreamNFT internal nft;

    constructor() BaseScript(address(0x2A6C106ae13B558BB9E2Ec64Bd2f1f7BEFF3A5E0)) {}

    function run() public payable broadcast {
        nft = new IceCreamNFT(dedicatedMsgSender);
    }

    function execute() public payable broadcast {
        nft.mintSVG();
    }
}
