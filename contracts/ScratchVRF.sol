// SPDX-License-Identifier: BCOM

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
        address _tokenAddress,
        bytes32 _gasKeyHash,
        uint64 _subscribtionId,
        uint32 _callBackMaxGas,
        uint16 _confirmationsNeeded
    )
        ScratchNFT(
            _name,
            _symbol
        )
        VRFConsumerBaseV2(
            _vrfCoordinatorV2Address
        )
    {
        VERSE_TOKEN = IERC20(
            _tokenAddress
        );

        GAS_KEYHASH = _gasKeyHash;

        VRF_COORDINATOR = VRFCoordinatorV2Interface(
            _vrfCoordinatorV2Address
        );

        SUBSCRIPTION_ID = _subscribtionId;
        CALLBACK_MAX_GAS = _callBackMaxGas;
        CONFIRMATIONS_NEEDED = _confirmationsNeeded;

        ticketCost = _ticketCost;
    }

    function getPrizeTier(
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
            if (_number >= prizeTiers[i].drawEdgeA && _number <= prizeTiers[i].drawEdgeB) {
                prize = prizeTiers[i].winAmount;
                return prize;
            }

            unchecked {
                ++i;
            }
        }
        return prize;
    }

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
            2
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
        Drawing storage currentDraw = requestIdToDrawing[
            _requestId
        ];

        uint32 randomEdition = uint32(
            (_randomWords[1] % 10) + 1
        ); // 1 to 10

        uint32 randomNumber = uint32(
            (_randomWords[0] % 1000) + 1
        ); // 1 to 1000

        uint256 prize = getPrizeTier(
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
            "ScratchVRF: INVALID_NFT_OWNER"
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

    function changeTicketCost(
        uint256 _newTicketCost
    )
        external
        onlyOwner
    {
        if (_newTicketCost == 0) {
            revert InvalidCost();
        }

        if (_newTicketCost == ticketCost) {
            revert InvalidCost();
        }

        ticketCost = _newTicketCost;
    }
}
