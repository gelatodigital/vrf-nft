// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {ERC721, ERC721Enumerable} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import "./Base64.sol";

// solhint-disable
contract IceCreamNFT is ERC721Enumerable, Ownable, Pausable {
    uint256 public immutable threshold;

    mapping(uint256 => uint256) public licks;
    mapping(uint256 => uint256) public lickTime;
    mapping(address => bool) public hasClaimed;

    constructor(uint256 threshold_) ERC721("Ice Cream NFT", "LICK") {
        threshold = threshold_;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function mint() external {
        require(!hasClaimed[msg.sender], "already claimed");
        uint256 nextTokenId = totalSupply() + 1;
        lickTime[nextTokenId] = block.timestamp;
        hasClaimed[msg.sender] = true;
        _safeMint(msg.sender, nextTokenId);
    }

    function lick(uint256 tokenId_) external {
        require(_exists(tokenId_), "tokenId does not exist");
        require(block.timestamp - lickTime[tokenId_] > threshold, "brainfreeze, cannot lick");
        licks[tokenId_] += 1;
        lickTime[tokenId_] = block.timestamp;
    }

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {
        uint256 numLicks = licks[tokenId_];
        string[3] memory parts;
        parts[0] = _getView(numLicks);
        parts[1] = uint2str(numLicks);
        parts[2] = "</text></svg>";

        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2]));

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Cone #',
                        uint2str(tokenId_),
                        '", "description": "Test Gelato Automation by auto-licking your sweet Gelato NFT", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(abi.encodePacked("data:application/json;base64,", json));

        return output;
    }

    function _getView(uint256 numLicks_) internal pure returns (string memory) {
        string memory s =
            '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 400 400"><defs><style>.cls-1{fill:#fae7ce;}.cls-2{fill:url(#linear-gradient);}.cls-3{fill:url(#linear-gradient-2);}.cls-4{fill:url(#linear-gradient-3);}.cls-5{fill:url(#linear-gradient-4);}.cls-6{opacity:0.3;}.cls-7{fill:#35211c;}.cls-8{fill:url(#radial-gradient);}.cls-9{fill:url(#radial-gradient-2);}.cls-10{fill:url(#radial-gradient-3);}</style><linearGradient id="linear-gradient" x1="168.88" y1="331" x2="218.89" y2="331" gradientUnits="userSpaceOnUse"><stop offset="0.19" stop-color="#ffd788"/><stop offset="0.96" stop-color="#f7a265"/></linearGradient><linearGradient id="linear-gradient-2" x1="155.64" y1="303.17" x2="227.67" y2="303.17" xlink:href="#linear-gradient"/><linearGradient id="linear-gradient-3" x1="144.23" y1="277.66" x2="253.66" y2="277.66" xlink:href="#linear-gradient"/><linearGradient id="linear-gradient-4" x1="182.12" y1="358.61" x2="210.1" y2="358.61" xlink:href="#linear-gradient"/><radialGradient id="radial-gradient" cx="174.15" cy="192.27" r="102.96" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#ffd9d2"/><stop offset="0.04" stop-color="#ffd5cf"/><stop offset="0.25" stop-color="#ffc5c4"/><stop offset="0.41" stop-color="#ffc0c0"/><stop offset="0.6" stop-color="#ffbdbd"/><stop offset="0.75" stop-color="#feb2b2"/><stop offset="0.9" stop-color="#fda0a0"/><stop offset="1" stop-color="#fc9090"/></radialGradient><radialGradient id="radial-gradient-2" cx="178.89" cy="125.64" r="89.23" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#fff"/><stop offset="0.27" stop-color="#fffcef"/><stop offset="0.48" stop-color="#fffbe9"/><stop offset="1" stop-color="#fcf2ca"/></radialGradient><radialGradient id="radial-gradient-3" cx="180.64" cy="60.86" r="98.15" gradientUnits="userSpaceOnUse"><stop offset="0" stop-color="#fff9a9"/><stop offset="0.47" stop-color="#ffd899"/><stop offset="0.71" stop-color="#f0b662"/><stop offset="0.9" stop-color="#e69d3c"/><stop offset="1" stop-color="#e2942d"/></radialGradient></defs><rect class="cls-1" width="400" height="400"/><polygon class="cls-2" points="218.89 335.2 168.88 309.63 179.12 335.5 212.09 352.37 218.89 335.2"/><polygon class="cls-3" points="165.88 302.05 220.87 330.18 227.67 313.01 155.64 276.17 165.88 302.05"/><polygon class="cls-4" points="229.66 307.99 253.66 247.34 144.23 247.34 152.64 268.59 229.66 307.99"/><path class="cls-5" d="M182.12,343.08l10.62,26.84a6.67,6.67,0,0,0,12.41,0l4.95-12.52Z"/>';
        if (numLicks_ % 5 == 0) {
            s = string(
                abi.encodePacked(
                    s,
                    '<g class="cls-6"><path class="cls-7" d="M265.39,229.55a16.5,16.5,0,0,0-8.75-9.46,12.4,12.4,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.46,16.46,0,0,0-8.77,9.47,16.7,16.7,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a19.13,19.13,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,229.55Z"/></g>',
                    '<g class="cls-6"><path class="cls-7" d="M265.39,164.23a16.5,16.5,0,0,0-8.75-9.46,12.4,12.4,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.46,16.46,0,0,0-8.77,9.47,16.7,16.7,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a19.13,19.13,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,164.23Z"/></g>',
                    '<g class="cls-6"><path class="cls-7" d="M265.39,164.23a16.5,16.5,0,0,0-8.75-9.46,12.4,12.4,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.46,16.46,0,0,0-8.77,9.47,16.7,16.7,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a19.13,19.13,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,164.23Z"/></g><g class="cls-6"><path class="cls-7" d="M265.39,98.91a16.5,16.5,0,0,0-8.75-9.46,12.4,12.4,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.46,16.46,0,0,0-8.77,9.47,16.7,16.7,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69A50.9,50.9,0,0,0,189.78,132c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a19.13,19.13,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,98.91Z"/></g>',
                    '<path class="cls-8" d="M265.39,224a16.49,16.49,0,0,0-8.75-9.47,12.39,12.39,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6A16.49,16.49,0,0,0,132.5,224a16.69,16.69,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a16.37,16.37,0,0,0,1.92-1.36A16.8,16.8,0,0,0,265.39,224Z"/>',
                    '<path class="cls-9" d="M265.39,158.65a16.5,16.5,0,0,0-8.75-9.46,12.39,12.39,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.49,16.49,0,0,0-8.77,9.47,16.69,16.69,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6A23.3,23.3,0,0,0,247.9,194c.3-6.62,4.84-12,10.49-15.47a16.37,16.37,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,158.65Z"/>',
                    '<path class="cls-10" d="M265.39,93.33a16.5,16.5,0,0,0-8.75-9.46,12.39,12.39,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.49,16.49,0,0,0-8.77,9.47,16.69,16.69,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a16.37,16.37,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,93.33Z"/>'
                )
            );
        } else if (numLicks_ % 5 == 1) {
            s = string(
                abi.encodePacked(
                    s,
                    '<g class="cls-6"><path class="cls-7" d="M265.39,229.55a16.5,16.5,0,0,0-8.75-9.46,12.4,12.4,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.46,16.46,0,0,0-8.77,9.47,16.7,16.7,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a19.13,19.13,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,229.55Z"/></g>',
                    '<g class="cls-6"><path class="cls-7" d="M265.39,164.23a16.5,16.5,0,0,0-8.75-9.46,12.4,12.4,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.46,16.46,0,0,0-8.77,9.47,16.7,16.7,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a19.13,19.13,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,164.23Z"/></g>',
                    '<path class="cls-8" d="M265.39,224a16.49,16.49,0,0,0-8.75-9.47,12.39,12.39,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6A16.49,16.49,0,0,0,132.5,224a16.69,16.69,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a16.37,16.37,0,0,0,1.92-1.36A16.8,16.8,0,0,0,265.39,224Z"/>',
                    '<path class="cls-9" d="M265.39,158.65a16.5,16.5,0,0,0-8.75-9.46,12.39,12.39,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.49,16.49,0,0,0-8.77,9.47,16.69,16.69,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6A23.3,23.3,0,0,0,247.9,194c.3-6.62,4.84-12,10.49-15.47a16.37,16.37,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,158.65Z"/>'
                )
            );
        } else if (numLicks_ % 5 == 2) {
            s = string(
                abi.encodePacked(
                    s,
                    '<g class="cls-6"><path class="cls-7" d="M265.39,229.55a16.5,16.5,0,0,0-8.75-9.46,12.4,12.4,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6,16.46,16.46,0,0,0-8.77,9.47,16.7,16.7,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a19.13,19.13,0,0,0,1.92-1.36A16.81,16.81,0,0,0,265.39,229.55Z"/></g>',
                    '<path class="cls-8" d="M265.39,224a16.49,16.49,0,0,0-8.75-9.47,12.39,12.39,0,0,1-7.09-10.57,50.7,50.7,0,0,0-101.19,0,12.45,12.45,0,0,1-7.09,10.6A16.49,16.49,0,0,0,132.5,224a16.69,16.69,0,0,0,21.73,21.25,13.3,13.3,0,0,1,13.18,1.69,50.9,50.9,0,0,0,22.37,10.17c6.31,1.17,11.14,5.85,14,11.6a23.3,23.3,0,0,0,44.13-9.32c.3-6.62,4.84-12,10.49-15.47a16.37,16.37,0,0,0,1.92-1.36A16.8,16.8,0,0,0,265.39,224Z"/>'
                )
            );
        } else if (numLicks_ % 5 == 4) {
            s =
                '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 400 400"><defs><style>.cls-1{fill:#fae7ce;}</style></defs><rect class="cls-1" width="400" height="400"/><text x="185" y="200">YUM!</text>';
        }

        return string(abi.encodePacked(s, '<text x="25" y="25">LICKS: '));
    }

    function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    receive() external payable {}
}
