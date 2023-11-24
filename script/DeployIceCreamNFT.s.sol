//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../src/IceCreamNFT.sol";
import "./base/BaseScript.s.sol";

contract DeployIceCreamNFT is BaseScript {
    IceCreamNFT internal nft;

    function run() public payable broadcast {
        nft = new IceCreamNFT(dedicatedMsgSender);
    }

    function execute() public payable broadcast {
        nft.mintSVG();
    }
}
