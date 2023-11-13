// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

interface ILinkToken is IERC20 {

    function transferAndCall(
        address _to,
        uint256 _value,
        bytes calldata _data
    )
        external
        returns (bool success);
}

abstract contract CommonVRF is Ownable, VRFConsumerBaseV2 {

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

    // Number of confirmations needed for RNG request.
    uint16 public constant CONFIRMATIONS_NEEDED = 3;

    // Higher value means more gas for callback.
    uint32 public constant CALLBACK_MAX_GAS = 2000000;

    event WithdrawTokens(
        address indexed receiver,
        uint256 amount
    );

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