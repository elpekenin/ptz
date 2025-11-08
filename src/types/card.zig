const std = @import("std");
const Allocator = std.mem.Allocator;
const ParseError = std.json.ParseError;
const ParseOptions = std.json.ParseOptions;
const Writer = std.Io.Writer;

const fmt = @import("../fmt.zig");
const meta = @import("../meta.zig");
const Language = @import("../language.zig").Language;
const Query = @import("../query.zig").Query;
const Category = @import("enums.zig").Category;
const Booster = @import("Booster.zig");
const Image = @import("Image.zig");
const Legality = @import("Legality.zig");
const Set = @import("set.zig").Set;
const Pricing = @import("Pricing.zig");

pub const Ability = struct {
    type: []const u8,
    // FIXME: these 2 should be required
    name: ?[]const u8 = null,
    effect: ?[]const u8 = null,

    pub fn format(self: Ability, writer: *Writer) Writer.Error!void {
        try writer.print("{{ .type = {s}", .{self.type});

        if (self.name) |name| {
            try writer.print(", .name = {s}", .{name});
        }

        if (self.effect) |effect| {
            try writer.print(", .effect = {s}", .{effect});
        }

        try writer.print(" }}", .{});
    }
};

pub const Attack = struct {
    cost: []const []const u8,
    name: ?[]const u8 = null, // ??
    effect: ?[]const u8 = null,
    damage: ?Damage = null,

    pub fn format(self: Attack, writer: *Writer) Writer.Error!void {
        try writer.print("{{ .cost = ", .{});
        try fmt.printSlice([]const u8, writer, "{s}", self.cost);

        if (self.name) |name| {
            try writer.print(", .name = {s}", .{name});
        }

        if (self.effect) |effect| {
            try writer.print(", .effect = {s}", .{effect});
        }

        try writer.print(" }}", .{});
    }
};

