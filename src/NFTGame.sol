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
    }

    mapping(address => Player) public players;
    uint256 public activeRound;
    uint256 public totalFightsInitiated;
    uint256 constant FIGHTS_PER_DAY = 2;
    uint256 constant ROUND_DURATION = 1 days;
    uint256 constant TOTAL_ROUNDS = 10;
    uint256 constant PLAYER_ATTACK = 100;
    uint256 constant PLAYER_HEALTH = 100;

    uint256 private _tokenIdCounter;

    // VRF Config (GOERLI)
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }

    mapping(address => bool) public hasInitiatedFight;

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

    event FightResult(address player, uint256 damage);

    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
        ERC721("GamePlayer", "GP")
    {
        COORDINATOR = VRFCoordinatorV2Interface(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);
        s_subscriptionId = subscriptionId;
        activeRound = 1;
    }

    function initiateFight() public {
        Player storage player = players[msg.sender];
        require(player.health > 0, "Your player is eliminated.");
        require(player.isActive == true, "Player not active for this round.");
        require(hasInitiatedFight[msg.sender] == false, "Player has already initiated a fight this round.");

        totalFightsInitiated += 1;

        uint256 randomMultiplier = randomNum(361, lastRequestId) % 3 + 1; // get a random number between 1-3

        uint256 enemyHealth = 100; // Assume enemy has 100 health

        while (player.health > 0 && enemyHealth > 0) {
            enemyHealth -= player.attack * randomMultiplier;
            if (enemyHealth <= 0) break;
            player.health -= 50 * randomMultiplier; // Assume enemy deals 50 damage per turn
        }

        if (player.health <= 0) player.isActive = false; // Player loses, mark as inactive
        totalFightsInitiated += 1;
        hasInitiatedFight[msg.sender] = true; // Mark that the player has initiated a fight this round

        // Emit the event for each fight
        emit FightResult(msg.sender, player.attack * randomMultiplier);
    }

    function endRound() public {
        require(block.timestamp % ROUND_DURATION == 0, "Round not ended yet.");
        require(totalFightsInitiated >= FIGHTS_PER_DAY, "Not enough fights initiated today.");

        activeRound += 1;

        totalFightsInitiated = 0;
        for (uint256 i = 1; i <= _tokenIdCounter; i++) {
            address playerAddress = ownerOf(i);
            hasInitiatedFight[playerAddress] = false;
        }

        if (activeRound > TOTAL_ROUNDS) {
            distributePrizes();
            return;
        }

        // Reset totalFightsInitiated for the new round
        totalFightsInitiated = 0;
    }

    function distributePrizes() private {
        // Logic for distributing prizes to remaining players
    }

    function mintPlayerNFT() public {
        _tokenIdCounter += 1;
        _mint(msg.sender, _tokenIdCounter);

        // Initialize player stats
        players[msg.sender] = Player(PLAYER_ATTACK, PLAYER_HEALTH, [0, 0, 0], true);
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
