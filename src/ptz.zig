// TODO: on `jsonParse()`, figure out what to do with allocated vs non-allocated
//       is it good as is, or shall we perform have to allocation/free?

const ptz = @This();

// standalone types
pub const Language = @import("language.zig").Language;
pub const Pricing = @import("types/Pricing.zig");

const serie = @import("types/serie.zig");

const set = @import("types/set.zig");
pub const CardCount = set.CardCount;

const card = @import("types/card.zig");
pub const Ability = card.Ability;
pub const Attack = card.Attack;
pub const Damage = card.Damage;
pub const DexId = card.DexId;
pub const Effectiveness = card.Effectiveness;
pub const VariantDetailed = card.VariantDetailed;
pub const Variants = card.Variants;

pub fn Sdk(comptime language: Language) type {
    return struct {
        pub const Pricing = ptz.Pricing;

        pub const Card = card.Card(language);
        pub const Serie = serie.Serie(language);
        pub const Set = set.Set(language);

        pub const Iterator = @import("query.zig").Query(language).Iterator;
    };
}
