const Language = @import("language.zig").Language;

pub fn Sdk(comptime language: Language) type {
    return struct {
        pub const Card = @import("types/card.zig").Card(language);
        pub const Serie = @import("types/serie.zig").Serie(language);
        pub const Set = @import("types/set.zig").Set(language);

        pub const Iterator = @import("query.zig").Query(language).Iterator;
    };
}
