// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

error InvalidCost();
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

abstract contract CommonBase is Ownable, VRFConsumerBaseV2, ERC721Enumerable {

    using SafeERC20 for IERC20;
    using SafeERC20 for ILinkToken;

    VRFCoordinatorV2Interface public immutable VRF_COORDINATOR;

    // Verse Token contract for service.
    IERC20 public immutable VERSE_TOKEN;

    // Link Token contract for top-up.
    ILinkToken public immutable LINK_TOKEN;

    // Generated on deployment or passed as argument.
    uint64 public immutable SUBSCRIPTION_ID;

    // Chainlink VRF Key Hash for RNG requests.
    bytes32 public immutable GAS_KEYHASH;

    // For free giveaways maximum receivers is 50.
    uint32 public constant MAX_LOOPS = 50;

    // Number of confirmations needed for RNG request.
    uint16 public constant CONFIRMATIONS_NEEDED = 3;

    // Higher value means more gas for callback.
    uint32 public constant CALLBACK_MAX_GAS = 2000000;

    // How much to charge for base service.
    uint256 public baseCost;

    // Keeps track of latest drawId to VRF.
    uint256 public latestDrawId;

    mapping(uint256 => string) public tokenURIs;
    mapping(uint256 => uint256) public drawIdToRequestId;

    event DrawRequest(
        uint256 indexed drawId,
        uint256 indexed requestId,
        address indexed requestAddress
    );

    event RequestFulfilled(
        uint256 indexed drawId,
        uint256 indexed requestId,
        uint256[] indexed resultValue
    );

    event WithdrawTokens(
        address indexed receiver,
        uint256 amount
    );

    modifier onlyTokenOwner(
        uint256 _tokenId
    )
    {
        require(
            ownerOf(_tokenId) == msg.sender,
            "CommonBase: INVALID_OWNER"
        );
        _;
    }

    constructor(
        address _linkTokenAddress,
        address _verseTokenAddress,
        bytes32 _gasKeyHash,
        uint64 _subscriptionId,
        address _vrfCoordinatorV2Address
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

        SUBSCRIPTION_ID = _subscriptionId > 0
            ? _subscriptionId
            : _createNewSubscription();

        GAS_KEYHASH = _gasKeyHash;
    }

    function _createNewSubscription()
        private
        returns (uint64 newSubscriptionId)
    {
        newSubscriptionId = VRF_COORDINATOR.createSubscription();

        VRF_COORDINATOR.addConsumer(
            newSubscriptionId,
            address(this)
        );
    }

    function _requestRandomWords(
        uint32 _wordCount
    )
        internal
        returns (uint256 requestId)
    {
        requestId = VRF_COORDINATOR.requestRandomWords(
            GAS_KEYHASH,
            SUBSCRIPTION_ID,
            CONFIRMATIONS_NEEDED,
            CALLBACK_MAX_GAS,
            _wordCount
        );
    }

    /**
     * @notice Allows load {$LINK} tokens to subscription.
     * @dev Can be called with anyone, who wants to donate.
     * @param _linkAmount how much to load to subscription.
     */
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
    function changeBaseCost(
        uint256 _newBaseCost
    )
        external
        onlyOwner
    {
        if (_newBaseCost == 0) {
            revert InvalidCost();
        }

        if (_newBaseCost == baseCost) {
            revert InvalidCost();
        }

        baseCost = _newBaseCost;
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

    function _giveTokens(
        address _receiver,
        uint256 _amount
    )
        internal
    {
        VERSE_TOKEN.safeTransfer(
            _receiver,
            _amount
        );
    }

    function _takeTokens(
        uint256 _transferValue
    )
        internal
    {
        VERSE_TOKEN.safeTransferFrom(
            msg.sender,
            address(this),
            _transferValue
        );
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