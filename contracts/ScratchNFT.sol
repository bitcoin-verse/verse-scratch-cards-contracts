// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./CommonNFT.sol";
import "./helpers/PrizeTiers.sol";

error AlreadyClaimed();

abstract contract ScratchNFT is CommonNFT, PrizeTiers  {

    using Strings for uint256;

    uint256 public latestTicketId;

    mapping(uint256 => bool) public claimed;
    mapping(uint256 => uint256) public prizes;

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
        address indexed recipient,
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

        _mint(
            _receiver,
            _ticketId
        );

        emit MintCompleted(
            _ticketId,
            _editionId,
            _receiver,
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
            revert InvalidId();
        }

        string memory baseURI = _baseURI();
        string memory claimDone = claimed[_ticketId]
            ? "true"
            : "false";

        return string(
            abi.encodePacked(
                baseURI,
                _ticketId.toString(),
                "/",
                claimDone,
                ".json"
            )
        );
    }

    function _setClaimed(
        uint256 _ticketId
    )
        internal
    {
        if (claimed[_ticketId] == true) {
            revert AlreadyClaimed();
        }

        claimed[_ticketId] = true;

        emit SetClaimed(
            _ticketId
        );
    }
}
