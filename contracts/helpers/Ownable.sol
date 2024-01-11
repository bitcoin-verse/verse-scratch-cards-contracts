// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

error NoValue();
error NotMaster();
error NotProposed();

contract Ownable {

    address public master;
    address private proposedMaster;

    address internal constant ZERO_ADDRESS = address(0x0);

    modifier onlyProposed() {
        _onlyProposed();
        _;
    }

    function _onlyOwner()
        private
        view
    {
        if (msg.sender == master) {
            return;
        }

        revert NotMaster();
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyProposed()
        private
        view
    {
        if (msg.sender == proposedMaster) {
            return;
        }

        revert NotProposed();
    }

    event MasterProposed(
        address indexed proposer,
        address indexed proposedMaster
    );

    event ClaimedOwnership(
        address indexed newMaster,
        address indexed previousMaster
    );

    event RenouncedOwnership(
        address indexed previousMaster
    );

    constructor(
        address _master
    ) {
        if (_master == ZERO_ADDRESS) {
            revert NoValue();
        }
        master = _master;
    }

    /**
     * @dev Allows to propose next master.
     * Must be claimed by proposer.
     */
    function proposeOwner(
        address _proposedOwner
    )
        external
        onlyOwner
    {
        if (_proposedOwner == ZERO_ADDRESS) {
            revert NoValue();
        }

        proposedMaster = _proposedOwner;

        emit MasterProposed(
            msg.sender,
            _proposedOwner
        );
    }

    /**
     * @dev Allows to claim master role.
     * Must be called by proposer.
     */
    function claimOwnership()
        external
        onlyProposed
    {
        master = proposedMaster;

        emit ClaimedOwnership(
            master,
            msg.sender
        );
    }

    /**
     * @dev Removes master role.
     * No ability to be in control.
     */
    function renounceOwnership()
        external
        onlyOwner
    {
        master = ZERO_ADDRESS;
        proposedMaster = ZERO_ADDRESS;

        emit RenouncedOwnership(
            msg.sender
        );
    }
}
