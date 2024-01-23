// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

contract PrizeTiers {

    PrizeTier[] public prizeTiers;

    struct PrizeTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        uint256 winAmount;
    }

    uint256 constant public PRECISION_FACTOR = 1E18;

    /**
     * RNG between 1 and 1000 values
     * RNG = 1 wins Jackpot (1,000,000)
     * RNG between A and B pays X tokens
     */
    constructor() {

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 800,
                drawEdgeB: 1000,
                winAmount: toWei(1_00)
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 280,
                drawEdgeB: 799,
                winAmount: toWei(5_00)
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 80,
                drawEdgeB: 279,
                winAmount: toWei(1_000)
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 30,
                drawEdgeB: 79,
                winAmount: toWei(5_000)
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 10,
                drawEdgeB: 29,
                winAmount: toWei(10_000)
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 4,
                drawEdgeB: 9,
                winAmount: toWei(50_000)
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 2,
                drawEdgeB: 3,
                winAmount: toWei(100_000)
            })
        );

        prizeTiers.push(
            PrizeTier({
                drawEdgeA: 1,
                drawEdgeB: 1,
                winAmount: toWei(1_000_000)
            })
        );
    }

    function toWei(
        uint256 _amount
    )
        public
        pure
        returns (uint256)
    {
        return _amount * PRECISION_FACTOR;
    }
}
