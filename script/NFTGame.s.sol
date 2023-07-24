//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/NFTGame.sol";

contract deployNFTGame is Script {
    NFTGame game;

    function init() public payable {
        uint64 subscriptionId = 0;
        game = new NFTGame(subscriptionId);
    }

    function execute() public payable {
        game.mintPlayerNFT();
    }
}
