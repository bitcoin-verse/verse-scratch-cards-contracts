// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

contract PrizeTiers {

    PrizeTier[] public prizeTiers;

    struct PrizeTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        uint256 winAmount;
    }

    uint256 constant public PRECISION_FACTOR = 1E18;

    constructor() {

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 790,
            drawEdgeB: 887,
            winAmount: toWei(1_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 889,
            drawEdgeB: 1000,
            winAmount: toWei(1_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 594,
            drawEdgeB: 789,
            winAmount: toWei(2_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 396,
            drawEdgeB: 593,
            winAmount: toWei(5_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 244,
            drawEdgeB: 395,
            winAmount: toWei(10_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 104,
            drawEdgeB: 243,
            winAmount: toWei(12000) 
        })
    );


    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 59,
            drawEdgeB: 103,
            winAmount: toWei(30_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 16,
            drawEdgeB: 58,
            winAmount: toWei(50_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 2,
            drawEdgeB: 15,
            winAmount: toWei(100_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 1,
            drawEdgeB: 1,
            winAmount: toWei(800_000) 
        })
    );

    prizeTiers.push(
        PrizeTier({
            drawEdgeA: 888,
            drawEdgeB: 888, 
            winAmount: toWei(8_888_888) 
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
