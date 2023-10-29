// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "forge-std/Test.sol";

import "../ScratchVRF.sol";

contract TestScratchVRF_MAINNET is Test {

    uint256 constant FORK_MAINNET_BLOCK = 18_456_485;

    ScratchVRF public scratcher;
    uint256 constant TICKET_COST = 3_000 * 1E18;

    address constant LINK_TOKEN = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant VERSE_TOKEN = 0x249cA82617eC3DfB2589c4c17ab7EC9765350a18;

    address constant VRD_COORDINATOR = 0x271682DEB8C4E0901D1a1550aD2e64D568E69909;
    bytes32 constant GAS_KEY_HASH = 0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef;

    function setUp()
        public
    {
        vm.createSelectFork(
            vm.rpcUrl("mainnet"),
            FORK_MAINNET_BLOCK
        );

        scratcher = new ScratchVRF(
            "ScratchVRF",
            "SVRF",
            VRD_COORDINATOR,
            TICKET_COST,
            LINK_TOKEN,
            VERSE_TOKEN,
            GAS_KEY_HASH
        );
    }

    function testSomething()
        public
    {
        uint256 initialCost = scratcher.ticketCost();
        uint256 newCost = 1_000 * 1E18;

        assertEq(
            initialCost,
            TICKET_COST
        );

        scratcher.changeTicketCost(
            newCost
        );

        uint256 updatedCost = scratcher.ticketCost();

        assertEq(
            updatedCost,
            newCost
        );
    }
}
