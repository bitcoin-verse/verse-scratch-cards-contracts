// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

abstract contract VRFConsumerBaseV2 {

    error OnlyCoordinatorCanFulfill(
        address have,
        address want
    );

    address private immutable vrfCoordinator;

    constructor(
        address _vrfCoordinator
    )
    {
        vrfCoordinator = _vrfCoordinator;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    )
        internal
        virtual;

    function rawFulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    )
        external
    {
        if (msg.sender != vrfCoordinator) {
            revert OnlyCoordinatorCanFulfill(
                msg.sender,
                vrfCoordinator
            );
        }

        fulfillRandomWords(
            _requestId,
            _randomWords
        );
    }
}
