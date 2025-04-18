// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "forge-std/Script.sol";

import "../ReelVRF.sol";
import "../ScratchVRF.sol";
// import "../TicketRouter.sol";
import "../TicketRouterV3.sol";

contract DeployReelVRF is Script {

    function setUp() public {}

    function run() public {

        vm.startBroadcast(
            vm.envUint("PRIVATE_KEY")
        );

        ReelVRF reel = new ReelVRF(
            "VerseVoyagers",
            "VV",
            0xAE975071Be8F8eE67addBC1A82488F1C24858067,
            3000000000000000000000,
            0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39,
            0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc,
            0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd,
            951
        );

        console.log(
            address(reel),
            "reel"
        );

        vm.stopBroadcast();
    }
}

contract DeployScratchVRF is Script {

    function setUp() public {}

    function run() public {

        vm.startBroadcast(
            vm.envUint("PRIVATE_KEY")
        );

        ScratchVRF scratch = new ScratchVRF(
            "ScratchEarthDay",
            "SVRF-EARTH-D",
            0xAE975071Be8F8eE67addBC1A82488F1C24858067,
            3000000000000000000000,
            0xb0897686c545045aFc77CF20eC7A532E3120E0F1,
            0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc,
            0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd,
            0
        );

        console.log(
            address(scratch),
            "scratch"
        );

        vm.stopBroadcast();
    }
}

/*
contract DeployTicketRouter is Script {

    function setUp() public {}

    function run() public {

        vm.startBroadcast(
            vm.envUint("PRIVATE_KEY")
        );

        address weth = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;
        address verseToken = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;

        TicketRouter ticketRouter = new TicketRouter(
            weth,
            verseToken
        );

        console.log(
            address(ticketRouter),
            "ticketRouter"
        );

        vm.stopBroadcast();
    }
}
*/

contract DeployTicketRouterV3 is Script {

    function setUp() public {}

    function run() public {

        vm.startBroadcast(
            vm.envUint("PRIVATE_KEY")
        );

        // The correct WETH address on Polygon (not WMATIC)
        address weth = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619;
        address verseToken = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;
        address swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564; // Uniswap V3 SwapRouter
        address quoter = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6; // Uniswap V3 Quoter

        // Deploy the contract with the correct WETH address
        // Note: WMATIC is defined as a constant in the contract (0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270)
        TicketRouterV3 ticketRouterV3 = new TicketRouterV3(
            weth,
            verseToken,
            swapRouter,
            quoter
        );

        console.log(
            address(ticketRouterV3),
            "ticketRouterV3"
        );

        vm.stopBroadcast();
    }
}