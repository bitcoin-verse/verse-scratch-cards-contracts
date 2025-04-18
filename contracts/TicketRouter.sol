// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "./ScratchVRF.sol";

interface IScratchContract {

    function bulkPurchase(
        address _receiver,
        uint256 _ticketCount
    )
        external;
}

interface IUniswapV2Router02 {

    function WETH()
        external
        pure
        returns (address);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    )
        external
        view
        returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256[] memory amounts);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        returns (uint256[] memory amounts);
}

contract TicketRouter {

    address public immutable WETH;
    address public immutable VERSE_TOKEN;

    receive()
        external
        payable
    {}

    fallback()
        external
        payable
    {}

    event TokenPurchase(
        address indexed buyer,
        address indexed token,
        uint256 amount,
        uint256 receivedAmount
    );

    constructor(
        address _weth,
        address _verseToken
    ) {
        WETH = _weth;
        VERSE_TOKEN = _verseToken;
    }

    function getETHPriceForTickets(
        address _scratcherContract,
        uint256 _ticketCount,
        address _uniswapRouter
    )
        public
        view
        returns (uint256 ethAmount)
    {
        ScratchVRF scratcher = ScratchVRF(
            _scratcherContract
        );

        uint256 totalCost = scratcher.baseCost() * _ticketCount;

        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = VERSE_TOKEN;

        uint256[] memory amounts = IUniswapV2Router02(_uniswapRouter).getAmountsIn(
            totalCost,
            path
        );

        return amounts[0];
    }

    function buyTicketsWithETH(
        address _scratcherContract,
        uint256 _ticketCount,
        address _uniswapRouter
    )
        external
        payable
    {
        require(
            _ticketCount > 0,
            "Ticket count must be greater than 0"
        );

        ScratchVRF scratcher = ScratchVRF(
            _scratcherContract
        );

        uint256 ethRequired = getETHPriceForTickets(
            _scratcherContract,
            _ticketCount,
            _uniswapRouter
        );

        require(
            msg.value >= ethRequired,
            "Insufficient ETH sent"
        );

        // Swap ETH for VERSE tokens
        uint256 totalCost = scratcher.baseCost() * _ticketCount;
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = VERSE_TOKEN;

        uint256[] memory amounts = IUniswapV2Router02(_uniswapRouter).swapETHForExactTokens{
            value: msg.value
        }(
            totalCost,
            path,
            address(this),
            block.timestamp
        );

        uint256 swapAmount = amounts[0];

        if (msg.value > swapAmount) {
            payable(msg.sender).transfer(
                msg.value - swapAmount
            );
        }

        IERC20(VERSE_TOKEN).approve(
            _scratcherContract,
            totalCost
        );

        scratcher.bulkPurchase(
            msg.sender,
            _ticketCount
        );

        emit TokenPurchase(
            msg.sender,
            WETH,
            msg.value,
            swapAmount
        );
    }

    function buyTickets(
        address scratcherContract,
        uint256 _ticketCount
    )
        external
    {
        require(
            _ticketCount > 0,
            "Ticket count must be greater than 0"
        );

        ScratchVRF scratcher = ScratchVRF(
            scratcherContract
        );

        uint256 totalCost = scratcher.baseCost() * _ticketCount;

        IERC20(VERSE_TOKEN).transferFrom(
            msg.sender,
            address(this),
            totalCost
        );

        IERC20(VERSE_TOKEN).approve(
            scratcherContract,
            totalCost
        );

        scratcher.bulkPurchase(
            msg.sender,
            _ticketCount
        );

        emit TokenPurchase(
            msg.sender,
            VERSE_TOKEN,
            totalCost,
            totalCost
        );
    }

    function getTokenPriceForTickets(
        address _scratcherContract,
        uint256 _ticketCount,
        address _inputToken,
        address _uniswapRouter
    )
        public
        view
        returns (uint256 tokenAmount)
    {
        ScratchVRF scratcher = ScratchVRF(
            _scratcherContract
        );

        uint256 totalCost = scratcher.baseCost() * _ticketCount;

        address[] memory path = new address[](2);
        path[0] = _inputToken;
        path[1] = VERSE_TOKEN;

        uint256[] memory amounts = IUniswapV2Router02(_uniswapRouter).getAmountsIn(
            totalCost,
            path
        );

        return amounts[0];
    }

    function buyWithToken(
        address _scratcherContract,
        uint256 _ticketCount,
        address _inputToken,
        uint256 _maxTokenAmount,
        address _uniswapRouter
    )
        external
    {
        require(
            _ticketCount > 0,
            "Ticket count must be greater than 0"
        );

        uint256 tokenRequired = getTokenPriceForTickets(
            _scratcherContract,
            _ticketCount,
            _inputToken,
            _uniswapRouter
        );

        require(
            _maxTokenAmount >= tokenRequired,
            "Insufficient token amount sent"
        );

        ScratchVRF scratcher = ScratchVRF(
            _scratcherContract
        );

        uint256 totalCost = scratcher.baseCost() * _ticketCount;

        address[] memory path = new address[](2);
        path[0] = _inputToken;
        path[1] = VERSE_TOKEN;

        IERC20(_inputToken).transferFrom(
            msg.sender,
            address(this),
            _maxTokenAmount
        );

        IERC20(_inputToken).approve(
            _uniswapRouter,
            _maxTokenAmount
        );

        uint256[] memory amounts = IUniswapV2Router02(_uniswapRouter).swapExactTokensForTokens(
            _maxTokenAmount,
            totalCost,
            path,
            address(this),
            block.timestamp
        );

        uint256 tokensUsed = amounts[0];

        if (_maxTokenAmount > tokensUsed) {
            IERC20(_inputToken).transfer(
                msg.sender,
                _maxTokenAmount - tokensUsed
            );
        }

        IERC20(VERSE_TOKEN).approve(
            _scratcherContract,
            totalCost
        );

        scratcher.bulkPurchase(
            msg.sender,
            _ticketCount
        );

        emit TokenPurchase(
            msg.sender,
            _inputToken,
            _maxTokenAmount,
            tokensUsed
        );
    }
}
