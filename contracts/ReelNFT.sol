// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonBase.sol";

abstract contract ReelNFT is ERC721Enumerable, CommonBase {

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

    struct Drawing {
        uint256 drawId;
        uint256 tokenId;
        uint256 traitId;
    }

    mapping(uint256 => uint256[]) public traits;

    mapping(uint256 => bool) public completed;
    mapping(uint256 => bool) public rerollInProgress;

    mapping(uint256 => Drawing) public requestIdToDrawing;

    constructor(
        string memory _name,
        string memory _symbol
    )
        ERC721(
            _name,
            _symbol
        )
    {}

    function tokenURI(
        uint256 _tokenId
    )
        public
        view
        override
        returns (string memory)
    {
        require(
            _exists(_tokenId),
            "Token does not exist"
        );

        string memory baseURI = _baseURI();

        return string(abi.encodePacked(
            baseURI,
            _tokenId.toString()
        ));
    }

    function _initialMint(
        Drawing memory currentDraw,
        uint256[] memory _randomWords,
        uint256 _requestId
    )
        internal
    {
        uint256[] memory numbers = new uint256[](
            MAX_TRAITS
        );

        for (uint256 i; i < MAX_TRAITS;) {
            numbers[i] = uniform(
                _randomWords[i],
                MAX_TRAITS
            );
            unchecked {
                ++i;
            }
        }

        /*
        for (uint8 i; i < MAX_TYPES;) {
            traits[currentDraw.tokenId][TraitType(i)] = uniform(
                _randomWords[i],
                MAX_TRAITS
            );
            unchecked {
                ++i;
            }
        }*/

        traits[currentDraw.tokenId] = numbers;
        completed[currentDraw.tokenId] = true;

        emit RequestFulfilled(
            currentDraw.drawId,
            _requestId,
            numbers
        );
    }

    function _rerollTrait(
        Drawing memory _currentDraw,
        uint256[] memory _randomWords
    )
        internal
    {
        uint256 rolledNumber = uniform(
            _randomWords[0],
            MAX_TRAITS
        );

        _updateTrait(
            _currentDraw.tokenId,
            _currentDraw.traitId,
            rolledNumber
        );

        rerollInProgress[_currentDraw.tokenId] = false;

        emit RerollFulfilled(
            _currentDraw.drawId,
            _currentDraw.tokenId,
            _currentDraw.traitId,
            rolledNumber
        );
    }

    function _updateTrait(
        uint256 _tokenId,
        uint256 _traitId,
        uint256 _rolledNumber
    )
        internal
    {
        traits[_astroId][_traitId] = _rolledNumber;
    }

    event RerollFulfilled(
        uint256 indexed drawId,
        uint256 indexed tokenId,
        uint256 traitNumber,
        uint256 rolledNumber
    );
}
