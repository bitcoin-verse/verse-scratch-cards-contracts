// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./ScratchBase.sol";

contract ScratchVRF is ScratchBase {

    using SafeERC20 for IERC20;
    using SafeERC20 for ILinkToken;

    constructor(
        string memory _name,
        string memory _symbol,
        address _vrfCoordinatorV2Address,
        uint256 _ticketCost,
        address _linkTokenAddress,
        address _verseTokenAddress,
        bytes32 _gasKeyHash
    )
        ScratchBase(
            _name,
            _symbol,
            _vrfCoordinatorV2Address,
            _ticketCost,
            _linkTokenAddress,
            _verseTokenAddress,
            _gasKeyHash
        )
    {}

    /**
     * @notice Allows to purchase scratch ticket as NFT.
     */
    function buyScratchTicket()
        external
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
        VERSE_TOKEN.safeTransferFrom(
            msg.sender,
            address(this),
            ticketCost
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

            _drawTicketRequest(
                _receivers[i]
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
        uint256 requestId = VRF_COORDINATOR.requestRandomWords(
            GAS_KEYHASH,
            SUBSCRIPTION_ID,
            CONFIRMATIONS_NEEDED,
            CALLBACK_MAX_GAS,
            NUM_WORDS
        );

        Drawing memory newDrawing = Drawing({
            drawId: drawCount,
            ticketReceiver: _receiver
        });

        ++drawCount;

        drawIdToRequestId[drawCount] = requestId;
        requestIdToDrawing[requestId] = newDrawing;

        emit DrawRequest(
            drawCount,
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

        uint32 randomEdition = uint32(
            (_randomWords[1] % 10) + 1
        ); // 1 to 10

        uint32 randomNumber = uint32(
            (_randomWords[0] % 1000) + 1
        ); // 1 to 1000

        uint256 prize = _getPrizeTier(
            randomNumber
        );

        ++latestTicketId;

        _mintTicket(
            latestTicketId,
            randomEdition,
            prize,
            currentDraw.ticketReceiver
        );

        emit RequestFulfilled(
            currentDraw.drawId,
            _requestId,
            randomNumber
        );
    }

    function _getPrizeTier(
        uint256 _number
    )
        internal
        view
        returns (uint256)
    {
        uint256 i;
        uint256 prize;
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

        return prize;
    }

    /**
     * @notice Allows claim prize for scratch NFT.
     * @param _ticketId of the scratch ticket NFT.
     */
    function claimPrize(
        uint256 _ticketId
    )
        external
    {
        require(
            ownerOf(_ticketId) == msg.sender,
            "ScratchVRF: INVALID_TICKET_OWNER"
        );

        if (claimed[_ticketId] == true) {
            revert AlreadyClaimed();
        }

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

        VERSE_TOKEN.safeTransfer(
            msg.sender,
            prizeWei
        );

        emit PrizeClaimed(
            _ticketId,
            msg.sender,
            prizeWei
        );
    }

    /**
     * @notice Allows to withdraw VERSE tokens from the contract.
     * @dev Only can be called by the contract owner.
     */
    function withdrawTokens()
        external
        onlyOwner
    {
        uint256 balance = VERSE_TOKEN.balanceOf(
            address(this)
        );

        VERSE_TOKEN.safeTransfer(
            msg.sender,
            balance
        );

        emit WithdrawTokens(
            msg.sender,
            balance
        );
    }

    function loadSubscription(
        uint256 _linkAmount
    )
        external
    {
        LINK_TOKEN.safeTransferFrom(
            msg.sender,
            address(this),
            _linkAmount
        );

        LINK_TOKEN.transferAndCall(
            address(VRF_COORDINATOR),
            _linkAmount,
            abi.encode(SUBSCRIPTION_ID)
        );
    }
}
