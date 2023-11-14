// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonBase.sol";

abstract contract ReelNFT is CommonBase {

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

    mapping(uint256 => bool) public completed;
    mapping(uint256 => bool) public rerollInProgress;
    mapping(uint256 => uint256[]) public traits;

    struct Drawing {
        uint256 drawId;
        uint256 astroId;
        uint256 traitId;
    }

    mapping(uint256 => Drawing) public requestIdToDrawing;

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


    event RerollFulfilled(
        uint256 indexed drawId,
        uint256 indexed astroId,
        uint256 traitNumber,
        uint256 rolledNumber
    );
}
