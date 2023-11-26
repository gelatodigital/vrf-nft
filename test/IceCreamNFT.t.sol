// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/IceCreamNFT.sol";

contract TestIceCreamNFT is Test {
    IceCreamNFT nft;
    address operator;
    address owner;
    address nobody;

    event RequestedRandomness(uint256 round, bytes data);

    function setUp() public {
        operator = address(1);
        owner = address(2);
        nobody = address(3);
        vm.prank(owner);
        nft = new IceCreamNFT(operator);
        // Fix timestamp for
        vm.warp(1700819134);
        // Allow test to mint 1 NFT
        vm.prank(owner);
        nft.allowMint(address(this));
    }

    function testRequestRandmoness() public {
        // Expected VRF Request event data
        uint256 requestId = 0;
        uint256 roundId = 2671924;
        bytes memory data = abi.encode(address(this));
        bytes memory dataWithRequest = abi.encode(requestId, data);
        vm.expectEmit(true, true, false, false);
        emit RequestedRandomness(roundId, dataWithRequest);

        nft.mintSVG();
    }

    function testFulfillRandomness() public {
        // Request mint
        nft.mintSVG();

        uint256 randomness = 0x471403f3a8764edd4d39c7748847c07098c05e5a16ed7b083b655dbab9809fae;
        uint256 requestId = 0;
        uint256 roundId = 2671924;
        bytes memory data = abi.encode(address(this));
        bytes memory dataWithRound = abi.encode(roundId, abi.encode(requestId, data));

        // Call fulfillRandomness as operator
        vm.prank(operator);
        nft.fulfillRandomness(randomness, dataWithRound);

        // User got his NFT generated randomly
        assertEq(nft.ownerOf(0), address(this));

        // Random SVG is generated
        assertEq(
            nft.tokenURI(0),
            "data:application/json;base64,eyJuYW1lIjoiU1ZHICMwIiwiZGVzY3JpcHRpb24iOiJBIHJhbmRvbWl6ZWQgU1ZHIGNvbG9yIE5GVCIsImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpSUhabGNuTnBiMjQ5SWpFdU1TSWdlRzFzYm5NNmVHeHBibXM5SW1oMGRIQTZMeTkzZDNjdWR6TXViM0puTHpFNU9Ua3ZlR3hwYm1zaUlIaHRiRzV6T25OMloycHpQU0pvZEhSd09pOHZjM1puYW5NdVpHVjJMM04yWjJweklpQjJhV1YzUW05NFBTSXdJREFnT0RBd0lEZ3dNQ0lnY0hKbGMyVnlkbVZCYzNCbFkzUlNZWFJwYnowaWVFMXBaRmxOYVdRZ2MyeHBZMlVpUGp4a1pXWnpQanh3WVhSMFpYSnVJR2xrUFNKd2NIQnBlR1ZzWVhSbExYQmhkSFJsY200aUlIZHBaSFJvUFNJeU1DSWdhR1ZwWjJoMFBTSXlNQ0lnY0dGMGRHVnlibFZ1YVhSelBTSjFjMlZ5VTNCaFkyVlBibFZ6WlNJZ2NHRjBkR1Z5YmxSeVlXNXpabTl5YlQwaWRISmhibk5zWVhSbEtEQWdNQ2tnYzJOaGJHVW9OREFwSUhKdmRHRjBaU2d3S1NJZ2MyaGhjR1V0Y21WdVpHVnlhVzVuUFNKamNtbHpjRVZrWjJWeklqNDhaeUJtYVd4c1BTSmplV0Z1SWo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTVJaUI1UFNJMklpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpTVRBaUlIazlJallpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTRJaUI1UFNJM0lpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpT1NJZ2VUMGlOeUl2UGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqRXdJaUI1UFNJM0lpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpT0NJZ2VUMGlPQ0l2UGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqa2lJSGs5SWpnaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0k1SWlCNVBTSTVJaTgrUEM5blBqeG5JR1pwYkd3OUltMWhaMlZ1ZEdFaVBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamNpSUhrOUlqY2lMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJMklpQjVQU0k0SWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlOeUlnZVQwaU9DSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpZaUlIazlJamtpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTNJaUI1UFNJNUlpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpT0NJZ2VUMGlPU0l2UGp3dlp6NDhaeUJtYVd4c1BTSmliSFZsSWo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSXhNU0lnZVQwaU55SXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpFeUlpQjVQU0kzSWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlNVEFpSUhrOUlqZ2lMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJeE1TSWdlVDBpT0NJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJakV5SWlCNVBTSTRJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU1UTWlJSGs5SWpnaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0l4TUNJZ2VUMGlPU0l2UGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqRXhJaUI1UFNJNUlpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpTVRJaUlIazlJamtpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSXhNeUlnZVQwaU9TSXZQand2Wno0OFp5Qm1hV3hzUFNKbmNtVmxiaUkrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU5pSWdlVDBpTVRBaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0k0SWlCNVBTSXhNQ0l2UGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqRXdJaUI1UFNJeE1DSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpFeUlpQjVQU0l4TUNJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamNpSUhrOUlqRXhJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU9TSWdlVDBpTVRFaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0l4TVNJZ2VUMGlNVEVpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTRJaUI1UFNJeE1pSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpFd0lpQjVQU0l4TWlJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamtpSUhrOUlqRXpJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU1URWlJSGs5SWpFeklpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpTVRJaUlIazlJakV5SWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlNVEFpSUhrOUlqRTBJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU9TSWdlVDBpTVRVaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0k0SWlCNVBTSXhOQ0l2UGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqRXdJaUI1UFNJeE5pSXZQand2Wno0OFp5Qm1hV3hzUFNKNVpXeHNiM2NpUGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqY2lJSGs5SWpFd0lpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpT1NJZ2VUMGlNVEFpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSXhNU0lnZVQwaU1UQWlMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJeE15SWdlVDBpTVRBaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0k0SWlCNVBTSXhNU0l2UGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqRXdJaUI1UFNJeE1TSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpFeUlpQjVQU0l4TVNJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamNpSUhrOUlqRXlJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU9TSWdlVDBpTVRJaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0l4TVNJZ2VUMGlNVElpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTRJaUI1UFNJeE15SXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpFd0lpQjVQU0l4TXlJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamtpSUhrOUlqRTBJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU1URWlJSGs5SWpFMElpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpTVRBaUlIazlJakUxSWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlPU0lnZVQwaU1UWWlMejQ4TDJjK1BDOXdZWFIwWlhKdVBqd3ZaR1ZtY3o0OGNtVmpkQ0IzYVdSMGFEMGlNVEF3SlNJZ2FHVnBaMmgwUFNJeE1EQWxJaUJtYVd4c1BTSjFjbXdvSTNCd2NHbDRaV3hoZEdVdGNHRjBkR1Z5YmlraUx6NDhMM04yWno0PSJ9"
        );
    }

    function testFulfillRandomnessNonOperator() public {
        uint256 randomness = 0x471403f3a8764edd4d39c7748847c07098c05e5a16ed7b083b655dbab9809fae;
        bytes memory dataWithRound = abi.encode(1);

        // Call fulfillRandomness from non operator
        vm.expectRevert("only operator");
        nft.fulfillRandomness(randomness, dataWithRound);
    }

    function testFulfillRandomnessNotValidRoundId() public {
        // Request mint
        nft.mintSVG();

        uint256 randomness = 0x471403f3a8764edd4d39c7748847c07098c05e5a16ed7b083b655dbab9809fae;
        uint256 requestId = 0;
        uint256 roundId = 42; // Calling with invalid roundId
        bytes memory data = abi.encode(address(this));
        bytes memory dataWithRound = abi.encode(roundId, abi.encode(requestId, data));

        // Call fulfillRandomness as operator
        vm.prank(operator);
        nft.fulfillRandomness(randomness, dataWithRound);

        // Randomness is not fulfilled
        assertEq(nft._tokenIdCounter(), 0);
    }

    function testFulfillRandomnessNotValidData() public {
        // Request mint
        nft.mintSVG();

        uint256 randomness = 0x471403f3a8764edd4d39c7748847c07098c05e5a16ed7b083b655dbab9809fae;
        uint256 requestId = 0;
        uint256 roundId = 2671924;
        bytes memory data = abi.encode(address(operator)); // Calling with modified extraData
        bytes memory dataWithRound = abi.encode(roundId, abi.encode(requestId, data));

        // Call fulfillRandomness as operator
        vm.prank(operator);
        nft.fulfillRandomness(randomness, dataWithRound);

        // Randomness is not fulfilled
        assertEq(nft._tokenIdCounter(), 0);
    }

    function testFulfillRandomnessReplayProtection() public {
        // Request mint
        nft.mintSVG();

        uint256 randomness = 0x471403f3a8764edd4d39c7748847c07098c05e5a16ed7b083b655dbab9809fae;
        uint256 requestId = 0;
        uint256 roundId = 2671924;
        bytes memory data = abi.encode(address(this));
        bytes memory dataWithRound = abi.encode(roundId, abi.encode(requestId, data));

        // Call fulfillRandomness as operator
        vm.prank(operator);
        nft.fulfillRandomness(randomness, dataWithRound);

        // 2nd fulfilment will fail
        vm.prank(operator);
        vm.expectRevert("request fulfilled or missing");
        nft.fulfillRandomness(randomness, dataWithRound);
    }

    function testMintDenied() public {
        vm.prank(nobody);
        vm.expectRevert("mint denied");
        nft.mintSVG();

        // allowance is one, so the second mint should fail
        nft.mintSVG();
        vm.expectRevert("mint denied");
        nft.mintSVG();
    }
}
