// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/IceCreamNFT.sol";

contract TestIceCreamNFT is Test {
    IceCreamNFT nft;
    address operator;

    function setUp() public {
        operator = address(1);
        nft = new IceCreamNFT(operator);
    }

    function testRequestRandmoness() public {
        vm.expectEmit(address(nft));
        nft.mintSVG();
    }

    function testFulfillRandomness() public {
        // Request mint
        nft.mintSVG();

        uint256 randomness = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
        uint256 requestId = 1;
        uint256 roundId = 1;
        bytes memory dataWithRound = abi.encode(roundId, abi.encode(requestId,address(this)));

        // Call fulfillRandomness as operator
        vm.prank(operator);
        nft.fulfillRandomness(randomness, dataWithRound);

        // User got his NFT generated randomly
        assertEq(nft.ownerOf(1), address(this));
    }

    function testFulfillRandomnessNonOperator() public {
        uint256 randomness = 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef;
        bytes memory dataWithRound = abi.encode(1);

        // Call fulfillRandomness from non operator
        vm.expectRevert("only operator");
        nft.fulfillRandomness(randomness, dataWithRound);
    }

    function testFulfillRandomnessNotValidRequest() public {
        uint256 randomness = 1;
        uint256 requestId = 42;
        uint256 roundId = 1;
        bytes memory dataWithRound = abi.encode(roundId, abi.encode(requestId,address(this)));

        // Call fulfillRandomness as operator
        vm.prank(operator);
        vm.expectRevert("request fulfilled or missing");
        nft.fulfillRandomness(randomness, dataWithRound);
    }

}
