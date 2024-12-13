// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

contract ChristmasPrizeTiers {

    PrizeTier[] public prizeTiers;

    struct PrizeTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        uint256 winAmount;
    }

    uint256 constant public PRECISION_FACTOR = 1E18;

    constructor() {

        _addPrize({
            _drawEdgeA: 889,
            _drawEdgeB: 1000,
            _winAmount: toWei(1_000)
        });

        _addPrize({
            _drawEdgeA: 790,
            _drawEdgeB: 887,
            _winAmount: toWei(1_000)
        });

        _addPrize({
            _drawEdgeA: 594,
            _drawEdgeB: 789,
            _winAmount: toWei(2_000)
        });

        _addPrize({
            _drawEdgeA: 396,
            _drawEdgeB: 593,
            _winAmount: toWei(5_000)
        });

        _addPrize({
            _drawEdgeA: 244,
            _drawEdgeB: 395,
            _winAmount: toWei(10_000)
        });

        _addPrize({
            _drawEdgeA: 104,
            _drawEdgeB: 243,
            _winAmount: toWei(12000)
        });

        _addPrize({
            _drawEdgeA: 59,
            _drawEdgeB: 103,
            _winAmount: toWei(30_000)
        });

        _addPrize({
            _drawEdgeA: 16,
            _drawEdgeB: 58,
            _winAmount: toWei(50_000)
        });

        _addPrize({
            _drawEdgeA: 2,
            _drawEdgeB: 15,
            _winAmount: toWei(100_000)
        });

        _addPrize({
            _drawEdgeA: 1,
            _drawEdgeB: 1,
            _winAmount: toWei(800_000)
        });

        _addPrize({
            _drawEdgeA: 888,
            _drawEdgeB: 888,
            _winAmount: toWei(10_000_000)
        });
    }

    function _addPrize(
        uint256 _drawEdgeA,
        uint256 _drawEdgeB,
        uint256 _winAmount
    )
        internal
    {
        prizeTiers.push(
            PrizeTier({
                drawEdgeA: _drawEdgeA,
                drawEdgeB: _drawEdgeB,
                winAmount: _winAmount
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
