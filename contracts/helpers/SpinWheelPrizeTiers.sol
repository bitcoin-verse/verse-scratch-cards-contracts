// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

contract SpinWheelPrizeTiers {

    PrizeTier[] public spinTiers;

    struct PrizeTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        uint256 multiplier; // Multiplier instead of winAmount (0, 1, 3, 10)
    }

    /**
     * RNG between 1 and 100 values
     * Based on spin wheel probabilities:
     * - 15% chance: 10x payout (1-15)
     * - 30% chance: 3x payout (16-45)
     * - 30% chance: 1x payout (46-75)
     * - 25% chance: 0x payout (76-100)
     */
    constructor() {
        // 15% chance for 10x (1-15)
        spinTiers.push(
            PrizeTier({
                drawEdgeA: 1,
                drawEdgeB: 15,
                multiplier: 10
            })
        );

        // 30% chance for 3x (16-45)
        spinTiers.push(
            PrizeTier({
                drawEdgeA: 16,
                drawEdgeB: 45,
                multiplier: 3
            })
        );

        // 30% chance for 1x (46-75)
        spinTiers.push(
            PrizeTier({
                drawEdgeA: 46,
                drawEdgeB: 75,
                multiplier: 1
            })
        );

        // 25% chance for 0x (76-100)
        spinTiers.push(
            PrizeTier({
                drawEdgeA: 76,
                drawEdgeB: 100,
                multiplier: 0
            })
        );
    }

    /**
     * @notice Get spin outcome multiplier based on random number
     * @param _randomNumber Random number between 1-100
     * @return multiplier The multiplier for this spin (0, 1, 3, or 10)
     */
    function getSpinMultiplier(
        uint256 _randomNumber
    )
        internal
        pure
        returns (uint256 multiplier)
    {
        // Create tier array inline for pure function
        PrizeTier[4] memory tiers = [
            PrizeTier({drawEdgeA: 1, drawEdgeB: 15, multiplier: 10}),   // 15% chance for 10x
            PrizeTier({drawEdgeA: 16, drawEdgeB: 45, multiplier: 3}),   // 30% chance for 3x
            PrizeTier({drawEdgeA: 46, drawEdgeB: 75, multiplier: 1}),   // 30% chance for 1x
            PrizeTier({drawEdgeA: 76, drawEdgeB: 100, multiplier: 0})   // 25% chance for 0x
        ];

        uint256 i;
        uint256 loops = tiers.length;

        for (i; i < loops;) {
            PrizeTier memory tier = tiers[i];

            if (_randomNumber >= tier.drawEdgeA && _randomNumber <= tier.drawEdgeB) {
                multiplier = tier.multiplier;
                return multiplier;
            }

            unchecked {
                ++i;
            }
        }

        // Fallback to 0 multiplier if no tier matches (shouldn't happen)
        return 0;
    }
}