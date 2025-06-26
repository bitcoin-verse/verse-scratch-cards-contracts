
// SPDX-License-Identifier: -- BCOM --

pragma solidity ^0.8.20;

// NOTE: These imports point to the Balancer V3 monorepo structure.
import { IVault } from "@balancer-labs/v3-interfaces/contracts/vault/IVault.sol";
import { BaseHooks } from "@balancer-labs/v3-vault/contracts/BaseHooks.sol";
import { VaultGuard } from "@balancer-labs/v3-vault/contracts/VaultGuard.sol";

import {
    HookFlags,
    PoolSwapParams,
    TokenConfig,
    LiquidityManagement
} from "@balancer-labs/v3-interfaces/contracts/vault/VaultTypes.sol";

interface ISenderGuard {

    function getSender()
        external
        view
        returns (address);
}

interface IDiscountConfig {

    function isEligible(
        address user
    )
        external
        view
        returns (bool);
}

/**
 * @title DiscountHook (V3) - Balancer V3 Compliant
 * @notice This hook calculates a dynamic swap fee for a Balancer V3 pool.
 * @dev This contract is fully compliant with the Balancer V3 hook standard. It applies a
 * 10% discount if the user is eligible. It now correctly uses the onComputeDynamicSwapFeePercentage
 * signature and securely determines the user's address via a trusted router.
 */
contract DiscountHook_V3 is BaseHooks, VaultGuard {

    // --- State Variables ---

    IDiscountConfig public immutable config;
    address public immutable trustedRouter;
    uint256 public constant DISCOUNT_FACTOR = 90; // 100% - 10% discount

    // --- Constructor ---

    constructor(
        IVault _vault,
        address _config,
        address _trustedRouter
    )
        VaultGuard(_vault)
    {
        config = IDiscountConfig(
            _config
        );

        trustedRouter = _trustedRouter;
    }

    // --- Balancer V3 Hook Standard Functions ---

    function getHookFlags()
        public
        pure
        override
        returns (HookFlags memory)
    {
        HookFlags memory flags;
        flags.shouldCallComputeDynamicSwapFee = true;
        return flags;
    }

    function onRegister(
        address, // factory
        address, // pool
        TokenConfig[] memory,
        LiquidityManagement calldata
    )
        public
        view
        override
        onlyVault
        returns (bool)
    {
        return true;
    }

    /**
     * @notice Dynamically calculates the swap fee percentage for the current swap.
     * @dev This function now uses the correct signature from the Balancer V3 IHooks interface.
     * It securely gets the user's address by calling `getSender()` on the trusted router
     * that is passed via the swap parameters.
     * @param params Swap parameters, which include the router address.
     * @param staticSwapFeePercentage The pool's currently configured static swap fee.
     * @return The new swap fee percentage to be applied to the swap.
     */
    function onComputeDynamicSwapFeePercentage(
        PoolSwapParams calldata params,
        address, // pool (unused in this hook)
        uint256 staticSwapFeePercentage
    )
        public
        override
        view
        returns (
            bool,
            uint256
        )
    {
        // Security check: Only allow calls from the trusted router.
        if (params.router != trustedRouter) {
            return (false, 0); // Do not apply a dynamic fee
        }

        // Securely get the original user's address from the trusted router.
        address user = ISenderGuard(
            params.router
        ).getSender();

        bool eligible = config.isEligible(
            user
        );

        uint256 dynamicFee;
        if (eligible) {
            // Apply a 10% discount.
            dynamicFee = (staticSwapFeePercentage * DISCOUNT_FACTOR) / 100;
        } else {
            // If not eligible, return the pool's original fee.
            dynamicFee = staticSwapFeePercentage;
        }

        return (
            true,
            dynamicFee
        );
    }
}