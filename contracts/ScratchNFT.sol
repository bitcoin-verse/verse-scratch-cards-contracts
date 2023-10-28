// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ScratchNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    // Mapping to store the revealed property for each token ID
    mapping(uint256 => bool) public claimed;
    mapping(uint256 => string) public tokenURIs;
    mapping(uint256 => uint256) public editions;
    mapping(uint256 => uint256) public prizes;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function _mintTicket(
        uint256 _tokenId,
        uint256 _editionId,
        uint256 _prize,
        address _receiver
    )
        internal
    {
        prizes[_tokenId] = _prize;
        editions[_tokenId] = _editionId;

        _mint(
            _receiver,
            _tokenId
        );

        emit mintCompleted(
            _tokenId,
            _editionId,
            _prize
        );
    }

    function tokenURI(
        uint256 _tokenId
    )
        public
        view
        override
        returns (string memory)
    {
        if (_exists(_tokenId) == false) {
            revert InvalidTokenId();
        }

        string memory baseURI = _baseURI();
        string memory claimDone = claimed[_tokenId]
            ? "true"
            : "false";

        uint256 editionIdFromToken = editions[
            _tokenId
        ];

        return string(
            abi.encodePacked(
                baseURI,
                _tokenId.toString(),
                "/",
                claimDone,
                "&edition=",
                editionIdFromToken.toString()
            )
        );
    }

    function ownedByAddress(
        address _owner
    )
        external
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(
            _owner
        );

        uint256[] memory tokenIds = new uint256[](
            ownerTokenCount
        );

        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(
                _owner,
                i
            );
        }

        return tokenIds;
    }

    function _setClaimed(
        uint256 _tokenId
    )
        internal
    {
        if (_exists(_tokenId) == false) {
            revert InvalidTokenId();
        }

        claimed[_tokenId] = true;
    }
}