// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonNFT.sol";
import "./helpers/TraitTiers.sol";

abstract contract ReelNFT is CommonNFT, TraitTiers {

    using Strings for uint256;

    uint32 public constant MAX_TRAIT_TYPES = 6;
    uint256 public constant MAX_TRAITS_INDEX = 1000;

    uint256 public latestCharacterId;
    mapping(uint256 => uint256[]) public traits;

    function tokenURI(
        uint256 _astroId
    )
        public
        view
        override
        returns (string memory)
    {
        if (_exists(_astroId) == false) {
            revert InvalidId();
        }

        string memory baseURI = _baseURI();

        return string(
            abi.encodePacked(
                baseURI,
                _astroId.toString()
            )
        );
    }

    /*
    function getTrait(
        uint256 _astroId,
        uint256 _traitType
    )
        external
        view
        returns (uint256)
        // returns (TraitType[] memory)
    {
        return traits[_astroId][_traitType];
    }
    */

    function _getTraitTier(
        uint256 _number
    )
        internal
        view
        returns (uint256 trait)
    {
        uint256 i;
        uint256 loops = traitTiers.length;

        for (i; i < loops;) {

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

    function getTraits(
        uint256 _astroId
    )
        external
        view
        returns (uint256[] memory)
        // returns (TraitType[] memory)
    {
        uint256[] memory tiers = new uint256[](
            MAX_TRAIT_TYPES
        );

        tiers = traits[_astroId];

        uint256 i;
        uint256 loops = tiers.length;

        for (i; i < loops;) {
            tiers[i] = _getTraitTier(
                tiers[i]
            );
            unchecked {
                ++i;
            }
        }

        return tiers;
    }

    function _increaseCharacterId()
        internal
        returns (uint256)
    {
        unchecked {
            return ++latestCharacterId;
        }
    }
}
