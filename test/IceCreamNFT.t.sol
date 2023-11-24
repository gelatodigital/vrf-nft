// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/IceCreamNFT.sol";

contract TestIceCreamNFT is Test {
    IceCreamNFT nft;

    function setUp() public {
        nft = new IceCreamNFT(0x0000000000000000000000000000000000000000);
    }

    function testRequestRandmoness() public {
        nft.mintSVG();
        // TodDo: check event
        //assertEq(nft.ownerOf(1), address(this));
    }

    function testFulfillRandomness() public {
        uint256 randomness = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
        bytes memory dataWithRound = abi.encode(1);
        // TodDo: call from operator with real round number
        nft.fulfillRandomness(randomness, dataWithRound);
        // TodDo: check NFT generation
        assertEq(nft.ownerOf(1), address(this));

    }
}
