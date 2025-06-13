// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "forge-std/Script.sol";
import "../FlexibleDrawVRF.sol";

contract DeployFlexibleDrawVRF is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(
            vm.envUint("PRIVATE_KEY")
        );

        // VRF Coordinator address on Polygon
        address vrfCoordinatorV2Address = 0xAE975071Be8F8eE67addBC1A82488F1C24858067;

        // Standard cost for a ticket in Verse tokens (e.g., 30 VERSE)
        uint256 standardCost = 22_000 * 1E18;

        // Minimum deposit amount in Verse tokens (e.g., 10 VERSE)
        uint256 minimumDeposit = 1000 * 1E18;

        // LINK token address on Polygon
        address linkTokenAddress = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;

        // VERSE token address on Polygon
        address verseTokenAddress = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;

        // VRF gas key hash for Polygon
        // bytes32 gasKeyHash = 0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd;
        bytes32 gasKeyHash = 0x6e099d640cde6de9d40ac749b4b594126b0169747122711109c9985d47751f93;

        // VRF subscription ID (you'll need to create this on Chainlink VRF)
        uint64 subscriptionId = 1274; // Replace with your actual subscription ID

        // Scratcher NFT contract address (replace with your actual address)
        address scratcherNFT = 0xaE16fca128D5A27C738419674a0EbA886E170595; // Replace with actual address

        // Voyager NFT contract address (replace with your actual address)
        address voyagerNFT = 0x0000000000000000000000000000000000000000; // Replace with actual address

        // Cost of one Scratcher NFT in Verse tokens (e.g., 5 VERSE)
        uint256 scratcherCost = 22_000 * 1E18;

        // Cost of one Voyager NFT in Verse tokens (e.g., 10 VERSE)
        uint256 voyagerCost = 22_000 * 1E18;

        FlexibleDrawVRF flexibleDraw = new FlexibleDrawVRF(
            vrfCoordinatorV2Address,
            standardCost,
            minimumDeposit,
            linkTokenAddress,
            verseTokenAddress,
            gasKeyHash,
            subscriptionId,
            scratcherNFT,
            voyagerNFT,
            scratcherCost,
            voyagerCost
        );

        console.log(
            address(flexibleDraw),
            "flexibleDraw"
        );

        vm.stopBroadcast();
    }
}
