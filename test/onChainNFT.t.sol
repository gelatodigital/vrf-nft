// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./src/onChainNFT.sol";

contract onChainNFT is Test {
    onChainNFT public onChainNFT;

    function setUp() public {
     onChainNFT = new onChainNFT();
     onChainNFT.setNumber(0);
    }

    function testIncrement() public {
     onChainNFT.increment();
        assertEq onChainNFT.number(), 1);
    }

    function testSetNumber(uint256 x) public {
     onChainNFT.setNumber(x);
        assertEq onChainNFT.number(), x);
    }
}
