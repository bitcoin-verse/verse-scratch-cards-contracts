// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

contract TraitTiers {

    enum HelmetType {
        Default,
        Bronze,
        Silver,
        Gold,
        Platinum,
        Diamond
    }

    enum WeaponType {
        None,
        Simple,
        Medium,
        Advanced,
        Exceptional,
        BFG
    }

    enum OutfitType {
        Default,
        Bronze,
        Silver,
        Gold,
        Platinum,
        Diamond
    }

    struct Character {
        HelmetType helmet;
        OutfitType outfit;
        WeaponType weapon;
    }

    struct TraitTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        uint256 traitIndex;
    }

    TraitTier[] public traitTiers;

    constructor() {

        // Diamond Index
        traitTiers.push(
            TraitTier({
                drawEdgeA: 1,
                drawEdgeB: 1,
                traitIndex: 7
            })
        );

        // Platinum Index
        traitTiers.push(
            TraitTier({
                drawEdgeA: 2,
                drawEdgeB: 3,
                traitIndex: 6
            })
        );

        // Gold Index
        traitTiers.push(
            TraitTier({
                drawEdgeA: 4,
                drawEdgeB: 9,
                traitIndex: 5
            })
        );

        // Silver Index
        traitTiers.push(
            TraitTier({
                drawEdgeA: 10,
                drawEdgeB: 49,
                traitIndex: 4
            })
        );

        // Bronze Index
        traitTiers.push(
            TraitTier({
                drawEdgeA: 50,
                drawEdgeB: 149,
                traitIndex: 3
            })
        );

        // Wooden Index
        traitTiers.push(
            TraitTier({
                drawEdgeA: 150,
                drawEdgeB: 349,
                traitIndex: 2
            })
        );

        // Paper Index
        traitTiers.push(
            TraitTier({
                drawEdgeA: 350,
                drawEdgeB: 649,
                traitIndex: 1
            })
        );

        // Default Index
        traitTiers.push(
            TraitTier({
                drawEdgeA: 650,
                drawEdgeB: 1000,
                traitIndex: 0
            })
        );
    }

    function getRealTraits(
        uint256[] memory _results,
        uint256 _maxTraitTypes
    )
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory traits = new uint256[](
            _maxTraitTypes
        );

        traits = _results;

        uint256 i;
        uint256 loops = traits.length;

        for (i; i < loops;) {
            traits[i] = _getTraitTier(
                traits[i]
            );
            unchecked {
                ++i;
            }
        }

        return traits;
    }

    function _getTraitTier(
        uint256 _number
    )
        internal
        view
        returns (uint256 trait)
    {
        uint256 i;
        uint256 loops = traitTiers.length;

        while (i < loops) {

            TraitTier memory tt = traitTiers[i];

            if (_number >= tt.drawEdgeA && _number <= tt.drawEdgeB) {
                trait = tt.traitIndex;
                return trait;
            }

            unchecked {
                ++i;
            }
        }
    }
}
