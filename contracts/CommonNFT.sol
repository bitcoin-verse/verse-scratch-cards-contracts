// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

import "./flats/ERC721Enumerable.sol";

error InvalidId();

abstract contract CommonNFT is ERC721Enumerable {

    string internal baseURI;
    mapping(uint256 => string) public tokenURIs;

    modifier onlyTokenOwner(
        uint256 _tokenId
    )
    {
        require(
            ownerOf(_tokenId) == msg.sender,
            "CommonNFT: INVALID_OWNER"
        );
        _;
    }

    function isMinted(
        uint256 _tokenId
    )
        external
        view
        returns(bool)
    {
        return _ownerOf(_tokenId) > address(0x0);
    }

    function ownedByAddress(
        address _owner
    )
        external
        view
        returns (uint256[] memory)
    {
        uint256 ownerNFTCount = balanceOf(
            _owner
        );

        uint256[] memory nftIds = new uint256[](
            ownerNFTCount
        );

        uint256 i;

        while (i < ownerNFTCount) {

            nftIds[i] = tokenOfOwnerByIndex(
                _owner,
                i
            );

            unchecked {
                ++i;
            }
        }

        return nftIds;
    }

    /**
     * @dev Converts tokenId uint to string.
     */
    function _toString(
        uint256 _tokenId
    )
        internal
        pure
        returns (string memory str)
    {
        if (_tokenId == 0) {
            return "0";
        }

        uint256 j = _tokenId;
        uint256 length;

        while (j != 0) {
            length++;
            j /= 10;
        }

        bytes memory bstr = new bytes(
            length
        );

        uint256 k = length;
        j = _tokenId;

        while (j != 0) {
            bstr[--k] = bytes1(
                uint8(
                    48 + j % 10
                )
            );
            j /= 10;
        }

        str = string(
            bstr
        );
    }
}