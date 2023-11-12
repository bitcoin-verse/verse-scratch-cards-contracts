// SPDX-License-Identifier: MIT
pragma solidity =0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./ReelNFT.sol";

contract VerseReel is Ownable
{
    using SafeERC20 for IERC20;

    VerseReelNFT nftContract;

    uint256 public characterCost;
    address constant TOKEN_ADDRESS = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;

    constructor(
        uint256 _characterCost,
        address _vrfCoordinatorV2Address
    )
    {
        nftContract = new VerseReelNFT(
            _vrfCoordinatorV2Address,
            "CHAR",
            "CHR"
        );

        characterCost = _characterCost;
    }

    function bulkSend(
        address[] memory receivers
    )
        public
        onlyOwner
    {
        for(uint i; i < receivers.length; i++) {
            nftContract.mint(receivers[i]);
        }
    }

    function buyCharacter(
        address receiver
    )
        public
    {
        // DISABLED FOR TESTING
        // IERC20(TOKEN_ADDRESS).safeTransferFrom( msg.sender, address(this), characterCost * 1 ether);

        address _ticketReceiver = msg.sender;
        if (receiver != address(0)) _ticketReceiver = receiver;

        nftContract.mint(
            _ticketReceiver
        );
    }

    function withdraw()
        public
        onlyOwner
    {
        uint256 balance = IERC20(TOKEN_ADDRESS).balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        IERC20(TOKEN_ADDRESS).safeTransfer(owner(), balance);
    }
}