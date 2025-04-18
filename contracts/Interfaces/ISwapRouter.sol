// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

interface ISwapRouter {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    )
        external
        payable
        returns (uint256 amountOut);

    function exactInput(
        ExactInputParams calldata params
    )
        external
        payable
        returns (uint256 amountOut);

    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    )
        external
        payable
        returns (uint256 amountIn);

    function exactOutput(
        ExactOutputParams calldata params
    )
        external
        payable
        returns (uint256 amountIn);
}