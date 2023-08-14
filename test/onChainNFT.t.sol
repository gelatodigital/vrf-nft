// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/IceCreamNFTV2.sol";

contract NFTGameTest is Test {
    NFTGame game;

    function setUp() public {
        uint64 subscriptionId = 0;
        game = new NFTGame(subscriptionId);
    }

    function testMintPlayerNFT() public {
        game.mintPlayerNFT();

        assertEq(game.ownerOf(1), address(this));

        (uint256 attack, uint256 health,, bool isActive) = game.players(address(this));

        assertEq(attack, 100);
        assertEq(health, 100);
        assertTrue(isActive);
    }

    function testRequestRandomWords() public {
        uint256 requestId = game.requestRandomWords();

        (bool fulfilled,,) = game.s_requests(requestId);

        assertFalse(fulfilled);
    }
}
