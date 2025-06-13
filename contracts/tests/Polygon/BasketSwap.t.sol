// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../BasketSwap.sol";
import "../../IERC721.sol";

interface IWETH9 {
    function deposit() external payable;
    function withdraw(uint wad) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract TestBasketSwap is Test {
    // Contract instance
    BasketSwap public basketSwap;

    // Addresses for Polygon mainnet
    address public constant VERSE_TOKEN = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;
    address public constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
    address public constant USDC = 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174;
    address public constant WBTC = 0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6;
    address public constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
    address public constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;

    // Uniswap router addresses for Polygon
    address public constant QUICKSWAP_ROUTER = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff; // Uniswap V2 compatible
    address public constant UNISWAP_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    // Test account with funds on Polygon
    address public constant WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC; // Binance hot wallet with tokens

    // Test parameters
    uint256 public constant SWAP_AMOUNT = 100 * 1e18; // 100 VERSE tokens
    uint256 public constant MIN_AMOUNT_OUT = 1; // Minimal amount for tests
    uint256 public DEADLINE;

    function setUp() public {
        // Fork Polygon mainnet
        vm.createSelectFork("polygon");
        console.log("Using Polygon mainnet fork");

        // Set deadline for tests - far in the future to avoid "Transaction too old"
        DEADLINE = block.timestamp + 100 days;

        // Deploy BasketSwap contract
        address[5] memory outputTokens = [WETH, USDC, WBTC, WMATIC, DAI];
        basketSwap = new BasketSwap(
            VERSE_TOKEN,
            outputTokens,
            QUICKSWAP_ROUTER,
            UNISWAP_V3_ROUTER
        );

        // Impersonate whale account to get tokens
        vm.startPrank(WHALE);

        // Deal VERSE tokens to the WHALE account for testing
        deal(VERSE_TOKEN, WHALE, SWAP_AMOUNT * 10);

        // Deal some MATIC to the WHALE for native tests
        vm.deal(WHALE, 10 ether);

        // Pre-approve tokens to avoid "Transaction too old" errors
        vm.startPrank(WHALE);
        IERC20(VERSE_TOKEN).approve(address(basketSwap), type(uint256).max);
        vm.stopPrank();
    }

    function testBasketSwapV2ERC20() public {
        vm.startPrank(WHALE);

        // Prepare swap parameters
        uint256[5] memory amountsToSwap;
        for (uint256 i = 0; i < 5; i++) {
            amountsToSwap[i] = SWAP_AMOUNT / 5; // 20% to each token
        }

        uint256[5] memory minAmountsOut;
        for (uint256 i = 0; i < 5; i++) {
            minAmountsOut[i] = MIN_AMOUNT_OUT; // Minimal amount for test
        }

        // Execute basket swap using V2
        basketSwap.basketSwapV2ERC20(
            SWAP_AMOUNT,
            amountsToSwap,
            minAmountsOut,
            DEADLINE
        );

        // If we get here without reverting, the test passes
        assertTrue(true, "BasketSwapV2ERC20 should not revert");

        vm.stopPrank();
    }

    function testBasketSwapV3ERC20() public {
        vm.startPrank(WHALE);

        // Prepare swap parameters
        uint256[5] memory amountsToSwap;
        for (uint256 i = 0; i < 5; i++) {
            amountsToSwap[i] = SWAP_AMOUNT / 5; // 20% to each token
        }

        uint256[5] memory minAmountsOut;
        for (uint256 i = 0; i < 5; i++) {
            minAmountsOut[i] = MIN_AMOUNT_OUT; // Minimal amount for test
        }

        uint24[5] memory feeTiers;
        for (uint256 i = 0; i < 5; i++) {
            feeTiers[i] = 3000; // 0.3% fee tier
        }

        // Execute basket swap using V3
        basketSwap.basketSwapV3ERC20(
            SWAP_AMOUNT,
            amountsToSwap,
            minAmountsOut,
            feeTiers,
            DEADLINE
        );

        // If we get here without reverting, the test passes
        assertTrue(true, "BasketSwapV3ERC20 should not revert");

        vm.stopPrank();
    }

    function testBasketSwapMixedERC20() public {
        vm.startPrank(WHALE);

        // Prepare swap parameters
        uint256[5] memory amountsToSwap;
        for (uint256 i = 0; i < 5; i++) {
            amountsToSwap[i] = SWAP_AMOUNT / 5; // 20% to each token
        }

        uint256[5] memory minAmountsOut;
        for (uint256 i = 0; i < 5; i++) {
            minAmountsOut[i] = MIN_AMOUNT_OUT; // Minimal amount for test
        }

        BasketSwap.DexVersion[5] memory dexVersions;
        uint24[5] memory feeTiers;
        dexVersions[0] = BasketSwap.DexVersion.V2; // WETH on V2
        dexVersions[1] = BasketSwap.DexVersion.V3; // USDC on V3
        feeTiers[1] = 500; // 0.05% for USDC
        dexVersions[2] = BasketSwap.DexVersion.V2; // WBTC on V2
        dexVersions[3] = BasketSwap.DexVersion.V3; // WMATIC on V3
        feeTiers[3] = 3000; // 0.3% for WMATIC
        dexVersions[4] = BasketSwap.DexVersion.V2; // DAI on V2

        // Execute basket swap
        basketSwap.basketSwapMixedERC20(
            SWAP_AMOUNT,
            amountsToSwap,
            minAmountsOut,
            dexVersions,
            feeTiers,
            DEADLINE
        );

        // If we get here without reverting, the test passes
        assertTrue(true, "BasketSwapMixedERC20 should not revert");

        vm.stopPrank();
    }

    function testBasketSwapV2Native() public {
        // Create a fresh Polygon fork for this test
        vm.createSelectFork("polygon");
        console.log("Using fresh Polygon mainnet fork for V2 Native test");

        // Set deadline for tests - far in the future to avoid "Transaction too old"
        DEADLINE = block.timestamp + 100 days;

        // Deploy BasketSwap contract
        address[5] memory outputTokens = [WETH, USDC, WBTC, WMATIC, DAI];
        basketSwap = new BasketSwap(
            address(0), // Native input
            outputTokens,
            QUICKSWAP_ROUTER,
            UNISWAP_V3_ROUTER
        );

        // Impersonate whale account to get funds
        vm.startPrank(WHALE);
        vm.deal(WHALE, 10 ether);

        uint256 initialMaticBalance = WHALE.balance;
        uint256[5] memory initialTokenBalances;
        for (uint256 i = 0; i < 5; i++) {
            if (outputTokens[i] != address(0)) {
                initialTokenBalances[i] = IERC20(outputTokens[i]).balanceOf(WHALE);
            }
        }

        console.log("Initial MATIC balance:", initialMaticBalance / 1e18, "MATIC");

        // Prepare swap parameters - use smaller amounts to ensure success
        uint256 totalSwapAmount = 0.01 ether; // 0.01 MATIC
        // Only swap for tokens with good liquidity
        uint256[5] memory amountsToSwap;
        amountsToSwap[0] = totalSwapAmount / 4; // WETH
        amountsToSwap[1] = totalSwapAmount / 4; // USDC
        amountsToSwap[2] = totalSwapAmount / 4; // WBTC
        amountsToSwap[3] = 0; // WMATIC - skip self-swap
        amountsToSwap[4] = totalSwapAmount / 4; // DAI

        uint256[5] memory minAmountsOut;
        for (uint256 i = 0; i < 5; i++) {
            // Set min output to 0 if input is 0, otherwise set to a minimal amount
            minAmountsOut[i] = amountsToSwap[i] > 0 ? MIN_AMOUNT_OUT : 0;
        }

        // Execute basket swap using V2 with native currency
        basketSwap.basketSwapV2Native{value: totalSwapAmount}(
            totalSwapAmount,
            amountsToSwap,
            minAmountsOut,
            DEADLINE
        );

        uint256 finalMaticBalance = WHALE.balance;
        uint256[5] memory finalTokenBalances;
        for (uint256 i = 0; i < 5; i++) {
            if (outputTokens[i] != address(0)) {
                finalTokenBalances[i] = IERC20(outputTokens[i]).balanceOf(WHALE);
            }
        }

        console.log("Final MATIC balance:", finalMaticBalance / 1e18, "MATIC");

        // Assert MATIC was spent
        assertLt(finalMaticBalance, initialMaticBalance, "MATIC balance should decrease");

        // Assert at least some tokens were received
        bool anyTokenReceived = false;
        for (uint256 i = 0; i < 5; i++) {
            // Skip checking WMATIC since we are not swapping for it
            if (i == 3) continue;
            if (outputTokens[i] != address(0) && finalTokenBalances[i] > initialTokenBalances[i]) {
                anyTokenReceived = true;
                console.log(
                    "Received token",
                    i,
                    "amount:",
                    finalTokenBalances[i] - initialTokenBalances[i]
                );
            }
        }

        assertTrue(anyTokenReceived, "Should have received at least one token");

        vm.stopPrank();
    }

    function testSetInputToken() public {
        address newInputToken = WMATIC;

        // Only owner can set input token
        vm.prank(address(1)); // Non-owner address
        vm.expectRevert("Ownable: caller is not the owner");
        basketSwap.setInputToken(newInputToken);

        // Owner can set input token
        vm.prank(address(this)); // Test contract is the owner
        basketSwap.setInputToken(newInputToken);

        // Verify input token was updated
        assertEq(basketSwap.inputToken(), newInputToken);
    }

    function testSetOutputTokens() public {
        address[5] memory newOutputTokens = [
            DAI,
            WETH,
            USDC,
            WBTC,
            WMATIC
        ];

        // Only owner can set output tokens
        vm.prank(address(1)); // Non-owner address
        vm.expectRevert("Ownable: caller is not the owner");
        basketSwap.setOutputTokens(newOutputTokens);

        // Owner can set output tokens
        vm.prank(address(this)); // Test contract is the owner
        basketSwap.setOutputTokens(newOutputTokens);

        // Verify output tokens were updated
        for (uint256 i = 0; i < 5; i++) {
            assertEq(basketSwap.outputTokens(i), newOutputTokens[i]);
        }
    }

    function testWithdrawTokens() public {
        // Send some tokens to the contract
        vm.startPrank(WHALE);
        uint256 amount = 1e18;

        // Transfer tokens to the contract
        IERC20(VERSE_TOKEN).transfer(address(basketSwap), amount);

        vm.stopPrank();

        // Non-owner cannot withdraw
        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        basketSwap.withdrawTokens(VERSE_TOKEN, amount);

        // Owner can withdraw
        uint256 initialBalance = IERC20(VERSE_TOKEN).balanceOf(address(this));

        vm.prank(address(this));
        basketSwap.withdrawTokens(VERSE_TOKEN, amount);

        uint256 finalBalance = IERC20(VERSE_TOKEN).balanceOf(address(this));
        assertEq(finalBalance, initialBalance + amount, "Owner should receive withdrawn tokens");
    }

    function testWithdrawEther() public {
        // Send some ETH to the contract
        vm.deal(address(basketSwap), 1 ether);

        // Non-owner cannot withdraw
        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        basketSwap.withdrawEther();

        // Owner can withdraw
        uint256 initialBalance = address(this).balance;

        vm.prank(address(this));
        basketSwap.withdrawEther();

        uint256 finalBalance = address(this).balance;
        assertEq(finalBalance, initialBalance + 1 ether, "Owner should receive withdrawn ETH");
    }

    // Helper function to get a token balance
    function _getTokenBalance(address token, address account) internal view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }

    // Receive function to accept ETH
    receive() external payable {}
}
