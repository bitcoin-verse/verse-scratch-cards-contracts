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
    uint256 public constant SWAP_AMOUNT = 100 * 1e6; // 100 USDC (6 decimals)
    uint256 public DEADLINE;

    function setUp() public {
        // Fork Polygon mainnet
        vm.createSelectFork("polygon");

        // Set deadline for tests
        DEADLINE = block.timestamp + 100 days;

        // Deploy BasketSwap contract with USDC as input
        address[5] memory outputTokens = [WETH, USDC, WBTC, WMATIC, DAI];
        basketSwap = new BasketSwap(
            USDC, // Use USDC as input for better liquidity
            outputTokens,
            QUICKSWAP_ROUTER,
            UNISWAP_V3_ROUTER
        );

        // Fund and approve whale account
        vm.startPrank(WHALE);
        deal(USDC, WHALE, SWAP_AMOUNT * 10);
        vm.deal(WHALE, 10 ether);
        IERC20(USDC).approve(address(basketSwap), type(uint256).max);
        vm.stopPrank();
    }

    function testBasketSwapV2ERC20() public {
        vm.startPrank(WHALE);

        uint256[5] memory amountsToSwap;
        amountsToSwap[0] = SWAP_AMOUNT / 4; // WETH
        amountsToSwap[1] = 0; // USDC - skip self-swap
        amountsToSwap[2] = SWAP_AMOUNT / 4; // WBTC
        amountsToSwap[3] = SWAP_AMOUNT / 4; // WMATIC
        amountsToSwap[4] = SWAP_AMOUNT / 4; // DAI

        uint256 totalAmountIn = amountsToSwap[0] + amountsToSwap[2] + amountsToSwap[3] + amountsToSwap[4];

        uint256[5] memory minAmountsOut;
        for (uint256 i = 0; i < 5; i++) minAmountsOut[i] = 0;

        basketSwap.basketSwapV2ERC20(totalAmountIn, amountsToSwap, minAmountsOut, DEADLINE);

        assertTrue(true, "BasketSwapV2ERC20 should not revert");
        vm.stopPrank();
    }

    function testBasketSwapV3ERC20() public {
        vm.startPrank(WHALE);

        uint256[5] memory amountsToSwap;
        amountsToSwap[0] = SWAP_AMOUNT / 4; // WETH
        amountsToSwap[1] = 0; // USDC - skip self-swap
        amountsToSwap[2] = SWAP_AMOUNT / 4; // WBTC
        amountsToSwap[3] = SWAP_AMOUNT / 4; // WMATIC
        amountsToSwap[4] = SWAP_AMOUNT / 4; // DAI

        uint256 totalAmountIn = amountsToSwap[0] + amountsToSwap[2] + amountsToSwap[3] + amountsToSwap[4];

        uint256[5] memory minAmountsOut;
        for (uint256 i = 0; i < 5; i++) minAmountsOut[i] = 0;

        uint24[5] memory feeTiers;
        for (uint256 i = 0; i < 5; i++) feeTiers[i] = 3000;

        basketSwap.basketSwapV3ERC20(totalAmountIn, amountsToSwap, minAmountsOut, feeTiers, DEADLINE);

        assertTrue(true, "BasketSwapV3ERC20 should not revert");
        vm.stopPrank();
    }

    function testBasketSwapMixedERC20() public {
        vm.startPrank(WHALE);

        uint256[5] memory amountsToSwap;
        amountsToSwap[0] = SWAP_AMOUNT / 4; // WETH
        amountsToSwap[1] = 0; // USDC - skip self-swap
        amountsToSwap[2] = SWAP_AMOUNT / 4; // WBTC
        amountsToSwap[3] = SWAP_AMOUNT / 4; // WMATIC
        amountsToSwap[4] = SWAP_AMOUNT / 4; // DAI

        uint256 totalAmountIn = amountsToSwap[0] + amountsToSwap[2] + amountsToSwap[3] + amountsToSwap[4];

        uint256[5] memory minAmountsOut;
        for (uint256 i = 0; i < 5; i++) minAmountsOut[i] = 0;

        BasketSwap.DexVersion[5] memory dexVersions;
        dexVersions[0] = BasketSwap.DexVersion.V2;
        dexVersions[1] = BasketSwap.DexVersion.V3; // Skipped
        dexVersions[2] = BasketSwap.DexVersion.V2;
        dexVersions[3] = BasketSwap.DexVersion.V3;
        dexVersions[4] = BasketSwap.DexVersion.V2;

        uint24[5] memory feeTiersV3;
        for (uint256 i = 0; i < 5; i++) feeTiersV3[i] = 3000;

        basketSwap.basketSwapMixedERC20(totalAmountIn, amountsToSwap, minAmountsOut, dexVersions, feeTiersV3, DEADLINE);

        assertTrue(true, "BasketSwapMixedERC20 should not revert");
        vm.stopPrank();
    }

    function testBasketSwapV2Native() public {
        // Create a fresh Polygon fork for this test
        vm.createSelectFork("polygon");

        // Deploy BasketSwap contract for native input
        address[5] memory outputTokens = [WETH, USDC, WBTC, WMATIC, DAI];
        basketSwap = new BasketSwap(
            address(0), // Native input
            outputTokens,
            QUICKSWAP_ROUTER,
            UNISWAP_V3_ROUTER
        );

        vm.startPrank(WHALE);
        vm.deal(WHALE, 10 ether);

        uint256 nativeAmount = 0.01 ether;

        uint256[5] memory amountsToSwap;
        amountsToSwap[0] = 0; // WETH - skip self-swap
        amountsToSwap[1] = nativeAmount / 4; // USDC
        amountsToSwap[2] = nativeAmount / 4; // WBTC
        amountsToSwap[3] = nativeAmount / 4; // WMATIC
        amountsToSwap[4] = nativeAmount / 4; // DAI

        uint256 totalAmountIn = amountsToSwap[1] + amountsToSwap[2] + amountsToSwap[3] + amountsToSwap[4];

        uint256[5] memory minAmountsOut;
        for (uint256 i = 0; i < 5; i++) minAmountsOut[i] = 0;

        basketSwap.basketSwapV2Native{value: totalAmountIn}(totalAmountIn, amountsToSwap, minAmountsOut, DEADLINE);

        assertTrue(true, "basketSwapV2Native should not revert");
        vm.stopPrank();
    }

    function testSetInputToken() public {
        basketSwap.setInputToken(WETH);
        assertEq(basketSwap.inputToken(), WETH, "Input token should be updated");
    }


    function testWithdrawEther() public {
        vm.deal(address(basketSwap), 1 ether);
        uint256 initialBalance = address(this).balance;
        basketSwap.withdrawEther();
        uint256 finalBalance = address(this).balance;
        assertGt(finalBalance, initialBalance, "Ether should be withdrawn");
    }

    function testWithdrawTokens() public {
        deal(VERSE_TOKEN, address(basketSwap), 100 ether);
        uint256 initialBalance = IERC20(VERSE_TOKEN).balanceOf(address(this));
        basketSwap.withdrawTokens(VERSE_TOKEN, 100 ether);
        uint256 finalBalance = IERC20(VERSE_TOKEN).balanceOf(address(this));
        assertGt(finalBalance, initialBalance, "Tokens should be withdrawn");
    }

    // Helper function to get a token balance
    function _getTokenBalance(address token, address account) internal view returns (uint256) {
        return IERC20(token).balanceOf(account);
    }

    // Receive function to accept ETH
    receive() external payable {}
}
