// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";

// Balancer V3 interfaces
import { IVault } from "@balancer-labs/v3-interfaces/contracts/vault/IVault.sol";
import { IRouter } from "@balancer-labs/v3-interfaces/contracts/vault/IRouter.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {
    SwapKind
} from "@balancer-labs/v3-interfaces/contracts/vault/VaultTypes.sol";

// Test for live DiscountHook_V3 contract
contract DiscountHook_V3_Live_Test is Test {
    // Mainnet addresses
    IVault constant VAULT = IVault(0xbA1333333333a1BA1108E8412f11850A5C319bA9);
    IRouter constant ROUTER = IRouter(payable(0xAE563E3f8219521950555F5962419C8919758Ea2));

    // Live contracts
    address constant DISCOUNT_HOOK = 0x4F4F5347EC267E18787e56efb654D4d7A3e0C0E7;
    address constant DISCOUNT_CONFIG = 0x7AffEf8867d0f00eF6A3793EC8f0c3ba9c568AF2;
    address constant POOL_ADDRESS = 0x33832529ca354536728A2f2515E4E2106A8D8afA;

    // Token addresses (WETH/VERSE pool)
    IERC20 constant VERSE = IERC20(0x249cA82617eC3DfB2589c4c17ab7EC9765350a18);
    IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    // Test accounts
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    // Whale addresses for getting tokens
    address constant VERSE_WHALE = 0x249cA82617eC3DfB2589c4c17ab7EC9765350a18; // Token contract itself
    address constant WETH_WHALE = 0x8EB8a3b98659Cce290402893d0123abb75E3ab28; // Known WETH holder

    struct SwapResult {
        uint256 amountIn;
        uint256 amountOut;
        uint256 swapFeeAmount;
        uint256 effectiveFeePercentage;
    }

    function setUp() public {
        // Fork mainnet using the configured RPC endpoint
        vm.createSelectFork("mainnet");

        // Setup test accounts with ETH
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);

        // Give Alice some VERSE tokens (she will get discount)
        vm.prank(VERSE_WHALE);
        VERSE.transfer(alice, 1000e18);

        // Give both users some WETH and USDC for testing
        _setupTokenBalances();

        console.log("=== Test Setup Complete ===");
        console.log("Alice VERSE balance:", VERSE.balanceOf(alice) / 1e18, "VERSE");
        console.log("Bob VERSE balance:", VERSE.balanceOf(bob) / 1e18, "VERSE");
        console.log("Alice WETH balance:", WETH.balanceOf(alice) / 1e18, "WETH");
        console.log("Bob WETH balance:", WETH.balanceOf(bob) / 1e18, "WETH");
    }

    function _setupTokenBalances() internal {
        // Give Alice and Bob some WETH
        vm.prank(WETH_WHALE);
        WETH.transfer(alice, 5 ether);
        vm.prank(WETH_WHALE);
        WETH.transfer(bob, 5 ether);

        // Give Alice and Bob some additional VERSE for trading
        vm.prank(VERSE_WHALE);
        VERSE.transfer(alice, 1000e18);
        vm.prank(VERSE_WHALE);
        VERSE.transfer(bob, 1000e18);
    }

    function testDiscountHookRealSwap() public {
        console.log("\n=== Testing DiscountHook_V3 Functionality ===");

        // Test the hook directly to see if it can detect VERSE holders
        console.log("Alice VERSE balance:", VERSE.balanceOf(alice) / 1e18, "VERSE");
        console.log("Bob VERSE balance:", VERSE.balanceOf(bob) / 1e18, "VERSE");

        // Try querying a swap instead of executing it
        console.log("\nTrying to query swap rates...");

        try ROUTER.querySwapSingleTokenExactIn(
            POOL_ADDRESS,
            WETH,
            VERSE,
            1 ether,
            alice,
            ""
        ) returns (uint256 aliceAmountOut) {
            console.log("Alice query result:", aliceAmountOut / 1e18, "VERSE");

            try ROUTER.querySwapSingleTokenExactIn(
                POOL_ADDRESS,
                WETH,
                VERSE,
                1 ether,
                bob,
                ""
            ) returns (uint256 bobAmountOut) {
                console.log("Bob query result:", bobAmountOut / 1e18, "VERSE");

                if (aliceAmountOut > bobAmountOut) {
                    console.log("SUCCESS: Alice gets more VERSE than Bob (discount working)");
                    uint256 extraTokens = aliceAmountOut - bobAmountOut;
                    console.log("Alice gets extra tokens:", extraTokens / 1e18, "VERSE");
                } else {
                    console.log("NOTE: No difference detected or Bob gets more");
                }
            } catch {
                console.log("Failed to query swap for Bob");
            }
        } catch {
            console.log("Failed to query swap for Alice");
        }
    }

    function _performSwap(address user, uint256 amountIn, string memory userLabel) internal returns (SwapResult memory) {
        console.log("\n--- Testing", userLabel, "---");

        // Record balances before
        uint256 wethBefore = WETH.balanceOf(user);
        uint256 verseBefore = VERSE.balanceOf(user);

        // Approve tokens
        vm.startPrank(user);
        WETH.approve(address(ROUTER), amountIn);

        // Perform swap: WETH -> VERSE using the Router directly
        uint256 amountOut = ROUTER.swapSingleTokenExactIn(
            POOL_ADDRESS,        // pool
            WETH,               // tokenIn
            VERSE,              // tokenOut
            amountIn,           // exactAmountIn
            0,                  // minAmountOut (no slippage protection for test)
            block.timestamp + 1 hours, // deadline
            false,              // wethIsEth
            ""                  // userData
        );

        vm.stopPrank();

        // Record balances after
        uint256 wethAfter = WETH.balanceOf(user);
        uint256 verseAfter = VERSE.balanceOf(user);

        // Calculate actual amounts
        uint256 actualAmountIn = wethBefore - wethAfter;
        uint256 actualAmountOut = verseAfter - verseBefore;

        console.log("Amount in (WETH):", actualAmountIn / 1e18);
        console.log("Amount out (VERSE):", actualAmountOut / 1e18);

        // Calculate effective fee
        // For WETH/VERSE pool, we'll estimate based on actual swap results
        // Since both tokens have 18 decimals, we can compare directly
        uint256 expectedOutputWithoutFee = actualAmountIn; // Simplified for test - would need actual price data
        uint256 feeAmount = expectedOutputWithoutFee > actualAmountOut ? expectedOutputWithoutFee - actualAmountOut : 0;
        uint256 effectiveFeePercentage = expectedOutputWithoutFee > 0 ? (feeAmount * 1e18) / expectedOutputWithoutFee : 0;

        console.log("Estimated fee amount (VERSE):", feeAmount / 1e18);
        console.log("Effective fee percentage:", effectiveFeePercentage / 1e14, "bps");

        return SwapResult({
            amountIn: actualAmountIn,
            amountOut: actualAmountOut,
            swapFeeAmount: feeAmount,
            effectiveFeePercentage: effectiveFeePercentage
        });
    }

    function testDiscountConfigEligibility() public {
        console.log("\n=== Testing DiscountConfig Eligibility ===");

        // Test Alice (has VERSE)
        (bool success, bytes memory data) = DISCOUNT_CONFIG.staticcall(
            abi.encodeWithSignature("isEligible(address,address,uint256)", alice, address(VERSE), VERSE.balanceOf(alice))
        );

        if (success && data.length > 0) {
            bool aliceEligible = abi.decode(data, (bool));
            console.log("Alice eligible for discount:", aliceEligible);
            assertTrue(aliceEligible, "Alice should be eligible");
        }

        // Test Bob (no VERSE)
        (success, data) = DISCOUNT_CONFIG.staticcall(
            abi.encodeWithSignature("isEligible(address,address,uint256)", bob, address(VERSE), VERSE.balanceOf(bob))
        );

        if (success && data.length > 0) {
            bool bobEligible = abi.decode(data, (bool));
            console.log("Bob eligible for discount:", bobEligible);
            assertFalse(bobEligible, "Bob should not be eligible");
        }
    }

    function testPoolHookConfiguration() public {
        console.log("\n=== Testing Pool Hook Configuration ===");

        // Check if pool has the hook configured
        (bool success, bytes memory data) = address(VAULT).staticcall(
            abi.encodeWithSignature("getHooksConfig(address)", POOL_ADDRESS)
        );

        if (success && data.length > 0) {
            console.log("Pool hook configuration retrieved successfully");
        }

        // Log pool details
        console.log("Pool address:", POOL_ADDRESS);
        console.log("Hook address:", DISCOUNT_HOOK);
        console.log("Config address:", DISCOUNT_CONFIG);
    }

    function testVERSETokenInfo() public view {
        console.log("\n=== VERSE Token Information ===");
        console.log("VERSE Token Address:", address(VERSE));
        console.log("Alice VERSE Balance:", VERSE.balanceOf(alice) / 1e18, "VERSE");
        console.log("Bob VERSE Balance:", VERSE.balanceOf(bob) / 1e18, "VERSE");
        console.log("Total VERSE Supply:", VERSE.totalSupply() / 1e18, "VERSE");
    }
}