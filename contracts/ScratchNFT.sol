// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

error InvalidTicketId();

contract ScratchNFT is ERC721Enumerable {

    using Strings for uint256;

    mapping(uint256 => bool) public claimed;
    mapping(uint256 => string) public tokenURIs;
    mapping(uint256 => uint256) public editions;
    mapping(uint256 => uint256) public prizes;

    event SetClaimed(
        uint256 indexed ticketId
    );

    event MintCompleted(
        uint256 indexed ticketId,
        uint256 edition,
        uint256 prize
    );

    constructor(
        string memory _name,
        string memory _symbol
    )
        ERC721(
            _name,
            _symbol
        )
    {}

    function _mintTicket(
        uint256 _ticketId,
        uint256 _editionId,
        uint256 _prize,
        address _receiver
    )
        internal
    {
        prizes[_ticketId] = _prize;
        editions[_ticketId] = _editionId;

        _mint(
            _receiver,
            _ticketId
        );

        emit MintCompleted(
            _ticketId,
            _editionId,
            _prize
        );
    }

    function tokenURI(
        uint256 _ticketId
    )
        public
        view
        override
        returns (string memory)
    {
        if (_exists(_ticketId) == false) {
            revert InvalidTicketId();
        }

        string memory baseURI = _baseURI();
        string memory claimDone = claimed[_ticketId]
            ? "true"
            : "false";

        uint256 editionIdFromTicket = editions[
            _ticketId
        ];

        return string(
            abi.encodePacked(
                baseURI,
                _ticketId.toString(),
                "/",
                claimDone,
                "&edition=",
                editionIdFromTicket.toString()
            )
        );
    }

    function ownedByAddress(
        address _owner
    )
        external
        view
        returns (uint256[] memory)
    {
        uint256 ownerTicketCount = balanceOf(
            _owner
        );

        uint256[] memory ticketIds = new uint256[](
            ownerTicketCount
        );

        uint256 i;

        for (i; i < ownerTicketCount;) {
            ticketIds[i] = tokenOfOwnerByIndex(
                _owner,
                i
            );

            unchecked {
                ++i;
            }
        }

        return ticketIds;
    }

    function _setClaimed(
        uint256 _ticketId
    )
        internal
    {
        if (_exists(_ticketId) == false) {
            revert InvalidTicketId();
        }

        claimed[_ticketId] = true;

        emit SetClaimed(
            _ticketId
        );
    }
}
