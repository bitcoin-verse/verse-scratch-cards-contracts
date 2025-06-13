// SPDX-License-Identifier: -- BCOM --

pragma solidity ^0.8.20;

/**
 * @title DiscountHook (V3)
 * @notice This hook calculates a swap fee based on whether the user is eligible for any
 * configured token discount.
 * @dev It integrates with DiscountConfig_V3. It automatically checks the caller's
 * eligibility by triggering a bounded loop, removing the need for user-provided data.
 */

interface IDiscountConfig_V3 {
    function isEligible(
        address user
    )
        external
        view
        returns (bool);
}

contract DiscountHook_V3 {

    // --- State Variables ---

    IDiscountConfig_V3 public immutable config;

    uint256 public constant DEFAULT_FEE = 30E14;      // 0.3%
    uint256 public constant DISCOUNTED_FEE = 27E14;  // 0.27% (10% discount)

    // --- Constructor ---

    constructor(
        address _config
    ) {
        config = IDiscountConfig_V3(
            _config
        );
    }

    /**
     * @notice Balancer V3 hook entry point, called before every swap.
     * @dev It automatically checks if the `caller` is eligible for a discount by calling
     * the config contract. The return value is an ABI-encoded fee that the
     * Balancer vault will apply to the swap.
     * @param caller The address of the swapping user, provided by the Balancer Vault.
     * @return An ABI-encoded uint256 representing the calculated swap fee.
     */
    function beforeSwap(
        address caller,
        address, // tokenIn (unused)
        address, // tokenOut (unused)
        uint256, // amount (unused)
        bytes calldata // userData (unused)
    )
        external
        view
        returns (bytes memory)
    {
        bool eligible = config.isEligible(
            caller
        );

        uint256 fee = eligible
            ? DISCOUNTED_FEE
            : DEFAULT_FEE;

        return abi.encode(fee);
    }
}