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

    uint64 immutable public SUBSCRIPTION_ID; // = 951;
    uint32 immutable public CALLBACK_MAX_GAS; // = 2000000;
    uint16 immutable public CONFIRMATIONS_NEEDED; //  = 3;

    // Polygon: 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc
    IERC20 immutable public VERSE_TOKEN;

    // Polygon: 0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd
    bytes32 immutable public GAS_KEYHASH;

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
     * @notice Allows to purchase scratch ticket
     */
    function buyScratchTicket()
        external
    {
        _newScratchTicket(
            msg.sender
        );
    }

    /**
     * @notice Allows to gift scratch ticket
     * @param _receiver address that receives NFT
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
            _tokenId,
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
}
