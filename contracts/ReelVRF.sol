// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

import "./CommonVRF.sol";
import "./ReelNFT.sol";

struct Drawing {
    bool isMinting;
    uint256 drawId;
    uint256 astroId;
    uint256 traitId;
}

error InvalidTraitId();
error RerollInProgress();
error RerollCostLocked();
error TraitNotYetDefined();

contract ReelVRF is ReelNFT, CommonVRF {

    uint256 public rerollCost;
    bool public isRerollCostLocked;

    mapping(uint256 => bool) public rerollInProgress;
    mapping(uint256 => Drawing) public requestIdToDrawing;

    mapping(uint256 => uint256) public rerollCountPerNft;

    event RerollFulfilled(
        uint256 indexed drawId,
        uint256 indexed astroId,
        uint256 traitNumber,
        uint256 rolledNumber
    );

    event RerollCostUpdated(
        uint256 newRerollCost
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _vrfCoordinatorV2Address,
        uint256 _characterCost,
        address _linkTokenAddress,
        address _verseTokenAddress,
        bytes32 _gasKeyHash,
        uint64 _subscriptionId
    )
        ERC721(
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
        baseCost = _characterCost;
        rerollCost = _characterCost / 10;
    }

    function buyCharacter()
        external
        whenNotPaused
    {
        _takeTokens(
            VERSE_TOKEN,
            baseCost
        );

        _mintCharacter(
            msg.sender
        );
    }

    function giftCharacter(
        address _receiver
    )
        external
        whenNotPaused
    {
        _takeTokens(
            VERSE_TOKEN,
            baseCost
        );

        _mintCharacter(
            _receiver
        );
    }

    /**
     * @notice Allows to gift NFT Character for free.
     * @dev Only can be called by the contract owner.
     * @param _receivers address for gifted NFTs.
     */
    function giftForFree(
        address[] calldata _receivers
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
        whenNotPaused
        onlyTokenOwner(_astroId)
    {
        if (_traitId > MAX_TRAIT_TYPES) {
            revert InvalidTraitId();
        }

        if (results[_astroId][_traitId] == 0) {
            revert TraitNotYetDefined();
        }

        if (rerollInProgress[_astroId] == true) {
            revert RerollInProgress();
        }

        rerollInProgress[_astroId] = true;

        _startRequest({
            _wordCount: 1,
            _astroId: _astroId,
            _traitId: _traitId
        });

        uint256 rerollCount = rerollCountPerNft[
            _astroId
        ];

        if (rerollCount > 0) {
            _takeTokens(
                VERSE_TOKEN,
                rerollCost ** rerollCount
            );
        }

        rerollCountPerNft[_astroId] = rerollCount + 1;
    }

    function getNextRerollPrice(
        uint256 _astroId
    )
        external
        view
        returns (uint256)
    {
        uint256 rerollCount = rerollCountPerNft[_astroId];

        if (rerollCount == 0) {
            return 0;
        }

        return rerollCost ** rerollCount;
    }

    function lockRerollCost()
        external
        onlyOwner
    {
        isRerollCostLocked = true;
    }

    function setRerollCost(
        uint256 _newRerollCost
    )
        external
        onlyOwner
    {
        if (isRerollCostLocked == true) {
            revert RerollCostLocked();
        }

        rerollCost = _newRerollCost;

        emit RerollCostUpdated(
            _newRerollCost
        );
    }

    function _mintCharacter(
        address _receiver
    )
        internal
    {
        uint256 latestCharacterId = _increaseCharacterId();

        _mint(
            _receiver,
            latestCharacterId
        );

        _startRequest({
            _traitId: 0,
            _wordCount: MAX_TRAIT_TYPES,
            _astroId: latestCharacterId
        });
    }

    function _startRequest(
        uint32 _wordCount,
        uint256 _traitId,
        uint256 _astroId
    )
        internal
    {
        uint256 requestId = _requestRandomWords(
            _wordCount
        );

        _increaseDrawId();

        Drawing memory newDrawing = Drawing({
            drawId: latestDrawId,
            astroId: _astroId,
            traitId: _traitId,
            isMinting: _wordCount == MAX_TRAIT_TYPES
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

        currentDraw.isMinting == true
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
        uint256 i;
        uint256[] memory numbers = new uint256[](
            MAX_TRAIT_TYPES
        );

        for (i; i < MAX_TRAIT_TYPES;) {
            numbers[i] = uniform(
                _randomWords[i],
                MAX_RESULT_INDEX
            );
            unchecked {
                ++i;
            }
        }

        results[
            currentDraw.astroId
        ] = numbers;

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
            MAX_RESULT_INDEX
        );

        _updateTrait(
            _currentDraw.astroId,
            _currentDraw.traitId,
            rolledNumber
        );

        rerollInProgress[
            _currentDraw.astroId
        ] = false;

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
        results[_astroId][_traitId] = _rolledNumber;
    }

    function _increaseDrawId()
        internal
        returns (uint256)
    {
        unchecked {
            return ++latestDrawId;
        }
    }
}
