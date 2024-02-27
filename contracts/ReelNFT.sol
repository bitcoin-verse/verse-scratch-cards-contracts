// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

import "./helpers/Ownable.sol";
import "./CommonNFT.sol";
import "./helpers/TraitTiers.sol";

abstract contract ReelNFT is CommonNFT, TraitTiers, Ownable {

    using Strings for uint256;

    uint8 public MAX_REROLL_COUNT = 12;
    uint8 public constant BADGE_TRAIT_ID = 6;
    uint8 public constant MAX_TRAIT_TYPES = 7;
    uint256 public constant MAX_RESULT_INDEX = 1000;

    uint256 public latestCharacterId;

    mapping(uint256 => uint256[]) public results;

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

    function updateBaseURI(
        string memory _newBaseURI
    )
        external
        onlyOwner
    {
        baseURI = _newBaseURI;
    }

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
                _astroId.toString(),
                ".json"
            )
        );
    }
}
