// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./src/IceCreamNFT.sol";

contract IceCreamNFT is Test {
    IceCreamNFT public IceCreamNFT;

    function setUp() public {
     IceCreamNFT = new IceCreamNFT();
     IceCreamNFT.setNumber(0);
    }

    function testIncrement() public {
     IceCreamNFT.increment();
        assertEq IceCreamNFT.number(), 1);
    }

    function testSetNumber(uint256 x) public {
     IceCreamNFT.setNumber(x);
        assertEq IceCreamNFT.number(), x);
    }
}
