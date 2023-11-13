// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./ReelNFT.sol";

contract ReelVRF is ReelNFT {

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
        CommonBase(
            _linkTokenAddress,
            _verseTokenAddress,
            _gasKeyHash,
            _subscriptionId,
            _vrfCoordinatorV2Address
        )
    {
        characterCost = _characterCost;
    }

    /**
     * @notice Allows to gift NFT Character for free.
     * @dev Only can be called by the contract owner.
     * @param _receivers address for gifted NFTs.
     */
    function giftForFree(
        address[] memory _receivers
    )
        external
        onlyOwner
    {
        uint256 i;
        uint256 loops = _receivers.length;

        if (loops > MAX_LOOPS) {
            revert TooManyReceivers();
        }

        for (i; i < loops;) {

            _mintCharacter(
                _receivers[i]
            );

            unchecked {
                ++i;
            }
        }
    }

    function buyCharacter()
        external
    {
        _takeTokens(
            characterCost
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
        onlyTokenOwner(_astroId)
    {
        require(
            ownerOf(_tokenId) == msg.sender,
            "only owner of NFT can reroll"
        );

        rerollInProgress[_tokenId] = true;

        uint256 requestId = _requestRandomWords({
            _wordCount: 1
        });

        unchecked {
            ++latestDrawId;
        }

        Drawing memory newDrawing = Drawing({
            drawId: latestDrawId,
            tokenId: _tokenId,
            traitId: _traitId
        });

        requestIdToDrawing[requestId] = newDrawing;
        drawIdToRequestId[latestDrawId] = requestId;

        emit DrawRequest(
            latestDrawId,
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

    // Mint a new NFT with a unique revealed property
    function _mintCharacter(
        address _receiver
    )
        internal
    {
        unchecked {
            ++latestCharacterId;
        }

        _mint(
            _receiver,
            latestCharacterId
        );

        uint256 requestId = _requestRandomWords({
            _wordCount: 6
        });

        unchecked {
            ++latestDrawId;
        }

        Drawing memory newDrawing = Drawing({
            drawId: latestDrawId,
            tokenId: latestCharacterId,
            traitId: 0
        });

        requestIdToDrawing[requestId] = newDrawing;
        drawIdToRequestId[latestDrawId] = requestId;

        emit DrawRequest(
            latestDrawId,
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

        currentDraw.traitId == 0
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
