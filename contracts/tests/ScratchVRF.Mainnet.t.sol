// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "forge-std/Test.sol";

import "../ScratchVRF.sol";
import "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract TestScratchVRF_MAINNET is Test {

    using SafeERC20 for IERC20;

    uint256 constant FORK_MAINNET_BLOCK = 18_456_485;

    ScratchVRF public scratcher;
    uint256 constant TICKET_COST = 3_000 * 1E18;

    address constant LINK_TOKEN = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant VERSE_TOKEN = 0x249cA82617eC3DfB2589c4c17ab7EC9765350a18;

    address constant VRF_COORDINATOR_ADDRESS = 0x271682DEB8C4E0901D1a1550aD2e64D568E69909;

    VRFCoordinatorV2Mock public coordinanotor;

    bytes32 constant GAS_KEY_HASH = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    address constant WISE_DEPLOYER = 0x641AD78BAca220C5BD28b51Ce8e0F495e85Fe689;

    uint64 constant SUBSCRIPTON_ID = 0;

    function setUp()
        public
    {
        vm.createSelectFork(
            vm.rpcUrl("mainnet"),
            FORK_MAINNET_BLOCK
        );

        uint96 _baseFee = 100000000000;
        uint96 _gasPriceLink = 1000000;

        coordinanotor = new VRFCoordinatorV2Mock(
            _baseFee,
            _gasPriceLink
        );

        scratcher = new ScratchVRF(
            "ScratchVRF",
            "SVRF",
            address(coordinanotor),
            TICKET_COST,
            LINK_TOKEN,
            VERSE_TOKEN,
            GAS_KEY_HASH,
            SUBSCRIPTON_ID
        );
    }

    function testChangeBaseCost()
        public
    {
        uint256 initialCost = scratcher.baseCost();
        uint256 newCost = 1_000 * 1E18;

        assertEq(
            initialCost,
            TICKET_COST
        );

        scratcher.changeBaseCost(
            newCost
        );

        uint256 updatedCost = scratcher.baseCost();

        assertEq(
            updatedCost,
            newCost
        );
    }

    function testchangeBaseCostExceptions()
        public
    {
        uint256 initialCost = scratcher.baseCost();
        uint256 newCost = 1_000 * 1E18;

        vm.startPrank(
            WISE_DEPLOYER
        );

        vm.expectRevert(
            "Ownable: caller is not the owner"
        );

        scratcher.changeBaseCost(
            newCost
        );

        vm.stopPrank();

        vm.expectRevert(
            InvalidCost.selector
        );

        scratcher.changeBaseCost(
            initialCost
        );

        vm.expectRevert(
            InvalidCost.selector
        );

        scratcher.changeBaseCost(
            0
        );

        scratcher.changeBaseCost(
            newCost
        );

        vm.expectRevert(
            InvalidCost.selector
        );

        scratcher.changeBaseCost(
            newCost
        );
    }

    function testSubscription()
        public
    {
        uint256 SUBSCRIPTION_ID = scratcher.SUBSCRIPTION_ID();

        assertGt(
            SUBSCRIPTION_ID,
            0
        );
    }

    function testBuyTickets()
        public
    {
        uint256 baseCost = scratcher.baseCost();
        uint256 topUp = 10 * 1E18;

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(LINK_TOKEN).approve(
            address(scratcher),
            topUp
        );

        coordinanotor.fundSubscription(
            uint64(scratcher.SUBSCRIPTION_ID()),
            uint96(topUp)
        );

        IERC20(VERSE_TOKEN).approve(
            address(scratcher),
            baseCost
        );

        scratcher.buyScratchTicket();

        IERC20(VERSE_TOKEN).approve(
            address(scratcher),
            baseCost
        );

        scratcher.giftScratchTicket(
            WISE_DEPLOYER
        );

        vm.stopPrank();

        uint256 initialTickets = 0;

        assertEq(
            scratcher.latestTicketId(),
            initialTickets
        );

        coordinanotor.fulfillRandomWords(
            1,
            address(scratcher)
        );

        assertEq(
            scratcher.latestTicketId(),
            initialTickets + 1
        );

        vm.startPrank(
            WISE_DEPLOYER
        );

        scratcher.claimPrize(
            1
        );

        uint256 expectedPrize = scratcher.prizes(
            1
        );

        IERC20(VERSE_TOKEN).transfer(
            address(scratcher),
            expectedPrize
        );

        scratcher.claimPrize(
            1
        );

        vm.stopPrank();

        address[] memory receiversMany = new address[](51);

        for (uint256 i = 0; i < 51; i++) {
            receiversMany[i] = WISE_DEPLOYER;
        }

        vm.expectRevert(
            TooManyReceivers.selector
        );

        scratcher.giftForFree(
            receiversMany
        );
    }

    function _getVerseBalance(
        address _address
    )
        internal
        view
        returns (uint256)
    {
        return IERC20(VERSE_TOKEN).balanceOf(
            _address
        );
    }
}
