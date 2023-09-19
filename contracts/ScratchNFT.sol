// copied from VNFT
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ScratchNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    // Mapping to store the revealed property for each token ID
    mapping(uint256 => bool) private claimed;
    mapping(uint256 => string) public tokenURIs;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    // Mint a new NFT with a unique revealed property
    function mint(uint256 tokenId, address receiver) public onlyOwner {
        _mint(receiver, tokenId);
        claimed[tokenId] = false;
    }

    // Get the revealed property for a specific token ID
    function getClaimedProperty(uint256 tokenId) public view returns (bool) {
        require(_exists(tokenId), "Token does not exist");
        return claimed[tokenId];
    }

    // Override the standard tokenURI function to include the revealed property
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        string memory baseURI = _baseURI();
        string memory claimDone = claimed[tokenId] ? "true" : "false";
        return string(abi.encodePacked(baseURI, tokenId.toString(), "/", claimDone));
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

}