// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

import "./CommonVRF.sol";
import "./ReelNFT.sol";

struct Drawing {
    bool addBadge;
    bool isMinting;
    uint256 drawId;
    uint256 astroId;
    uint256 traitId;
}

error InvalidTraitId();
error RerollInProgress();
error RerollCostLocked();
error TooManyFreeGifts();
error TraitNotYetDefined();

contract ReelVRF is ReelNFT, CommonVRF {

    bool public isRerollCostLocked;

    mapping(uint256 => bool) public rerollInProgress;
    mapping(uint256 => Drawing) public requestIdToDrawing;
    mapping(uint256 => uint256) public rerollCountPerNft;

    uint256 public freeGiftCount;
    uint256 public MAX_FREE_GIFT = 2000;

    uint256[] rerollPrices = new uint256[](
        MAX_REROLL_COUNT
    );

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
        rerollPrices[0] = 0;

        rerollPrices[1] = 300E18;
        rerollPrices[2] = 600E18;

        rerollPrices[3] = 1_500E18;
        rerollPrices[4] = 4_000E18;
        rerollPrices[5] = 8_000E18;

        rerollPrices[6] = 13_000E18;
        rerollPrices[7] = 20_000E18;
        rerollPrices[8] = 50_000E18;

        rerollPrices[9] = 50_000E18;

        rerollPrices[10] = 100_000E18;
        rerollPrices[11] = 250_000E18;
    }

    function setRerollPrice(
        uint256 _rerollCount,
        uint256 _newPrice
    )
        external
        onlyOwner
    {
        if (isRerollCostLocked == true) {
            revert RerollCostLocked();
        }

        rerollPrices[_rerollCount] = _newPrice;
    }

    function getRerollPrice(
        uint256 _rerollCount
    )
        external
        view
        returns (uint256)
    {
        return rerollPrices[_rerollCount];
    }

    function buyCharacter()
        external
        whenNotPaused
    {
        _takeTokens(
            VERSE_TOKEN,
            baseCost
        );

        _mintCharacter({
            _addBadge: false,
            _receiver: msg.sender
        });
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

        _mintCharacter({
            _addBadge: false,
            _receiver: _receiver
        });
    }

    /**
     * @notice Allows to gift NFT Character for free.
     * @dev Only can be called by the contract owner.
     * @param _receivers address for gifted NFTs.
     */
    function giftForFree(
        bool _addBadge,
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

        if (freeGiftCount + loops > MAX_FREE_GIFT) {
            revert TooManyFreeGifts();
        }

        while (i < loops) {

            _mintCharacter(
                _addBadge,
                _receivers[i]
            );

            unchecked {
                ++i;
            }
        }

        freeGiftCount += loops;
    }

    function _updateBadge(
        uint256 _astroId
    )
        internal
    {
        uint256 i;
        uint256 resultSum;

        while (i < MAX_TRAIT_TYPES) {
            resultSum += results[_astroId][i];
            unchecked {
                ++i;
            }
        }

        uint256 badgeType = resultSum % 2 == 0 ? 1 : 2;
        results[_astroId][BADGE_TRAIT_ID] = badgeType;
    }

    function rerollTrait(
        uint256 _astroId,
        uint256 _traitId
    )
        external
        whenNotPaused
        onlyTokenOwner(_astroId)
    {
        require(
            _traitId < MAX_TRAIT_TYPES,
            "ReelVRF: InvalidTraitId"
        );

        if (_traitId == BADGE_TRAIT_ID) {
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
            _addBadge: false,
            _astroId: _astroId,
            _traitId: _traitId
        });

        uint256 rerollCount = rerollCountPerNft[
            _astroId
        ];

        uint256 rerollPrice = rerollPrices[
            rerollCount
        ];

        if (rerollPrice > 0) {
            _takeTokens(
                VERSE_TOKEN,
                rerollPrice
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
        return rerollPrices[
            rerollCountPerNft[_astroId]
        ];
    }

    function lockRerollCost()
        external
        onlyOwner
    {
        isRerollCostLocked = true;
    }

    function _mintCharacter(
        bool _addBadge,
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
            _addBadge: _addBadge,
            _wordCount: MAX_TRAIT_TYPES,
            _astroId: latestCharacterId
        });
    }

    function _startRequest(
        bool _addBadge,
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
            addBadge: _addBadge,
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

        while (i < MAX_TRAIT_TYPES) {

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

        currentDraw.addBadge == true
            ? _updateBadge(
                currentDraw.astroId
            )
            : _updateTrait(
                currentDraw.astroId,
                BADGE_TRAIT_ID,
                MAX_RESULT_INDEX
            );

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
