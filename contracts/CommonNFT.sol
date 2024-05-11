// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

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
        return _ownerOf(_tokenId) > ZERO_ADDRESS;
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
}