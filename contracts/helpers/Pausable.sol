// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "./Ownable.sol";

error ContractPaused();
error ContractNotPaused();

contract Pausable is Ownable {

    bool public paused;

    event Paused(
        address indexed caller,
        uint256 blocktime
    );

    event Unpaused(
        address indexed caller,
        uint256 blocktime
    );

    constructor()
        Ownable(msg.sender)
    {
        paused = false;
    }

    modifier whenNotPaused() {
        if (paused == true) {
            revert ContractPaused();
        }
        _;
    }

    modifier whenPaused() {
        if (paused == false) {
            revert ContractNotPaused();
        }
        _;
    }

    function pauseContract()
        external
        onlyOwner
        whenNotPaused
    {
        paused = true;

        emit Paused(
            msg.sender,
            block.timestamp
        );
    }

    function unpauseContract()
        external
        onlyOwner
        whenPaused
    {
        paused = false;

        emit Unpaused(
            msg.sender,
            block.timestamp
        );
    }
}
