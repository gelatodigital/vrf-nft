//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin/access/Ownable.sol";
import "chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "./Base64.sol";

contract onChainNFT is ERC721Enumerable, Ownable, VRFConsumerBaseV2 {
    using Strings for uint256;

    bool public paused = false;
    mapping(uint256 => Word) public wordsToTokenId;
    uint256 public stringLimit = 45;

    struct Word {
        string name;
        string description;
        string bgHue;
        string textHue;
        string value;
    }

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

    //string[] public wordValues = ["accomplish", "accepted", "absolutely", "admire", "achievment", "active"];
    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
        ERC721("onChainNFT", "OCN")
    {
        COORDINATOR = VRFCoordinatorV2Interface(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D);
        s_subscriptionId = subscriptionId;
    }

    // Assumes the subscription is funded sufficiently
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

    function mint(string memory _userText) public payable {
        uint256 supply = totalSupply();
        bytes memory strBytes = bytes(_userText);
        require(strBytes.length <= stringLimit, "String input exceeds limit.");
        require(exists(_userText) != true, "String already exists!");

        Word memory newWord = Word(
            string(abi.encodePacked("NFT", uint256(supply + 1).toString())),
            "This is our on-chain NFT",
            randomNum(361, block.difficulty, supply).toString(),
            randomNum(361, block.timestamp, supply).toString(),
            _userText
        );

        if (msg.sender != owner()) {
            require(msg.value >= 0.005 ether);
        }

        wordsToTokenId[supply + 1] = newWord; //Add word to mapping @tokenId
        _safeMint(msg.sender, supply + 1);
    }

    function exists(string memory _text) public view returns (bool) {
        bool result = false;
        //totalSupply function starts at 1, as does out wordToTokenId mapping
        for (uint256 i = 1; i <= totalSupply(); i++) {
            string memory text = wordsToTokenId[i].value;
            if (keccak256(abi.encodePacked(text)) == keccak256(abi.encodePacked(_text))) {
                result = true;
            }
        }
        return result;
    }

    // TODO: Replace random num with chainlink VRF
    function randomNum(uint256 _mod, uint256 _seed, uint256 _salt) public view returns (uint256) {
        uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, _seed, _salt))) % _mod;
        return num;
    }

    function buildImage(uint256 _tokenId) private view returns (string memory) {
        Word memory currentWord = wordsToTokenId[_tokenId];
        string memory random = randomNum(361, 3, 3).toString();
        return Base64.encode(
            bytes(
                abi.encodePacked(
                    '<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg">',
                    '<rect id="svg_11" height="600" width="503" y="0" x="0" fill="hsl(',
                    currentWord.bgHue,
                    ',50%,25%)"/>',
                    '<text font-size="18" y="10%" x="5%" fill="hsl(',
                    random,
                    ',100%,80%)">Some Text</text>',
                    '<text font-size="18" y="15%" x="5%" fill="hsl(',
                    random,
                    ',100%,80%)">Some Text</text>',
                    '<text font-size="18" y="20%" x="5%" fill="hsl(',
                    random,
                    ',100%,80%)">Some Text</text>',
                    '<text font-size="18" y="10%" x="80%" fill="hsl(',
                    random,
                    ',100%,80%)">Token: ',
                    _tokenId.toString(),
                    "</text>",
                    '<text font-size="18" y="50%" x="50%" text-anchor="middle" fill="hsl(',
                    random,
                    ',100%,80%)">',
                    currentWord.value,
                    "</text>",
                    "</svg>"
                )
            )
        );
    }

    function buildMetadata(uint256 _tokenId) private view returns (string memory) {
        Word memory currentWord = wordsToTokenId[_tokenId];
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            currentWord.name,
                            '", "description":"',
                            currentWord.description,
                            '", "image": "',
                            "data:image/svg+xml;base64,",
                            buildImage(_tokenId),
                            '", "attributes": ',
                            "[",
                            '{"trait_type": "TextColor",',
                            '"value":"',
                            currentWord.textHue,
                            '"}',
                            "]",
                            "}"
                        )
                    )
                )
            )
        );
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        return buildMetadata(_tokenId);
    }

    //only owner
    function withdraw() public payable onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success);
    }
}
