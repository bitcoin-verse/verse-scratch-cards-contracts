// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "./IERC20V.sol";

interface IERC20VExtended is IERC20V {
    function decimals()
        external
        view
        returns (uint8);
}