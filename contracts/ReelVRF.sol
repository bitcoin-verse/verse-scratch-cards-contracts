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
        ERC721(
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
        baseCost = _characterCost;
    }

    function buyCharacter()
        external
    {
        _takeTokens(
            baseCost
        );

        _mintCharacter(
            msg.sender
        );
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

    function rerollTrait(
        uint256 _astroId,
        uint256 _traitId
    )
        external
        onlyTokenOwner(_astroId)
    {
        rerollInProgress[_astroId] = true;

        uint256 requestId = _requestRandomWords({
            _wordCount: 1
        });

        unchecked {
            ++latestDrawId;
        }

        Drawing memory newDrawing = Drawing({
            drawId: latestDrawId,
            astroId: _astroId,
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
            astroId: latestCharacterId,
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

    function _initialMint(
        Drawing memory currentDraw,
        uint256[] memory _randomWords,
        uint256 _requestId
    )
        internal
    {
        uint256[] memory numbers = new uint256[](
            MAX_TRAITS
        );

        for (uint256 i; i < MAX_TRAITS;) {
            numbers[i] = uniform(
                _randomWords[i],
                MAX_TRAITS
            );
            unchecked {
                ++i;
            }
        }

        /*
        for (uint8 i; i < MAX_TYPES;) {
            traits[currentDraw.astroId][TraitType(i)] = uniform(
                _randomWords[i],
                MAX_TRAITS
            );
            unchecked {
                ++i;
            }
        }*/

        traits[currentDraw.astroId] = numbers;
        completed[currentDraw.astroId] = true;

        emit RequestFulfilled(
            currentDraw.drawId,
            _requestId,
            numbers
        );
    }

    function _rerollTrait(
        Drawing memory _currentDraw,
        uint256[] memory _randomWords
    )
        internal
    {
        uint256 rolledNumber = uniform(
            _randomWords[0],
            MAX_TRAITS
        );

        _updateTrait(
            _currentDraw.astroId,
            _currentDraw.traitId,
            rolledNumber
        );

        rerollInProgress[_currentDraw.astroId] = false;

        emit RerollFulfilled(
            _currentDraw.drawId,
            _currentDraw.astroId,
            _currentDraw.traitId,
            rolledNumber
        );
    }

    function _updateTrait(
        uint256 _astroId,
        uint256 _traitId,
        uint256 _rolledNumber
    )
        internal
    {
        traits[_astroId][_traitId] = _rolledNumber;
    }
}
