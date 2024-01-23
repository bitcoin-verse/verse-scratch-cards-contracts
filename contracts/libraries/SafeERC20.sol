// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

error SafeERC20FailedOperation(
    IERC20 token
);

interface IERC20 {

    function functionCall(
        bytes calldata _data
    )
        external
        returns (bytes memory);

    function transfer(
        address _recipient,
        uint256 _amount
    )
        external
        returns (bool);

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        external
        returns (bool);

    function approve(
        address _spender,
        uint256 _amount
    )
        external
        returns (bool);

    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256);

    function balanceOf(
        address _account
    )
        external
        view
        returns (uint256);
}

library SafeERC20 {

    function safeTransfer(
        IERC20 _token,
        address _to,
        uint256 _value
    )
        internal
    {
        _callOptionalReturn(
            _token,
            abi.encodeCall(
                _token.transfer,
                (
                    _to,
                    _value
                )
            )
        );
    }

    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    )
        internal
    {
        _callOptionalReturn(
            _token,
            abi.encodeCall(
                _token.transferFrom,
                (
                    _from,
                    _to,
                    _value
                )
            )
        );
    }

    function _callOptionalReturn(
        IERC20 _token,
        bytes memory _data
    )
        private
    {
        bytes memory returndata = _token.functionCall(
            _data
        );

        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(
                _token
            );
        }
    }
}
