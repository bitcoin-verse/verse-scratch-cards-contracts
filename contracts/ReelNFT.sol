// SPDX-License-Identifier: MIT
pragma solidity =0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

contract VerseReelNFT is ERC721Enumerable, Ownable, VRFConsumerBaseV2 {
    using Strings for uint256;

    VRFCoordinatorV2Interface private immutable vrfCoordinator;

    uint64 constant SUBSCRIPTION_ID = 951;
    uint16 constant CONFIRMATIONS_NEEDED = 3;
    uint32 constant CALLBACK_MAX_GAS = 2000000;
    bytes32 constant GAS_KEYHASH = 0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd;
    address constant TOKEN_ADDRESS = 0xc708D6F2153933DAA50B2D0758955Be0A93A8FEc;

    uint256 public tokenId;
    uint public drawId;

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
        ERC721(name, symbol)
        VRFConsumerBaseV2(_vrfCoordinatorV2Address)
    {
        vrfCoordinator = VRFCoordinatorV2Interface(
            _vrfCoordinatorV2Address
        );
    }

    // Mint a new NFT with a unique revealed property
    function mint(address _receiver) public onlyOwner {
        ++tokenId;
        _mint(_receiver, tokenId);

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
        emit DrawRequest(drawId, requestId, msg.sender);
    }

    function tokenURI(
        uint256 _tokenId
    )
        public
        view
        override
        returns (string memory)
    {
        require(_exists(_tokenId), "Token does not exist");
        string memory baseURI = _baseURI();

        return string(abi.encodePacked(baseURI, _tokenId.toString()));
    }

    function getTraits(uint256 _tokenId)
        public
        view
        returns (uint256[] memory)
    {
        return traits[_tokenId];
    }

    function reRollTrait(
        uint8 _traitNumber,
        uint256 _tokenId
    )
        public
    {
        // check if user owns the nft before rerolling
        // currently rerolling is free, can either charge verse or use credit syste
        require(ownerOf(_tokenId) == address(msg.sender), "only owner of NFT can reroll");
        rerollInProgress[tokenId] = true;

        uint256 requestId = vrfCoordinator.requestRandomWords(
            GAS_KEYHASH, // gas keyhash (sepoila 30 gwei)
            SUBSCRIPTION_ID, // subscription id
            CONFIRMATIONS_NEEDED, // conf needed
            CALLBACK_MAX_GAS, // callback gas
            1
        );
        ++drawId;

        Drawing memory newDrawing = Drawing({
            drawId: drawId,
            tokenId: _tokenId,
            reroll: true,
            rerollNumber: _traitNumber
        });

        requestIdToDrawing[requestId] = newDrawing;
        drawIdToRequestId[drawId] = requestId;
        emit DrawRequest(drawId, requestId, msg.sender);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords)
        internal
        override
    {
        Drawing storage currentDraw = requestIdToDrawing[_requestId];

        if(currentDraw.reroll == false) {
            // handle normal minting of NFT
            uint256[] memory numbers = new uint256[](6);

            for(uint i; i < 6;) {
                numbers[i] = uint32((_randomWords[i] % 15 + 1)); // number between 1 and 15
                ++i;
            }
            traits[currentDraw.tokenId] = numbers;
            completed[currentDraw.tokenId] = true;

            emit requestFulfilled(currentDraw.drawId, _requestId, numbers);
        } else {
            // handle a reroll
            uint256[] memory oldTraits = traits[currentDraw.tokenId];
            uint256[] memory newTraits = oldTraits;
            uint32 rolledNumber = uint32((_randomWords[0] % 15 + 1));
            newTraits[currentDraw.rerollNumber] = rolledNumber;
            traits[currentDraw.tokenId] = newTraits;
            rerollInProgress[tokenId] = false;
            emit rerollFulfilled(currentDraw.drawId, currentDraw.tokenId, currentDraw.rerollNumber, rolledNumber);
        }
    }

    function ownedByAddress(address _owner) public view returns (uint256[] memory)
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