// Reference: https://github.com/tcgdex/cards-database/blob/master/interfaces.d.ts

const Language = @import("../language.zig").Language;

pub fn Category(comptime language: Language) type {
    return switch (language) {
        .en => enum {
            Pokemon,
            Trainer,
            Energy,
        },
        else => unreachable,
    };
}

// TODO: Implement language-specific enums at some point, so far just treat them as free text

fn AbilityType(comptime language: Language) type {
    return switch (language) {
        .en => enum {
            @"Pokemon Power",
            @"Poke-BODY",
            @"Poke-POWER",
            Ability,
            @"Ancient Trait",
        },
        else => unreachable,
    };
}

fn EnergyType(comptime language: Language) type {
    return switch (language) {
        .en => enum {
            Normal,
            Special,
        },
        else => unreachable,
    };
}

fn Rarity(comptime language: Language) type {
    return switch (language) {
        .en => enum {
            @"ACE SPEC Rare",
            @"Amazing Rare",
            @"Classic Collection",
            Common,
            @"Double rare",
            @"Full Art Trainer",
            @"Holo Rare",
            @"Holo Rare V",
            @"Holo Rare VMAX",
            @"Holo Rare VSTAR",
            @"Hyper rare",
            @"Illustration rare",
            LEGEND,
            None,
            @"Radiant Rare",
            Rare,
            @"Rare Holo",
            @"Rare Holo LV.X",
            @"Rare PRIME",
            @"Secret Rare",
            @"Shiny Ultra Rare",
            @"Shiny rare",
            @"Shiny rare V",
            @"Shiny rare VMAX",
            @"Special illustration rare",
            @"Ultra Rare",
            Uncommon,
            @"Black White Rare",
            @"Mega Hyper Rare",
            @"One Diamond",
            @"Two Diamond",
            @"Three Diamond",
            @"Four Diamond",
            @"One Star",
            @"Two Star",
            @"Three Star",
            Crown,
            @"One Shiny",
            @"Two Shiny",
        },
        else => unreachable,
    };
}

const RegulationMark = enum {
    D,
    E,
    F,
    G,
    H,
    I,
};

fn Stage(comptime language: Language) type {
    return switch (language) {
        .en => enum {
            Basic,
            BREAK,
            @"LEVEL-UP",
            MEGA,
            RESTORED,
            Stage1,
            Stage2,
            VMAX,
            @"V-UNION",
            Baby,
            VSTAR,
        },
        else => unreachable,
    };
}

fn Suffix(comptime language: Language) type {
    return switch (language) {
        .en => enum {
            EX,
            GX,
            V,
            Legend,
            Prime,
            SP,
            @"TAG TEAM-GX",
        },
        else => unreachable,
    };
}
fn TrainerType(comptime language: Language) type {
    return switch (language) {
        .en => enum {
            Supporter,
            Item,
            Stadium,
            Tool,
            @"Ace Spec",
            @"Technical Machine",
            @"Goldenrod Game Corner",
            @"Rocket's Secret Machine",
        },
        else => unreachable,
    };
}

fn Type(comptime language: Language) type {
    return switch (language) {
        .en => enum {
            Colorless,
            Darkness,
            Dragon,
            Fairy,
            Fighting,
            Fire,
            Grass,
            Lightning,
            Metal,
            Psychic,
            Water,
        },
        else => unreachable,
    };
}
