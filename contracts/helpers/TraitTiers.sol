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
        _pushBackgrounTier({
            _drawEdgeA: 1,
            _drawEdgeB: 50,
            _backgroundColor: "Pitch Black Void"
        });

        _pushBackgrounTier({
            _drawEdgeA: 51,
            _drawEdgeB: 100,
            _backgroundColor: "Pure White Expanse"
        });

        _pushBackgrounTier({
            _drawEdgeA: 101,
            _drawEdgeB: 150,
            _backgroundColor: "Azure Sky"
        });

        _pushBackgrounTier({
            _drawEdgeA: 151,
            _drawEdgeB: 200,
            _backgroundColor: "Mint Freshness"
        });

        _pushBackgrounTier({
            _drawEdgeA: 201,
            _drawEdgeB: 250,
            _backgroundColor: "Deep Space Purple"
        });

        _pushBackgrounTier({
            _drawEdgeA: 251,
            _drawEdgeB: 300,
            _backgroundColor: "Oceanic Blue"
        });

        _pushBackgrounTier({
            _drawEdgeA: 301,
            _drawEdgeB: 350,
            _backgroundColor: "Sunset Purple"
        });

        _pushBackgrounTier({
            _drawEdgeA: 351,
            _drawEdgeB: 400,
            _backgroundColor: "Coral Radiance"
        });

        _pushBackgrounTier({
            _drawEdgeA: 401,
            _drawEdgeB: 450,
            _backgroundColor: "Vibrant Magenta"
        });

        _pushBackgrounTier({
            _drawEdgeA: 451,
            _drawEdgeB: 500,
            _backgroundColor: "Saffron Sunrise"
        });

        _pushBackgrounTier({
            _drawEdgeA: 501,
            _drawEdgeB: 526,
            _backgroundColor: "Pastel Dream"
        });

        _pushBackgrounTier({
            _drawEdgeA: 527,
            _drawEdgeB: 552,
            _backgroundColor: "Twilight Serenity"
        });

        _pushBackgrounTier({
            _drawEdgeA: 553,
            _drawEdgeB: 578,
            _backgroundColor: "Arctic Chill"
        });

        _pushBackgrounTier({
            _drawEdgeA: 579,
            _drawEdgeB: 604,
            _backgroundColor: "Midnight Velvet"
        });

        _pushBackgrounTier({
            _drawEdgeA: 605,
            _drawEdgeB: 630,
            _backgroundColor: "Blazing Horizon"
        });

        _pushBackgrounTier({
            _drawEdgeA: 631,
            _drawEdgeB: 656,
            _backgroundColor: "Neon Spring"
        });

        _pushBackgrounTier({
            _drawEdgeA: 657,
            _drawEdgeB: 682,
            _backgroundColor: "Golden Shine"
        });

        _pushBackgrounTier({
            _drawEdgeA: 683,
            _drawEdgeB: 708,
            _backgroundColor: "Spring Meadow"
        });

        _pushBackgrounTier({
            _drawEdgeA: 709,
            _drawEdgeB: 734,
            _backgroundColor: "Lavender Dream"
        });

        _pushBackgrounTier({
            _drawEdgeA: 735,
            _drawEdgeB: 760,
            _backgroundColor: "Ocean Horizon"
        });

        _pushBackgrounTier({
            _drawEdgeA: 761,
            _drawEdgeB: 786,
            _backgroundColor: "Starry Night"
        });

        _pushBackgrounTier({
            _drawEdgeA: 787,
            _drawEdgeB: 812,
            _backgroundColor: "Solar Eclipse"
        });

        _pushBackgrounTier({
            _drawEdgeA: 813,
            _drawEdgeB: 838,
            _backgroundColor: "Star Trails"
        });

        _pushBackgrounTier({
            _drawEdgeA: 851,
            _drawEdgeB: 868,
            _backgroundColor: "Indonesian Pagoda"
        });

        _pushBackgrounTier({
            _drawEdgeA: 869,
            _drawEdgeB: 886,
            _backgroundColor: "Martian Dome"
        });

        _pushBackgrounTier({
            _drawEdgeA: 887,
            _drawEdgeB: 904,
            _backgroundColor: "New York Dusk"
        });

        _pushBackgrounTier({
            _drawEdgeA: 905,
            _drawEdgeB: 922,
            _backgroundColor: "Nigerian Abuja Gate"
        });

        _pushBackgrounTier({
            _drawEdgeA: 923,
            _drawEdgeB: 940,
            _backgroundColor: "Singapore Neon"
        });

        _pushBackgrounTier({
            _drawEdgeA: 941,
            _drawEdgeB: 958,
            _backgroundColor: "Tokyo Twilight"
        });

        _pushBackgrounTier({
            _drawEdgeA: 959,
            _drawEdgeB: 976,
            _backgroundColor: "Vietnam Visitor"
        });

        _pushBackgrounTier({
            _drawEdgeA: 977,
            _drawEdgeB: 1000,
            _backgroundColor: "Antarctic Glow"
        });
    }

    function _pushBackgrounTier(
        uint256 _drawEdgeA,
        uint256 _drawEdgeB,
        string memory _backgroundColor
    )
        internal
    {
        backgroundTiers.push(
            BackgroundTier({
                drawEdgeA: _drawEdgeA,
                drawEdgeB: _drawEdgeB,
                backgroundColor: _backgroundColor
            })
        );
    }

    function _setupBackTiers()
        internal
    {
        _pushBackTier({
            _drawEdgeA: 1,
            _drawEdgeB: 400,
            _backType: "None"
        });


        _pushBackTier({
            _drawEdgeA: 401,
            _drawEdgeB: 438,
            _backType: "Offworld Pack"
        });


        _pushBackTier({
            _drawEdgeA: 439,
            _drawEdgeB: 476,
            _backType: "Expanse Wings"
        });


        _pushBackTier({
            _drawEdgeA: 477,
            _drawEdgeB: 514,
            _backType: "Radar Pack"
        });


        _pushBackTier({
            _drawEdgeA: 515,
            _drawEdgeB: 552,
            _backType: "Arcane Shield"
        });


        _pushBackTier({
            _drawEdgeA: 553,
            _drawEdgeB: 590,
            _backType: "Covert Ops Pack"
        });


        _pushBackTier({
            _drawEdgeA: 591,
            _drawEdgeB: 628,
            _backType: "Armored Pack"
        });


        _pushBackTier({
            _drawEdgeA: 629,
            _drawEdgeB: 666,
            _backType: "Settler's Rake"
        });


        _pushBackTier({
            _drawEdgeA: 667,
            _drawEdgeB: 704,
            _backType: "Void Wings"
        });

        _pushBackTier({
            _drawEdgeA: 705,
            _drawEdgeB: 742,
            _backType: "Battered Trail Rockets"
        });

        _pushBackTier({
            _drawEdgeA: 743,
            _drawEdgeB: 770,
            _backType: "Hydro Pack"
        });

        _pushBackTier({
            _drawEdgeA: 771,
            _drawEdgeB: 798,
            _backType: "Rocket Thrusters"
        });

        _pushBackTier({
            _drawEdgeA: 799,
            _drawEdgeB: 826,
            _backType: "Canon Pack"
        });

        _pushBackTier({
            _drawEdgeA: 827,
            _drawEdgeB: 854,
            _backType: "Neon Pack"
        });

        _pushBackTier({
            _drawEdgeA: 855,
            _drawEdgeB: 882,
            _backType: "Crimson Pulse Rifle"
        });

        _pushBackTier({
            _drawEdgeA: 883,
            _drawEdgeB: 910,
            _backType: "Gromlin"
        });

        _pushBackTier({
            _drawEdgeA: 911,
            _drawEdgeB: 938,
            _backType: "Advanced Jetpack"
        });

        _pushBackTier({
            _drawEdgeA: 939,
            _drawEdgeB: 950,
            _backType: "Baby Monkey Pal"
        });

        _pushBackTier({
            _drawEdgeA: 951,
            _drawEdgeB: 962,
            _backType: "Sludged"
        });

        _pushBackTier({
            _drawEdgeA: 963,
            _drawEdgeB: 974,
            _backType: "Templar Sword"
        });

        _pushBackTier({
            _drawEdgeA: 975,
            _drawEdgeB: 986,
            _backType: "Dual Wakizashi"
        });

    }

    function _pushBackTier(
        uint256 _drawEdgeA,
        uint256 _drawEdgeB,
        string memory _backType
    )
        internal
    {
        backTiers.push(
            BackTier({
                drawEdgeA: _drawEdgeA,
                drawEdgeB: _drawEdgeB,
                backType: _backType
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
