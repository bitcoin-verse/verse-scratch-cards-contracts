// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "forge-std/Test.sol";

import "../../ScratchVRF.sol";
import "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract TestScratchVRF_MAINNET is Test {

    using SafeERC20 for IERC20;

    uint256 constant FORK_MAINNET_BLOCK = 18_456_485;

    ScratchVRF public scratcher;
    uint256 constant TICKET_COST = 3_000 * 1E18;

    address constant LINK_TOKEN = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant VERSE_TOKEN = 0x249cA82617eC3DfB2589c4c17ab7EC9765350a18;
    address constant WISE_DEPLOYER = 0x641AD78BAca220C5BD28b51Ce8e0F495e85Fe689;

    VRFCoordinatorV2Mock public coordinanotor;

    bytes32 constant GAS_KEY_HASH = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    uint64 constant SUBSCRIPTON_ID = 0;

    function setUp()
        public
    {
        vm.createSelectFork(
            vm.rpcUrl("mainnet"),
            FORK_MAINNET_BLOCK
        );

        uint96 _baseFee = 100_000_000_000;
        uint96 _gasPriceLink = 1_000_000;

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

        vm.startPrank(
            WISE_DEPLOYER
        );

        uint256 topUp = 10 * 1E18;

        IERC20(LINK_TOKEN).approve(
            address(scratcher),
            topUp
        );

        coordinanotor.fundSubscription(
            uint64(scratcher.SUBSCRIPTION_ID()),
            uint96(topUp)
        );

        vm.stopPrank();
    }

    /**
     * @notice it should not be possible to change
     * the base cost if the caller is the owner
     */
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

    /**
     * @notice it should not be possible to change
     * the base cost if the caller is not the owner
     */
    function testChangeBaseCostExceptions()
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

    /**
     * @notice it should be possible to query the subscription id
     * from the contract and it should be greater than 0
     */
    function testSubscription()
        public
    {
        uint256 SUBSCRIPTION_ID = scratcher.SUBSCRIPTION_ID();

        assertGt(
            SUBSCRIPTION_ID,
            0
        );
    }

    /**
     * @notice it should be possible to buy tickets
     */
    function testBuyTickets()
        public
    {
        uint256 baseCost = scratcher.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(scratcher),
            baseCost
        );

        scratcher.buyScratchTicket();

        uint256 initialTickets = 0;

        assertEq(
            scratcher.latestTicketId(),
            initialTickets
        );

        vm.stopPrank();

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

        uint256 balanceBefore = _getVerseBalance(
            WISE_DEPLOYER
        );

        scratcher.claimPrize(
            1
        );

        uint256 balanceAfter = _getVerseBalance(
            WISE_DEPLOYER
        );

        assertGt(
            balanceAfter,
            balanceBefore
        );

        vm.expectRevert(
            AlreadyClaimed.selector
        );

        scratcher.claimPrize(
            1
        );
    }

    /**
     * @notice it should be possible to gift tickets
     */
    function testGiftTickets()
        public
    {
        uint256 baseCost = scratcher.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(scratcher),
            baseCost
        );

        scratcher.giftScratchTicket(
            WISE_DEPLOYER
        );

        uint256 initialTickets = 0;

        assertEq(
            scratcher.latestTicketId(),
            initialTickets
        );

        vm.stopPrank();

        coordinanotor.fulfillRandomWords(
            1,
            address(scratcher)
        );

        assertEq(
            scratcher.latestTicketId(),
            initialTickets + 1
        );

        uint256 amount = _getVerseBalance(
            address(scratcher)
        );

        scratcher.withdrawTokens(
            IERC20(VERSE_TOKEN),
            amount
        );

        vm.startPrank(
            WISE_DEPLOYER
        );

        vm.expectRevert(
            NotEnoughFunds.selector
        );

        scratcher.claimPrize(
            1
        );

        vm.expectRevert(
            "ERC721: invalid token ID"
        );

        scratcher.claimPrize(
            2
        );

        vm.expectRevert(
            "ERC721: invalid token ID"
        );

        scratcher.claimPrize(
            0
        );
    }

    /**
     * @notice it should be possible to gift tickets
     * for free if the caller is the owner of the contract
     */
    function testGiftTicketsForFree()
        public
    {
        address[] memory receivers = new address[](1);
        receivers[0] = WISE_DEPLOYER;

        scratcher.giftForFree(
            receivers
        );

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

        vm.expectRevert(
            NotEnoughFunds.selector
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

    /**
     * @notice it should be possible test ownedByAddress function
     */
    function testOwnerByAddress()
        public
    {
        uint256 baseCost = scratcher.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(scratcher),
            baseCost
        );

        scratcher.buyScratchTicket();

        vm.stopPrank();

        coordinanotor.fulfillRandomWords(
            1,
            address(scratcher)
        );

        uint256[] memory tokens = scratcher.ownedByAddress(
            WISE_DEPLOYER
        );

        assertEq(
            tokens.length,
            1
        );

        assertEq(
            tokens[0],
            1
        );
    }

    /**
     * @notice it should be possible test isMinted
     */
    function testIsMinted()
        public
    {
        uint256 baseCost = scratcher.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(scratcher),
            baseCost
        );

        scratcher.buyScratchTicket();

        vm.stopPrank();

        coordinanotor.fulfillRandomWords(
            1,
            address(scratcher)
        );

        bool token1Exists = scratcher.isMinted(
            1
        );

        assertEq(
            token1Exists,
            true
        );

        bool token2Exists = scratcher.isMinted(
            2
        );

        assertEq(
            token2Exists,
            false
        );
    }

    /**
     * @notice it should be possible to test tokenURI
     */
    function testTokenURI()
        public
    {
        uint256 baseCost = scratcher.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(scratcher),
            baseCost
        );

        scratcher.buyScratchTicket();

        vm.stopPrank();

        coordinanotor.fulfillRandomWords(
            1,
            address(scratcher)
        );

        string memory tokenURI = scratcher.tokenURI(
            1
        );

        assertEq(
            tokenURI,
            "1/false.json"
        );

        vm.expectRevert(
            InvalidId.selector
        );

        scratcher.tokenURI(
            0
        );
    }

    /**
     * @notice it should be possible update baseURI
     */
    function testUpdateBaseURI()
        public
    {
        testTokenURI();

        vm.startPrank(
            WISE_DEPLOYER
        );

        vm.expectRevert(
            "Ownable: caller is not the owner"
        );

        scratcher.updateBaseURI(
            "https://example.com/"
        );

        vm.stopPrank();

        scratcher.updateBaseURI(
            "https://example.com/"
        );

        string memory tokenURI = scratcher.tokenURI(
            1
        );

        assertEq(
            tokenURI,
            "https://example.com/1/false.json"
        );
    }

    /**
     * @notice it should be possible to test toWei()
     * @param _value value in ether
     */
    function testToWei(
        uint128 _value
    )
        public
    {
        uint256 etherValue = uint256(_value);
        uint256 expectedWeiValue = etherValue * 1 ether;

        uint256 actualWeiValue = scratcher.toWei(
            etherValue
        );

        assertEq(
            actualWeiValue,
            expectedWeiValue
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
