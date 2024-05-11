// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.25;

import "./CommonNFT.sol";

import "./helpers/Ownable.sol";
import "./helpers/TraitTiers.sol";

error StakedVoyager();
error StakingOperatorOnly();

abstract contract ReelNFT is CommonNFT, TraitTiers, Ownable {

    using Strings for uint256;

    uint32 public constant BADGE_TRAIT_ID = 6;
    uint32 public constant MAX_TRAIT_TYPES = 7;
    uint32 public constant MAX_REROLL_COUNT = 12;
    uint32 public constant MAX_RESULT_INDEX = 1000;

    uint256 public latestCharacterId;

    mapping(uint256 => uint256[]) public results;
    mapping(address => bool) public stakingOperator;
    mapping(uint256 => bool) public isVoyagerStaked;

    uint256[] rerollPrices = new uint256[](
        MAX_REROLL_COUNT
    );

    modifier onlyStakingOperator() {
        if (stakingOperator[msg.sender] == false) {
            revert StakingOperatorOnly();
        }
        _;
    }

    event VoyagerStaked(
        uint256 indexed voyagerId
    );

    event VoyagerUnstaked(
        uint256 indexed voyagerId
    );

    event StakingOperatorSet(
        address indexed operator,
        bool isActive
    );

    function setStakingOperator(
        address _operator,
        bool _isActive
    )
        external
        onlyOwner
    {
        stakingOperator[_operator] = _isActive;

        emit StakingOperatorSet(
            _operator,
            _isActive
        );
    }

    function stakeVoyager(
        uint256 _voyagerId
    )
        external
        onlyStakingOperator
    {
        isVoyagerStaked[_voyagerId] = true;

        emit VoyagerStaked(
            _voyagerId
        );
    }

    function unstakeVoyager(
        uint256 _voyagerId
    )
        external
        onlyStakingOperator
    {
        isVoyagerStaked[_voyagerId] = false;

        emit VoyagerUnstaked(
            _voyagerId
        );
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _voyagerId
    )
        public
        override(
            ERC721,
            IERC721
        )
    {
        if (isVoyagerStaked[_voyagerId] == true) {
            revert StakedVoyager();
        }

        super.transferFrom(
            _from,
            _to,
            _voyagerId
        );
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _voyagerId
    )
        public
        override(
            ERC721,
            IERC721
        )
    {
        if (isVoyagerStaked[_voyagerId] == true) {
            revert StakedVoyager();
        }

        super.safeTransferFrom(
            _from,
            _to,
            _voyagerId
        );
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _voyagerId,
        bytes memory _data
    )
        public
        override(
            ERC721,
            IERC721
        )
    {
        if (isVoyagerStaked[_voyagerId] == true) {
            revert StakedVoyager();
        }

        super.safeTransferFrom(
            _from,
            _to,
            _voyagerId,
            _data
        );
    }

    function getTraitIds(
        uint256 _astroId
    )
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory traits = new uint256[](
            MAX_TRAIT_TYPES
        );

        traits = results[
            _astroId
        ];

        return traits;
    }

    function getTraitNames(
        uint256 _astroId
    )
        external
        view
        returns (Character memory astro)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        astro.backgroundColor = _getBackgroundColor(
            traits[0]
        );

        astro.backType = _getBackType(
            traits[1]
        );

        astro.bodyType = _getBodyType(
            traits[2]
        );

        astro.gearType = _getGearType(
            traits[3]
        );

        astro.headType = _getHeadType(
            traits[4]
        );

        astro.extraType = _getExtraType(
            traits[5]
        );

        astro.saleBadge = _getBadgeType(
            traits[6]
        );

        return astro;
    }

    function getBackgroundColorName(
        uint256 _astroId
    )
        external
        view
        returns (string memory backgroundColor)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getBackgroundColor(
            traits[0]
        );
    }

    function getBackName(
        uint256 _astroId
    )
        external
        view
        returns (string memory backName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getBackType(
            traits[1]
        );
    }

    function getBodyName(
        uint256 _astroId
    )
        external
        view
        returns (string memory bodyName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getBodyType(
            traits[2]
        );
    }

    function getGearName(
        uint256 _astroId
    )
        external
        view
        returns (string memory gearName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getGearType(
            traits[3]
        );
    }

    function getHeadName(
        uint256 _astroId
    )
        external
        view
        returns (string memory headName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getHeadType(
            traits[4]
        );
    }

    function getExtraName(
        uint256 _astroId
    )
        external
        view
        returns (string memory extraName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getExtraType(
            traits[5]
        );
    }

    function getBadgeName(
        uint256 _astroId
    )
        external
        view
        returns (string memory badgeName)
    {
        uint256[] memory traits = getTraitIds(
            _astroId
        );

        return _getBadgeType(
            traits[6]
        );
    }

    function _increaseCharacterId()
        internal
        returns (uint256)
    {
        unchecked {
            return ++latestCharacterId;
        }
    }

    function updateBaseURI(
        string memory _newBaseURI
    )
        external
        onlyOwner
    {
        baseURI = _newBaseURI;
    }

    function tokenURI(
        uint256 _astroId
    )
        public
        view
        override
        returns (string memory)
    {
        if (_ownerOf(_astroId) == ZERO_ADDRESS) {
            revert InvalidId();
        }

        return string(
            abi.encodePacked(
                baseURI,
                _astroId.toString(),
                ".json"
            )
        );
    }
}
