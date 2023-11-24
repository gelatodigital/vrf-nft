// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./vendor/GelatoVRFConsumerBase.sol";
import "./Base64.sol";

contract IceCreamNFT is ERC721Enumerable, GelatoVRFConsumerBase {
    using Strings for uint256;

    address private immutable _operatorAddr;
    uint256 public _tokenIdCounter;

    // Mapping from token ID to SVG data
    mapping(uint256 => string) private _svgData;

    function _operator() internal view override returns (address) {
        return _operatorAddr;
    }
    constructor(address operator)
        ERC721("IceCreamNFT", "ICE")
    {
        _operatorAddr = operator;
    }

    function _fulfillRandomness(uint256 randomness, uint256, bytes memory extraData) internal override {
        uint256 tokenId = _tokenIdCounter;
        _mint(abi.decode(extraData, (address)), tokenId);
        _tokenIdCounter += 1;

        string memory svg = generateSVG(randomness);
        _svgData[tokenId] = svg;
    }

    function mintSVG() public {
        _requestRandomness(abi.encode(msg.sender));
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
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
                            '"}'
                        )
                    )
                )
            )
        );
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
                '<defs>',
                '<pattern id="pppixelate-pattern" width="20" height="20" patternUnits="userSpaceOnUse" patternTransform="translate(0 0) scale(40) rotate(0)" shape-rendering="crispEdges">',
                '<g fill="', colors[0], '">',
                    '<rect width="1" height="1" x="9" y="6"/>'
                    '<rect width="1" height="1" x="10" y="6"/>'
                    '<rect width="1" height="1" x="8" y="7"/>'
                    '<rect width="1" height="1" x="9" y="7"/>'
                    '<rect width="1" height="1" x="10" y="7"/>'
                    '<rect width="1" height="1" x="8" y="8"/>'
                    '<rect width="1" height="1" x="9" y="8"/>'
                    '<rect width="1" height="1" x="9" y="9"/>'                
                '</g>',
                '<g fill="', colors[1], '">',
                    '<rect width="1" height="1" x="7" y="7"/>'
                    '<rect width="1" height="1" x="6" y="8"/>'
                    '<rect width="1" height="1" x="7" y="8"/>'
                    '<rect width="1" height="1" x="6" y="9"/>'
                    '<rect width="1" height="1" x="7" y="9"/>'
                    '<rect width="1" height="1" x="8" y="9"/>'
                '</g>',
                '<g fill="', colors[2], '">',
                    '<rect width="1" height="1" x="11" y="7"/>'
                    '<rect width="1" height="1" x="12" y="7"/>'
                    '<rect width="1" height="1" x="10" y="8"/>'
                    '<rect width="1" height="1" x="11" y="8"/>'
                    '<rect width="1" height="1" x="12" y="8"/>'
                    '<rect width="1" height="1" x="13" y="8"/>'
                    '<rect width="1" height="1" x="10" y="9"/>'
                    '<rect width="1" height="1" x="11" y="9"/>'
                    '<rect width="1" height="1" x="12" y="9"/>'
                    '<rect width="1" height="1" x="13" y="9"/>'
                '</g>',
                '<g fill="', colors[3], '">',
                    '<rect width="1" height="1" x="6" y="10"/>'
                    '<rect width="1" height="1" x="8" y="10"/>'
                    '<rect width="1" height="1" x="10" y="10"/>'
                    '<rect width="1" height="1" x="12" y="10"/>'
                    '<rect width="1" height="1" x="7" y="11"/>'
                    '<rect width="1" height="1" x="9" y="11"/>'
                    '<rect width="1" height="1" x="11" y="11"/>'
                    '<rect width="1" height="1" x="8" y="12"/>'
                    '<rect width="1" height="1" x="10" y="12"/>'
                    '<rect width="1" height="1" x="9" y="13"/>'
                    '<rect width="1" height="1" x="11" y="13"/>'
                    '<rect width="1" height="1" x="12" y="12"/>'
                    '<rect width="1" height="1" x="10" y="14"/>'
                    '<rect width="1" height="1" x="9" y="15"/>'
                    '<rect width="1" height="1" x="8" y="14"/>'
                    '<rect width="1" height="1" x="10" y="16"/>'
                '</g>',
                '<g fill="', colors[4], '">',
                    '<rect width="1" height="1" x="7" y="10"/>'
                    '<rect width="1" height="1" x="9" y="10"/>'
                    '<rect width="1" height="1" x="11" y="10"/>'
                    '<rect width="1" height="1" x="13" y="10"/>'
                    '<rect width="1" height="1" x="8" y="11"/>'
                    '<rect width="1" height="1" x="10" y="11"/>'
                    '<rect width="1" height="1" x="12" y="11"/>'
                    '<rect width="1" height="1" x="7" y="12"/>'
                    '<rect width="1" height="1" x="9" y="12"/>'
                    '<rect width="1" height="1" x="11" y="12"/>'
                    '<rect width="1" height="1" x="8" y="13"/>'
                    '<rect width="1" height="1" x="10" y="13"/>'
                    '<rect width="1" height="1" x="9" y="14"/>'
                    '<rect width="1" height="1" x="11" y="14"/>'
                    '<rect width="1" height="1" x="10" y="15"/>'
                    '<rect width="1" height="1" x="9" y="16"/>'
                '</g>',
                '</pattern>',
                '</defs>',
                '<rect width="100%" height="100%" fill="url(#pppixelate-pattern)"/>',
                '</svg>'
            )
        );
    }

    function randomColor(uint256 randomness, uint256 offset) private pure returns (string memory) {
        string[10] memory colors = [
            "red",
            "green",
            "blue",
            "yellow",
            "pink",
            "purple",
            "orange",
            "cyan",
            "magenta",
            "black"
        ];
        uint256 index = (uint256(keccak256(abi.encodePacked(randomness, offset))) % 10);
        return colors[index];
    }
}
