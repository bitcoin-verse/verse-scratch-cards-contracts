// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./CommonVRF.sol";
import "./PrizeTiers.sol";
import "./ScratchNFT.sol";

error InvalidCost();
error AlreadyClaimed();
error NotEnoughFunds();
error TooManyReceivers();

abstract contract ScratchBase is CommonVRF, ScratchNFT, PrizeTiers {

    // For free giveaways maximum receivers is 50.
    uint32 public constant MAX_LOOPS = 50;

    // Number of words in RNG request.
    uint32 public constant NUM_WORDS = 2;

    uint256 public drawCount;
    uint256 public ticketCost;
    uint256 public latestTicketId;

    uint256[] private _randomNumbers;

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
        uint256 indexed result
    );

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
        ScratchNFT(
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
        ticketCost = _ticketCost;
    }

    function _createNewSubscription()
        internal
        returns (uint64 newSubscriptionId)
    {
        newSubscriptionId = VRF_COORDINATOR.createSubscription();

        VRF_COORDINATOR.addConsumer(
            newSubscriptionId,
            address(this)
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

    /**
     * @notice Allows to avoid modulo bias for RNG.
     * @param _entropy random value passed from VRF.
     * @param _upperBound maximum outcome for {_entropy}.
    */
    function uniform(
        uint256 _entropy,
        uint256 _upperBound
    )
        public
        pure
        returns (uint256)
    {
        uint256 min = (type(uint256).max - _upperBound + 1)
            % _upperBound;

        uint256 random = _entropy;

        while (true) {
            if (random >= min) {
                break;
            }

            random = uint256(
                keccak256(
                    abi.encodePacked(
                        random
                    )
                )
            );
        }

        return random
            % _upperBound
            + 1;
    }
}
