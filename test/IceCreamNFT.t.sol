// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/IceCreamNFT.sol";

contract TestIceCreamNFT is Test {
    IceCreamNFT nft;
    address operator;

    event RequestedRandomness(uint256 indexed round, bytes data);

    function setUp() public {
        operator = address(1);
        nft = new IceCreamNFT(operator);
        // Fix timestamp for
        vm.warp(1700819134);
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
            "data:application/json;base64,eyJuYW1lIjoiU1ZHICMwIiwiZGVzY3JpcHRpb24iOiJBIHJhbmRvbWl6ZWQgU1ZHIGNvbG9yIE5GVCIsImltYWdlIjoiZGF0YTppbWFnZS9zdmcreG1sO2Jhc2U2NCxQSE4yWnlCNGJXeHVjejBpYUhSMGNEb3ZMM2QzZHk1M015NXZjbWN2TWpBd01DOXpkbWNpSUhabGNuTnBiMjQ5SWpFdU1TSWdlRzFzYm5NNmVHeHBibXM5SW1oMGRIQTZMeTkzZDNjdWR6TXViM0puTHpFNU9Ua3ZlR3hwYm1zaUlIaHRiRzV6T25OMloycHpQU0pvZEhSd09pOHZjM1puYW5NdVpHVjJMM04yWjJweklpQjJhV1YzUW05NFBTSXdJREFnT0RBd0lEZ3dNQ0lnY0hKbGMyVnlkbVZCYzNCbFkzUlNZWFJwYnowaWVFMXBaRmxOYVdRZ2MyeHBZMlVpUGp4a1pXWnpQanh3WVhSMFpYSnVJR2xrUFNKd2NIQnBlR1ZzWVhSbExYQmhkSFJsY200aUlIZHBaSFJvUFNJeU1DSWdhR1ZwWjJoMFBTSXlNQ0lnY0dGMGRHVnlibFZ1YVhSelBTSjFjMlZ5VTNCaFkyVlBibFZ6WlNJZ2NHRjBkR1Z5YmxSeVlXNXpabTl5YlQwaWRISmhibk5zWVhSbEtEQWdNQ2tnYzJOaGJHVW9OREFwSUhKdmRHRjBaU2d3S1NJZ2MyaGhjR1V0Y21WdVpHVnlhVzVuUFNKamNtbHpjRVZrWjJWeklqNDhaeUJtYVd4c1BTSndkWEp3YkdVaVBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamtpSUhrOUlqWWlMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJeE1DSWdlVDBpTmlJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamdpSUhrOUlqY2lMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJNUlpQjVQU0kzSWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlNVEFpSUhrOUlqY2lMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJNElpQjVQU0k0SWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlPU0lnZVQwaU9DSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpraUlIazlJamtpTHo0OEwyYytQR2NnWm1sc2JEMGljSFZ5Y0d4bElqNDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0kzSWlCNVBTSTNJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU5pSWdlVDBpT0NJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamNpSUhrOUlqZ2lMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJMklpQjVQU0k1SWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlOeUlnZVQwaU9TSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpnaUlIazlJamtpTHo0OEwyYytQR2NnWm1sc2JEMGlZM2xoYmlJK1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlNVEVpSUhrOUlqY2lMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJeE1pSWdlVDBpTnlJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJakV3SWlCNVBTSTRJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU1URWlJSGs5SWpnaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0l4TWlJZ2VUMGlPQ0l2UGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqRXpJaUI1UFNJNElpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpTVRBaUlIazlJamtpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSXhNU0lnZVQwaU9TSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpFeUlpQjVQU0k1SWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlNVE1pSUhrOUlqa2lMejQ4TDJjK1BHY2dabWxzYkQwaWIzSmhibWRsSWo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTJJaUI1UFNJeE1DSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpnaUlIazlJakV3SWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlNVEFpSUhrOUlqRXdJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU1USWlJSGs5SWpFd0lpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpTnlJZ2VUMGlNVEVpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTVJaUI1UFNJeE1TSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpFeElpQjVQU0l4TVNJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamdpSUhrOUlqRXlJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU1UQWlJSGs5SWpFeUlpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpT1NJZ2VUMGlNVE1pTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSXhNU0lnZVQwaU1UTWlMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJeE1pSWdlVDBpTVRJaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0l4TUNJZ2VUMGlNVFFpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTVJaUI1UFNJeE5TSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpnaUlIazlJakUwSWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlNVEFpSUhrOUlqRTJJaTgrUEM5blBqeG5JR1pwYkd3OUlubGxiR3h2ZHlJK1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlOeUlnZVQwaU1UQWlMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJNUlpQjVQU0l4TUNJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJakV4SWlCNVBTSXhNQ0l2UGp4eVpXTjBJSGRwWkhSb1BTSXhJaUJvWldsbmFIUTlJakVpSUhnOUlqRXpJaUI1UFNJeE1DSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpnaUlIazlJakV4SWk4K1BISmxZM1FnZDJsa2RHZzlJakVpSUdobGFXZG9kRDBpTVNJZ2VEMGlNVEFpSUhrOUlqRXhJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU1USWlJSGs5SWpFeElpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpTnlJZ2VUMGlNVElpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSTVJaUI1UFNJeE1pSXZQanh5WldOMElIZHBaSFJvUFNJeElpQm9aV2xuYUhROUlqRWlJSGc5SWpFeElpQjVQU0l4TWlJdlBqeHlaV04wSUhkcFpIUm9QU0l4SWlCb1pXbG5hSFE5SWpFaUlIZzlJamdpSUhrOUlqRXpJaTgrUEhKbFkzUWdkMmxrZEdnOUlqRWlJR2hsYVdkb2REMGlNU0lnZUQwaU1UQWlJSGs5SWpFeklpOCtQSEpsWTNRZ2QybGtkR2c5SWpFaUlHaGxhV2RvZEQwaU1TSWdlRDBpT1NJZ2VUMGlNVFFpTHo0OGNtVmpkQ0IzYVdSMGFEMGlNU0lnYUdWcFoyaDBQU0l4SWlCNFBTSXhNU0lnZVQwaU1UUWlMejQ4Y21WamRDQjNhV1IwYUQwaU1TSWdhR1ZwWjJoMFBTSXhJaUI0UFNJeE1DSWdlVDBpTVRVaUx6NDhjbVZqZENCM2FXUjBhRDBpTVNJZ2FHVnBaMmgwUFNJeElpQjRQU0k1SWlCNVBTSXhOaUl2UGp3dlp6NDhMM0JoZEhSbGNtNCtQQzlrWldaelBqeHlaV04wSUhkcFpIUm9QU0l4TURBbElpQm9aV2xuYUhROUlqRXdNQ1VpSUdacGJHdzlJblZ5YkNnamNIQndhWGhsYkdGMFpTMXdZWFIwWlhKdUtTSXZQand2YzNablBnPT0ifQ=="
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
}
