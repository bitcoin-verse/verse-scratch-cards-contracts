// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "./IWETH.sol";

interface IWETHExtended is IWETH {

    function decimals()
        external
        view
        returns (uint8);
}