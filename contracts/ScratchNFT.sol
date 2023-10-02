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

    // Mint a new NFT with a unique revealed property
    function mint(uint256 _tokenId, uint256 _editionId, uint256 _prize, address _receiver) public onlyOwner {
        _mint(_receiver, _tokenId);
        claimed[_tokenId] = false;
        prizes[_tokenId] = _prize;
        editions[_tokenId] = _editionId;
        emit mintCompleted(_tokenId, uint32(_editionId), _prize);
    }


    // Override the standard tokenURI function to include the revealed property
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        string memory baseURI = _baseURI();
        string memory claimDone = claimed[tokenId] ? "true" : "false";
        uint editionIdFromToken = editions[tokenId];

        return string(abi.encodePacked(baseURI, tokenId.toString(), "/", claimDone, "&edition=", editionIdFromToken.toString()));
    }

    function ownedByAddress(address _owner) public view returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
   }

    function setClaimed(uint256 tokenId) public onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        claimed[tokenId] = true;
    }

    event mintCompleted(
        uint256 indexed tokenId,
        uint32 edition,
        uint256 prize
    );

}