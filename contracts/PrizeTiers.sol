// SPDX-License-Identifier: BCOM

pragma solidity =0.8.21;

contract PrizeTiers {

    PrizeTier[] public prizeTiers;

    struct PrizeTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        uint256 winAmount;
    }

    /**
     * RNG between 1 and 1000 values
     * RNG = 1 wins Jackpot (1,000,000)
     * RNG between A and B pays X tokens
     */
    constructor() {

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 1,
                drawEdgeB: 1,
                winAmount: 1_000_000
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 2,
                drawEdgeB: 3,
                winAmount: 100_000
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 4,
                drawEdgeB: 9,
                winAmount: 50_000
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 10,
                drawEdgeB: 49,
                winAmount: 10_000
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 50,
                drawEdgeB: 149,
                winAmount: 5_000
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 150,
                drawEdgeB: 349,
                winAmount: 1_000
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 350,
                drawEdgeB: 649,
                winAmount: 5_00
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 650,
                drawEdgeB: 1000,
                winAmount: 1_00
            })
        );
    }
}