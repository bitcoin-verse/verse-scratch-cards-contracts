// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../../FlexibleDrawVRF.sol";
import { VRFCoordinatorV2Mock } from "../../flats/VRFCoordinatorV2Mock.sol";

// Mock ERC20 implementation for testing
contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
    }
}

// Mock ERC721 implementation for testing
contract MockERC721Enumerable is IERC721Enumerable {
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _owners;
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;

    function mint(address to, uint256 tokenId) external {
        _owners[tokenId] = to;
        _balances[to]++;

        _addTokenToOwnerEnumeration(to, tokenId);
        _addTokenToAllTokensEnumeration(tokenId);
    }

    function balanceOf(address owner) external view override returns (uint256) {
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) external view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_owners[tokenId] == from, "ERC721: transfer of token that is not own");
        _owners[tokenId] = to;
        _balances[from]--;
        _balances[to]++;

        _removeTokenFromOwnerEnumeration(from, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(_owners[tokenId] == from, "ERC721: transfer of token that is not own");
        _owners[tokenId] = to;
        _balances[from]--;
        _balances[to]++;

        _removeTokenFromOwnerEnumeration(from, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }

    function approve(address to, uint256 tokenId) external override {}

    function getApproved(uint256 tokenId) external view override returns (address) {
        return address(0);
    }

    function setApprovalForAll(address operator, bool approved) external override {}

    function isApprovedForAll(address owner, address operator) external view override returns (bool) {
        return false;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view override returns (uint256) {
        require(index < _balances[owner], "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    function totalSupply() external view override returns (uint256) {
        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) external view override returns (uint256) {
        require(index < _allTokens.length, "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId;
    }

    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = _balances[to] - 1;
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = _balances[from];
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex - 1];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex - 1];
    }
}

