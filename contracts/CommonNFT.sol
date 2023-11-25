// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error InvalidId();

abstract contract CommonNFT is ERC721Enumerable, Ownable {

    mapping(uint256 => string) public tokenURIs;
    string private _baseURIextended;

    modifier onlyTokenOwner(
        uint256 _tokenId
    )
    {
        require(
            ownerOf(_tokenId) == msg.sender,
            "CommonBase: INVALID_OWNER"
        );
        _;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        _baseURIextended = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }

    function isMinted(
        uint256 _tokenId
    )
        external
        view
        returns(bool)
    {
        return _exists(_tokenId);
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

        for (i; i < ownerNFTCount;) {

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