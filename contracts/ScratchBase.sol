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
    // Verse Token contract.
    IERC20 public immutable VERSE_TOKEN;

    // Link Token contract.
    ILinkToken public immutable LINK_TOKEN;

    // Chainlink VRF Key Hash for RNG requests.
    bytes32 public immutable GAS_KEYHASH;

    // Automatically generated on deployment.
    uint64 public immutable SUBSCRIPTION_ID;

    // For free giveaways maximum receivers is 50.
    uint32 public constant MAX_LOOPS = 50;

    // Higher value means more gas for callback.
    uint32 public constant CALLBACK_MAX_GAS = 2000000;

    // Number of confirmations needed for RNG request.
    uint16 public constant CONFIRMATIONS_NEEDED = 3;

    // Number of words in RNG request.
    uint32 public constant NUM_WORDS = 2;

    uint256 public drawCount;
    uint256 public ticketCost;
    uint256 public latestTicketId;

    uint256[] private _randomNumbers;

    mapping(uint256 => uint256) public drawIdToRequestId;
    mapping(uint256 => Drawing) public requestIdToDrawing;

    // Chainlink VRF Coordinator for RNG requests.
    VRFCoordinatorV2Interface public immutable VRF_COORDINATOR;

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
