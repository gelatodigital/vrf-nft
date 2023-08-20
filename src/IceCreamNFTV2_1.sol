// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./Consumer.sol";
import "./Inbox.sol";
import "./Base64.sol";

contract RandomSVGColorNFT_1 is ERC721Enumerable, GelatoVRFConsumer {
    using Strings for uint256;

    GelatoVRFInbox public inbox;
    address public dedicatedMsgSender;
    uint256 public _tokenIdCounter;

    // Mapping from token ID to SVG data
    mapping(uint256 => string) private _svgData;

    // Mapping from token ID to rarity
    mapping(uint256 => uint256) private _tokenRarities;

    constructor(GelatoVRFInbox _inbox, address _dedicatedMsgSender) ERC721("RandomSVGColorNFT", "RSCNFT") {
        inbox = _inbox;
        dedicatedMsgSender = _dedicatedMsgSender;
    }

    function fullfillRandomness(uint256 randomness, bytes calldata) external {
        require(msg.sender == dedicatedMsgSender, "The sender is not the VRF");

        uint256 tokenId = _tokenIdCounter;
        _mint(msg.sender, tokenId);
        _tokenIdCounter += 1;

        string memory svg = generateSVG(randomness);
        _svgData[tokenId] = svg;

        // Calculate and set the rarity for the token
        _tokenRarities[tokenId] = calculateRarityBasedOnColors(svg);
    }

    function mintSVG() public {
        inbox.requestRandomness(this, "");
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory svg = _svgData[tokenId];
        string memory base64Svg = Base64.encode(bytes(svg));
        string memory imageURI = string(abi.encodePacked("data:image/svg+xml;base64,", base64Svg));

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"SVG #',
                            tokenId.toString(),
                            '","description":"A randomized SVG color NFT","image":"',
                            imageURI,
                            '","rarity":"',
                            _tokenRarities[tokenId].toString(),
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function calculateRarityBasedOnColors(string memory svg) internal pure returns (uint256) {
        uint256 maxRarity = 0;

        string[10] memory colors = [
            "red", // 0
            "green", // 1
            "blue", // 2
            "yellow", // 3
            "pink", // 4
            "purple", // 5
            "orange", // 6
            "cyan", // 7
            "magenta", // 8
            "black" // 9
        ];

        for (uint256 i = 0; i < 10; i++) {
            if (containsString(svg, colors[i])) {
                if (i > maxRarity) {
                    maxRarity = i;
                }
            }
        }

        return maxRarity;
    }

    function containsString(string memory _base, string memory _value) internal pure returns (bool) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        for (uint256 i = 0; i < _baseBytes.length - _valueBytes.length + 1; i++) {
            bool found = true;
            for (uint256 j = 0; j < _valueBytes.length; j++) {
                if (_baseBytes[i + j] != _valueBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                return true;
            }
        }
        return false;
    }

    function generateSVG(uint256 randomness) internal pure returns (string memory) {
        string[5] memory colors = [
            randomColor(randomness, 0),
            randomColor(randomness, 1),
            randomColor(randomness, 2),
            randomColor(randomness, 3),
            randomColor(randomness, 4)
        ];

        return string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:svgjs="http://svgjs.dev/svgjs" viewBox="0 0 800 800" preserveAspectRatio="xMidYMid slice">',
                "<defs>",
                '<pattern id="pppixelate-pattern" width="20" height="20" patternUnits="userSpaceOnUse" patternTransform="translate(0 0) scale(40) rotate(0)" shape-rendering="crispEdges">',
                '<g fill="',
                colors[0],
                '">',
                '<rect width="1" height="1" x="9" y="6"/>' '<rect width="1" height="1" x="10" y="6"/>'
                '<rect width="1" height="1" x="8" y="7"/>' '<rect width="1" height="1" x="9" y="7"/>'
                '<rect width="1" height="1" x="10" y="7"/>' '<rect width="1" height="1" x="8" y="8"/>'
                '<rect width="1" height="1" x="9" y="8"/>' '<rect width="1" height="1" x="9" y="9"/>' "</g>",
                '<g fill="',
                colors[1],
                '">',
                '<rect width="1" height="1" x="7" y="7"/>' '<rect width="1" height="1" x="6" y="8"/>'
                '<rect width="1" height="1" x="7" y="8"/>' '<rect width="1" height="1" x="6" y="9"/>'
                '<rect width="1" height="1" x="7" y="9"/>' '<rect width="1" height="1" x="8" y="9"/>' "</g>",
                '<g fill="',
                colors[2],
                '">',
                '<rect width="1" height="1" x="11" y="7"/>' '<rect width="1" height="1" x="12" y="7"/>'
                '<rect width="1" height="1" x="10" y="8"/>' '<rect width="1" height="1" x="11" y="8"/>'
                '<rect width="1" height="1" x="12" y="8"/>' '<rect width="1" height="1" x="13" y="8"/>'
                '<rect width="1" height="1" x="10" y="9"/>' '<rect width="1" height="1" x="11" y="9"/>'
                '<rect width="1" height="1" x="12" y="9"/>' '<rect width="1" height="1" x="13" y="9"/>' "</g>",
                '<g fill="',
                colors[3],
                '">',
                '<rect width="1" height="1" x="6" y="10"/>' '<rect width="1" height="1" x="8" y="10"/>'
                '<rect width="1" height="1" x="10" y="10"/>' '<rect width="1" height="1" x="12" y="10"/>'
                '<rect width="1" height="1" x="7" y="11"/>' '<rect width="1" height="1" x="9" y="11"/>'
                '<rect width="1" height="1" x="11" y="11"/>' '<rect width="1" height="1" x="8" y="12"/>'
                '<rect width="1" height="1" x="10" y="12"/>' '<rect width="1" height="1" x="9" y="13"/>'
                '<rect width="1" height="1" x="11" y="13"/>' '<rect width="1" height="1" x="12" y="12"/>'
                '<rect width="1" height="1" x="10" y="14"/>' '<rect width="1" height="1" x="9" y="15"/>'
                '<rect width="1" height="1" x="8" y="14"/>' '<rect width="1" height="1" x="10" y="16"/>' "</g>",
                '<g fill="',
                colors[4],
                '">',
                '<rect width="1" height="1" x="7" y="10"/>' '<rect width="1" height="1" x="9" y="10"/>'
                '<rect width="1" height="1" x="11" y="10"/>' '<rect width="1" height="1" x="13" y="10"/>'
                '<rect width="1" height="1" x="8" y="11"/>' '<rect width="1" height="1" x="10" y="11"/>'
                '<rect width="1" height="1" x="12" y="11"/>' '<rect width="1" height="1" x="7" y="12"/>'
                '<rect width="1" height="1" x="9" y="12"/>' '<rect width="1" height="1" x="11" y="12"/>'
                '<rect width="1" height="1" x="8" y="13"/>' '<rect width="1" height="1" x="10" y="13"/>'
                '<rect width="1" height="1" x="9" y="14"/>' '<rect width="1" height="1" x="11" y="14"/>'
                '<rect width="1" height="1" x="10" y="15"/>' '<rect width="1" height="1" x="9" y="16"/>' "</g>",
                "</pattern>",
                "</defs>",
                '<rect width="100%" height="100%" fill="url(#pppixelate-pattern)"/>',
                "</svg>"
            )
        );
    }

    function randomColor(uint256 randomness, uint256 offset) private pure returns (string memory) {
        string[10] memory colors =
            ["red", "green", "blue", "yellow", "pink", "purple", "orange", "cyan", "magenta", "black"];
        uint256 index = (uint256(keccak256(abi.encodePacked(randomness, offset))) % 10);
        return colors[index];
    }
}
