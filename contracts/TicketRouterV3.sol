// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "./Interfaces/IERC20V.sol";
import "./Interfaces/IWETH.sol";
import "./Interfaces/ISwapRouter.sol";
import "./Interfaces/IQuoter.sol";
import "./Interfaces/IScratchContract.sol";

contract TicketRouterV3 {

    address public immutable WETH;
    address public immutable VERSE_TOKEN;
    address public immutable SWAP_ROUTER;
    address public immutable QUOTER;

    uint24 public constant DEFAULT_POOL_FEE = 3000;
    uint24 public constant VERSE_WETH_POOL_FEE = 3000;

    mapping(address => uint24) public customPoolFees;
    address public constant WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    receive()
        external
        payable {}

    fallback()
        external
        payable {}

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "TicketRouterV3: NOT_OWNER"
        );
        _;
    }

    address private owner;

    event TokenPurchase(
        address indexed buyer,
        address indexed token,
        uint256 amount,
        uint256 receivedAmount
    );

    event FeeUpdated(
        address indexed token,
        uint24 fee
    );

    constructor(
        address _weth,
        address _verseToken,
        address _swapRouter,
        address _quoter
    ) {
        WETH = _weth;
        VERSE_TOKEN = _verseToken;
        SWAP_ROUTER = _swapRouter;
        QUOTER = _quoter;
        owner = msg.sender;
    }

    function setCustomPoolFee(
        address _token,
        uint24 _fee
    )
        external
        onlyOwner
    {
        customPoolFees[_token] = _fee;
        emit FeeUpdated(
            _token,
            _fee
        );
    }

    function getPoolFee(
        address _token
    )
        public
        view
        returns (uint24)
    {
        uint24 customFee = customPoolFees[
            _token
        ];

        return customFee > 0
            ? customFee
            : DEFAULT_POOL_FEE;
    }

    function encodePath(
        address _tokenIn,
        address _tokenMid,
        address _tokenOut,
        uint24 _fee1,
        uint24 _fee2
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            _tokenOut,
            _fee2,
            _tokenMid,
            _fee1,
            _tokenIn
        );
    }

    function _encodeDirectPath(
        address _tokenIn,
        address _tokenOut,
        uint24 _fee
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(
            _tokenOut,
            _fee,
            _tokenIn
        );
    }

    function getNativePriceForTickets(
        address _scratcherContract,
        uint256 _ticketCount
    )
        public
        returns (uint256 nativeAmount)
    {
        // Get the base cost of a ticket from the scratcher contract
        IScratchContract scratcher = IScratchContract(
            _scratcherContract
        );

        // Calculate total VERSE tokens needed for all tickets
        uint256 totalVerseNeeded = scratcher.baseCost() * _ticketCount;

        // Step 1: Get WETH needed for VERSE
        bytes memory pathStep1 = abi.encodePacked(
            VERSE_TOKEN,
            VERSE_WETH_POOL_FEE,
            WETH
        );

        // Get WETH amount needed for VERSE tokens
        uint256 wethNeeded = IQuoter(QUOTER).quoteExactOutput(
            pathStep1,
            totalVerseNeeded
        );

        // Step 2: Get WMATIC needed for WETH
        bytes memory pathStep2 = abi.encodePacked(
            WETH,
            getPoolFee(WMATIC),
            WMATIC
        );

        // Get the final WMATIC amount needed
        return IQuoter(QUOTER).quoteExactOutput(
            pathStep2,
            wethNeeded
        );
    }

    function buyTicketsWithNative(
        address _scratcherContract,
        uint256 _ticketCount
    )
        external
        payable
    {
        _buyTicketsWithNative(
            _scratcherContract,
            _ticketCount,
            msg.sender
        );
    }

    function giftTicketsWithNative(
        address _scratcherContract,
        uint256 _ticketCount,
        address _recipient
    )
        external
        payable
    {
        _buyTicketsWithNative(
            _scratcherContract,
            _ticketCount,
            _recipient
        );
    }

    function _buyTicketsWithNative(
        address _scratcherContract,
        uint256 _ticketCount,
        address _recipient
    )
        internal
    {
        require(
            _ticketCount > 0,
            "TicketRouterV3: INVALID_COUNT"
        );

        IScratchContract scratcher = IScratchContract(
            _scratcherContract
        );

        uint256 totalVerseNeeded = scratcher.baseCost()
            * _ticketCount;

        // On Polygon, native currency is MATIC, but VERSE pairs with WETH
        // So we need to:
        // 1. First wrap MATIC to WMATIC
        // 2. Then swap WMATIC for WETH
        // 3. Then swap WETH for VERSE

        // First wrap native MATIC to WMATIC
        IWETH(WMATIC).deposit{
            value: msg.value
        }();

        uint256 nativeRequired = getNativePriceForTickets(
            _scratcherContract,
            _ticketCount
        );

        require(
            msg.value >= nativeRequired,
            "TicketRouterV3: INSUFFICIENT_NATIVE_CURRENCY"
        );

        // Approve WMATIC for swapping
        IERC20V(WMATIC).approve(
            SWAP_ROUTER,
            msg.value
        );

        bytes memory wethToVersePath = abi.encodePacked(
            VERSE_TOKEN,
            VERSE_WETH_POOL_FEE,
            WETH
        );

        // Quote how much WETH is needed
        uint256 wethNeeded = IQuoter(QUOTER).quoteExactOutput(
            wethToVersePath,
            totalVerseNeeded
        );

        // Step 1: Convert WMATIC to WETH
        ISwapRouter.ExactOutputSingleParams memory wmaticToWethParams = ISwapRouter.ExactOutputSingleParams({
            tokenIn: WMATIC,
            tokenOut: WETH,
            fee: getPoolFee(WMATIC),
            recipient: address(this),
            deadline: block.timestamp,
            amountOut: wethNeeded,
            amountInMaximum: msg.value,
            sqrtPriceLimitX96: 0
        });

        // Get WETH from WMATIC
        uint256 wmaticUsed = ISwapRouter(SWAP_ROUTER).exactOutputSingle(
            wmaticToWethParams
        );

        // Approve WETH for second swap
        IERC20V(WETH).approve(
            SWAP_ROUTER,
            wethNeeded
        );

        // Step 2: Convert WETH to VERSE
        ISwapRouter.ExactOutputSingleParams memory wethToVerseParams = ISwapRouter.ExactOutputSingleParams({
            tokenIn: WETH,
            tokenOut: VERSE_TOKEN,
            fee: VERSE_WETH_POOL_FEE,
            recipient: address(this),
            deadline: block.timestamp,
            amountOut: totalVerseNeeded,
            amountInMaximum: wethNeeded,
            sqrtPriceLimitX96: 0
        });

        // Get VERSE from WETH
        ISwapRouter(SWAP_ROUTER).exactOutputSingle(
            wethToVerseParams
        );

        // Refund unused WMATIC
        if (msg.value > wmaticUsed) {
            uint256 refundAmount = msg.value - wmaticUsed;

            // Withdraw WMATIC back to native MATIC
            IWETH(WMATIC).withdraw(
                refundAmount
            );

            // Send the refund to the user
            payable(msg.sender).transfer(
                refundAmount
            );
        }

        // Approve VERSE for the scratcher contract
        IERC20V(VERSE_TOKEN).approve(
            _scratcherContract,
            totalVerseNeeded
        );

        // Purchase tickets
        scratcher.bulkPurchase(
            _recipient,
            _ticketCount
        );

        emit TokenPurchase(
            _recipient,
            WMATIC,
            wmaticUsed,
            totalVerseNeeded
        );
    }

    function buyTickets(
        address scratcherContract,
        uint256 _ticketCount
    )
        public
    {
        _buyTickets(
            scratcherContract,
            _ticketCount,
            msg.sender
        );
    }

    function giftTickets(
        address scratcherContract,
        uint256 _ticketCount,
        address _recipient
    )
        public
    {
        _buyTickets(
            scratcherContract,
            _ticketCount,
            _recipient
        );
    }

    function _buyTickets(
        address scratcherContract,
        uint256 _ticketCount,
        address _recipient
    )
        internal
    {
        require(
            _ticketCount > 0,
            "TicketRouterV3: INVALID_COUNT"
        );

        IScratchContract scratcher = IScratchContract(
            scratcherContract
        );

        uint256 totalCost = scratcher.baseCost()
            * _ticketCount;

        IERC20V(VERSE_TOKEN).transferFrom(
            msg.sender,
            address(this),
            totalCost
        );

        IERC20V(VERSE_TOKEN).approve(
            scratcherContract,
            totalCost
        );

        scratcher.bulkPurchase(
            _recipient,
            _ticketCount
        );

        emit TokenPurchase(
            _recipient,
            VERSE_TOKEN,
            totalCost,
            totalCost
        );
    }

    function getTokenPriceForTickets(
        address _scratcherContract,
        uint256 _ticketCount,
        address _inputToken
    )
        public
        returns (uint256 tokenAmount)
    {
        IScratchContract scratcher = IScratchContract(
            _scratcherContract
        );

        uint256 totalVerseNeeded = scratcher.baseCost()
            * _ticketCount;

        // If the input token is VERSE, return the exact amount
        if (_inputToken == VERSE_TOKEN) {
            return totalVerseNeeded;
        }

        // If the input token is WETH, use direct swap path
        if (_inputToken == WETH) {

            bytes memory pathWeth = abi.encodePacked(
                VERSE_TOKEN,
                VERSE_WETH_POOL_FEE,
                WETH
            );

            return IQuoter(QUOTER).quoteExactOutput(
                pathWeth,
                totalVerseNeeded
            );
        }

        uint24 tokenWethFee = getPoolFee(
            _inputToken
        );

        bytes memory path = encodePath(
            _inputToken,
            WETH,
            VERSE_TOKEN,
            tokenWethFee,
            VERSE_WETH_POOL_FEE
        );

        return IQuoter(QUOTER).quoteExactOutput(
            path,
            totalVerseNeeded
        );
    }

    function testEncodePath(
        address _tokenIn,
        address _tokenMid,
        address _tokenOut,
        uint24 _fee1,
        uint24 _fee2
    )
        public
        pure
        returns (bytes memory)
    {
        return encodePath(
            _tokenIn,
            _tokenMid,
            _tokenOut,
            _fee1,
            _fee2
        );
    }

    function testEncodeDirectPath(
        address _tokenIn,
        address _tokenOut,
        uint24 _fee
    )
        public
        pure
        returns (bytes memory)
    {
        return _encodeDirectPath(
            _tokenIn,
            _tokenOut,
            _fee
        );
    }

    function _buyWithToken(
        address _scratcherContract,
        uint256 _ticketCount,
        address _inputToken,
        uint256 _maxTokenAmount,
        address _recipient
    )
        internal
    {
        require(
            _ticketCount > 0,
            "TicketRouterV3: INVALID_COUNT"
        );

        // Special case for VERSE token to skip swapping
        if (_inputToken == VERSE_TOKEN) {
            buyTickets(
                _scratcherContract,
                _ticketCount
            );

            return;
        }

        IScratchContract scratcher = IScratchContract(
            _scratcherContract
        );

        uint256 totalVerseNeeded = scratcher.baseCost()
            * _ticketCount;

        // Get required token amount
        uint256 tokenRequired = getTokenPriceForTickets(
            _scratcherContract,
            _ticketCount,
            _inputToken
        );

        require(
            _maxTokenAmount >= tokenRequired,
            "TicketRouterV3: INVALID_COUNT"
        );

        // Transfer tokens from user to this contract
        IERC20V(_inputToken).transferFrom(
            msg.sender,
            address(this),
            _maxTokenAmount
        );

        // Approve tokens for router
        IERC20V(_inputToken).approve(
            SWAP_ROUTER,
            _maxTokenAmount
        );

        uint256 amountIn;

        if (_inputToken == WETH) {
            ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
                tokenIn: WETH,
                tokenOut: VERSE_TOKEN,
                fee: VERSE_WETH_POOL_FEE,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: totalVerseNeeded,
                amountInMaximum: _maxTokenAmount,
                sqrtPriceLimitX96: 0
            });

            amountIn = ISwapRouter(SWAP_ROUTER).exactOutputSingle(
                params
            );

        } else {

            uint24 tokenWethFee = getPoolFee(
                _inputToken
            );

            bytes memory wethToVersePath = abi.encodePacked(
                VERSE_TOKEN,
                VERSE_WETH_POOL_FEE,
                WETH
            );

            uint256 wethNeeded = IQuoter(QUOTER).quoteExactOutput(
                wethToVersePath,
                totalVerseNeeded
            );

            // Step 2: Swap input token to WETH
            ISwapRouter.ExactOutputSingleParams memory tokenToWethParams = ISwapRouter.ExactOutputSingleParams({
                tokenIn: _inputToken,
                tokenOut: WETH,
                fee: tokenWethFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: wethNeeded,
                amountInMaximum: _maxTokenAmount,
                sqrtPriceLimitX96: 0
            });

            amountIn = ISwapRouter(SWAP_ROUTER).exactOutputSingle(
                tokenToWethParams
            );

            // Step 3: Swap WETH to VERSE
            IERC20V(WETH).approve(
                SWAP_ROUTER,
                wethNeeded
            );

            ISwapRouter.ExactOutputSingleParams memory wethToVerseParams = ISwapRouter.ExactOutputSingleParams({
                tokenIn: WETH,
                tokenOut: VERSE_TOKEN,
                fee: VERSE_WETH_POOL_FEE,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: totalVerseNeeded,
                amountInMaximum: wethNeeded,
                sqrtPriceLimitX96: 0
            });

            ISwapRouter(SWAP_ROUTER).exactOutputSingle(
                wethToVerseParams
            );
        }

        // Refund unused tokens
        if (_maxTokenAmount > amountIn) {
            IERC20V(_inputToken).transfer(
                msg.sender,
                _maxTokenAmount - amountIn
            );
        }

        // Approve VERSE for the scratcher contract
        IERC20V(VERSE_TOKEN).approve(
            _scratcherContract,
            totalVerseNeeded
        );

        // Purchase tickets
        scratcher.bulkPurchase(
            _recipient,
            _ticketCount
        );

        emit TokenPurchase(
            _recipient,
            _inputToken,
            amountIn,
            totalVerseNeeded
        );
    }

    function buyWithToken(
        address _scratcherContract,
        uint256 _ticketCount,
        address _inputToken,
        uint256 _maxTokenAmount
    )
        public
    {
        _buyWithToken(
            _scratcherContract,
            _ticketCount,
            _inputToken,
            _maxTokenAmount,
            msg.sender
        );
    }

    function giftWithToken(
        address _scratcherContract,
        uint256 _ticketCount,
        address _inputToken,
        uint256 _maxTokenAmount,
        address _recipient
    )
        public
    {
        _buyWithToken(
            _scratcherContract,
            _ticketCount,
            _inputToken,
            _maxTokenAmount,
            _recipient
        );
    }
}