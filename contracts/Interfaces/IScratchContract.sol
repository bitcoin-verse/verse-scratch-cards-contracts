// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

interface IScratchContract {

    function bulkPurchase(
        address _receiver,
        uint256 _ticketCount
    )
        external;

    function baseCost()
        external
        view
        returns (uint256);
}