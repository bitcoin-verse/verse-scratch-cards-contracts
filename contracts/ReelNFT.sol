// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonNFT.sol";
import "./helpers/TraitTiers.sol";

abstract contract ReelNFT is CommonNFT, TraitTiers {

    using Strings for uint256;

    enum TraitType {
        Background,
        Reel,
        Symbol,
        SymbolColor,
        SymbolBackground,
        SymbolOverlay
    }

    uint256 constant MAX_TYPES = uint256(
        type(TraitType).max
    );

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

    function getTraits(
        uint256 _astroId
    )
        external
        view
        returns (uint256[] memory)
        // returns (TraitType[] memory)
    {
        return traits[_astroId];
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
