// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "forge-std/Script.sol";
import "../BasketSwap.sol";

contract DeployBasketSwap is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(
            vm.envUint("PRIVATE_KEY")
        );

        // Input token - VERSE token on Polygon
        // Use address(0) for native token (MATIC) or specify an ERC20 token
        address inputToken = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc; // VERSE token on Polygon

        // Output tokens - array of 5 tokens that users can swap into
        address[5] memory outputTokens = [
            0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619, // WETH on Polygon
            0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174, // USDC on Polygon
            0x1BFD67037B42Cf73acF2047067bd4F2C47D9BfD6, // WBTC on Polygon
            0xc2132D05D31c914a87C6611C10748AEb04B58e8F, // USDT on Polygon
            0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063  // DAI on Polygon
        ];

        // Uniswap V2 Router address on Polygon (QuickSwap)
        address uniswapV2Router = 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;

        // Uniswap V3 Router address on Polygon
        address uniswapV3Router = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

        // Deploy BasketSwap contract (WETH address will be read from V2 router)
        BasketSwap basketSwap = new BasketSwap(
            inputToken,
            outputTokens,
            uniswapV2Router,
            uniswapV3Router
        );

        console.log(
            address(basketSwap),
            "BasketSwap deployed at:"
        );

        vm.stopBroadcast();
    }
}
