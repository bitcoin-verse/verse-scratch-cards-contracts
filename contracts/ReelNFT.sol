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
        address _vrfCoordinatorV2Address,
        string memory name,
        string memory symbol
    )
        ERC721(
            name,
            symbol
        )
        VRFConsumerBaseV2(
            _vrfCoordinatorV2Address
        )
    {
        vrfCoordinator = VRFCoordinatorV2Interface(
            _vrfCoordinatorV2Address
        );
    }

    // Mint a new NFT with a unique revealed property
    function _mintCharacter(
        address _receiver
    )
        internal
    {
        ++tokenId;

        _mint(
            _receiver,
            tokenId
        );

        // create a request to VRF
        uint256 requestId = vrfCoordinator.requestRandomWords(
            GAS_KEYHASH, // gas keyhash (sepoila 30 gwei)
            SUBSCRIPTION_ID, // subscription id
            CONFIRMATIONS_NEEDED, // conf needed
            CALLBACK_MAX_GAS, // callback gas
            6 // amount of numbers, first one is trait one etc
        );

        ++drawId;

        Drawing memory newDrawing = Drawing({
            drawId: drawId,
            tokenId: tokenId,
            reroll: false,
            rerollNumber: 0
        });

        requestIdToDrawing[requestId] = newDrawing;
        drawIdToRequestId[drawId] = requestId;

        emit DrawRequest(
            drawId,
            requestId,
            msg.sender
        );
    }

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
