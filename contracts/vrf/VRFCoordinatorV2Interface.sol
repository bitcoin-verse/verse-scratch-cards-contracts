// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

interface VRFCoordinatorV2Interface {

    function getRequestConfig()
        external
        view
        returns (
            uint16,
            uint32,
            bytes32[] memory
        );

    function requestRandomWords(
        bytes32 _keyHash,
        uint64 _subId,
        uint16 _minimumRequestConfirmations,
        uint32 _callbackGasLimit,
        uint32 _numWords
    )
        external
        returns (
            uint256 requestId
        );

    function createSubscription()
        external
        returns (
            uint64 subId
        );

    function getSubscription(
        uint64 _subId
    )
        external
        view
        returns (
            uint96 balance,
            uint64 reqCount,
            address owner,
            address[] memory consumers
        );

    function requestSubscriptionOwnerTransfer(
        uint64 _subId,
        address _newOwner
    )
        external;

    function acceptSubscriptionOwnerTransfer(
        uint64 _subId
    )
        external;

    function addConsumer(
        uint64 _subId,
        address _consumer
    )
        external;

    function removeConsumer(
        uint64 _subId,
        address _consumer
    )
        external;

    function cancelSubscription(
        uint64 _subId,
        address _to
    )
        external;

    function pendingRequestExists(
        uint64 _subId
    )
        external
        view
        returns (bool);
}
