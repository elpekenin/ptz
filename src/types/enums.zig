pub const BasicEnergyType = enum {
    Darkness,
    Fairy,
    Fighting,
    Fire,
    Grass,
    Lighting,
    Metal,
    Psychic,
    Water,
};

pub const Category = enum {
    Pokemon,
    Energy,
    Trainer,
};

pub const EnergyKind = enum {
    Basic,
    Special,
};

pub const MoneyUnit = enum {
    EUR,
    USD,
};

pub const PokemonType = enum {
    Darkness,
    Colorless,
    Dragon,
    Fighting,
    Fire,
    Grass,
    Lighting,
    Metal,
    Psychic,
    Water,
};

pub const Rarity = enum {
    Common,
    Ex,
    @"Four Diamond",
    @"Holo Rare",
    @"Holo Rare V",
    @"Holo Rare VMAX",
    None,
    @"One Diamond",
    @"One Shiny",
    Rare,
    @"Rare Holo",
    @"Rare Holo LV.X",
    @"Rare PRIME",
    @"Secret Rare",
    @"Three Diamond",
    @"Two Shiny",
    @"Two Star",
    @"Ultra Rare",
    Uncommon,
};

pub const Stage = enum {
    Basic,
    BREAK,
    @"LEVEL-UP",
    Stage1,
    Stage2,
    VMAX,
};

pub const TrainerType = enum {
    Item,
    @"Rocket's Secret Machine",
    Supporter,
    @"Technical Machine",
    Tool,
};
