// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

/**
 * @title ERC721 interface
 * @dev Required interface for ERC721 compatible contracts
 */
interface IERC721 {
    /**
     * @dev Transfers token from one address to another
     * @param from The current owner of the token
     * @param to The new owner
     * @param tokenId The ID of the token being transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gets the balance of the specified address
     * @param owner Address to query the balance of
     * @return Balance of the owner
     */
    function balanceOf(address owner) external view returns (uint256);

    /**
     * @dev Gets the owner of the specified token ID
     * @param tokenId Token ID to query the owner of
     * @return Owner address
     */
    function ownerOf(uint256 tokenId) external view returns (address);

    /**
     * @dev Mint a new token
     * @param to The address that will own the minted token
     * @param tokenId The token ID to mint
     */
    function mint(address to, uint256 tokenId) external;
}
