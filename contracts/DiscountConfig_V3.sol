// SPDX-License-Identifier: -- BCOM --

pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(
        address account
    )
        external
        view
        returns (uint256);
}

interface IERC721 {
    function balanceOf(
        address owner
    )
        external
        view
        returns (uint256);
}

contract DiscountConfig_V3 {

    // --- State Variables ---

    address public immutable admin;
    uint256 public constant MAX_TOKEN_RULES = 10;

    struct TokenRule {
        uint256 threshold; // For ERC20: min balance, For ERC721: min NFTs
        bool isNFT;        // True if the token is an ERC721, false for ERC20
    }

    mapping(address => TokenRule) public rules;
    mapping(address => uint) private _tokenIndex;

    address[] private _tokenList;

    // --- Events ---

    event RuleSet(
        address indexed token,
        uint256 threshold,
        bool isNFT
    );

    event RuleRemoved(
        address indexed token
    );

    // --- Constructor ---

    constructor(
        address _admin
    ) {
        admin = _admin;
    }

    // --- Modifiers ---

    modifier onlyAdmin() {
        require(
            msg.sender == admin,
            "NOT_AUTHORIZED"
        );
        _;
    }

    // --- Admin Functions ---

    /**
     * @notice Sets or updates a discount rule for a token, enforcing the MAX_TOKEN_RULES limit.
     * @param _token The address of the ERC20 or ERC721 token.
     * @param _threshold The minimum balance or number of NFTs required for a discount.
     * @param _isNFT Set to true for ERC721 tokens, false for ERC20.
     */
    function setTokenRule(
        address _token,
        uint256 _threshold,
        bool _isNFT
    )
        external
        onlyAdmin
    {
        // Add the token to the list only if it's new.
        if (_tokenIndex[_token] == 0) {
            require(
                _tokenList.length < MAX_TOKEN_RULES,
                "MAX_TOKEN_RULES_REACHED"
            );
            _tokenList.push(_token);
            _tokenIndex[_token] = _tokenList.length; // Store index + 1
        }

        rules[_token] = TokenRule({
            threshold: _threshold,
            isNFT: _isNFT
        });

        emit RuleSet(
            _token,
            _threshold,
            _isNFT
        );
    }

    /**
     * @notice Removes a discount rule for a token.
     */
    function removeTokenRule(
        address _token
    )
        external
        onlyAdmin
    {
        uint256 index = _tokenIndex[
            _token
        ];

        require(
            index > 0,
            "TOKEN_RULE_DOES_NOT_EXIST"
        );

        uint256 indexToRemove = index - 1;

        address lastToken = _tokenList[
            _tokenList.length - 1
        ];

        if (indexToRemove != _tokenList.length - 1) {
            _tokenList[indexToRemove] = lastToken;
            _tokenIndex[lastToken] = index;
        }

        _tokenList.pop();

        delete _tokenIndex[
            _token
        ];

        delete rules[
            _token
        ];

        emit RuleRemoved(
            _token
        );
    }

    // --- Main View Functions ---

    /**
     * @notice Checks if a user is eligible for a discount by looping through all configured tokens.
     * @dev This function performs external calls in a loop, but the loop is bounded by
     * MAX_TOKEN_RULES to limit gas costs and DoS risk. The admin MUST ensure only
     * trusted, non-malicious token contracts are added.
     * @param _user The address of the user to check.
     * @return bool True if the user meets any token rule's threshold.
     */
    function isEligible(
        address _user
    )
        external
        view
        returns (bool)
    {
        for (uint256 i = 0; i < _tokenList.length; i++) {

            address token = _tokenList[i];

            TokenRule memory rule = rules[
                token
            ];

            // A rule with a threshold of 0 is considered invalid/deleted, so we skip.
            if (rule.threshold > 0) {
                if (rule.isNFT) {
                    if (IERC721(token).balanceOf(_user) >= rule.threshold) return true;
                } else {
                    if (IERC20(token).balanceOf(_user) >= rule.threshold) return true;
                }
            }
        }
        return false;
    }

    /**
     * @notice Returns the list of all tokens with active discount rules.
     */
    function getTokenList()
        external
        view
        returns (address[] memory)
    {
        return _tokenList;
    }
}