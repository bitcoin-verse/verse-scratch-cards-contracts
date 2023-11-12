// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

abstract contract ReelNFT is ERC721Enumerable {

    using Strings for uint256;

    uint8 constant MAX_TRAITS = 6;

    uint256 public tokenId;
    uint256 public drawId;

    struct Drawing {
        uint256 drawId;
        uint256 tokenId;
        bool reroll;
        uint8 rerollNumber;
    }

    mapping(uint256 => string) public tokenURIs;
    mapping(uint256 => uint256[]) public traits;

    mapping(uint256 => bool) public completed;
    mapping(uint256 => bool) public rerollInProgress;

    mapping(uint256 => uint256) public drawIdToRequestId;
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
        // handle normal minting of NFT
        uint256[] memory numbers = new uint256[](
            MAX_TRAITS
        );

        for (uint256 i; i < MAX_TRAITS;) {
            // @TODO: use uniform function
            numbers[i] = uint32((_randomWords[i] % 15 + 1));
            unchecked {
                ++i;
            }
        }

        traits[currentDraw.tokenId] = numbers;
        completed[currentDraw.tokenId] = true;

        emit requestFulfilled(
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
        uint256[] memory currentTraits = traits[
            _currentDraw.tokenId
        ];

        // @TODO: use uniform function here and avoid index[0]
        uint32 rolledNumber = uint32((_randomWords[0] % 15 + 1));

        currentTraits[_currentDraw.rerollNumber] = rolledNumber;
        traits[_currentDraw.tokenId] = currentTraits;
        rerollInProgress[tokenId] = false;

        emit rerollFulfilled(
            _currentDraw.drawId,
            _currentDraw.tokenId,
            _currentDraw.rerollNumber,
            rolledNumber
        );
    }

    function ownedByAddress(
        address _owner
    )
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokenIds;
    }

    event DrawRequest(
        uint256 indexed drawId,
        uint256 indexed requestId,
        address indexed ticketReceiver
    );

    event requestFulfilled(
        uint256 indexed drawId,
        uint256 indexed requestId,
        uint256[] numbers
    );

    event rerollFulfilled(
        uint256 indexed drawId,
        uint256 indexed tokenId,
        uint256 traitNumber,
        uint256 rolledNumber
    );
}