pub const Damage = union(enum) {
    str: []const u8,
    int: usize,

    pub fn format(self: Damage, writer: *Writer) Writer.Error!void {
        switch (self) {
            .str => |str| try writer.print("{s}", .{str}),
            .int => |int| try writer.print("{d}", .{int}),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: ParseOptions,
    ) ParseError(@TypeOf(source.*))!Damage {
        const token: std.json.Token = try source.nextAlloc(allocator, options.allocate orelse .alloc_always);
        switch (token) {
            .number, .allocated_number => |buf| {
                const int = try std.fmt.parseInt(usize, buf, 10);
                return .{
                    .int = int,
                };
            },
            .string, .allocated_string => |str| {
                return .{
                    .str = str,
                };
            },
            else => return error.UnexpectedToken,
        }
    }
};

// TODO: remove/simplify when values get unified upstream
pub const DexId = union(enum) {
    str: []const u8,
    int: usize,

    pub fn format(self: DexId, writer: *Writer) Writer.Error!void {
        switch (self) {
            .str => |str| try writer.print("{s}", .{str}),
            .int => |int| try writer.print("{d}", .{int}),
        }
    }

    pub fn jsonParse(
        allocator: Allocator,
        source: anytype,
        options: ParseOptions,
    ) ParseError(@TypeOf(source.*))!DexId {
        const token_type: std.json.TokenType = try source.peekNextTokenType();
        switch (token_type) {
            .string => {
                const token: std.json.Token = try source.nextAlloc(allocator, options.allocate orelse .alloc_always);
                switch (token) {
                    .string, .allocated_string => |str| {
                        return .{
                            .str = str,
                        };
                    },
                    else => unreachable,
                }
            },
            .array_begin => {
                const ids = try std.json.innerParse([]const usize, allocator, source, options);
                if (ids.len != 1) return error.LengthMismatch;

                return .{
                    .int = ids[0],
                };
            },
            else => return error.UnexpectedToken,
        }
    }
};

pub const Effectiveness = struct {
    type: []const u8,
    value: ?[]const u8 = null,

    pub fn format(self: Effectiveness, writer: *Writer) Writer.Error!void {
        try writer.print("{{ .type = {s}", .{self.type});

        if (self.value) |value| {
            try writer.print(", .value = {s}", .{value});
        }

        try writer.print(" }}", .{});
    }
};

pub const Variants = struct {
    normal: bool,
    reverse: bool,
    holo: bool,
    firstEdition: bool,

    pub fn format(self: Variants, writer: *Writer) Writer.Error!void {
        try writer.print("{{ .normal = {}, .reverse = {}, .holo ={}, .firstEdition = {} }}", .{ self.normal, self.reverse, self.holo, self.firstEdition });
    }
};

pub const VariantDetailed = struct {
    type: []const u8,
    size: ?[]const u8 = null,
    stamp: ?[]const []const u8 = null,
    foil: ?[]const u8 = null,

    pub fn format(self: VariantDetailed, writer: *Writer) Writer.Error!void {
        try writer.print("{{ .type = {s}", .{self.type});

        if (self.size) |size| {
            try writer.print(", .size = {s}", .{size});
        }

        if (self.stamp) |stamp| {
            try writer.print(", .stamp = ", .{});
            try fmt.printSlice([]const u8, writer, "{s}", stamp);
        }

        if (self.foil) |foil| {
            try writer.print(", .foil = {s}", .{foil});
        }

        try writer.print(" }}", .{});
    }
};

pub fn Card(comptime language: Language) type {
    const query = Query(language);

    // common args
    const Common = struct {
        const Self = @This();

        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image,
        illustrator: ?[]const u8,
        rarity: ?[]const u8,
        set: Set(language).Brief,
        variants: Variants,
        variant_detailed: ?[]const VariantDetailed,
        boosters: ?[]const Booster,
        pricing: ?Pricing,
        updated: []const u8, // date
        legal: Legality,
        regulationMark: ?[]const u8,

        fn from(value: anytype) Self {
            return .{
                .id = value.id,
                .localId = value.localId,
                .name = value.name,
                .image = value.image,
                .illustrator = value.illustrator,
                .rarity = value.rarity,
                .set = value.set,
                .variants = value.variants,
                .variant_detailed = value.variant_detailed,
                .boosters = value.boosters,
                .pricing = value.pricing,
                .updated = value.updated,
                .legal = value.legal,
                .regulationMark = value.regulationMark,
            };
        }

        fn formatFields(value: anytype, writer: *Writer) Writer.Error!void {
            // for autocompletion in editor to work
            const self: Self = from(value);

            try writer.print(".id = {s}, .local_id = {s}, .name = {s}", .{
                self.id,
                self.localId,
                self.name,
            });

            if (self.image) |image| {
                try writer.print(", .image = {f}", .{image});
            }

            if (self.illustrator) |illustrator| {
                try writer.print(", .illustrator = {s}", .{illustrator});
            }

            if (self.rarity) |rarity| {
                try writer.print(", .rarity = {s}", .{rarity});
            }

            try writer.print(", .set = {f}, .variants = {f}", .{ self.set, self.variants });

            if (self.variant_detailed) |detailed| {
                try writer.print(", .variant_detailed = ", .{});
                try fmt.printSlice(VariantDetailed, writer, "{f}", detailed);
            }

            if (self.boosters) |boosters| {
                try writer.print(", .boosters = ", .{});
                try fmt.printSlice(Booster, writer, "{f}", boosters);
            }

            if (self.pricing) |pricing| {
                try writer.print(", .pricing = {f}", .{pricing});
            }

            try writer.print(", .updated = {s}", .{self.updated});

            try writer.print(", .legal = {f}", .{self.legal});

            if (self.regulationMark) |regulation_mark| {
                try writer.print(", .regulationMark = {s}", .{regulation_mark});
            }
        }
    };

    return union(enum) {
        const C = @This();

        pub const url = "cards";

        pub const Pokemon = struct {
            const P = @This();

            __arena: ?*meta.Empty = null,

            id: []const u8,
            localId: []const u8,
            name: []const u8,
            image: ?Image = null,
            illustrator: ?[]const u8 = null,
            rarity: ?[]const u8 = null,
            set: Set(language).Brief,
            variants: Variants,
            variant_detailed: ?[]const VariantDetailed = null,
            boosters: ?[]const Booster = null,
            pricing: ?Pricing = null,
            updated: []const u8,
            legal: Legality,
            regulationMark: ?[]const u8 = null,

            //

            dexId: ?DexId = null,
            hp: ?usize = null,
            types: ?[]const []const u8 = null,
            evolveFrom: ?[]const u8 = null,
            description: ?[]const u8 = null,
            level: ?[]const u8 = null,
            stage: ?[]const u8 = null,
            suffix: ?[]const u8 = null,
            item: ?Item = null,
            abilities: ?[]const Ability = null,
            attacks: ?[]const Attack = null,
            weaknesses: ?[]const Effectiveness = null,
            resistances: ?[]const Effectiveness = null,
            retreat: ?u8 = null,

            const Item = struct {
                name: []const u8,
                effect: []const u8,

                pub fn format(self: Item, writer: *Writer) Writer.Error!void {
                    try writer.print("{{ .name = {s}, .effect = {s} }}", .{ self.name, self.effect });
                }
            };

            pub fn deinit(self: P) void {
                meta.deinit(P, self);
            }

            pub fn format(self: P, writer: *Writer) Writer.Error!void {
                try writer.print("{{ ", .{});

                try Common.formatFields(self, writer);

                if (self.dexId) |dexId| {
                    try writer.print(", .dexId = {f}", .{dexId});
                }

                if (self.hp) |hp| {
                    try writer.print(", .hp = {d}", .{hp});
                }

                if (self.types) |types| {
                    try writer.print(", .types = ", .{});
                    try fmt.printSlice([]const u8, writer, "{s}", types);
                }

                if (self.evolveFrom) |evolveFrom| {
                    try writer.print(", .evolveFrom = {s}", .{evolveFrom});
                }

                if (self.description) |description| {
                    try writer.print(", .description = {s}", .{description});
                }

                if (self.level) |level| {
                    try writer.print(", .level = {s}", .{level});
                }

                if (self.stage) |stage| {
                    try writer.print(", .stage = {s}", .{stage});
                }

                if (self.suffix) |suffix| {
                    try writer.print(", .suffix = {s}", .{suffix});
                }

                if (self.item) |item| {
                    try writer.print(", .item = {f}", .{item});
                }

                if (self.abilities) |abilities| {
                    try writer.print(", .abilities = ", .{});
                    try fmt.printSlice(Ability, writer, "{f}", abilities);
                }

                if (self.attacks) |attacks| {
                    try writer.print(", .attacks = ", .{});
                    try fmt.printSlice(Attack, writer, "{f}", attacks);
                }

                if (self.weaknesses) |weaknesses| {
                    try writer.print(", .weaknesses = ", .{});
                    try fmt.printSlice(Effectiveness, writer, "{f}", weaknesses);
                }

                if (self.resistances) |resistances| {
                    try writer.print(", .resistances = ", .{});
                    try fmt.printSlice(Effectiveness, writer, "{f}", resistances);
                }

                if (self.retreat) |retreat| {
                    try writer.print(", .retreat = {d}", .{retreat});
                }

                try writer.print(" }}", .{});
            }
        };

        pub const Trainer = struct {
            const T = @This();

            __arena: ?*meta.Empty = null,

            id: []const u8,
            localId: []const u8,
            name: []const u8,
            image: ?Image = null,
            illustrator: ?[]const u8 = null,
            rarity: ?[]const u8 = null,
            set: Set(language).Brief,
            variants: Variants,
            variant_detailed: ?[]const VariantDetailed = null,
            boosters: ?[]const Booster = null,
            pricing: ?Pricing = null,
            updated: []const u8,
            legal: Legality,
            regulationMark: ?[]const u8 = null,

            //

            // FIXME: these should be required (?)
            effect: ?[]const u8 = null,
            trainerType: ?[]const u8 = null,

            pub fn deinit(self: T) void {
                meta.deinit(T, self);
            }

            pub fn format(self: T, writer: *Writer) Writer.Error!void {
                try writer.print("{{ ", .{});

                try Common.formatFields(self, writer);

                if (self.effect) |effect| {
                    try writer.print(", .effect = {s}", .{effect});
                }

                if (self.trainerType) |trainerType| {
                    try writer.print(", .trainerType = {s}", .{trainerType});
                }

                try writer.print(" }}", .{});
            }
        };

        pub const Energy = struct {
            const E = @This();

            __arena: ?*meta.Empty = null,

            id: []const u8,
            localId: []const u8,
            name: []const u8,
            image: ?Image = null,
            illustrator: ?[]const u8 = null,
            rarity: ?[]const u8 = null,
            set: Set(language).Brief,
            variants: Variants,
            variant_detailed: ?[]const VariantDetailed = null,
            boosters: ?[]const Booster = null,
            pricing: ?Pricing = null,
            updated: []const u8,
            legal: Legality,
            regulationMark: ?[]const u8 = null,

            //

            effect: []const u8,
            energyType: []const u8,

            pub fn deinit(self: E) void {
                meta.deinit(E, self);
            }

            pub fn format(self: E, writer: *Writer) Writer.Error!void {
                try writer.print("{{ ", .{});

                try Common.formatFields(self, writer);

                try writer.print(", .effect = {s}, .type = {s}", .{ self.effect, self.energyType });

                try writer.print(" }}", .{});
            }
        };

        pokemon: Pokemon,
        trainer: Trainer,
        energy: Energy,

        pub fn __setArena(self: *C, arena: *meta.Empty) void {
            switch (self.*) {
                .pokemon => self.pokemon.__arena = arena,
                .trainer => self.trainer.__arena = arena,
                .energy => self.energy.__arena = arena,
            }
        }

        pub fn deinit(self: C) void {
            switch (self) {
                .pokemon => self.pokemon.deinit(),
                .trainer => self.trainer.deinit(),
                .energy => self.energy.deinit(),
            }
        }

        pub fn get(allocator: Allocator, params: query.Get) !C {
            var q: query.Q(C, .one) = .init(allocator, params);
            return q.run();
        }

        pub fn all(allocator: Allocator, params: query.ParamsFor(Brief)) query.Iterator(Brief) {
            return Brief.iterator(allocator, params);
        }

        pub const Brief = struct {
            pub const url = C.url;

            __arena: ?*meta.Empty = null,

            id: []const u8,
            localId: []const u8,
            name: []const u8,
            image: ?Image = null,

            pub fn deinit(self: Brief) void {
                meta.deinit(Brief, self);
            }

            pub fn get(allocator: Allocator, params: query.Get) !Brief {
                var q: query.Q(Brief, .one) = .init(allocator, params);
                return q.run();
            }

            pub fn iterator(allocator: Allocator, params: query.ParamsFor(Brief)) query.Iterator(Brief) {
                return .init(allocator, params);
            }

            pub fn format(self: Brief, writer: *Writer) Writer.Error!void {
                try writer.print("{{ .id = {s}, .localId = {s}, .name = {s}", .{ self.id, self.localId, self.name });

                if (self.image) |image| {
                    try writer.print(", .image = {f}", .{image});
                }

                try writer.print(" }}", .{});
            }
        };

        pub fn jsonParse(
            allocator: Allocator,
            source: anytype,
            options: ParseOptions,
        ) ParseError(@TypeOf(source.*))!C {
            // dummy type just to parse the category from the API's response
            const Raw = struct {
                category: Category(language),
            };

            // create an ephimeral scanner for the dummy type, not to mess original's state
            var common_source: std.json.Scanner = .initCompleteInput(allocator, source.input);
            defer common_source.deinit();

            const common = try std.json.parseFromTokenSource(Raw, allocator, &common_source, options);
            defer common.deinit();

            switch (common.value.category) {
                .Pokemon => {
                    var pokemon = try std.json.parseFromTokenSource(Pokemon, allocator, source, options);
                    meta.setArena(Pokemon, &pokemon.value, pokemon.arena);
                    return .{ .pokemon = pokemon.value };
                },
                .Trainer => {
                    var trainer = try std.json.parseFromTokenSource(Trainer, allocator, source, options);
                    meta.setArena(Trainer, &trainer.value, trainer.arena);
                    return .{ .trainer = trainer.value };
                },
                .Energy => {
                    var energy = try std.json.parseFromTokenSource(Energy, allocator, source, options);
                    meta.setArena(Energy, &energy.value, energy.arena);
                    return .{ .energy = energy.value };
                },
            }
        }

        pub fn format(self: C, writer: *Writer) Writer.Error!void {
            try writer.print("{{ .{t} = ", .{self});

            switch (self) {
                .pokemon => |value| try writer.print("{f}", .{value}),
                .trainer => |value| try writer.print("{f}", .{value}),
                .energy => |value| try writer.print("{f}", .{value}),
            }

            try writer.print(" }}", .{});
        }
    };
}
