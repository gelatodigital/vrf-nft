//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/IceCreamNFT.sol";

contract DeployIceCreamNFT is Script {
    IceCreamNFT nft;

    function init() public payable {
        // ToDo: get dynamic msg.sender address
        nft = new IceCreamNFT(0x0000000000000000000000000000000000000000);
    }

    function execute() public payable {
        nft.mintSVG();
    }
}
