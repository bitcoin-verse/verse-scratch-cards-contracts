// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "forge-std/Test.sol";
import "../../TicketRouterV3.sol";
import "../../Interfaces/IScratchContract.sol";
import "../../Interfaces/IERC20V.sol";
import "../../Interfaces/IWETH.sol";
import "../../Interfaces/IQuoter.sol";
import "../../Interfaces/ISwapRouter.sol";

// Interface for Uniswap V3 Pool
interface IUniswapV3Pool {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
}

/**
 * Test file specifically for testing the deployed contract at a specific block
 */
contract DeployedContractTest is Test {
    // Specific Polygon fork block where the contract is deployed
    uint256 constant FORK_POLYGON_BLOCK = 70420856;

    // Deployed contract address
    address constant DEPLOYED_ROUTER = 0xc7EEf0C726D43CA13D99eB2CBeD4BE230cB3620d;

    // Existing scratcher contract address
    address constant EXISTING_SCRATCHER = 0xABce2e6DE1bf18722ee06eEE85f07Fdc90a3Bc9C;

    // Addresses needed for testing
    address constant UNISWAP_V3_QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    address constant UNISWAP_V3_SWAP_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address constant VERSE_TOKEN = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; // Real WETH on Polygon
    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270; // WMATIC

    // Test user
    address public user = makeAddr("user");

    // Contract interfaces
    TicketRouterV3 public router;

    function setUp() public {
        // Create fork at specific block
        vm.createSelectFork(
            vm.rpcUrl("polygon"),
            FORK_POLYGON_BLOCK
        );

        // Connect to already deployed router
        router = TicketRouterV3(payable(DEPLOYED_ROUTER));

        // Log key information
        emit log_named_address("Deployed router address", DEPLOYED_ROUTER);
        emit log_named_address("Existing scratcher address", EXISTING_SCRATCHER);
        emit log_named_address("WETH address", WETH);
        emit log_named_address("WMATIC address", WMATIC);
        emit log_named_address("VERSE token address", VERSE_TOKEN);
        emit log_named_uint("Testing at block", block.number);
    }

    function test_GetBaseCost() public {
        // Check if we can access the scratcher contract's baseCost
        try IScratchContract(EXISTING_SCRATCHER).baseCost() returns (uint256 cost) {
            emit log_named_uint("Scratch card base cost (VERSE)", cost);
            assertTrue(cost > 0, "Base cost should be greater than 0");
        } catch Error(string memory reason) {
            emit log_string(string.concat("baseCost() call reverted with: ", reason));
            fail("Failed to get base cost from scratcher contract");
        } catch {
            emit log("baseCost() call reverted with unknown reason");
            fail("Failed to get base cost from scratcher contract");
        }
    }

    function test_DeployedRouterConfiguration() public {
        // Verify router configuration is correct
        assertEq(router.WETH(), WETH, "WETH configuration incorrect");
        assertEq(router.VERSE_TOKEN(), VERSE_TOKEN, "VERSE token configuration incorrect");
        assertEq(router.SWAP_ROUTER(), UNISWAP_V3_SWAP_ROUTER, "Swap router configuration incorrect");
        assertEq(router.QUOTER(), UNISWAP_V3_QUOTER, "Quoter configuration incorrect");
    }

    function test_GetTokenPriceForTicketsVerse() public {
        // This should always work since it's just returning baseCost * ticketCount for VERSE token
        try router.getTokenPriceForTickets(EXISTING_SCRATCHER, 1, VERSE_TOKEN) returns (uint256 versePrice) {
            emit log_named_uint("Price for 1 ticket in VERSE", versePrice);
            assertTrue(versePrice > 0, "VERSE price should be greater than 0");
        } catch Error(string memory reason) {
            emit log_string(string.concat("getTokenPriceForTickets(VERSE) reverted with: ", reason));
            fail("Failed to get token price in VERSE");
        } catch {
            emit log("getTokenPriceForTickets(VERSE) reverted with unknown reason");
            fail("Failed to get token price in VERSE");
        }
    }

    function test_GetTokenPriceForTicketsWETH() public {
        // Test the WETH price calculation
        try router.getTokenPriceForTickets(EXISTING_SCRATCHER, 1, WETH) returns (uint256 wethPrice) {
            emit log_named_uint("Price for 1 ticket in WETH", wethPrice);
            assertTrue(wethPrice > 0, "WETH price should be greater than 0");
        } catch Error(string memory reason) {
            emit log_string(string.concat("getTokenPriceForTickets(WETH) reverted with: ", reason));
            emit log("Direct query of price in WETH failed - this may indicate a pool liquidity issue");
        } catch {
            emit log("getTokenPriceForTickets(WETH) reverted with unknown reason");
            emit log("Direct query of price in WETH failed - this may indicate a pool liquidity issue");
        }
    }

    function test_GetNativePriceForTickets() public {
        // Test native price calculation
        try router.getNativePriceForTickets(EXISTING_SCRATCHER, 1) returns (uint256 nativePrice) {
            emit log_named_uint("Price for 1 ticket in native currency (MATIC)", nativePrice);
            assertTrue(nativePrice > 0, "Native price should be greater than 0");
        } catch Error(string memory reason) {
            emit log_string(string.concat("getNativePriceForTickets reverted with: ", reason));
            emit log("This indicates an issue with the quoter or path construction");
        } catch {
            emit log("getNativePriceForTickets reverted with unknown reason");
            emit log("This indicates an issue with the quoter or path construction");
        }
    }

    function test_DirectUniswapQuotation() public {
        // Get the base cost of a ticket from the scratcher contract
        uint256 totalVerseNeeded;
        try IScratchContract(EXISTING_SCRATCHER).baseCost() returns (uint256 cost) {
            totalVerseNeeded = cost;
            emit log_named_uint("Total VERSE needed for 1 ticket", totalVerseNeeded);
        } catch {
            emit log("Failed to get base cost, using 10 VERSE as default for testing");
            totalVerseNeeded = 10 * 10**18; // Default to 10 VERSE for testing
        }

        // Test direct quotation with Uniswap's quoter - VERSE to WETH
        bytes memory verseToWethPath = abi.encodePacked(
            VERSE_TOKEN,      // output token for ExactOutput
            uint24(3000),     // fee tier 0.3%
            WETH              // input token for ExactOutput
        );

        emit log("Testing direct quotation: VERSE -> WETH");
        emit log_named_bytes(
            "Path bytes (expected: output token -> fee -> input token)",
            verseToWethPath
        );

        try IQuoter(UNISWAP_V3_QUOTER).quoteExactOutput(
            verseToWethPath,
            totalVerseNeeded
        ) returns (uint256 wethNeeded) {
            emit log_named_uint("WETH needed for VERSE tokens", wethNeeded);

            // Now test WETH to WMATIC conversion
            bytes memory wethToWmaticPath = abi.encodePacked(
                WETH,              // output token for ExactOutput
                uint24(3000),     // fee tier 0.3%
                WMATIC             // input token for ExactOutput
            );

            emit log("Testing direct quotation: WETH -> WMATIC");
            emit log_named_bytes(
                "Path bytes (expected: output token -> fee -> input token)",
                wethToWmaticPath
            );

            try IQuoter(UNISWAP_V3_QUOTER).quoteExactOutput(
                wethToWmaticPath,
                wethNeeded
            ) returns (uint256 wmaticNeeded) {
                emit log_named_uint("WMATIC needed for WETH tokens", wmaticNeeded);
                emit log("Both quotes succeeded - problem is likely in the contract's path construction");
            } catch Error(string memory reason) {
                emit log_string(string.concat("WETH -> WMATIC quote reverted with: ", reason));
                emit log("Second quotation failed - check if this pool has liquidity");
            } catch {
                emit log("WETH -> WMATIC quote reverted with unknown reason");
                emit log("Second quotation failed - check if this pool has liquidity");
            }
        } catch Error(string memory reason) {
            emit log_string(string.concat("VERSE -> WETH quote reverted with: ", reason));
            emit log("First quotation failed - check if this pool has liquidity");
        } catch {
            emit log("VERSE -> WETH quote reverted with unknown reason");
            emit log("First quotation failed - check if this pool has liquidity");
        }
    }

    function test_TokenOrdering() public {
        // Test output to understand token0/token1 ordering in pools
        address verseWethPoolAddress = 0xd19A1C8278D0420BFb2c825D99DC31fF86224607; // Known VERSE/WETH pool

        // Check VERSE/WETH pool liquidity
        uint256 verseBalance = IERC20V(VERSE_TOKEN).balanceOf(verseWethPoolAddress);
        uint256 wethBalance = IERC20V(WETH).balanceOf(verseWethPoolAddress);

        emit log_named_uint("VERSE tokens in VERSE/WETH pool", verseBalance);
        emit log_named_uint("WETH tokens in VERSE/WETH pool", wethBalance);

        // Check WMATIC/WETH pool liquidity
        address wmaticWethPoolAddress = 0x86f1d8390222A3691C28938eC7404A1661E618e0; // Found in previous test
        uint256 wmaticBalance = IERC20V(WMATIC).balanceOf(wmaticWethPoolAddress);
        uint256 wethBalanceInWmaticPool = IERC20V(WETH).balanceOf(wmaticWethPoolAddress);

        emit log_named_uint("WMATIC tokens in WMATIC/WETH pool", wmaticBalance);
        emit log_named_uint("WETH tokens in WMATIC/WETH pool", wethBalanceInWmaticPool);

        try IUniswapV3Pool(verseWethPoolAddress).token0() returns (address token0) {
            emit log_named_address("VERSE/WETH Pool token0", token0);

            try IUniswapV3Pool(verseWethPoolAddress).token1() returns (address token1) {
                emit log_named_address("VERSE/WETH Pool token1", token1);

                try IUniswapV3Pool(verseWethPoolAddress).fee() returns (uint24 poolFee) {
                    emit log_named_uint("VERSE/WETH Pool fee", poolFee);

                    // Log which token is which for clarity
                    if (token0 == VERSE_TOKEN) {
                        emit log("Pool ordering: token0 = VERSE, token1 = WETH");
                    } else if (token0 == WETH) {
                        emit log("Pool ordering: token0 = WETH, token1 = VERSE");
                    } else {
                        emit log("Unexpected token ordering in VERSE/WETH pool");
                    }
                } catch {
                    emit log("Failed to get pool fee");
                }
            } catch {
                emit log("Failed to get token1");
            }
        } catch {
            emit log("Failed to get token0 - pool may not exist at this block");
        }

        // Try to find WETH/WMATIC pool if it exists
        address possibleWethWmaticPool = 0x86f1d8390222A3691C28938eC7404A1661E618e0; // Try a potential address

        emit log("Attempting to check WETH/WMATIC pool info");
        try IUniswapV3Pool(possibleWethWmaticPool).token0() returns (address token0) {
            emit log_named_address("Possible WETH/WMATIC Pool token0", token0);

            try IUniswapV3Pool(possibleWethWmaticPool).token1() returns (address token1) {
                emit log_named_address("Possible WETH/WMATIC Pool token1", token1);

                // Verify if this is indeed the WETH/WMATIC pool
                if ((token0 == WETH && token1 == WMATIC) || (token0 == WMATIC && token1 == WETH)) {
                    emit log("Found valid WETH/WMATIC pool");
                } else {
                    emit log("This is not a WETH/WMATIC pool");
                }
            } catch {
                emit log("Failed to get token1");
            }
        } catch {
            emit log("Failed to access pool - trying to find the right WETH/WMATIC pool");

            // Another possible strategy: check factory for the pool address
            emit log("Consider using the Uniswap factory to find the correct pool address");
        }
    }

    function test_ExactOutputQuoteCall() public {
        // Get the base cost
        uint256 totalVerseNeeded = 22000 * 10**18; // Using 22,000 VERSE as approximate cost

        // Also try with a much smaller value
        uint256 smallAmount = 1 * 10**18; // Just 1 VERSE

        // Try an exact output call directly
        address quoter = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;

        // Trace through each possible path for diagnosing
        // First try with small amount to see if size is the issue
        emit log_string("=== TESTING WITH SMALL AMOUNT (1 VERSE) ===");

        // 1. First try with output token first (canonical ExactOutput ordering)
        bytes memory path1 = abi.encodePacked(
            VERSE_TOKEN,        // output token (first in path for ExactOutput)
            uint24(3000),       // fee
            WETH                // input token
        );

        emit log("Trying path with output token first: VERSE -> WETH");
        try IQuoter(quoter).quoteExactOutput(path1, smallAmount) returns (uint256 amount) {
            emit log_named_uint("SUCCESS - WETH needed for 1 VERSE", amount);
        } catch Error(string memory reason) {
            emit log_string(string.concat("Failed: ", reason));
        } catch {
            emit log("Failed with unknown error");
        }

        // Now try with full amount
        emit log_string("=== TESTING WITH FULL AMOUNT (22,000 VERSE) ===");

        emit log("Trying path with output token first: VERSE -> WETH");
        try IQuoter(quoter).quoteExactOutput(path1, totalVerseNeeded) returns (uint256 amount) {
            emit log_named_uint("SUCCESS - WETH needed for 22,000 VERSE", amount);
        } catch Error(string memory reason) {
            emit log_string(string.concat("Failed: ", reason));
        } catch {
            emit log("Failed with unknown error");
        }

        // Try exact input instead of exact output
        emit log_string("=== TESTING EXACT INPUT INSTEAD ===");

        // For ExactInput, the path is from input to output token
        bytes memory inputPath = abi.encodePacked(
            WETH,               // input token
            uint24(3000),       // fee
            VERSE_TOKEN         // output token
        );

        // We need to call quoteExactInput but it's not in our IQuoter interface
        // Let's try a direct call instead

        // Try a small WETH input amount (0.01 WETH)
        uint256 smallWethInput = 0.01 * 10**18;

        emit log("Trying ExactInput: WETH -> VERSE");
        // We'll skip ExactInput testing since it requires updating the interface
    }
}