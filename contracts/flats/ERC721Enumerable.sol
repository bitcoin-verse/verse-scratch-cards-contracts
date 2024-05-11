// SPDX-License-Identifier: -- OZ --

pragma solidity =0.8.25;

interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0x0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(
        address owner
    );

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(
        uint256 tokenId
    );

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(
        address sender,
        uint256 tokenId,
        address owner
    );

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(
        address sender
    );

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(
        address receiver
    );

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(
        address operator,
        uint256 tokenId
    );

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(
        address approver
    );

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(
        address operator
    );
}

library SignedMath {
    /**
     * @dev Returns the largest of two signed numbers.
     */
    function max(
        int256 a,
        int256 b
    )
        internal
        pure
        returns (int256)
    {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two signed numbers.
     */
    function min(
        int256 a,
        int256 b
    )
        internal
        pure
        returns (int256)
    {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two signed numbers without overflow.
     * The result is rounded towards zero.
     */
    function average(
        int256 a,
        int256 b
    )
        internal
        pure
        returns (int256)
    {
        // Formula from the book "Hacker's Delight"
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }

    /**
     * @dev Returns the absolute unsigned value of a signed value.
     */
    function abs(
        int256 n
    )
        internal
        pure
        returns (uint256)
    {
        unchecked {
            // must be unchecked in order to support `n = type(int256).min`
            return uint256(n >= 0 ? n : -n);
        }
    }
}

library Math {
    /**
     * @dev Muldiv operation overflow.
     */
    error MathOverflowedMulDiv();

    enum Rounding {
        Floor, // Toward negative infinity
        Ceil, // Toward positive infinity
        Trunc, // Toward zero
        Expand // Away from zero
    }

    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     */
    function tryAdd(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     */
    function trySub(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     */
    function tryMul(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     */
    function tryDiv(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     */
    function tryMod(
        uint256 a,
        uint256 b
    )
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds towards infinity instead
     * of rounding towards zero.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b == 0) {
            // Guarantee the same behavior as in a regular Solidity division.
            return a / b;
        }

        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or
     * denominator == 0.
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv) with further edits by
     * Uniswap Labs also under MIT license.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0 = x * y; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                // Solidity will revert if denominator == 0, unlike the div opcode on its own.
                // The surrounding unchecked block does not change this fact.
                // See https://docs.soliditylang.org/en/latest/control-structures.html#checked-or-unchecked-arithmetic.
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator.
            // Always >= 1. See https://cs.stackexchange.com/q/138556/92363.

            uint256 twos = denominator & (0 - denominator);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also
            // works in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded
     * towards zero.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256 of a positive value rounded towards zero.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 256, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }

    /**
     * @dev Returns whether a provided rounding mode is considered rounding up for unsigned integers.
     */
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}

library Strings {

    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;

    /**
     * @dev The `value` string doesn't fit in the specified `length`.
     */
    error StringsInsufficientHexLength(
        uint256 value,
        uint256 length
    );

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(
        uint256 value
    )
        internal
        pure
        returns (string memory)
    {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function toStringSigned(
        int256 value
    )
        internal
        pure
        returns (string memory)
    {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal
     * representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }

    /**
     * @dev Returns true if the two strings are equal.
     */
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

abstract contract Context {

    function _msgSender()
        internal
        view
        virtual
        returns (address)
    {
        return msg.sender;
    }

    function _msgData()
        internal
        view
        virtual
        returns (bytes calldata)
    {
        return msg.data;
    }

    function _contextSuffixLength()
        internal
        view
        virtual
        returns (uint256)
    {
        return 0;
    }
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be
     * reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    )
        external
        returns (bytes4);
}

interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(
        bytes4 _interfaceId
    )
        external
        view
        returns (bool);
}

abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 _interfaceId
    )
        public
        view
        virtual
        returns (bool)
    {
        return _interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Returns the number of tokens in ``_owner``'s account.
     */
    function balanceOf(
        address _owner
    )
        external
        view
        returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `_tokenId` must exist.
     */
    function ownerOf(
        uint256 _tokenId
    )
        external
        view
        returns (address owner);

    /**
     * @dev Safely transfers `_tokenId` token from `_from` to `_to`.
     *
     * Requirements:
     *
     * - `_from` cannot be the zero address.
     * - `_to` cannot be the zero address.
     * - `_tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
        external;

    /**
     * @dev Safely transfers `_tokenId` token from `_from` to `_to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `_from` cannot be the zero address.
     * - `_to` cannot be the zero address.
     * - `_tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or
     *   {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon
     *   a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external;

    /**
     * @dev Transfers `_tokenId` token from `_from` to `_to`.
     *
     * WARNING: Note that the caller is responsible to confirm that the recipient is capable of receiving ERC721
     * or else they may be permanently lost. Usage of {safeTransferFrom} prevents loss, though the caller must
     * understand this adds an external call which potentially creates a reentrancy vulnerability.
     *
     * Requirements:
     *
     * - `_from` cannot be the zero address.
     * - `_to` cannot be the zero address.
     * - `_tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external;

    /**
     * @dev Gives permission to `_to` to transfer `_tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `_tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(
        address _to,
        uint256 _tokenId
    )
        external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(
        address _operator,
        bool _approved
    )
        external;

    /**
     * @dev Returns the account approved for `_tokenId` token.
     *
     * Requirements:
     *
     * - `_tokenId` must exist.
     */
    function getApproved(
        uint256 _tokenId
    )
        external
        view
        returns (address operator);

    /**
     * @dev Returns if the `_operator` is allowed to manage all of the assets of `_owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    )
        external
        view
        returns (bool);
}

interface IERC721Enumerable is IERC721 {
    /**
     * @dev Returns the total amount of tokens stored by the contract.
     */
    function totalSupply()
        external
        view
        returns (uint256);

    /**
     * @dev Returns a token ID owned by `_owner` at a given `_index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``_owner``'s tokens.
     */
    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    )
        external
        view
        returns (uint256);

    /**
     * @dev Returns a token ID at a given `_index` of all the tokens stored by the contract.
     * Use along with {totalSupply} to enumerate all tokens.
     */
    function tokenByIndex(
        uint256 _index
    )
        external
        view
        returns (uint256);
}

interface IERC721Metadata is IERC721 {
    /**
     * @dev Returns the token collection name.
     */
    function name()
        external
        view
        returns (string memory);

    /**
     * @dev Returns the token collection symbol.
     */
    function symbol()
        external
        view
        returns (string memory);

    /**
     * @dev Returns the Uniform Resource Identifier (URI) for `_tokenId` token.
     */
    function tokenURI(
        uint256 _tokenId
    )
        external
        view
        returns (string memory);
}

abstract contract ERC721 is
    Context,
    ERC165,
    IERC721,
    IERC721Metadata,
    IERC721Errors
{
    using Strings for uint256;

    string private _name;
    string private _symbol;

    mapping(uint256 tokenId => address) private _owners;
    mapping(uint256 tokenId => address) private _tokenApprovals;

    mapping(address owner => uint256) private _balances;
    mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

    address internal ZERO_ADDRESS = address(0x0);

    constructor(
        string memory name_,
        string memory symbol_
    ) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 _interfaceId
    )
        public
        view
        virtual
        override(
            ERC165,
            IERC165
        )
        returns (bool)
    {
        return
            _interfaceId == type(IERC721).interfaceId ||
            _interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(
                _interfaceId
            );
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(
        address _owner
    )
        public
        view
        virtual
        returns (uint256)
    {
        if (_owner == ZERO_ADDRESS) {
            revert ERC721InvalidOwner(
                ZERO_ADDRESS
            );
        }

        return _balances[
            _owner
        ];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(
        uint256 _tokenId
    )
        public
        view
        virtual
        returns (address)
    {
        return _requireOwned(
            _tokenId
        );
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name()
        public
        view
        virtual
        returns (string memory)
    {
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol()
        public
        view
        virtual
        returns (string memory)
    {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(
        uint256 _tokenId
    )
        public
        view
        virtual
        returns (string memory)
    {
        _requireOwned(
            _tokenId
        );

        string memory baseURI = _baseURI();

        return bytes(baseURI).length > 0
            ? string.concat(
                baseURI,
                _tokenId.toString()
            )
            : "";
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI()
        internal
        view
        virtual
        returns (string memory)
    {
        return "";
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(
        address _to,
        uint256 _tokenId
    )
        public
        virtual
    {
        _approve(
            _to,
            _tokenId,
            _msgSender()
        );
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(
        uint256 _tokenId
    )
        public
        view
        virtual
        returns (address)
    {
        _requireOwned(
            _tokenId
        );

        return _getApproved(
            _tokenId
        );
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(
        address _operator,
        bool _approved
    )
        public
        virtual
    {
        _setApprovalForAll(
            _msgSender(),
            _operator,
            _approved
        );
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(
        address _owner,
        address _operator
    )
        public
        view
        virtual
        returns (bool)
    {
        return _operatorApprovals[_owner][_operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        virtual
    {
        if (_to == ZERO_ADDRESS) {
            revert ERC721InvalidReceiver(
                ZERO_ADDRESS
            );
        }
        // Setting an "auth" arguments enables the `_isAuthorized` check which verifies that the token exists
        // (from != 0). Therefore, it is not needed to verify that the return value is not 0 here.
        address previousOwner = _update(
            _to,
            _tokenId,
            _msgSender()
        );
        if (previousOwner != _from) {
            revert ERC721IncorrectOwner(
                _from,
                _tokenId,
                previousOwner
            );
        }
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        virtual
    {
        safeTransferFrom(
            _from,
            _to,
            _tokenId,
            ""
        );
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    )
        public
        virtual
    {
        transferFrom(
            _from,
            _to,
            _tokenId
        );

        _checkOnERC721Received(
            _from,
            _to,
            _tokenId,
            _data
        );
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function _ownerOf(
        uint256 _tokenId
    )
        internal
        view
        virtual
        returns (address)
    {
        return _owners[_tokenId];
    }

    /**
     * @dev Returns the approved address for `_tokenId`. Returns 0 if `_tokenId` is not minted.
     */
    function _getApproved(
        uint256 _tokenId
    )
        internal
        view
        virtual
        returns (address)
    {
        return _tokenApprovals[_tokenId];
    }

    /**
     * @dev Returns whether `_spender` is allowed to manage `_owner`'s tokens, or `_tokenId` in
     * particular (ignoring whether it is owned by `_owner`).
     *
     * WARNING: This function assumes that `_owner` is the actual owner of `_tokenId` and does not verify this
     * assumption.
     */
    function _isAuthorized(
        address _owner,
        address _spender,
        uint256 _tokenId
    )
        internal
        view
        virtual
        returns (bool)
    {
        return
            _spender != ZERO_ADDRESS &&
            (
                _owner == _spender
                || isApprovedForAll(_owner, _spender)
                || _getApproved(_tokenId) == _spender
            );
    }

    /**
     * @dev Checks if `_spender` can operate on `_tokenId`, assuming the provided `_owner` is the actual owner.
     * Reverts if `_spender` does not have approval from the provided `_owner` for the given token or for all its assets
     * the `_spender` for the specific `_tokenId`.
     *
     * WARNING: This function assumes that `_owner` is the actual owner of `_tokenId` and does not verify this
     * assumption.
     */
    function _checkAuthorized(
        address _owner,
        address _spender,
        uint256 _tokenId
    )
        internal
        view
        virtual
    {
        if (!_isAuthorized(
            _owner,
            _spender,
            _tokenId
        )) {
            if (_owner == ZERO_ADDRESS) {
                revert ERC721NonexistentToken(
                    _tokenId
                );
            } else {
                revert ERC721InsufficientApproval(
                    _spender,
                    _tokenId
                );
            }
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function _increaseBalance(
        address _account,
        uint128 _value
    )
        internal
        virtual
    {
        unchecked {
            _balances[_account] += _value;
        }
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `_to`, or alternatively mints (or burns) if the current owner
     * (or `_to`) is the zero address. Returns the owner of the `_tokenId` before the update.
     *
     * The `_auth` argument is optional. If the value passed is non 0, then this function will check that
     * `_auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function _update(
        address _to,
        uint256 _tokenId,
        address _auth
    )
        internal
        virtual
        returns (address)
    {
        address from = _ownerOf(
            _tokenId
        );

        // Perform (optional) operator check
        if (_auth != ZERO_ADDRESS) {
            _checkAuthorized(
                from,
                _auth,
                _tokenId
            );
        }

        // Execute the update
        if (from != ZERO_ADDRESS) {

            // Clear approval. No need to re-authorize or emit the Approval event
            _approve(
                ZERO_ADDRESS,
                _tokenId,
                ZERO_ADDRESS,
                false
            );

            unchecked {
                _balances[from] -= 1;
            }
        }

        if (_to != ZERO_ADDRESS) {
            unchecked {
                _balances[_to] += 1;
            }
        }

        _owners[_tokenId] = _to;

        emit Transfer(
            from,
            _to,
            _tokenId
        );

        return from;
    }

    /**
     * @dev Mints `_tokenId` and transfers it to `_to`.
     *
     * Requirements:
     *
     * - `_tokenId` must not exist.
     * - `_to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function _mintNoCallBack(
        address _to,
        uint256 _tokenId
    )
        internal
    {
        if (_to == ZERO_ADDRESS) {
            revert ERC721InvalidReceiver(
                ZERO_ADDRESS
            );
        }

        address previousOwner = _update(
            _to,
            _tokenId,
            ZERO_ADDRESS
        );

        if (previousOwner != ZERO_ADDRESS) {
            revert ERC721InvalidSender(
                ZERO_ADDRESS
            );
        }
    }

    /**
     * @dev Mints `_tokenId`, transfers it to `_to` and checks for `_to` acceptance.
     *
     * Requirements:
     *
     * - `_tokenId` must not exist.
     * - If `_to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeMint(
        address _to,
        uint256 _tokenId
    )
        internal
    {
        _safeMint(
            _to,
            _tokenId,
            ""
        );
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `_data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeMint(
        address _to,
        uint256 _tokenId,
        bytes memory _data
    )
        internal
        virtual
    {
        _mintNoCallBack(
            _to,
            _tokenId
        );

        _checkOnERC721Received(
            ZERO_ADDRESS,
            _to,
            _tokenId,
            _data
        );
    }

    /**
     * @dev Destroys `_tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `_tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(
        uint256 _tokenId
    )
        internal
    {
        address previousOwner = _update(
            ZERO_ADDRESS,
            _tokenId,
            ZERO_ADDRESS
        );

        if (previousOwner == ZERO_ADDRESS) {
            revert ERC721NonexistentToken(
                _tokenId
            );
        }
    }

    /**
     * @dev Transfers `_tokenId` from `_from` to `_to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `_to` cannot be the zero address.
     * - `_tokenId` token must be owned by `_from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    )
        internal
    {
        if (_to == ZERO_ADDRESS) {
            revert ERC721InvalidReceiver(
                ZERO_ADDRESS
            );
        }

        address previousOwner = _update(
            _to,
            _tokenId,
            ZERO_ADDRESS
        );

        if (previousOwner == ZERO_ADDRESS) {
            revert ERC721NonexistentToken(
                _tokenId
            );
        }

        if (previousOwner != _from) {
            revert ERC721IncorrectOwner(
                _from,
                _tokenId,
                previousOwner
            );
        }
    }

    /**
     * @dev Safely transfers `tokenId` token from `_from` to `_to`, checking that contract recipients
     * are aware of the ERC721 standard to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `_to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `_tokenId` token must exist and be owned by `_from`.
     * - `_to` cannot be the zero address.
     * - `_from` cannot be the zero address.
     * - If `_to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function _safeTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    )
        internal
    {
        _safeTransfer(
            _from,
            _to,
            _tokenId,
            ""
        );
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `_data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function _safeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    )
        internal
        virtual
    {
        _transfer(
            _from,
            _to,
            _tokenId
        );

        _checkOnERC721Received(
            _from,
            _to,
            _tokenId,
            _data
        );
    }

    /**
     * @dev Approve `_to` to operate on `_tokenId`
     *
     * The `_auth` argument is optional. If the value passed is non 0, then this function will check that `_auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(
        address _to,
        uint256 _tokenId,
        address _auth
    )
        internal
    {
        _approve(
            _to,
            _tokenId,
            _auth,
            true
        );
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event.
     * The event is not emitted in the context of transfers.
     */
    function _approve(
        address _to,
        uint256 _tokenId,
        address _auth,
        bool _emitEvent
    )
        internal
        virtual
    {
        // Avoid reading the owner unless necessary
        if (_emitEvent || _auth != ZERO_ADDRESS) {

            address owner = _requireOwned(
                _tokenId
            );

            // We do not use _isAuthorized because single-token approvals should not be able to call approve
            if (_auth != ZERO_ADDRESS && owner != _auth && !isApprovedForAll(owner, _auth)) {
                revert ERC721InvalidApprover(_auth);
            }

            if (_emitEvent) {
                emit Approval(
                    owner,
                    _to,
                    _tokenId
                );
            }
        }

        _tokenApprovals[_tokenId] = _to;
    }

    /**
     * @dev Approve `_operator` to operate on all of `_owner` tokens
     *
     * Requirements:
     * - _operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address _owner,
        address _operator,
        bool _approved
    )
        internal
        virtual
    {
        if (_operator == ZERO_ADDRESS) {
            revert ERC721InvalidOperator(
                _operator
            );
        }

        _operatorApprovals[_owner][_operator] = _approved;

        emit ApprovalForAll(
            _owner,
            _operator,
            _approved
        );
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner
     * (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function _requireOwned(
        uint256 _tokenId
    )
        internal
        view
        returns (address)
    {
        address owner = _ownerOf(
            _tokenId
        );

        if (owner == ZERO_ADDRESS) {
            revert("ERC721: invalid token ID");
        }

        return owner;
    }

    /**
     * @dev Private function to invoke {IERC721Receiver-onERC721Received} on a target address. This will revert if the
     * recipient doesn't accept the token transfer. The call is not executed if the target address is not a contract.
     *
     * @param _from address representing the previous owner of the given token ID
     * @param _to target address that will receive the tokens
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     */
    function _checkOnERC721Received(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    )
        private
    {
        if (_to.code.length > 0) {
            try IERC721Receiver(_to).onERC721Received(
                _msgSender(),
                _from,
                _tokenId,
                _data
            )
                returns (bytes4 retval)
            {
                if (retval != IERC721Receiver.onERC721Received.selector) {
                    revert ERC721InvalidReceiver(
                        _to
                    );
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721InvalidReceiver(
                        _to
                    );
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(
                            add(32, reason),
                            mload(reason)
                        )
                    }
                }
            }
        }
    }
}

abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {

    uint256[] private _allTokens;

    mapping(uint256 tokenId => uint256) private _allTokensIndex;
    mapping(uint256 tokenId => uint256) private _ownedTokensIndex;

    mapping(address owner => mapping(uint256 index => uint256)) private _ownedTokens;
    /**
     * @dev An `owner`'s token query was out of bounds for `index`.
     *
     * NOTE: The owner being `address(0x0)` indicates a global out of bounds index.
     */
    error ERC721OutOfBoundsIndex(
        address owner,
        uint256 index
    );

    /**
     * @dev Batch mint is not allowed.
     */
    error ERC721EnumerableForbiddenBatchMint();

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 _interfaceId
    )
        public
        view
        virtual
        override (
            IERC165,
            ERC721
        )
        returns (bool)
    {
        return
            _interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(
                _interfaceId
            );
    }

    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    )
        public
        view
        virtual
        returns (uint256)
    {
        if (_index >= balanceOf(_owner)) {
            revert ERC721OutOfBoundsIndex(
                _owner,
                _index
            );
        }

        return _ownedTokens[_owner][_index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply()
        public
        view
        virtual
        returns (uint256)
    {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(
        uint256 _index
    )
        public
        view
        virtual
        returns (uint256)
    {
        if (_index >= totalSupply()) {
            revert ERC721OutOfBoundsIndex(
                ZERO_ADDRESS,
                _index
            );
        }

        return _allTokens[
            _index
        ];
    }

    /**
     * @dev See {ERC721-_update}.
     */
    function _update(
        address _to,
        uint256 _tokenId,
        address _auth
    )
        internal
        override
        returns (address)
    {
        address previousOwner = super._update(
            _to,
            _tokenId,
            _auth
        );

        if (previousOwner == ZERO_ADDRESS) {
            _addTokenToAllTokensEnumeration(_tokenId);
        } else if (previousOwner != _to) {
            _removeTokenFromOwnerEnumeration(
                previousOwner,
                _tokenId
            );
        }
        if (_to == ZERO_ADDRESS) {
            _removeTokenFromAllTokensEnumeration(
                _tokenId
            );
        } else if (previousOwner != _to) {
            _addTokenToOwnerEnumeration(
                _to,
                _tokenId
            );
        }

        return previousOwner;
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param _to address representing the new owner of the given token ID
     * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(
        address _to,
        uint256 _tokenId
    )
        private
    {
        uint256 length = balanceOf(_to) - 1;
        _ownedTokens[_to][length] = _tokenId;
        _ownedTokensIndex[_tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param _tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(
        uint256 _tokenId
    )
        private
    {
        _allTokensIndex[_tokenId] = _allTokens.length;
        _allTokens.push(_tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param _from address representing the previous owner of the given token ID
     * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(
        address _from,
        uint256 _tokenId
    )
        private
    {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(_from);
        uint256 tokenIndex = _ownedTokensIndex[_tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[_from][lastTokenIndex];

            _ownedTokens[_from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[_tokenId];
        delete _ownedTokens[_from][lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param _tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(
        uint256 _tokenId
    )
        private
    {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[_tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[_tokenId];
        _allTokens.pop();
    }

    /**
     * See {ERC721-_increaseBalance}. We need that to account tokens that were minted in batch
     */
    function _increaseBalance(
        address _account,
        uint128 _amount
    )
        internal
        override
    {
        if (_amount > 0) {
            revert ERC721EnumerableForbiddenBatchMint();
        }
        super._increaseBalance(
            _account,
            _amount
        );
    }
}
