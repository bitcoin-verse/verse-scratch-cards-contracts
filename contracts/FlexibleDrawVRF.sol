// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "./CommonVRF.sol";
import "./ScratchNFT.sol";
import "./flats/ERC721Enumerable.sol";

error ZeroTickets();
error ZeroAddress();
error NotEnoughFunds();
error BelowMinimumDeposit();
error InvalidNFTAddress();
error NFTTransferFailed();

contract FlexibleDrawVRF is ScratchNFT, CommonVRF {

    // Base cost for a standard ticket
    uint256 public standardCost;

    // Scratcher NFT contract
    IERC721Enumerable public scratcherNFT;

    // Voyager NFT contract
    IERC721Enumerable public voyagerNFT;

    // Cost of one Scratcher NFT in Verse tokens
    uint256 public scratcherCost;

    // Cost of one Voyager NFT in Verse tokens
    uint256 public voyagerCost;

    // Chance parameters for NFT distribution (0-100)
    uint256 public scratcherChance = 50;  // 50% chance to get Scratchers
    uint256 public voyagerChance = 30;    // 30% chance to get Voyagers
    uint256 public minNFTChance = 10;     // 10% chance to get at least one NFT if randomized to 0

    // We no longer track reserved NFTs to save gas
    // NFT counts are determined during callback but distributed during claim

    // Structure to store flexible drawing data
    struct FlexibleDrawing {
        uint256 drawId;
        address ticketReceiver;
        uint256 depositAmount;
    }

    // Mapping to store NFT distribution data for each ticket
    mapping(uint256 => uint256) public ticketToScratcherCount;
    mapping(uint256 => uint256) public ticketToVoyagerCount;

    constructor(
        address _vrfCoordinatorV2Address,
        uint256 _standardCost,
        uint256 _minimumDeposit,
        address _linkTokenAddress,
        address _verseTokenAddress,
        bytes32 _gasKeyHash,
        uint64 _subscriptionId,
        address _scratcherNFT,
        address _voyagerNFT,
        uint256 _scratcherCost,
        uint256 _voyagerCost
    )
        ERC721(
            "FlexibleSpace",
            "FSpace"
        )
        CommonVRF(
            _linkTokenAddress,
            _verseTokenAddress,
            _gasKeyHash,
            _subscriptionId,
            _vrfCoordinatorV2Address
        )
    {
        if (_minimumDeposit == 0) {
            revert InvalidCost();
        }

        standardCost = _standardCost;
        baseCost = _minimumDeposit;

        scratcherNFT = IERC721Enumerable(
            _scratcherNFT
        );

        voyagerNFT = IERC721Enumerable(
            _voyagerNFT
        );

        scratcherCost = _scratcherCost;
        voyagerCost = _voyagerCost;
    }

    /**
     * @notice Allows to purchase a flexible draw with custom deposit amount
     * @param _depositAmount The amount of Verse tokens to deposit (must be >= baseCost)
     */
    function buyFlexibleDraw(
        uint256 _depositAmount
    )
        external
        whenNotPaused
    {
        if (_depositAmount < baseCost) {
            revert BelowMinimumDeposit();
        }

        _newFlexibleDraw(
            msg.sender,
            _depositAmount
        );
    }

    function _newFlexibleDraw(
        address _receiver,
        uint256 _depositAmount
    )
        internal
    {
        _takeTokens(
            VERSE_TOKEN,
            _depositAmount
        );

        _drawFlexibleRequest(
            _receiver,
            _depositAmount
        );
    }

    // Mapping to store flexible drawing data
    mapping(uint256 => FlexibleDrawing) public requestIdToFlexibleDrawing;

    function _drawFlexibleRequest(
        address _receiver,
        uint256 _depositAmount
    )
        internal
    {
        uint256 requestId = _requestRandomWords({
            _wordCount: 3 // Need 3 random words: 1 for prize tier, 1 for edition, 1 for NFT distribution
        });

        uint256 latestDrawId = _increaseLatestDrawId();

        FlexibleDrawing memory newDrawing = FlexibleDrawing({
            drawId: latestDrawId,
            ticketReceiver: _receiver,
            depositAmount: _depositAmount
        });

        drawIdToRequestId[latestDrawId] = requestId;
        requestIdToFlexibleDrawing[requestId] = newDrawing;

        emit DrawRequest(
            latestDrawId,
            requestId,
            msg.sender
        );
    }

    /**
     * @notice Callback function for chainlink VRF
     * @param _requestId ID of the VRF request
     * @param _randomWords Array with random numbers
     */
    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    )
        internal
        override
    {
        _fulfillFlexibleDrawing(
            _requestId,
            _randomWords
        );
    }

    function _fulfillFlexibleDrawing(
        uint256 _requestId,
        uint256[] memory _randomWords
    )
        internal
    {
        FlexibleDrawing memory currentDraw = requestIdToFlexibleDrawing[
            _requestId
        ];

        uint256 randomEdition = uniform(
            _randomWords[1],
            10
        );

        uint256 randomNumber = uniform(
            _randomWords[0],
            1_000
        );

        // Get base prize tier
        uint256 basePrize = _getPrizeTier(
            randomNumber
        );

        // Calculate actual prize based on deposit amount
        uint256 prizeMultiplier = currentDraw.depositAmount
            * PRECISION_FACTOR
            / standardCost;

        uint256 adjustedPrize = basePrize
            * prizeMultiplier
            / PRECISION_FACTOR;

        // Use the third random number to determine NFT distribution
        uint256 nftRandom = uniform(
            _randomWords[2],
            1000
        );

        // Determine how many NFTs to give based on prize amount and random number
        (
            uint256 scratcherCount,
            uint256 voyagerCount,
            uint256 remainingPrize
        ) = _calculateNFTDistribution(
            adjustedPrize,
            nftRandom
        );

        uint256 latestTicketId = _increaseLatestTicketId();

        // Store the remaining prize amount after NFT distribution
        _mintTicket(
            latestTicketId,
            randomEdition,
            remainingPrize,
            currentDraw.ticketReceiver
        );

        // Store NFT distribution data for claiming later
        ticketToScratcherCount[latestTicketId] = scratcherCount;
        ticketToVoyagerCount[latestTicketId] = voyagerCount;

        // Emit the standard VRF event for compatibility
        emit RequestFulfilled(
            currentDraw.drawId,
            _requestId,
            _randomWords
        );
    }

    /**
     * @notice Calculate how many NFTs to distribute based on prize amount
     * @param _prizeAmount Total prize amount in Verse tokens
     * @param _randomNumber Random number to determine distribution
     */
    function _calculateNFTDistribution(
        uint256 _prizeAmount,
        uint256 _randomNumber
    )
        internal
        view
        returns (
            uint256 scratcherCount,
            uint256 voyagerCount,
            uint256 remainingPrize
        )
    {
        remainingPrize = _prizeAmount;

        // Get current NFT balances in the contract
        uint256 availableScratchers = scratcherNFT.balanceOf(
            address(this)
        );

        uint256 availableVoyagers = voyagerNFT.balanceOf(
            address(this)
        );

        // If no NFTs available after accounting for reservations, return early with all prize as Verse
        if (availableScratchers == 0 && availableVoyagers == 0) {
            return (
                0,
                0,
                _prizeAmount
            );
        }

        // Calculate NFT distributions using shared logic
        // First for Scratchers
        if (remainingPrize >= scratcherCost && availableScratchers > 0) {
            (scratcherCount, remainingPrize) = _calculateNFTCount(
                remainingPrize,
                scratcherCost,
                availableScratchers,
                scratcherChance,
                _randomNumber
            );
        }

        // Then for Voyagers, using a different part of the random number
        if (remainingPrize >= voyagerCost && availableVoyagers > 0) {
            (voyagerCount, remainingPrize) = _calculateNFTCount(
                remainingPrize,
                voyagerCost,
                availableVoyagers,
                voyagerChance,
                _randomNumber / 100 // Use a different part of the random number
            );
        }

        return (
            scratcherCount,
            voyagerCount,
            remainingPrize
        );
    }

    /**
     * @notice Helper function to calculate NFT counts based on parameters
     * @param _remainingPrize Remaining prize amount
     * @param _nftCost Cost of one NFT
     * @param _availableNFTs Number of available NFTs
     * @param _chancePercent Chance percentage to get any NFTs (0-100)
     * @param _randomNumber Random number for calculations
     * @return nftCount Number of NFTs to distribute
     * @return updatedPrize Remaining prize after NFT distribution
     */
    function _calculateNFTCount(
        uint256 _remainingPrize,
        uint256 _nftCost,
        uint256 _availableNFTs,
        uint256 _chancePercent,
        uint256 _randomNumber
    )
        internal
        view
        returns (
            uint256 nftCount,
            uint256 updatedPrize
        )
    {
        updatedPrize = _remainingPrize;

        // Determine max possible NFTs based on prize and available NFTs
        uint256 maxNFTs = updatedPrize / _nftCost;

        if (maxNFTs > _availableNFTs) {
            maxNFTs = _availableNFTs;
        }

        // Check if user gets any NFTs based on chance percentage
        if (_randomNumber % 100 < _chancePercent) {
            // If they get NFTs, determine how many
            uint256 randomPercentage = _randomNumber % 100;

            nftCount = maxNFTs
                * randomPercentage
                / 100;

            // Minimum NFT chance if we can afford it and randomized to 0
            if (nftCount == 0 && maxNFTs > 0 && _randomNumber % 100 < minNFTChance) {
                nftCount = 1;
            }

            // Deduct from remaining prize
            updatedPrize -= _nftCost * nftCount;
        }

        return (
            nftCount,
            updatedPrize
        );
    }

    /**
     * @notice Distribute NFTs to the winner
     * @param _receiver Address to receive the NFTs
     * @param _scratcherCount Number of Scratcher NFTs to mint
     * @param _voyagerCount Number of Voyager NFTs to mint
     */
    function _distributeNFTs(
        address _receiver,
        uint256 _scratcherCount,
        uint256 _voyagerCount
    )
        internal
    {
        // Transfer Scratcher NFTs if any
        for (uint256 i = 0; i < _scratcherCount; i++) {

            uint256 tokenId = scratcherNFT.tokenOfOwnerByIndex(
                address(this),
                0
            );

            scratcherNFT.safeTransferFrom(
                address(this),
                _receiver,
                tokenId
            );
        }

        // Transfer Voyager NFTs if any
        for (uint256 i = 0; i < _voyagerCount; i++) {

            uint256 tokenId = voyagerNFT.tokenOfOwnerByIndex(
                address(this),
                0
            );

            voyagerNFT.safeTransferFrom(
                address(this),
                _receiver,
                tokenId
            );
        }
    }

    /**
     * @notice Allows claim prize for galaxy ticket NFT
     * @param _ticketId ID of the galaxy ticket NFT
     */
    function claimPrize(
        uint256 _ticketId
    )
        external
        whenNotPaused
        onlyTokenOwner(_ticketId)
    {
        _setClaimed(
            _ticketId
        );

        uint256 prizeWei = prizes[
            _ticketId
        ];

        // Check if we have enough tokens for the prize
        uint256 balance = VERSE_TOKEN.balanceOf(
            address(this)
        );

        if (balance < prizeWei) {
            revert NotEnoughFunds();
        }

        _giveTokens(
            VERSE_TOKEN,
            msg.sender,
            prizeWei
        );

        uint256 scratcherCount = ticketToScratcherCount[
            _ticketId
        ];

        uint256 voyagerCount = ticketToVoyagerCount[
            _ticketId
        ];

        // Distribute any NFTs associated with this ticket
        if (scratcherCount > 0 || voyagerCount > 0) {
            _distributeNFTs(
                msg.sender,
                scratcherCount,
                voyagerCount
            );

            // Clear the NFT counts to prevent double-claiming
            ticketToScratcherCount[_ticketId] = 0;
            ticketToVoyagerCount[_ticketId] = 0;
        }

        emit PrizeClaimed(
            _ticketId,
            msg.sender,
            prizeWei
        );
    }

    /**
     * @notice Update the standard cost for a ticket
     * @param _newStandardCost New standard cost in Verse tokens
     */
    function updateStandardCost(
        uint256 _newStandardCost
    )
        external
        onlyOwner
    {
        if (_newStandardCost == 0) {
            revert InvalidCost();
        }

        standardCost = _newStandardCost;
    }

    /**
     * @notice Update the base cost (minimum deposit amount)
     * @param _newBaseCost New base cost in Verse tokens
     */
    function updateBaseCost(
        uint256 _newBaseCost
    )
        external
        onlyOwner
    {
        if (_newBaseCost == 0) {
            revert InvalidCost();
        }

        baseCost = _newBaseCost;
    }

    /**
     * @notice Update the Scratcher NFT cost
     * @param _newScratcherCost New cost for a Scratcher NFT in Verse tokens
     */
    function updateScratcherCost(
        uint256 _newScratcherCost
    )
        external
        onlyOwner
    {
        if (_newScratcherCost == 0) {
            revert InvalidCost();
        }

        scratcherCost = _newScratcherCost;
    }

    /**
     * @notice Update the Voyager NFT cost
     * @param _newVoyagerCost New cost for a Voyager NFT in Verse tokens
     */
    function updateVoyagerCost(
        uint256 _newVoyagerCost
    )
        external
        onlyOwner
    {
        if (_newVoyagerCost == 0) {
            revert InvalidCost();
        }

        voyagerCost = _newVoyagerCost;
    }

    /**
     * @notice Update the Scratcher NFT contract address
     * @param _newScratcherNFT New Scratcher NFT contract address
     */
    function updateScratcherNFT(
        address _newScratcherNFT
    )
        external
        onlyOwner
    {
        if (_newScratcherNFT == ZERO_ADDRESS) {
            revert InvalidNFTAddress();
        }

        scratcherNFT = IERC721Enumerable(
            _newScratcherNFT
        );
    }

    /**
     * @notice Update the Voyager NFT contract address
     * @param _newVoyagerNFT New Voyager NFT contract address
     */
    function updateVoyagerNFT(
        address _newVoyagerNFT
    )
        external
        onlyOwner
    {
        if (_newVoyagerNFT == ZERO_ADDRESS) {
            revert InvalidNFTAddress();
        }

        voyagerNFT = IERC721Enumerable(
            _newVoyagerNFT
        );
    }

    function updateBaseURI(
        string calldata _newBaseURI
    )
        external
        onlyOwner
    {
        baseURI = _newBaseURI;
    }

    /**
     * @notice Update the Scratcher NFT chance percentage
     * @param _newChance New chance percentage (0-100)
     */
    function updateScratcherChance(
        uint256 _newChance
    )
        external
        onlyOwner
    {
        if (_newChance > 100) {
            revert InvalidCost();
        }

        scratcherChance = _newChance;
    }

    /**
     * @notice Update the Voyager NFT chance percentage
     * @param _newChance New chance percentage (0-100)
     */
    function updateVoyagerChance(
        uint256 _newChance
    )
        external
        onlyOwner
    {
        if (_newChance > 100) {
            revert InvalidCost();
        }

        voyagerChance = _newChance;
    }

    /**
     * @notice Update the minimum NFT chance percentage
     * @param _newChance New chance percentage (0-100)
     */
    function updateMinNFTChance(
        uint256 _newChance
    )
        external
        onlyOwner
    {
        if (_newChance > 100) {
            revert InvalidCost();
        }

        minNFTChance = _newChance;
    }

    function _increaseLatestTicketId()
        internal
        returns (uint256)
    {
        unchecked {
            return ++latestTicketId;
        }
    }

    function _getPrizeTier(
        uint256 _number
    )
        internal
        view
        returns (uint256 prize)
    {
        uint256 i;
        uint256 loops = prizeTiers.length;

        for (i; i < loops;) {
            PrizeTier memory pt = prizeTiers[i];

            if (_number >= pt.drawEdgeA && _number <= pt.drawEdgeB) {
                prize = pt.winAmount;
                return prize;
            }

            unchecked {
                ++i;
            }
        }
    }

    function _increaseLatestDrawId()
        internal
        returns (uint256)
    {
        unchecked {
            return ++latestDrawId;
        }
    }

    function addConsumer(
        address _newConsumer
    )
        external
        onlyOwner
    {
        if (_newConsumer == ZERO_ADDRESS) {
            revert ZeroAddress();
        }

        VRF_COORDINATOR.addConsumer(
            SUBSCRIPTION_ID,
            _newConsumer
        );
    }

    /**
     * @notice Get the number of Scratcher NFTs owned by the contract
     * @return count The number of Scratcher NFTs
     */
    function getScratcherCount()
        external
        view
        returns (uint256)
    {
        return scratcherNFT.balanceOf(
            address(this)
        );
    }

    /**
     * @notice Get the number of Voyager NFTs owned by the contract
     * @return count The number of Voyager NFTs
     */
    function getVoyagerCount()
        external
        view
        returns (uint256)
    {
        return voyagerNFT.balanceOf(
            address(this)
        );
    }

    function removeConsumer(
        address _oldConsumer
    )
        external
        onlyOwner
    {
        if (_oldConsumer == ZERO_ADDRESS) {
            revert ZeroAddress();
        }

        VRF_COORDINATOR.removeConsumer(
            SUBSCRIPTION_ID,
            _oldConsumer
        );
    }
}
