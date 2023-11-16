// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonNFT.sol";

abstract contract ReelNFT is CommonNFT {

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

    uint256 constant MAX_TRAITS = 15;
    uint256 public latestCharacterId;

    // @TODO: ex.completed mapping, can delete this mapping
    // this mapping is not needed, can use checkIfTokenExists
    // or can rely on traits mapping to determine if token exists.

    mapping(uint256 => bool) public minted;
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
}
