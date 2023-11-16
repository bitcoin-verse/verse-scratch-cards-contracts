
// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.21;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface ILinkToken is IERC20 {

    function transferAndCall(
        address _to,
        uint256 _value,
        bytes calldata _data
    )
        external
        returns (bool success);
}

contract TokenHelper {

    using SafeERC20 for IERC20;

    /**
     * @notice Allows to transfer tokens
     * from this contract to a receiver.
     */
    function _giveTokens(
        IERC20 _token,
        address _receiver,
        uint256 _amount
    )
        internal
    {
        _token.safeTransfer(
            _receiver,
            _amount
        );
    }

    /**
     * @notice Allows to transfer tokens
     * from the caller to this contract.
     */
    function _takeTokens(
        IERC20 _token,
        uint256 _amount
    )
        internal
    {
        _token.safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );
    }
}
