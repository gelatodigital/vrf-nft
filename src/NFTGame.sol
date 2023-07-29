// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFTGame is ERC721Enumerable, VRFConsumerBaseV2, Ownable {
    struct Player {
        uint256 attack;
        uint256 health;
        uint256[3] items;
        bool isActive;
        bool isWinner;
    }

    mapping(address => Player) public players;
    mapping(uint256 => bool) public hasParticipatedInRound;

    uint256 public activeRound;
    uint256 public winnerLB;
    uint256 public winnerUB;

    uint256 constant ROUND_DURATION = 12 hours;
    uint256 constant TOTAL_ROUNDS = 6;
    uint256 constant PLAYER_ATTACK = 100;
    uint256 constant PLAYER_HEALTH = 100;

    uint256 private _tokenIdCounter;

    uint256 public round;
    uint256 public lastRoundTime;

    // VRF Config (GOERLI)
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests;

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to. (GOERLI)
    bytes32 keyHash = 0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 2;

    array = new uint256[](0);

    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
        ERC721("GamePlayer", "GP")
    {
        COORDINATOR = VRFCoordinatorV2Interface(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);
        s_subscriptionId = subscriptionId;
        activeRound = 1;
        winnerLB = 0;
        winnerUB = totalSupply();
    }

    function mintPlayerNFT() public {
        _tokenIdCounter += 1;
        _mint(msg.sender, _tokenIdCounter);
        players[msg.sender] = Player(PLAYER_ATTACK, PLAYER_HEALTH, , true, false);
    }

    function startNextRound() public {
        require(block.timestamp % ROUND_DURATION == 0, "Round not ended yet.");

        activeRound += 1;
        uint256 totalMinted = totalSupply();

        if (activeRound > 1) {
            uint256 randomNum = randomNum(totalMinted, lastRequestId);

            if (randomNum % 2 == 0) {
                winnerUB = winnerLB + ((winnerUB - winnerLB) / 2);
            } else {
                winnerLB = winnerLB + ((winnerUB - winnerLB) / 2);
            }

            for (uint256 i = 1; i <= _tokenIdCounter; i++) {
                address playerAddress = ownerOf(i);
                if (i >= winnerLB && i <= winnerUB) {
                    players[playerAddress].isWinner = true;
                } else {
                    players[playerAddress].isWinner = false;
                    players[playerAddress].isActive = false;
                }
            }
        }
    }

    function isWinner(uint256 tokenId) public view returns (bool) {
        return (tokenId >= winnerLB && tokenId <= winnerUB);
    }

    function requestRandomWords() external onlyOwner returns (uint256 requestId) {
        requestId =
            COORDINATOR.requestRandomWords(keyHash, s_subscriptionId, requestConfirmations, callbackGasLimit, numWords);
        s_requests[requestId] = RequestStatus({randomWords: new uint256[](0), exists: true, fulfilled: false});
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

    function randomNum(uint256 _mod, uint256 _requestId) public view returns (uint256) {
        require(s_requests[_requestId].fulfilled, "request not fulfilled");
        require(s_requests[_requestId].exists, "request not found");
        uint256 num = uint256(keccak256(abi.encodePacked(s_requests[_requestId].randomWords[0], msg.sender))) % _mod;
        return num;
    }
}
