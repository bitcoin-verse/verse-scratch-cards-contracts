// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "forge-std/Test.sol";

import "../ScratchVRF.sol";

contract TestScratchVRF_POLYGON is Test {

    uint256 constant FORK_POLYGON_BLOCK = 49_296_033;

    ScratchVRF public scratcher;
    uint256 constant TICKET_COST = 3_000 * 1E18;

    address constant LINK_TOKEN = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;
    address constant VERSE_TOKEN = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;

    address constant VRD_COORDINATOR = 0xAE975071Be8F8eE67addBC1A82488F1C24858067;
    bytes32 constant GAS_KEY_HASH = 0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd;

    function setUp()
        public
    {
        vm.createSelectFork(
            vm.rpcUrl("polygon"),
            FORK_POLYGON_BLOCK
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

    function testChangeTicketCost()
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

    // @TODO: Add More Tests
}
