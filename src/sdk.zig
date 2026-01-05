// TODO: on `jsonParse()`, figure out what to do with allocated vs non-allocated
//       is it good as is, or shall we perform have to allocation/free?

pub const Language = @import("language.zig").Language;

const card = @import("types/card.zig");
const serie = @import("types/serie.zig");
const set = @import("types/set.zig");

pub fn For(comptime language: Language) type {
    return struct {
        // language-agnostic types
        pub const Ability = card.Ability;
        pub const Attack = card.Attack;
        pub const Booster = @import("types/Booster.zig");
        pub const CardCount = set.CardCount;
        pub const Damage = card.Damage;
        pub const DexId = card.DexId;
        pub const Effectiveness = card.Effectiveness;
        pub const Image = @import("types/Image.zig");
        pub const Legality = @import("types/Legality.zig");
        pub const VariantDetailed = card.VariantDetailed;
        pub const Variants = card.Variants;
        pub const Pricing = @import("types/Pricing.zig");

        // language-specific types
        pub const Iterator = @import("query.zig").Query(language).Iterator;
        pub const Card = card.Card(language);
        pub const Serie = serie.Serie(language);
        pub const Set = set.Set(language);
    };
}
