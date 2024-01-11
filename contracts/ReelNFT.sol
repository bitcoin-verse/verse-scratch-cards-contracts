// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonNFT.sol";
import "./helpers/TraitTiers.sol";

abstract contract ReelNFT is CommonNFT, TraitTiers {

    using Strings for uint256;

    uint32 public constant MAX_TRAIT_TYPES = 6;
    uint256 public constant MAX_RESULT_INDEX = 1000;

    uint256 public latestCharacterId;

    // stores results from VRF calls ceiled by MAX_RESULT_INDEX
    mapping(uint256 => uint256[]) public results;

    function tokenURI(
        uint256 _astroId
    )
        public
        view
        override
        returns (string memory)
    {
        if (_ownerOf(_astroId) == address(0x0)) {
            revert InvalidId();
        }

        return string(
            abi.encodePacked(
                baseURI,
                _astroId.toString()
            )
        );
    }

    function getTraitIds(
        uint256 _astroId
    )
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory traits = new uint256[](
            MAX_TRAIT_TYPES
        );

        traits = results[
            _astroId
        ];

        return traits;
    }

    function getTraitNames(
        uint256 _astroId
    )
        external
        view
        returns (Character memory astro)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        astro.backgroundColor = _getBackgroundColor(
            traits[0]
        );

        astro.backType = _getBackType(
            traits[1]
        );

        astro.bodyType = _getBodyType(
            traits[2]
        );

        astro.gearType = _getGearType(
            traits[3]
        );

        astro.headType = _getHeadType(
            traits[4]
        );

        astro.extraType = _getExtraType(
            traits[5]
        );

        return astro;
    }

    function getBackgroundColorName(
        uint256 _astroId
    )
        external
        view
        returns (string memory backgroundColor)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getBackgroundColor(
            traits[0]
        );
    }

    function getBackName(
        uint256 _astroId
    )
        external
        view
        returns (string memory backName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getBackType(
            traits[1]
        );
    }

    function getBodyName(
        uint256 _astroId
    )
        external
        view
        returns (string memory bodyName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getBodyType(
            traits[2]
        );
    }

    function getGearName(
        uint256 _astroId
    )
        external
        view
        returns (string memory gearName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getGearType(
            traits[3]
        );
    }

    function getHeadName(
        uint256 _astroId
    )
        external
        view
        returns (string memory headName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getHeadType(
            traits[4]
        );
    }

    function getExtraName(
        uint256 _astroId
    )
        external
        view
        returns (string memory extraName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getExtraType(
            traits[5]
        );
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
