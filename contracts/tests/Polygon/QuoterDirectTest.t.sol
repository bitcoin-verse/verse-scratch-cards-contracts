// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "forge-std/Test.sol";
import "../../Interfaces/IQuoter.sol";

contract QuoterDirectTest is Test {
    // Specific Polygon fork block where the contract is deployed
    uint256 constant FORK_POLYGON_BLOCK = 70420856;

    // Main addresses
    address constant VERSE_TOKEN = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;
    address constant WETH = 0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619; // Real WETH on Polygon
    address constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270; // WMATIC
    address constant UNISWAP_V3_QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
    
    function setUp() public {
        // Create fork at specific block
        vm.createSelectFork(
            vm.rpcUrl("polygon"),
            FORK_POLYGON_BLOCK
        );
    }
    
    // Since quoter functions aren't view, they can't be called from view functions
    function test_GetNativePriceForTickets() public {
        // Get total VERSE needed for one ticket
        uint256 totalVerseNeeded = 22000 * 10**18;
        
        // First get the WETH needed for VERSE
        bytes memory pathStep1 = abi.encodePacked(
            VERSE_TOKEN,        // output token
            uint24(3000),       // fee
            WETH                // input token
        );
        
        emit log("Step 1: Getting WETH needed for VERSE");
        uint256 wethNeeded = IQuoter(UNISWAP_V3_QUOTER).quoteExactOutput(
            pathStep1,
            totalVerseNeeded
        );
        emit log_named_uint("WETH needed", wethNeeded);
        
        // Then get the WMATIC needed for WETH
        bytes memory pathStep2 = abi.encodePacked(
            WETH,               // output token
            uint24(3000),       // fee
            WMATIC              // input token  
        );
        
        emit log("Step 2: Getting WMATIC needed for WETH");
        uint256 wmaticNeeded = IQuoter(UNISWAP_V3_QUOTER).quoteExactOutput(
            pathStep2,
            wethNeeded
        );
        emit log_named_uint("WMATIC needed", wmaticNeeded);
        
        emit log_named_uint("Total VERSE needed", totalVerseNeeded);
        emit log_named_uint("WETH intermediate", wethNeeded);
        emit log_named_uint("Final WMATIC needed", wmaticNeeded);
    }
}