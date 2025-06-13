// SPDX-License-Identifier: -- BCOM --

pragma solidity ^0.8.20;
import "./BasketHelper.sol";

/**
 * @title BasketSwap
 * @dev A contract to perform a basket swap of one input currency (ERC20 or native)
 * into five predefined output ERC20 tokens using Uniswap V2 or V3.
 * The 'inputToken' state variable dictates configuration: address(0) for native, ERC20 address otherwise.
 */
contract BasketSwap is Ownable, ReentrancyGuard {

    address public inputToken;
    address public wethAddress;
    address[5] public outputTokens;

    address public uniswapV2Router;
    address public uniswapV3Router;

    enum DexVersion { V2, V3 }

    constructor(
        address _inputToken,
        address[5] memory _outputTokens,
        address _v2Router,
        address _v3Router
    ) {
        inputToken = _inputToken;
        outputTokens = _outputTokens;
        uniswapV2Router = _v2Router;
        uniswapV3Router = _v3Router;
        
        // Always get WETH address from V2 router to ensure network compatibility
        wethAddress = IUniswapV2Router02(_v2Router).WETH();
    }

    function _validateAndPrepareInput(
        uint256 _totalAmountIn,
        uint256[5] memory _amountsToSwapForOutputs,
        uint256[5] memory _minAmountsOut
    )
        internal
        pure
    {
        uint256 calculatedTotalAmountIn = 0;

        for (uint256 i = 0; i < 5; i++) {
            calculatedTotalAmountIn += _amountsToSwapForOutputs[i];
            if (_amountsToSwapForOutputs[i] == 0) {
                require(_minAmountsOut[i] == 0, "Min output must be 0 for 0 input");
            }
        }

        require(
            _totalAmountIn == calculatedTotalAmountIn,
            "Sum of amountsToSwap != totalAmountIn"
        );
    }

    // --- Mixed V2/V3 Swaps ---
    function basketSwapMixedERC20(
        uint256 _totalAmountIn,
        uint256[5] memory _amountsToSwapForOutputs,
        uint256[5] memory _minAmountsOut,
        DexVersion[5] memory _dexVersionsToUse,
        uint24[5] memory _feeTiersV3,
        uint256 _deadline
    )
        external
        nonReentrant
    {
        _validateAndPrepareInput(
            _totalAmountIn,
            _amountsToSwapForOutputs,
            _minAmountsOut
        );

        IERC20(inputToken).transferFrom(
            msg.sender,
            address(this),
            _totalAmountIn
        );

        uint256[5] memory actualAmountsReceived;

        for (uint256 i = 0; i < 5; i++) {

            if (_amountsToSwapForOutputs[i] == 0) {
                actualAmountsReceived[i] = 0; continue;
            }

            uint256 currentAmountIn = _amountsToSwapForOutputs[i];

            if (_dexVersionsToUse[i] == DexVersion.V2) {

                IERC20(inputToken).approve(
                    uniswapV2Router,
                    currentAmountIn
                );

                address[] memory path = new address[](2);
                path[0] = inputToken;
                path[1] = outputTokens[i];

                uint256[] memory amounts = IUniswapV2Router02(uniswapV2Router).swapExactTokensForTokens(
                    currentAmountIn,
                    _minAmountsOut[i],
                    path,
                    address(this),
                    _deadline
                );

                actualAmountsReceived[i] = amounts[
                    amounts.length - 1
                ];

            } else if (_dexVersionsToUse[i] == DexVersion.V3) {

                IERC20(inputToken).approve(
                    uniswapV3Router,
                    currentAmountIn
                );

                ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
                    inputToken,
                    outputTokens[i],
                    _feeTiersV3[i],
                    address(this),
                    _deadline,
                    currentAmountIn,
                    _minAmountsOut[i],
                    0
                );

                actualAmountsReceived[i] = ISwapRouter(uniswapV3Router).exactInputSingle(
                    params
                );

            }
        }

        _transferOutputs(
            actualAmountsReceived
        );
    }

    // --- Uniswap V2 Specific Swaps ---
    function basketSwapV2ERC20(
        uint256 _totalAmountIn,
        uint256[5] memory _amountsToSwapForOutputs,
        uint256[5] memory _minAmountsOut,
        uint256 _deadline
    )
        external
        nonReentrant
    {
        _validateAndPrepareInput(
            _totalAmountIn,
            _amountsToSwapForOutputs,
            _minAmountsOut
        );

        IERC20(inputToken).transferFrom(
            msg.sender,
            address(this),
            _totalAmountIn
        );

        uint256[5] memory actualAmountsReceived;

        for (uint256 i = 0; i < 5; i++) {

            if (_amountsToSwapForOutputs[i] == 0) {
                actualAmountsReceived[i] = 0; continue;
            }

            uint256 currentAmountIn = _amountsToSwapForOutputs[i];

            IERC20(inputToken).approve(
                uniswapV2Router,
                currentAmountIn
            );

            address[] memory path = new address[](2);
            path[0] = inputToken;
            path[1] = outputTokens[i];

            uint256[] memory amounts = IUniswapV2Router02(uniswapV2Router).swapExactTokensForTokens(
                currentAmountIn,
                _minAmountsOut[i],
                path,
                address(this),
                _deadline
            );

            actualAmountsReceived[i] = amounts[
                amounts.length - 1
            ];
        }

        _transferOutputs(
            actualAmountsReceived
        );
    }

    function basketSwapV2Native(
        uint256 _totalAmountIn,
        uint256[5] memory _amountsToSwapForOutputs,
        uint256[5] memory _minAmountsOut,
        uint256 _deadline
    )
        external
        payable
        nonReentrant
    {
        require(msg.value == _totalAmountIn, "Native value sent does not match totalAmountIn");
        _validateAndPrepareInput(
            _totalAmountIn,
            _amountsToSwapForOutputs,
            _minAmountsOut
        );

        uint256[5] memory actualAmountsReceived;

        for (uint256 i = 0; i < 5; i++) {

            if (_amountsToSwapForOutputs[i] == 0) {
                actualAmountsReceived[i] = 0; continue;
            }

            uint256 currentAmountIn = _amountsToSwapForOutputs[i];

            address[] memory path = new address[](2);
            path[0] = wethAddress;
            path[1] = outputTokens[i];

            uint256[] memory amounts = IUniswapV2Router02(uniswapV2Router).swapExactETHForTokens{value: currentAmountIn}(
                _minAmountsOut[i],
                path,
                address(this),
                _deadline
            );

            actualAmountsReceived[i] = amounts[
                amounts.length - 1
            ];
        }

        _transferOutputs(
            actualAmountsReceived
        );
    }

    // --- Uniswap V3 Specific Swaps ---
    function basketSwapV3ERC20(
        uint256 _totalAmountIn,
        uint256[5] memory _amountsToSwapForOutputs,
        uint256[5] memory _minAmountsOut,
        uint24[5] memory _feeTiersV3,
        uint256 _deadline
    )
        external
        nonReentrant
    {
        _validateAndPrepareInput(
            _totalAmountIn,
            _amountsToSwapForOutputs,
            _minAmountsOut
        );

        IERC20(inputToken).transferFrom(
            msg.sender,
            address(this),
            _totalAmountIn
        );

        uint256[5] memory actualAmountsReceived;

        for (uint256 i = 0; i < 5; i++) {

            if (_amountsToSwapForOutputs[i] == 0) {
                actualAmountsReceived[i] = 0; continue;
            }

            uint256 currentAmountIn = _amountsToSwapForOutputs[i];

            IERC20(inputToken).approve(
                uniswapV3Router,
                currentAmountIn
            );

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
                inputToken,
                outputTokens[i],
                _feeTiersV3[i],
                address(this),
                _deadline,
                currentAmountIn,
                _minAmountsOut[i],
                0
            );

            actualAmountsReceived[i] = ISwapRouter(uniswapV3Router).exactInputSingle(
                params
            );
        }

        _transferOutputs(
            actualAmountsReceived
        );
    }

    function basketSwapV3Native(
        uint256 _totalAmountIn,
        uint256[5] memory _amountsToSwapForOutputs,
        uint256[5] memory _minAmountsOut,
        uint24[5] memory _feeTiersV3,
        uint256 _deadline
    )
        external
        payable
        nonReentrant
    {
        require(msg.value == _totalAmountIn, "Native value sent does not match totalAmountIn");
        _validateAndPrepareInput(
            _totalAmountIn,
            _amountsToSwapForOutputs,
            _minAmountsOut
        );


        uint256[5] memory actualAmountsReceived;

        for (uint256 i = 0; i < 5; i++) {

            if (_amountsToSwapForOutputs[i] == 0) {
                actualAmountsReceived[i] = 0; continue;
            }

            uint256 currentAmountIn = _amountsToSwapForOutputs[i];

            ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams(
                wethAddress,
                outputTokens[i],
                _feeTiersV3[i],
                address(this),
                _deadline,
                currentAmountIn,
                _minAmountsOut[i],
                0
            );

            actualAmountsReceived[i] = ISwapRouter(uniswapV3Router).exactInputSingle{
                value: currentAmountIn
            }(params);
        }

        _transferOutputs(
            actualAmountsReceived
        );
    }

    function _transferOutputs(
        uint256[5] memory _amountsReceived
    )
        internal
    {
        for (uint256 i = 0; i < 5; i++) {
            if (_amountsReceived[i] > 0) {
                IERC20(outputTokens[i]).transfer(
                    msg.sender,
                    _amountsReceived[i]
                );
            }
        }
    }

    function setInputToken(
        address _token
    )
        external
        onlyOwner
    {
        inputToken = _token;
    }

    function setOutputTokens(
        address[5] memory _tokens
    )
        external
        onlyOwner
    {
        outputTokens = _tokens;
    }

    function setWethAddress(
        address _newWethAddress
    )
        external
        onlyOwner
    {
        wethAddress = _newWethAddress;
    }

    function setUniswapV2Router(
        address _router
    )
        external
        onlyOwner
    {
        uniswapV2Router = _router;
    }

    function setUniswapV3Router(
        address _router
    )
        external
        onlyOwner
    {
        uniswapV3Router = _router;
    }

    function withdrawEther()
        external
        onlyOwner
    {
        uint256 balance = address(this).balance;
        if (balance > 0) {
            payable(owner).transfer(balance);
        }
    }

    function withdrawTokens(
        address _tokenAddress,
        uint256 _amount
    )
        external
        onlyOwner
    {
        IERC20(_tokenAddress).transfer(
            owner,
            _amount
        );
    }

    receive()
        external
        payable {}
}
