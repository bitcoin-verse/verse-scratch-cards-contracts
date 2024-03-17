// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

import "forge-std/Script.sol";

import "../ReelVRF.sol";

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
