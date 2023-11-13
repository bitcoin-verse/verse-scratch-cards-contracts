// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./ReelNFT.sol";

contract ReelVRF is ReelNFT {

    using SafeERC20 for IERC20;

    uint256 public characterCost;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _characterCost,
        address _vrfCoordinatorV2Address,
        address _linkTokenAddress,
        address _verseTokenAddress,
        bytes32 _gasKeyHash,
        uint64 _subscriptionId
    )
        ReelNFT(
            _name,
            _symbol
        )
        CommonVRF(
            _linkTokenAddress,
            _verseTokenAddress,
            _gasKeyHash,
            _subscriptionId,
            _vrfCoordinatorV2Address
        )
    {
        characterCost = _characterCost;
    }

    function giftCharactersForFree(
        address[] memory receivers
    )
        external
        onlyOwner
    {
        uint256 i;
        uint256 total = receivers.length;

        for (i; i < total;) {
            _mintCharacter(
                receivers[i]
            );
            unchecked {
                ++i;
            }
        }
    }

    function buyCharacter()
        external
    {
        VERSE_TOKEN.safeTransferFrom(
            msg.sender,
            address(this),
            characterCost * 1 ether
        );

        _mintCharacter(
            msg.sender
        );
    }

    function rerollTrait(
        uint256 _tokenId,
        uint256 _traitId
    )
        external
    {
        require(
            ownerOf(_tokenId) == msg.sender,
            "only owner of NFT can reroll"
        );

        rerollInProgress[tokenId] = true;

        uint256 requestId = _requestRandomWords({
            _wordCount: 1
        });

        ++drawId;

        Drawing memory newDrawing = Drawing({
            drawId: drawId,
            tokenId: _tokenId,
            traitId: _traitId
        });

        requestIdToDrawing[requestId] = newDrawing;
        drawIdToRequestId[drawId] = requestId;

        emit DrawRequest(
            drawId,
            requestId,
            msg.sender
        );
    }

    function getTraits(
        uint256 _tokenId
    )
        external
        view
        returns (uint256[] memory)
        // returns (TraitType[] memory)
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

    // Mint a new NFT with a unique revealed property
    function _mintCharacter(
        address _receiver
    )
        internal
    {
        ++tokenId;

        _mint(
            _receiver,
            tokenId
        );

        uint256 requestId = _requestRandomWords({
            _wordCount: 6
        });

        ++drawId;

        Drawing memory newDrawing = Drawing({
            drawId: drawId,
            tokenId: tokenId,
            reroll: false,
            rerollNumber: 0
        });

        requestIdToDrawing[requestId] = newDrawing;
        drawIdToRequestId[drawId] = requestId;

        emit DrawRequest(
            drawId,
            requestId,
            msg.sender
        );
    }


    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    )
        internal
        override
    {
        Drawing memory currentDraw = requestIdToDrawing[
            _requestId
        ];

        currentDraw.reroll == false
            ? _initialMint(
                currentDraw,
                _randomWords,
                _requestId
            )
            : _rerollTrait(
                currentDraw,
                _randomWords
            );
    }
}
