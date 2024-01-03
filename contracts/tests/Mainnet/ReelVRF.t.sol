// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "forge-std/Test.sol";

import "../../ReelVRF.sol";
import "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";

contract TestReelVRF_MAINNET is Test {

    using SafeERC20 for IERC20;

    uint256 constant FORK_MAINNET_BLOCK = 18_456_485;

    ReelVRF public reel;
    uint256 constant CHARACTER_COST = 3_000 * 1E18;

    address constant LINK_TOKEN = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
    address constant VERSE_TOKEN = 0x249cA82617eC3DfB2589c4c17ab7EC9765350a18;
    address constant WISE_DEPLOYER = 0x641AD78BAca220C5BD28b51Ce8e0F495e85Fe689;

    VRFCoordinatorV2Mock public coordinator;

    bytes32 constant GAS_KEY_HASH = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint64 constant SUBSCRIPTON_ID = 0;

    uint256 traitsInContract;
    uint256 expectedTraitCount;

    function setUp()
        public
    {
        vm.createSelectFork(
            vm.rpcUrl("mainnet"),
            FORK_MAINNET_BLOCK
        );

        uint96 _baseFee = 100_000_000_000;
        uint96 _gasPriceLink = 1_000_000;

        coordinator = new VRFCoordinatorV2Mock(
            _baseFee,
            _gasPriceLink
        );

        reel = new ReelVRF(
            "ReelVRF",
            "RVRF",
            address(coordinator),
            CHARACTER_COST,
            LINK_TOKEN,
            VERSE_TOKEN,
            GAS_KEY_HASH,
            SUBSCRIPTON_ID
        );

        expectedTraitCount = 6;
        traitsInContract = reel.MAX_TRAIT_TYPES();

        assertEq(
            traitsInContract,
            expectedTraitCount,
            "expectedTraitCount count should be equal to traitsInContract"
        );

        vm.startPrank(
            WISE_DEPLOYER
        );

        uint256 topUp = 10 * 1E18;

        IERC20(LINK_TOKEN).approve(
            address(reel),
            topUp
        );

        coordinator.fundSubscription(
            uint64(reel.SUBSCRIPTION_ID()),
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
        uint256 initialCost = reel.baseCost();
        uint256 newCost = 1_000 * 1E18;

        assertEq(
            initialCost,
            CHARACTER_COST
        );

        reel.changeBaseCost(
            newCost
        );

        uint256 updatedCost = reel.baseCost();

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
        uint256 initialCost = reel.baseCost();
        uint256 newCost = 1_000 * 1E18;

        vm.startPrank(
            WISE_DEPLOYER
        );

        vm.expectRevert(
            "Ownable: caller is not the owner"
        );

        reel.changeBaseCost(
            newCost
        );

        vm.stopPrank();

        vm.expectRevert(
            InvalidCost.selector
        );

        reel.changeBaseCost(
            initialCost
        );

        vm.expectRevert(
            InvalidCost.selector
        );

        reel.changeBaseCost(
            0
        );

        reel.changeBaseCost(
            newCost
        );

        vm.expectRevert(
            InvalidCost.selector
        );

        reel.changeBaseCost(
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
        uint256 SUBSCRIPTION_ID = reel.SUBSCRIPTION_ID();

        assertGt(
            SUBSCRIPTION_ID,
            0
        );
    }

    /**
     * @notice it should allow to reroll trait
     */
    function testRerollTrait()
        public
    {
        uint256 baseCost = reel.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(reel),
            baseCost
        );

        uint256 initialCharacterId = 0;
        uint256 expectedCharactedId = initialCharacterId + 1;

        assertEq(
            reel.latestCharacterId(),
            initialCharacterId
        );

        assertEq(
            reel.isMinted(1),
            false
        );

        reel.buyCharacter();

        assertEq(
            reel.isMinted(1),
            true
        );

        vm.stopPrank();

        (
            uint256 drawId,
            uint256 astroId,
            uint256 traitId
        ) = reel.requestIdToDrawing(1);

        assertEq(
            drawId,
            1
        );

        assertEq(
            astroId,
            1
        );

        assertEq(
            traitId,
            0
        );

        assertEq(
            reel.latestCharacterId(),
            expectedCharactedId
        );

        coordinator.fulfillRandomWords(
            1,
            address(reel)
        );

        assertEq(
            reel.latestCharacterId(),
            expectedCharactedId
        );

        uint256 REROLL_TRAIT_ID = 1;

        assertGt(
            reel.results(
                1,
                REROLL_TRAIT_ID
            ),
            0
        );

        assertEq(
            expectedTraitCount,
            reel.getTraits(1).length,
            "Traits length should be expectedTraitCount"
        );

        assertEq(
            reel.rerollInProgress(
                expectedCharactedId
            ),
            false
        );

        vm.expectRevert(
            "CommonBase: INVALID_OWNER"
        );

        reel.rerollTrait(
            expectedCharactedId,
            REROLL_TRAIT_ID
        );

        vm.startPrank(
            WISE_DEPLOYER
        );

        uint256 rerollCost = reel.rerollCost();

        IERC20(VERSE_TOKEN).approve(
            address(reel),
            rerollCost
        );

        uint256 maxTrait = reel.MAX_TRAIT_TYPES();

        vm.expectRevert(
            InvalidTraitId.selector
        );

        reel.rerollTrait(
            expectedCharactedId,
            maxTrait + 1
        );

        reel.rerollTrait(
            expectedCharactedId,
            REROLL_TRAIT_ID
        );

        assertEq(
            reel.rerollInProgress(
                expectedCharactedId
            ),
            true
        );

        vm.expectRevert(
            RerollInProgress.selector
        );

        reel.rerollTrait(
            expectedCharactedId,
            REROLL_TRAIT_ID
        );

        vm.stopPrank();

        coordinator.fulfillRandomWords(
            2,
            address(reel)
        );

        assertEq(
            reel.rerollInProgress(
                expectedCharactedId
            ),
            false
        );

        uint256[] memory traits = reel.getTraits(
            expectedCharactedId
        );

        assertGt(
            traits[0],
            0
        );
    }

    /**
     * @notice it should be possible to buy character
     */
    function testBuyCharacter()
        public
    {
        uint256 baseCost = reel.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(reel),
            baseCost
        );

        uint256 initialCharacter = 0;

        assertEq(
            reel.latestCharacterId(),
            initialCharacter,
            "Latest character id should be 0"
        );

        reel.buyCharacter();

        vm.stopPrank();

        coordinator.fulfillRandomWords(
            1,
            address(reel)
        );

        assertEq(
            reel.latestCharacterId(),
            initialCharacter + 1,
            "Latest character id should be 1"
        );

        assertEq(
            reel.getTraits(1).length,
            expectedTraitCount,
            "Traits length should be equal to expectedTraitCount"
        );
    }

    /**
     * @notice it should be possible to gift characters
     */
    function testGiftCharacter()
        public
    {
        uint256 baseCost = reel.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(reel),
            baseCost
        );

        uint256 initialCharacters = 0;

        assertEq(
            reel.latestCharacterId(),
            initialCharacters
        );

        reel.giftCharacter(
            WISE_DEPLOYER
        );

        assertEq(
            reel.latestCharacterId(),
            initialCharacters + 1,
            "Latest character id should be 1"
        );

        vm.stopPrank();

        coordinator.fulfillRandomWords(
            1,
            address(reel)
        );

        assertEq(
            reel.getTraits(1).length,
            expectedTraitCount,
            "Traits length should be equal to expectedTraitCount"
        );
    }

    function testUnifrom()
        public
    {
        uint256 outcome = reel.uniform(
            1000,
            1000
        );

        assertGt(
            outcome,
            0
        );

        outcome = reel.uniform(
            1000,
            1
        );

        assertEq(
            outcome,
            1
        );
    }

    /**
     * @notice it should be possible to change rerollCost
     */
    function testRerollCost()
        public
    {
        uint256 rerollCost = reel.rerollCost();

        assertGt(
            rerollCost,
            0
        );

        uint256 newRerollCost = 1_000 * 1E18;

        reel.setRerollCost(
            newRerollCost
        );

        assertEq(
            reel.rerollCost(),
            newRerollCost
        );

        vm.startPrank(
            WISE_DEPLOYER
        );

        vm.expectRevert(
            "Ownable: caller is not the owner"
        );

        reel.setRerollCost(
            rerollCost
        );
    }

    /**
     * @notice it should be possible to gift characters
     * for free if the caller is the owner of the contract
     */
    function testGiftCharactersForFree()
        public
    {
        address[] memory receivers = new address[](1);
        receivers[0] = WISE_DEPLOYER;

        uint256 initialCharacter = 0;

        assertEq(
            reel.latestCharacterId(),
            initialCharacter
        );

        reel.giftForFree(
            receivers
        );

        assertEq(
            reel.latestCharacterId(),
            initialCharacter + 1
        );

        coordinator.fulfillRandomWords(
            1,
            address(reel)
        );

        vm.startPrank(
            WISE_DEPLOYER
        );

        vm.stopPrank();

        uint256 aboveMAX = 51;

        address[] memory receiversMany = new address[](
            aboveMAX
        );

        for (uint256 i = 0; i < aboveMAX; i++) {
            receiversMany[i] = WISE_DEPLOYER;
        }

        vm.expectRevert(
            TooManyReceivers.selector
        );

        reel.giftForFree(
            receiversMany
        );
    }

    /**
     * @notice it should be possible test ownedByAddress function
     */
    function testOwnerByAddress()
        public
    {
        uint256 baseCost = reel.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(reel),
            baseCost
        );

        reel.buyCharacter();

        vm.stopPrank();

        coordinator.fulfillRandomWords(
            1,
            address(reel)
        );

        uint256[] memory tokens = reel.ownedByAddress(
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
     * @notice it should be possible test checkIfTokenExists
     */
    function testCheckIfTokenExists()
        public
    {
        uint256 baseCost = reel.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(reel),
            baseCost
        );

        reel.buyCharacter();

        vm.stopPrank();

        coordinator.fulfillRandomWords(
            1,
            address(reel)
        );

        bool token1Exists = reel.isMinted(
            1
        );

        assertEq(
            token1Exists,
            true
        );

        bool token2Exists = reel.isMinted(
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
        uint256 baseCost = reel.baseCost();

        vm.startPrank(
            WISE_DEPLOYER
        );

        IERC20(VERSE_TOKEN).approve(
            address(reel),
            baseCost
        );

        reel.buyCharacter();

        vm.stopPrank();

        coordinator.fulfillRandomWords(
            1,
            address(reel)
        );

        string memory tokenURI = reel.tokenURI(
            1
        );

        assertEq(
            tokenURI,
            "1"
        );

        vm.expectRevert(
            InvalidId.selector
        );

        reel.tokenURI(
            0
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
