// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "./IERC20V.sol";

interface IWETH is IERC20V {

    function deposit()
        external
        payable;

    function withdraw(uint256)
        external;
}