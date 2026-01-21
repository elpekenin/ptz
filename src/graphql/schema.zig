//! THIS FILE WAS GENERATED, DON'T EDIT MANUALLY

// aliases for zig compatibility
pub const Boolean = bool;
pub const Float = f64;
pub const ID = Int; // FIXME: should this be String?
pub const Int = u64;
pub const String = []const u8;

pub const Query = struct {
    pub const cards = struct {
        pub const Args = struct {
            filters: ?CardsFilters = null,
            pagination: ?Pagination = null,
            sort: ?Sort = null,
        };
        pub const Return = ?[]const Card;
    };

    pub const sets = struct {
        pub const Args = struct {
            filters: ?SetFilters = null,
            pagination: ?Pagination = null,
            sort: ?Sort = null,
        };
        pub const Return = ?[]const Set;
    };

    pub const series = struct {
        pub const Args = struct {
            filters: ?SerieFilters = null,
            pagination: ?Pagination = null,
            sort: ?Sort = null,
        };
        pub const Return = ?[]const Serie;
    };

    pub const card = struct {
        pub const Args = struct {
            id: ?ID = null,
            set: ?String = null,
            filters: ?CardsFilters = null,
        };
        pub const Return = ?Card;
    };

    pub const set = struct {
        pub const Args = struct {
            id: ?ID = null,
            filters: ?SetFilters = null,
        };
        pub const Return = ?Set;
    };

    pub const serie = struct {
        pub const Args = struct {
            id: ?ID = null,
            filters: ?SerieFilters = null,
        };
        pub const Return = ?Serie;
    };
};

pub const Pagination = struct {
    page: Int,
    itemsPerPage: ?Int = null,
};

pub const Sort = struct {
    field: String,
    order: ?String = null,
};

pub const CardsFilters = struct {
    category: ?String = null,
    description: ?String = null,
    energyType: ?String = null,
    evolveFrom: ?String = null,
    hp: ?Int = null,
    id: ?ID = null,
    localId: ?String = null,
    dexId: ?Int = null,
    illustrator: ?String = null,
    level: ?Int = null,
    name: ?String = null,
    rarity: ?String = null,
    regulationMark: ?String = null,
    stage: ?String = null,
    suffix: ?String = null,
    trainerType: ?String = null,
    retreat: ?Int = null,
};

pub const Card = struct {
    abilities: ?[]const AbilitiesListItem = null,
    attacks: ?[]const AttacksListItem = null,
    category: String,
    description: ?String = null,
    dexId: ?[]const Int = null,
    effect: ?String = null,
    energyType: ?String = null,
    evolveFrom: ?String = null,
    hp: ?Int = null,
    id: String,
    illustrator: ?String = null,
    image: ?String = null,
    item: ?Item = null,
    legal: Legal,
    level: ?Int = null,
    localId: String,
    name: String,
    rarity: String,
    regulationMark: ?String = null,
    resistances: ?[]const WeakResListItem = null,
    retreat: ?Int = null,
    set: Set,
    stage: ?String = null,
    suffix: ?String = null,
    trainerType: ?String = null,
    types: ?[]const String = null,
    variants: ?Variants = null,
    variants_detailed: ?[]const DetailedVariants = null,
    boosters: ?[]const Booster = null,
    weaknesses: ?[]const WeakResListItem = null,
};

pub const AbilitiesListItem = struct {
    effect: ?String = null,
    name: ?String = null,
    type: ?String = null,
};

pub const AttacksListItem = struct {
    cost: ?[]const String = null,
    damage: ?String = null,
    effect: ?String = null,
    name: String,
};

pub const Item = struct {
    effect: String,
    name: String,
};

pub const Legal = struct {
    expanded: ?Boolean = null,
    standard: ?Boolean = null,
};

pub const WeakResListItem = struct {
    type: String,
    value: ?String = null,
};

pub const Variants = struct {
    firstEdition: Boolean,
    holo: Boolean,
    normal: Boolean,
    reverse: Boolean,
    wPromo: Boolean,
};

pub const DetailedVariants = struct {
    type: String,
    size: String,
    stamps: ?[]const String = null,
    foil: ?String = null,
};

pub const Booster = struct {
    id: String,
    name: String,
    logo: ?String = null,
    artwork_front: ?String = null,
    artwork_back: ?String = null,
};

pub const Set = struct {
    cardCount: CardCount,
    cards: []const Card,
    id: String,
    logo: ?String = null,
    name: String,
    symbol: ?String = null,
    serie: Serie,
    releaseDate: String,
    tcgOnline: ?String = null,
    boosters: ?[]const Booster = null,
};

pub const SetFilters = struct {
    id: ?String = null,
    name: ?String = null,
    serie: ?String = null,
    releaseDate: ?String = null,
    tcgOnline: ?String = null,
};

pub const CardCount = struct {
    firstEd: ?Int = null,
    holo: ?Int = null,
    normal: ?Int = null,
    official: Int,
    reverse: ?Int = null,
    total: Int,
};

pub const Serie = struct {
    id: String,
    logo: ?String = null,
    name: String,
    sets: []const Set,
};

pub const SerieFilters = struct {
    id: ?String = null,
    name: ?String = null,
};

pub const StringEndpoint = struct {
    cards: []const Card,
    name: String,
};