contract TestFlexibleDrawVRF is Test {
    // Contract instances
    FlexibleDrawVRF public flexibleDraw;
    VRFCoordinatorV2Mock public coordinator;
    MockERC721Enumerable public scratcherNFT;
    MockERC721Enumerable public voyagerNFT;
    MockERC20 public verseToken;
    MockERC20 public linkToken;

    // Test parameters
    address constant WISE_DEPLOYER = 0x641AD78BAca220C5BD28b51Ce8e0F495e85Fe689;
    uint256 constant STANDARD_COST = 22_000 * 1e18;
    uint256 constant MINIMUM_DEPOSIT = 1_000 * 1e18;
    bytes32 constant GAS_KEY_HASH = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint64 constant SUBSCRIPTION_ID = 0;
    uint256 constant SCRATCHER_COST = 22_000 * 1e18;
    uint256 constant VOYAGER_COST = 22_000 * 1e18;

    function setUp() public {
        // Set up token contracts
        verseToken = new MockERC20("Verse Token", "VERSE");
        linkToken = new MockERC20("Chainlink Token", "LINK");

        // Set up VRF coordinator mock
        uint96 _baseFee = 100_000_000_000;
        uint96 _gasPriceLink = 1_000_000;

        coordinator = new VRFCoordinatorV2Mock(
            _baseFee,
            _gasPriceLink
        );

        // Set up NFT contracts
        scratcherNFT = new MockERC721Enumerable();
        voyagerNFT = new MockERC721Enumerable();

        // Deploy FlexibleDrawVRF contract
        flexibleDraw = new FlexibleDrawVRF(
            address(coordinator),
            STANDARD_COST,
            MINIMUM_DEPOSIT,
            address(linkToken),
            address(verseToken),
            GAS_KEY_HASH,
            SUBSCRIPTION_ID,
            address(scratcherNFT),
            address(voyagerNFT),
            SCRATCHER_COST,
            VOYAGER_COST
        );

        // Fund the subscription
        vm.startPrank(WISE_DEPLOYER);

        // Fund with VERSE tokens
        verseToken.mint(WISE_DEPLOYER, 1_000_000 * 1e18);
        verseToken.mint(address(flexibleDraw), 1_000_000 * 1e18);

        // Fund with LINK tokens for VRF
        linkToken.mint(WISE_DEPLOYER, 10 * 1e18);
        linkToken.approve(address(flexibleDraw), 10 * 1e18);

        // Fund the VRF subscription
        coordinator.fundSubscription(
            uint64(flexibleDraw.SUBSCRIPTION_ID()),
            uint96(10 * 1e18)
        );

        vm.stopPrank();

        // Mint some NFTs to the contract for distribution
        for (uint256 i = 1; i <= 10; i++) {
            scratcherNFT.mint(address(flexibleDraw), i);
            voyagerNFT.mint(address(flexibleDraw), i + 100);
        }
    }

    function testBuyFlexibleDraw() public {
        uint256 depositAmount = 5_000 * 1e18;

        vm.startPrank(WISE_DEPLOYER);

        // Approve tokens for spending
        verseToken.approve(address(flexibleDraw), depositAmount);

        // Buy a flexible draw
        flexibleDraw.buyFlexibleDraw(depositAmount);

        // Verify a draw was created
        uint256 latestDrawId = flexibleDraw.latestDrawId();
        assertEq(latestDrawId, 1);

        // Check that a request ID was stored for this draw
        uint256 requestId = flexibleDraw.drawIdToRequestId(latestDrawId);
        assertTrue(requestId > 0, "No request ID was stored for the draw");

        vm.stopPrank();
    }

    function testBuyFlexibleDrawBelowMinimum() public {
        uint256 depositAmount = 500 * 1e18; // Below minimum deposit

        vm.startPrank(WISE_DEPLOYER);

        // Approve tokens for spending
        verseToken.approve(address(flexibleDraw), depositAmount);

        // Expect revert due to below minimum deposit
        vm.expectRevert(BelowMinimumDeposit.selector);
        flexibleDraw.buyFlexibleDraw(depositAmount);

        vm.stopPrank();
    }

    function testFulfillRandomWords() public {
        uint256 depositAmount = 5_000 * 1e18;

        vm.startPrank(WISE_DEPLOYER);

        // Approve tokens for spending
        verseToken.approve(address(flexibleDraw), depositAmount);

        // Buy a flexible draw
        flexibleDraw.buyFlexibleDraw(depositAmount);

        vm.stopPrank();

        // Create random words for the VRF callback
        uint256[] memory randomWords = new uint256[](3);
        randomWords[0] = 123456; // For prize tier
        randomWords[1] = 789012; // For edition
        randomWords[2] = 345678; // For NFT distribution

        // Fulfill the random words request
        coordinator.fulfillRandomWordsWithOverride(1, address(flexibleDraw), randomWords);

        // Verify a ticket was minted
        assertEq(flexibleDraw.latestTicketId(), 1);
    }

    function testClaimPrize() public {
        uint256 depositAmount = 5_000 * 1e18;

        vm.startPrank(WISE_DEPLOYER);

        // Approve tokens for spending
        verseToken.approve(address(flexibleDraw), depositAmount);

        // Buy a flexible draw
        flexibleDraw.buyFlexibleDraw(depositAmount);

        vm.stopPrank();

        // Create random words for the VRF callback
        uint256[] memory randomWords = new uint256[](3);
        randomWords[0] = 123456; // For prize tier
        randomWords[1] = 789012; // For edition
        randomWords[2] = 345678; // For NFT distribution

        // Fulfill the random words request
        coordinator.fulfillRandomWordsWithOverride(1, address(flexibleDraw), randomWords);

        // Claim the prize
        vm.startPrank(WISE_DEPLOYER);
        flexibleDraw.claimPrize(1);
        vm.stopPrank();

        // Verify the ticket was claimed
        assertTrue(flexibleDraw.claimed(1), "Ticket was not marked as claimed");
    }

    function testNFTDistribution() public {
        // Set up a scenario where NFTs will be distributed
        uint256 depositAmount = 50_000 * 1e18; // Large deposit to increase chance of NFTs

        vm.startPrank(WISE_DEPLOYER);

        // Approve tokens for spending
        verseToken.approve(address(flexibleDraw), depositAmount);

        // Buy a flexible draw
        flexibleDraw.buyFlexibleDraw(depositAmount);

        vm.stopPrank();

        // Create random words for the VRF callback
        uint256[] memory randomWords = new uint256[](3);
        randomWords[0] = 123456; // For prize tier
        randomWords[1] = 789012; // For edition
        randomWords[2] = 10; // Low number to increase chance of NFT distribution

        // Fulfill the random words request - this now calculates NFT distribution during callback
        coordinator.fulfillRandomWordsWithOverride(1, address(flexibleDraw), randomWords);

        // Verify the ticket was created
        assertEq(flexibleDraw.latestTicketId(), 1);
        
        // Check if NFTs were determined during callback
        uint256 scratcherCount = flexibleDraw.ticketToScratcherCount(1);
        uint256 voyagerCount = flexibleDraw.ticketToVoyagerCount(1);
        
        console.log("Scratchers determined during callback:", scratcherCount);
        console.log("Voyagers determined during callback:", voyagerCount);

        // Get initial NFT balances
        uint256 initialScratcherBalance = scratcherNFT.balanceOf(address(flexibleDraw));
        uint256 initialVoyagerBalance = voyagerNFT.balanceOf(address(flexibleDraw));

        // Claim the prize to trigger NFT distribution
        vm.startPrank(WISE_DEPLOYER);
        flexibleDraw.claimPrize(1);
        vm.stopPrank();

        // Now check if NFTs were distributed during claim
        uint256 finalScratcherBalance = scratcherNFT.balanceOf(address(flexibleDraw));
        uint256 finalVoyagerBalance = voyagerNFT.balanceOf(address(flexibleDraw));

        // Calculate how many NFTs were distributed
        uint256 scratchersDistributed = initialScratcherBalance - finalScratcherBalance;
        uint256 voyagersDistributed = initialVoyagerBalance - finalVoyagerBalance;

        console.log("Scratchers distributed during claim:", scratchersDistributed);
        console.log("Voyagers distributed during claim:", voyagersDistributed);

        // Verify the user received the NFTs if any were distributed
        if (scratchersDistributed > 0) {
            assertEq(scratcherNFT.balanceOf(WISE_DEPLOYER), scratchersDistributed);
        }

        if (voyagersDistributed > 0) {
            assertEq(voyagerNFT.balanceOf(WISE_DEPLOYER), voyagersDistributed);
        }

        // Verify the ticket is marked as claimed
        assertTrue(flexibleDraw.claimed(1));
        
        // Verify NFT counts were cleared after claim
        assertEq(flexibleDraw.ticketToScratcherCount(1), 0);
        assertEq(flexibleDraw.ticketToVoyagerCount(1), 0);
    }

    function testUpdateChances() public {
        // Test updating NFT chance parameters
        uint256 newScratcherChance = 60;
        uint256 newVoyagerChance = 40;
        uint256 newMinNFTChance = 15;

        // Update chances
        flexibleDraw.updateScratcherChance(newScratcherChance);
        flexibleDraw.updateVoyagerChance(newVoyagerChance);
        flexibleDraw.updateMinNFTChance(newMinNFTChance);

        // Verify chances were updated
        assertEq(flexibleDraw.scratcherChance(), newScratcherChance);
        assertEq(flexibleDraw.voyagerChance(), newVoyagerChance);
        assertEq(flexibleDraw.minNFTChance(), newMinNFTChance);
    }

    function testUpdateChancesExceptions() public {
        // Test invalid chance values (>100)
        vm.expectRevert(InvalidCost.selector);
        flexibleDraw.updateScratcherChance(101);

        vm.expectRevert(InvalidCost.selector);
        flexibleDraw.updateVoyagerChance(101);

        vm.expectRevert(InvalidCost.selector);
        flexibleDraw.updateMinNFTChance(101);
    }

    function testGetNFTCounts() public {
        // Test the NFT count getters
        uint256 scratcherCount = flexibleDraw.getScratcherCount();
        uint256 voyagerCount = flexibleDraw.getVoyagerCount();

        // Verify counts match what we minted in setup
        assertEq(scratcherCount, 10);
        assertEq(voyagerCount, 10);
    }

    function testUpdateNFTCosts() public {
        // Test updating NFT costs
        uint256 newScratcherCost = 25_000 * 1e18;
        uint256 newVoyagerCost = 30_000 * 1e18;

        // Update costs
        flexibleDraw.updateScratcherCost(newScratcherCost);
        flexibleDraw.updateVoyagerCost(newVoyagerCost);

        // Verify costs were updated
        assertEq(flexibleDraw.scratcherCost(), newScratcherCost);
        assertEq(flexibleDraw.voyagerCost(), newVoyagerCost);
    }

    function testUpdateNFTAddresses() public {
        // Create new mock NFT contracts
        MockERC721Enumerable newScratcherNFT = new MockERC721Enumerable();
        MockERC721Enumerable newVoyagerNFT = new MockERC721Enumerable();

        // Update NFT addresses
        flexibleDraw.updateScratcherNFT(address(newScratcherNFT));
        flexibleDraw.updateVoyagerNFT(address(newVoyagerNFT));

        // Verify addresses were updated
        assertEq(address(flexibleDraw.scratcherNFT()), address(newScratcherNFT));
        assertEq(address(flexibleDraw.voyagerNFT()), address(newVoyagerNFT));
    }

    function testUpdateNFTAddressesExceptions() public {
        // Test invalid NFT addresses (zero address)
        vm.expectRevert(InvalidNFTAddress.selector);
        flexibleDraw.updateScratcherNFT(address(0));

        vm.expectRevert(InvalidNFTAddress.selector);
        flexibleDraw.updateVoyagerNFT(address(0));
    }
}
