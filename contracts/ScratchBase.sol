// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "./PrizeTiers.sol";
import "./ScratchNFT.sol";

error InvalidCost();
error AlreadyClaimed();
error NotEnoughFunds();
error TooManyReceivers();

interface ILinkToken is IERC20 {

    function transferAndCall(
        address _to,
        uint256 _value,
        bytes calldata _data
    )
        external
        returns (bool success);
}

abstract contract ScratchBase is
    VRFConsumerBaseV2,
    Ownable,
    ScratchNFT,
    PrizeTiers
{
    VRFCoordinatorV2Interface public immutable VRF_COORDINATOR;

    uint64 immutable public SUBSCRIPTION_ID; // = 951;

    uint32 constant public MAX_LOOPS = 50;
    uint32 constant public CALLBACK_MAX_GAS = 2000000;
    uint16 constant public CONFIRMATIONS_NEEDED = 3;

    // Polygon: 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc
    IERC20 immutable public VERSE_TOKEN;

    // Polygon:
    ILinkToken immutable public LINK_TOKEN;

    // Polygon: 0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd
    bytes32 immutable public GAS_KEYHASH;

    uint256 public ticketCost;
    uint256 public latestTicketId;

    uint256[] private _randomNumbers;

    uint256 public drawCount;

    mapping(uint256 => uint256) public drawIdToRequestId;
    mapping(uint256 => Drawing) public requestIdToDrawing;

    struct Drawing {
        uint256 drawId;
        address ticketReceiver;
    }

    event PrizeClaimed(
        uint256 indexed ticketId,
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
        address _linkTokenAddress,
        address _verseTokenAddress,
        bytes32 _gasKeyHash
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
            _verseTokenAddress
        );

        LINK_TOKEN = ILinkToken(
            _linkTokenAddress
        );

        VRF_COORDINATOR = VRFCoordinatorV2Interface(
            _vrfCoordinatorV2Address
        );

        GAS_KEYHASH = _gasKeyHash;

        SUBSCRIPTION_ID = VRF_COORDINATOR.createSubscription();

        VRF_COORDINATOR.addConsumer(
            SUBSCRIPTION_ID,
            address(this)
        );

        ticketCost = _ticketCost;
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
