// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

import "./CommonVRF.sol";
import "./ScratchNFT.sol";

error ZeroTickts();
error NotEnoughFunds();

contract ScratchVRF is ScratchNFT, CommonVRF {

    constructor(
        string memory _name,
        string memory _symbol,
        address _vrfCoordinatorV2Address,
        uint256 _ticketCost,
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
        baseCost = _ticketCost;
    }

    /**
     * @notice Allows to purchase scratch ticket as NFT.
     */
    function buyScratchTicket()
        external
        whenNotPaused
    {
        _newScratchTicket(
            msg.sender
        );
    }

    /**
     * @notice Allows to gift scratch ticket.
     * @param _receiver address for gifted NFT.
     */
    function giftScratchTicket(
        address _receiver
    )
        external
        whenNotPaused
    {
        _newScratchTicket(
            _receiver
        );
    }

    function _newScratchTicket(
        address _receiver
    )
        internal
    {
        _takeTokens(
            VERSE_TOKEN,
            baseCost
        );

        _drawTicketRequest(
            _receiver
        );
    }

    /**
     * @notice Allows to gift scratch ticket for free.
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

        while (i < loops) {
            _drawTicketRequest(
                _receivers[i]
            );
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Allows to bulk purchase of multiple tickets
     * @param _receiver destination address for purchased tickets
     * @param _ticketCount amount of tickets to purchase
     */
    function bulkPurchase(
        address _receiver,
        uint256 _ticketCount
    )
        external
    {
        if (_ticketCount == 0) {
            revert ZeroTickts();
        }

        if (_ticketCount > MAX_LOOPS) {
            revert TooManyTickets();
        }

        _takeTokens(
            VERSE_TOKEN,
            baseCost * _ticketCount
        );

        uint256 i;

        while (i < _ticketCount) {
            _drawTicketRequest(
                _receiver
            );
            unchecked {
                ++i;
            }
        }
    }

    function _drawTicketRequest(
        address _receiver
    )
        internal
    {
        uint256 requestId = _requestRandomWords({
            _wordCount: 2
        });

        uint256 latestDrawId = _increaseLatestDrawId();

        Drawing memory newDrawing = Drawing({
            drawId: latestDrawId,
            ticketReceiver: _receiver
        });

        drawIdToRequestId[latestDrawId] = requestId;
        requestIdToDrawing[requestId] = newDrawing;

        emit DrawRequest(
            latestDrawId,
            requestId,
            msg.sender
        );
    }

    /**
     * @notice callback function for chainlink VRF.
     * @param _requestId id of the VRF request.
     * @param _randomWords array with random numbers.
    */
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

        uint256 randomEdition = uniform(
            _randomWords[1],
            10
        );

        uint256 randomNumber = uniform(
            _randomWords[0],
            1_000
        );

        uint256 prize = _getPrizeTier(
            randomNumber
        );

        uint256 latestTicketId = _increaseLatestTicketId();

        _mintTicket(
            latestTicketId,
            randomEdition,
            prize,
            currentDraw.ticketReceiver
        );

        emit RequestFulfilled(
            currentDraw.drawId,
            _requestId,
            // @TODO: replace with randomEdition and randomNumber
            _randomWords
        );
    }

    function _increaseLatestTicketId()
        internal
        returns (uint256)
    {
        unchecked {
            return ++latestTicketId;
        }
    }

    function _increaseLatestDrawId()
        internal
        returns (uint256)
    {
        unchecked {
            return ++latestDrawId;
        }
    }

    function _getPrizeTier(
        uint256 _number
    )
        internal
        view
        returns (uint256 prize)
    {
        uint256 i;
        uint256 loops = prizeTiers.length;

        for (i; i < loops;) {

            PrizeTier memory pt = prizeTiers[i];

            if (_number >= pt.drawEdgeA && _number <= pt.drawEdgeB) {
                prize = pt.winAmount;
                return prize;
            }

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Allows claim prize for scratch NFT.
     * @param _ticketId of the scratch ticket NFT.
     */
    function claimPrize(
        uint256 _ticketId
    )
        external
        whenNotPaused
        onlyTokenOwner(_ticketId)
    {
        _setClaimed(
            _ticketId
        );

        uint256 prizeWei = prizes[
            _ticketId
        ];

        uint256 balance = VERSE_TOKEN.balanceOf(
            address(this)
        );

        if (balance < prizeWei) {
            revert NotEnoughFunds();
        }

        _giveTokens(
            VERSE_TOKEN,
            msg.sender,
            prizeWei
        );

        emit PrizeClaimed(
            _ticketId,
            msg.sender,
            prizeWei
        );
    }

    function updateBaseURI(
        string calldata _newBaseURI
    )
        external
        onlyOwner
    {
        baseURI = _newBaseURI;
    }
}
