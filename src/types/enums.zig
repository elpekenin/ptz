// Reference: https://github.com/tcgdex/cards-database/blob/master/interfaces.d.ts

// TODO: Language-specific texts

pub const AbilityType = enum {
    @"Pokemon Power",
    @"Poke-BODY",
    @"Poke-POWER",
    Ability,
    @"Ancient Trait",
};

pub const Category = enum {
    Pokemon,
    Trainer,
    Energy,
};

pub const EnergyType = enum {
    Normal,
    Special,
};

pub const Language = enum {
    en,
    fr,
    es,
    @"es-mx",
    it,
    pt,
    @"pt-br",
    @"pt-pt",
    de,
    nl,
    pl,
    ru,
    ja,
    ko,
    @"zh-tw",
    id,
    th,
    @"zn-cn",
};

pub const MoneyUnit = enum {
    EUR,
    USD,
};

pub const Rarity = enum {
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
};

pub const Stage = enum {
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
};

pub const Suffix = enum {
    EX,
    GX,
    V,
    Legend,
    Prime,
    SP,
    @"TAG TEAM-GX",
};

pub const TrainerType = enum {
    Supporter,
    Item,
    Stadium,
    Tool,
    @"Ace Spec",
    @"Technical Machine",
    @"Goldenrod Game Corner",
    @"Rocket's Secret Machine",
};

pub const Type = enum {
    Colorless,
    Darkness,
    Dragon,
    Fairy,
    Fighting,
    Fire,
    Grass,
    Lighting,
    Metal,
    Psychic,
    Water,
};
