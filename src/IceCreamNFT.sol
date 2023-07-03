// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {ERC721, ERC721Enumerable} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import "openzeppelin/utils/Strings.sol";
import "./Base64.sol";

// solhint-disable
contract IceCreamNFT is ERC721Enumerable, Ownable, Pausable {
    mapping(address => bool) public hasClaimed;
    uint256 public constant W = 1000;
    uint256 public constant H = 1000;

    constructor() ERC721("Ice Cream NFT", "LICK") {}

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _createSVG(string memory body) internal view returns (string memory svgElement) {
        svgElement = string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" ',
            'width="',
            Strings.toString(W),
            '" height="',
            Strings.toString(H),
            '"><g>',
            body,
            "</g></svg>"
        );
    }

    function _createCircle(
        uint256 cx,
        uint256 cy,
        uint256 r,
        string memory fill,
        string memory stroke,
        string memory body
    ) internal pure returns (string memory svgElement) {
        svgElement = string.concat(
            "<circle ",
            'cx ="',
            Strings.toString(cx),
            '" ',
            'cy="',
            Strings.toString(cy),
            '" ',
            'r="',
            Strings.toString(r),
            '" ',
            'fill="',
            fill,
            '" ',
            'stroke="',
            stroke,
            '">',
            body,
            "</circle>"
        );
    }

    function _createAnimation(uint256 cx, uint256 cy, uint256 r) internal pure returns (string memory) {
        return string.concat(
            '<animateTransform attributeName="transform" attributeType="XML" type="rotate"',
            'from="0 ',
            string.concat(Strings.toString(cx), " ", Strings.toString(cy), '" '),
            'to="360 ',
            string.concat(Strings.toString(cx), " ", Strings.toString(cy), '" '),
            'dur="',
            Strings.toString(2 + r),
            '" ',
            'repeatCount="indefinite"/>'
        );
    }

    function mint() external {
        require(!hasClaimed[msg.sender], "already claimed");
        uint256 nextTokenId = totalSupply() + 1;
        hasClaimed[msg.sender] = true;
        _safeMint(msg.sender, nextTokenId);
    }

    function tokenURI(uint256 tokenId_) public view virtual override returns (string memory) {}

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
