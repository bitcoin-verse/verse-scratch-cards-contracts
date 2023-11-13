// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonBase.sol";
import "./PrizeTiers.sol";

error AlreadyClaimed();
error NotEnoughFunds();
error InvalidTicketId();

abstract contract ScratchNFT is PrizeTiers, CommonBase {

    using Strings for uint256;

    uint256 public ticketCost;
    uint256 public latestTicketId;

    mapping(uint256 => bool) public claimed;
    mapping(uint256 => uint256) public prizes;
    mapping(uint256 => uint256) public editions;

    struct Drawing {
        uint256 drawId;
        address ticketReceiver;
    }

    mapping(uint256 => Drawing) public requestIdToDrawing;

    event SetClaimed(
        uint256 indexed ticketId
    );

    event MintCompleted(
        uint256 indexed ticketId,
        uint256 indexed edition,
        uint256 prize
    );

    event PrizeClaimed(
        uint256 indexed ticketId,
        address indexed receiver,
        uint256 amount
    );

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
