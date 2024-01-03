// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonNFT.sol";

abstract contract ReelNFT is CommonNFT {

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
        if (_exists(_astroId) == false) {
            revert InvalidId();
        }

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



    function getTraits(
        uint256 _astroId
    )
        external
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

    function _increaseCharacterId()
        internal
        returns (uint256)
    {
        unchecked {
            return ++latestCharacterId;
        }
    }
}
