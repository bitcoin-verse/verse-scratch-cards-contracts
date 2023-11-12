// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./ReelNFT.sol";

contract ReelVRF is ReelNFT {

    using SafeERC20 for IERC20;

    uint256 public characterCost;
    address constant TOKEN_ADDRESS = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;

    constructor(
        uint256 _characterCost,
        address _vrfCoordinatorV2Address
    )
        ReelNFT(
            _vrfCoordinatorV2Address,
            "CHAR",
            "CHR"
        )
    {
        characterCost = _characterCost;
    }

    function bulkSend(
        address[] memory receivers
    )
        external
        onlyOwner
    {
        for (uint i; i < receivers.length; i++) {
            _mintCharacter(receivers[i]);
        }
    }

    function buyCharacter()
        external
    {
        IERC20(TOKEN_ADDRESS).safeTransferFrom(
            msg.sender,
            address(this),
            characterCost * 1 ether
        );

        _mintCharacter(
            msg.sender
        );
    }


    function reRollTrait(
        uint8 _traitNumber,
        uint256 _tokenId
    )
        public
    {
        // check if user owns the nft before rerolling
        // currently rerolling is free, can either charge verse or use credit syste
        require(ownerOf(_tokenId) == address(msg.sender), "only owner of NFT can reroll");
        rerollInProgress[tokenId] = true;

        uint256 requestId = vrfCoordinator.requestRandomWords(
            GAS_KEYHASH, // gas keyhash (sepoila 30 gwei)
            SUBSCRIPTION_ID, // subscription id
            CONFIRMATIONS_NEEDED, // conf needed
            CALLBACK_MAX_GAS, // callback gas
            1
        );
        ++drawId;

        Drawing memory newDrawing = Drawing({
            drawId: drawId,
            tokenId: _tokenId,
            reroll: true,
            rerollNumber: _traitNumber
        });

        requestIdToDrawing[requestId] = newDrawing;
        drawIdToRequestId[drawId] = requestId;
        emit DrawRequest(drawId, requestId, msg.sender);
    }

    function getTraits(
        uint256 _tokenId
    )
        external
        view
        returns (uint256[] memory)
    {
        return traits[_tokenId];
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
