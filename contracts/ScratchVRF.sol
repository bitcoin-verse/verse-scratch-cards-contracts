// SPDX-License-Identifier: BCOM

pragma solidity =0.8.21;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "./PrizeTiers.sol";
import "./ScratchNFT.sol";

error AlreadyClaimed();
error NotEnoughFunds();

contract ScratchVRF is ScratchNFT, PrizeTiers, VRFConsumerBaseV2 {

    using SafeERC20 for IERC20;

    ScratchNFT public immutable NFT_CONTRACT;
    VRFCoordinatorV2Interface private immutable VRF_COORDINATOR;

    uint64 constant public SUBSCRIPTION_ID = 951;
    uint16 constant public CONFIRMATIONS_NEEDED = 3;
    uint32 constant public CALLBACK_MAX_GAS = 2000000;

    bytes32 constant public GAS_KEYHASH = 0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd;

    IERC20 constant public TOKEN_ADDRESS = IERC20(
        0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc
    );

    uint256 public ticketCost;
    uint256 public currentTokenId;

    uint256[] private _randomNumbers;

    uint256 public drawCount;

    mapping(uint256 => uint256) public drawIdToRequestId;
    mapping(uint256 => Drawing) public requestIdToDrawing;

    struct Drawing {
        uint256 drawId;
        address ticketReceiver;
    }

    event PrizeClaimed(
        uint256 indexed tokenId,
        address indexed receiver,
        uint256 amount
    );

    event WithdrawTokens(
        address indexed receiver,
        uint256 amount
    );

    event DrawRequest(
        uint256 indexed drawId,
        uint256 indexed requestId,
        address indexed ticketReceiver
    );

    event RequestFulfilled(
        uint256 indexed drawId,
        uint256 indexed requestId,
        uint32 indexed result
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _vrfCoordinatorV2Address,
        uint256 _ticketCost
    )
        ScratchNFT(
            _name,
            _symbol
        )
        VRFConsumerBaseV2(
            _vrfCoordinatorV2Address
        )
    {
        VRF_COORDINATOR = VRFCoordinatorV2Interface(
            _vrfCoordinatorV2Address
        );

        ticketCost = _ticketCost;
    }

    function getPrizeTier(
        uint256 _number
    )
        internal
        view
        returns (uint256)
    {
        uint256 prize = 0;
        for (uint256 i = 0; i < prizeTiers.length; i++) {
            if (_number >= prizeTiers[i].drawEdgeA && _number <= prizeTiers[i].drawEdgeB) {
                prize = prizeTiers[i].winAmount;
                return prize;
            }
        }
        return prize;
    }

    /// @notice callback function for chainlink's VRF
    /// @dev amount of gas this function is allowed to spent is set on VRF_COORDINATOR.requestRandomWords
    /// @param _requestId id of the vrf request
    /// @param _randomWords array with random numbers generated by VRF
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

        uint32 randomNumber = uint32(
            (_randomWords[0] % 1000) + 1
        ); // 1 to 1000

        uint32 randomEdition = uint32(
            (_randomWords[1] % 10) + 1
        ); // 1 to 10

        uint256 prize = getPrizeTier(
            randomNumber
        );

        ++currentTokenId;

        _mintTicket(
            currentTokenId,
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

    function bulkSend(
        address[] memory _receivers
    )
        external
        onlyOwner
    {
        uint256 i;
        uint256 loops = _receivers.length;

        for (i; i < loops;) {

            uint256 requestId = VRF_COORDINATOR.requestRandomWords(
                GAS_KEYHASH,
                SUBSCRIPTION_ID,
                CONFIRMATIONS_NEEDED,
                CALLBACK_MAX_GAS,
                2 // unknown number
            );

            ++drawCount;

            requestIdToDrawing[requestId] = Drawing({
                drawId: drawCount,
                ticketReceiver: _receivers[i]
            });

            drawIdToRequestId[drawCount] = requestId;

            emit DrawRequest(
                drawCount,
                requestId,
                msg.sender
            );

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Request to purchase scratch ticket
     * @param _receiver address that receives NFT
     */
    function buyScratchTicket(
        address _receiver
    )
        external
    {
        TOKEN_ADDRESS.safeTransferFrom(
            msg.sender,
            address(this),
            ticketCost
        );

        uint256 requestId = VRF_COORDINATOR.requestRandomWords(
            GAS_KEYHASH,
            SUBSCRIPTION_ID,
            CONFIRMATIONS_NEEDED,
            CALLBACK_MAX_GAS,
            2
        );

        address ticketReceiver = msg.sender;

        if (_receiver != address(0)) {
            ticketReceiver = _receiver;
        }

        Drawing memory newDrawing = Drawing({
            drawId: drawCount,
            ticketReceiver: ticketReceiver
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

    function claimPrize(
        uint256 _tokenId
    )
        external
    {
        require(
            ownerOf(_tokenId) == msg.sender,
            "ScratchVRF: INVALID_OWNER"
        );

        if (claimed[_tokenId] == true) {
            revert AlreadyClaimed();
        }

        _setClaimed(
            _tokenId
        );

        uint256 prizeWei = prizes[
            _tokenId
        ];

        uint256 balance = TOKEN_ADDRESS.balanceOf(
            address(this)
        );

        if (balance < prizeWei) {
            revert NotEnoughFunds();
        }

        TOKEN_ADDRESS.safeTransfer(
            msg.sender,
            prizeWei
        );

        emit PrizeClaimed(
            _tokenId,
            msg.sender,
            prizeWei
        );
    }

    function withdrawTokens()
        external
        onlyOwner
    {
        uint256 balance = TOKEN_ADDRESS.balanceOf(
            address(this)
        );

        TOKEN_ADDRESS.safeTransfer(
            msg.sender,
            balance
        );

        emit WithdrawTokens(
            msg.sender,
            balance
        );
    }
}
