// SPDX-License-Identifier: -- BCOM --

pragma solidity =0.8.23;

struct Character {
    string backgroundColor;
    string backType;
    string bodyType;
    string gearType;
    string headType;
    string extraType;
}

contract TraitTiers {

    struct BackgroundTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        string backgroundColor;
    }

    struct BackTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        string backType;
    }

    struct BodyTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        string bodyType;
    }

    struct GearTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        string gearType;
    }

    struct HeadTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        string headType;
    }

    struct ExtraTier {
        uint256 drawEdgeA;
        uint256 drawEdgeB;
        string extraType;
    }

    BackgroundTier[] public backgroundTiers;

    BackTier[] public backTiers;
    BodyTier[] public bodyTiers;
    GearTier[] public gearTiers;
    HeadTier[] public headTiers;

    ExtraTier[] public extraTiers;

    constructor() {
        _setupBackgroundTiers();

        _setupBackTiers();
        _setupBodyTiers();
        _setupGearTiers();
        _setupHeadTiers();

        _setupExtraTiers();
    }

    function _setupBackgroundTiers()
        internal
    {
        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 1,
                drawEdgeB: 50,
                backgroundColor: "Pitch Black Void"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 51,
                drawEdgeB: 100,
                backgroundColor: "Pure White Expanse"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 101,
                drawEdgeB: 150,
                backgroundColor: "Azure Sky"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 151,
                drawEdgeB: 200,
                backgroundColor: "Mint Freshness"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 201,
                drawEdgeB: 250,
                backgroundColor: "Deep Space Purple"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 251,
                drawEdgeB: 300,
                backgroundColor: "Oceanic Blue"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 301,
                drawEdgeB: 350,
                backgroundColor: "Sunset Purple"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 351,
                drawEdgeB: 400,
                backgroundColor: "Coral Radiance"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 401,
                drawEdgeB: 450,
                backgroundColor: "Vibrant Magenta"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 451,
                drawEdgeB: 500,
                backgroundColor: "Saffron Sunrise"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 501,
                drawEdgeB: 526,
                backgroundColor: "Pastel Dream"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 527,
                drawEdgeB: 552,
                backgroundColor: "Twilight Serenity"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 553,
                drawEdgeB: 578,
                backgroundColor: "Arctic Chill"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 579,
                drawEdgeB: 604,
                backgroundColor: "Midnight Velvet"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 605,
                drawEdgeB: 630,
                backgroundColor: "Blazing Horizon"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 631,
                drawEdgeB: 656,
                backgroundColor: "Neon Spring"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 657,
                drawEdgeB: 682,
                backgroundColor: "Golden Shine"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 683,
                drawEdgeB: 708,
                backgroundColor: "Spring Meadow"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 709,
                drawEdgeB: 734,
                backgroundColor: "Lavender Dream"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 735,
                drawEdgeB: 760,
                backgroundColor: "Ocean Horizon"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 761,
                drawEdgeB: 786,
                backgroundColor: "Starry Night"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 787,
                drawEdgeB: 812,
                backgroundColor: "Solar Eclipse"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 813,
                drawEdgeB: 838,
                backgroundColor: "Star Trails"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 851,
                drawEdgeB: 868,
                backgroundColor: "Indonesian Pagoda"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 869,
                drawEdgeB: 886,
                backgroundColor: "Martian Dome"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 887,
                drawEdgeB: 904,
                backgroundColor: "New York Dusk"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 905,
                drawEdgeB: 922,
                backgroundColor: "Nigerian Abuja Gate"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 923,
                drawEdgeB: 940,
                backgroundColor: "Singapore Neon"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 941,
                drawEdgeB: 958,
                backgroundColor: "Tokyo Twilight"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 959,
                drawEdgeB: 976,
                backgroundColor: "Vietnam Visitor"
            })
        );

        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: 977,
                drawEdgeB: 1000,
                backgroundColor: "Antarctic Glow"
            })
        );
    }

    function _setupBackTiers()
        internal
    {
        backTiers.push(
            BackTier({
                drawEdgeA: 1,
                drawEdgeB: 400,
                backType: "None"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 401,
                drawEdgeB: 438,
                backType: "Offworld Pack"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 439,
                drawEdgeB: 476,
                backType: "Expanse Wings"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 477,
                drawEdgeB: 514,
                backType: "Radar Pack"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 515,
                drawEdgeB: 552,
                backType: "Arcane Shield"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 553,
                drawEdgeB: 590,
                backType: "Covert Ops Pack"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 591,
                drawEdgeB: 628,
                backType: "Armored Pack"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 629,
                drawEdgeB: 666,
                backType: "Settler's Rake"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 667,
                drawEdgeB: 704,
                backType: "Void Wings"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 705,
                drawEdgeB: 742,
                backType: "Battered Trail Rockets"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 743,
                drawEdgeB: 770,
                backType: "Hydro Pack"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 771,
                drawEdgeB: 798,
                backType: "Rocket Thrusters"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 799,
                drawEdgeB: 826,
                backType: "Canon Pack"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 827,
                drawEdgeB: 854,
                backType: "Neon Pack"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 855,
                drawEdgeB: 882,
                backType: "Crimson Pulse Rifle"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 883,
                drawEdgeB: 910,
                backType: "Gromlin"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 911,
                drawEdgeB: 938,
                backType: "Advanced Jetpack"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 939,
                drawEdgeB: 950,
                backType: "Baby Monkey Pal"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 951,
                drawEdgeB: 962,
                backType: "Sludged"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 963,
                drawEdgeB: 974,
                backType: "Templar Sword"
            })
        );

        backTiers.push(
            BackTier({
                drawEdgeA: 975,
                drawEdgeB: 986,
                backType: "Dual Wakizashi"
            })
        );
    }

    function _setupBodyTiers()
        internal
    {
        bodyTiers.push(
            BodyTier({
                drawEdgeA: 1,
                drawEdgeB: 78,
                bodyType: "Terran Stardwellers"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 79,
                drawEdgeB: 156,
                bodyType: "Gravitas Shade"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 157,
                drawEdgeB: 234,
                bodyType: "Deep Nebulites"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 235,
                drawEdgeB: 312,
                bodyType: "Terranox Bronze"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 313,
                drawEdgeB: 390,
                bodyType: "Solsetians"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 391,
                drawEdgeB: 468,
                bodyType: "Martian Dustwalkers"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 469,
                drawEdgeB: 546,
                bodyType: "Etherlight Greens"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 551,
                drawEdgeB: 616,
                bodyType: "Veridian Starfolk"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 617,
                drawEdgeB: 682,
                bodyType: "Lunargent Sentinels"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 683,
                drawEdgeB: 748,
                bodyType: "Astranox Blues"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 749,
                drawEdgeB: 814,
                bodyType: "Solarian Reds"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 815,
                drawEdgeB: 880,
                bodyType: "Geoheart Giants"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 881,
                drawEdgeB: 946,
                bodyType: "Venusian Sandfolk"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 951,
                drawEdgeB: 975,
                bodyType: "Eclipseborn"
            })
        );

        bodyTiers.push(
            BodyTier({
                drawEdgeA: 976,
                drawEdgeB: 1000,
                bodyType: "Zephyrion Mints"
            })
        );
    }

    function _setupGearTiers()
        internal
    {
        gearTiers.push(
            GearTier({
                drawEdgeA: 1,
                drawEdgeB: 60,
                gearType: "None"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 61,
                drawEdgeB: 120,
                gearType: "Racer Jacket"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 121,
                drawEdgeB: 180,
                gearType: "Crimson Hoodie"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 181,
                drawEdgeB: 240,
                gearType: "Camo Combat"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 241,
                drawEdgeB: 300,
                gearType: "Floral Collar"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 301,
                drawEdgeB: 360,
                gearType: "Skydive Windbreaker"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 361,
                drawEdgeB: 420,
                gearType: "Monochrome Stripe Tee"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 421,
                drawEdgeB: 480,
                gearType: "Wool Shirt"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 481,
                drawEdgeB: 540,
                gearType: "Red Wool Shirt"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 541,
                drawEdgeB: 600,
                gearType: "Stealth Zip-up"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 601,
                drawEdgeB: 642,
                gearType: "3024 Jacket"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 643,
                drawEdgeB: 684,
                gearType: "Formal Field Uniform"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 685,
                drawEdgeB: 726,
                gearType: "Leafline Hoodie"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 727,
                drawEdgeB: 768,
                gearType: "Leather Armor"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 769,
                drawEdgeB: 810,
                gearType: "Mission Bandolier"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 811,
                drawEdgeB: 852,
                gearType: "Polar Trail Vest"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 853,
                drawEdgeB: 894,
                gearType: "Symbiote High Collar"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 901,
                drawEdgeB: 925,
                gearType: "Armored Explorer"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 926,
                drawEdgeB: 950,
                gearType: "Firestorm Jacket"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 951,
                drawEdgeB: 975,
                gearType: "Orbiter Suit"
            })
        );

        gearTiers.push(
            GearTier({
                drawEdgeA: 976,
                drawEdgeB: 1000,
                gearType: "Lunar Trim"
            })
        );
    }

    function _setupHeadTiers()
        internal
    {
        headTiers.push(
            HeadTier({
                drawEdgeA: 1,
                drawEdgeB: 60,
                headType: "Knight's Valor"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 67,
                drawEdgeB: 132,
                headType: "Stealth Operative"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 133,
                drawEdgeB: 198,
                headType: "Rogue Sniper"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 199,
                drawEdgeB: 264,
                headType: "Speed Demon"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 265,
                drawEdgeB: 330,
                headType: "Star Visor"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 331,
                drawEdgeB: 396,
                headType: "Skull Visor"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 397,
                drawEdgeB: 462,
                headType: "HAL Visor"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 463,
                drawEdgeB: 528,
                headType: "Spartan Guard"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 529,
                drawEdgeB: 594,
                headType: "Cyberpunk Voyager"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 601,
                drawEdgeB: 630,
                headType: "Verse Helmet"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 631,
                drawEdgeB: 660,
                headType: "Anime Bandit"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 661,
                drawEdgeB: 690,
                headType: "Futurist Pilot"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 691,
                drawEdgeB: 720,
                headType: "Tactical Vision"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 721,
                drawEdgeB: 750,
                headType: "Combat Engineer"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 751,
                drawEdgeB: 780,
                headType: "Phantom Racer"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 781,
                drawEdgeB: 810,
                headType: "Swords Visors"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 811,
                drawEdgeB: 840,
                headType: "Samurai Slash"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 841,
                drawEdgeB: 870,
                headType: "Anime Ace"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 871,
                drawEdgeB: 900,
                headType: "Guardian Royale"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 901,
                drawEdgeB: 925,
                headType: "Max Pain"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 926,
                drawEdgeB: 950,
                headType: "Dragon Skull Warlord"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 951,
                drawEdgeB: 975,
                headType: "Odin's Sentry"
            })
        );

        headTiers.push(
            HeadTier({
                drawEdgeA: 976,
                drawEdgeB: 1000,
                headType: "Oni War Helmet"
            })
        );
    }

    function _setupExtraTiers()
        internal
    {
        extraTiers.push(
            ExtraTier({
                drawEdgeA: 1,
                drawEdgeB: 500,
                extraType: "None"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 501,
                drawEdgeB: 542,
                extraType: "Full Spectrum Badge"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 543,
                drawEdgeB: 584,
                extraType: "Tri-Core Circuit Badge"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 585,
                drawEdgeB: 626,
                extraType: "Arachnid Defender"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 627,
                drawEdgeB: 668,
                extraType: "Graphite Arrow"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 669,
                drawEdgeB: 710,
                extraType: "Radio Comms"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 711,
                drawEdgeB: 752,
                extraType: "Blue Energy Orb"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 795,
                drawEdgeB: 815,
                extraType: "Drone Recorder"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 816,
                drawEdgeB: 836,
                extraType: "AR Field Laser"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 837,
                drawEdgeB: 857,
                extraType: "Emerald Hammer"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 858,
                drawEdgeB: 878,
                extraType: "Twinkle"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 879,
                drawEdgeB: 899,
                extraType: "Cybernetic Dove Navigator"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 900,
                drawEdgeB: 920,
                extraType: "Red Energy Orb"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 921,
                drawEdgeB: 941,
                extraType: "Explorer Unit Pin"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 942,
                drawEdgeB: 957,
                extraType: "Diamond Pauldron"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 958,
                drawEdgeB: 973,
                extraType: "Skull Clip"
            })
        );

        extraTiers.push(
            ExtraTier({
                drawEdgeA: 974,
                drawEdgeB: 989,
                extraType: "Starfield"
            })
        );
    }

    function _getBackgroundColor(
        uint256 _number
    )
        internal
        view
        returns (string memory backgroundColor)
    {
        uint256 i;
        uint256 backgrounds = backgroundTiers.length;

        while (i < backgrounds) {

            BackgroundTier memory tier = backgroundTiers[i];

            if (_number >= tier.drawEdgeA && _number <= tier.drawEdgeB) {
                return tier.backgroundColor;
            }

            unchecked {
                ++i;
            }
        }
    }

    function _getBackType(
        uint256 _number
    )
        internal
        view
        returns (string memory backType)
    {
        uint256 i;
        uint256 backs = backTiers.length;

        while (i < backs) {

            BackTier memory tier = backTiers[i];

            if (_number >= tier.drawEdgeA && _number <= tier.drawEdgeB) {
                return tier.backType;
            }

            unchecked {
                ++i;
            }
        }
    }

    function _getBodyType(
        uint256 _number
    )
        internal
        view
        returns (string memory bodyType)
    {
        uint256 i;
        uint256 bodies = bodyTiers.length;

        while (i < bodies) {

            BodyTier memory tier = bodyTiers[i];

            if (_number >= tier.drawEdgeA && _number <= tier.drawEdgeB) {
                return tier.bodyType;
            }

            unchecked {
                ++i;
            }
        }
    }

    function _getGearType(
        uint256 _number
    )
        internal
        view
        returns (string memory gearType)
    {
        uint256 i;
        uint256 gears = gearTiers.length;

        while (i < gears) {

            GearTier memory tier = gearTiers[i];

            if (_number >= tier.drawEdgeA && _number <= tier.drawEdgeB) {
                return tier.gearType;
            }

            unchecked {
                ++i;
            }
        }
    }

    function _getHeadType(
        uint256 _number
    )
        internal
        view
        returns (string memory headType)
    {
        uint256 i;
        uint256 heads = headTiers.length;

        while (i < heads) {

            HeadTier memory tier = headTiers[i];

            if (_number >= tier.drawEdgeA && _number <= tier.drawEdgeB) {
                return tier.headType;
            }

            unchecked {
                ++i;
            }
        }
    }

    function _getExtraType(
        uint256 _number
    )
        internal
        view
        returns (string memory extraType)
    {
        uint256 i;
        uint256 extras = extraTiers.length;

        while (i < extras) {

            ExtraTier memory tier = extraTiers[i];

            if (_number >= tier.drawEdgeA && _number <= tier.drawEdgeB) {
                return tier.extraType;
            }

            unchecked {
                ++i;
            }
        }
    }
}
