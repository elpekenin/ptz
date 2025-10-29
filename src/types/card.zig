const std = @import("std");

const fmt = @import("../fmt.zig");
const enums = @import("enums.zig");
const query = @import("../query.zig");
const Booster = @import("Booster.zig");
const Image = @import("Image.zig");
const Legality = @import("Legality.zig");
const Set = @import("Set.zig");
const Pricing = @import("Pricing.zig");

// TODO:
// legal: Legality,
// regulationMark: ?[]const u8 = null, // TODO: enum
// variants_detailed: []Variants.Detailed,

const Common = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?Image = null,
    illustrator: ?[]const u8 = null,
    rarity: ?enums.Rarity = null,
    set: Set.Brief,
    variants: Variants,
    boosters: ?[]const Booster = null,
    pricing: ?Pricing = null,
    updated: []const u8, // date
};

// assert that types have all the common fields, and they are the right type
comptime {
    for (.{ Pokemon, Trainer, Energy }) |T| {
        for (@typeInfo(Common).@"struct".fields) |field| {
            std.debug.assert(@FieldType(T, field.name) == field.type);
        }
    }
}

const Ability = struct {
    type: enums.AbilityType,
    // FIXME: these 2 should be required
    name: ?[]const u8 = null,
    effect: ?[]const u8 = null,

    pub fn format(
        self: Ability,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .type = {t},", .{self.type});

        if (self.name) |name| {
            try writer.print(" .name = {s},", .{name});
        }

        if (self.effect) |effect| {
            try writer.print(" .effect = {s},", .{effect});
        }

        try writer.print(" }}", .{});
    }
};

const Attack = struct {
    cost: []const enums.Type,
    name: []const u8,
    effect: ?[]const u8 = null,
    damage: ?Damage = null,

    pub fn format(
        self: Attack,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .cost = ", .{});

        try fmt.printSlice(enums.Type, writer, "{t}", self.cost);

        try writer.print(", .name = {s},", .{self.name});

        if (self.effect) |effect| {
            try writer.print(" .effect = {s},", .{effect});
        }

        try writer.print(" }}", .{});
    }
};

const Damage = union(enum) {
    str: []const u8,
    int: usize,

    pub fn format(
        self: Damage,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        switch (self) {
            .str => |str| try writer.print("{s}", .{str}),
            .int => |int| try writer.print("{d}", .{int}),
        }
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) std.json.ParseFromValueError!Damage {
        _ = allocator;
        _ = options;

        switch (source) {
            .integer => |int| {
                return .{ .int = @intCast(int) };
            },
            .string => |str| {
                return .{ .str = str };
            },
            else => return error.UnexpectedToken,
        }
    }
};

// TODO: remove/simplify when values get unified upstream
const DexId = union(enum) {
    str: []const u8,
    int: usize,

    pub fn format(
        self: DexId,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        switch (self) {
            .str => |str| try writer.print("{s}", .{str}),
            .int => |int| try writer.print("{d}", .{int}),
        }
    }

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) std.json.ParseFromValueError!DexId {
        _ = allocator;
        _ = options;

        switch (source) {
            .string => |str| {
                return .{ .str = str };
            },
            .array => |arr| {
                if (arr.items.len != 1) {
                    return error.LengthMismatch;
                }

                const int = switch (arr.items[0]) {
                    .integer => |int| int,
                    else => return error.UnexpectedToken,
                };

                return .{ .int = @intCast(int) };
            },
            else => return error.UnexpectedToken,
        }
    }
};

const Effectiveness = struct {
    const Value = enum {
        @"×2",
        @"+10",
        @"+20",
        @"+30",
        @"+40",
        @"10+",
        @"20+",
    };

    type: enums.Type,
    value: Value,

    pub fn format(
        self: Effectiveness,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .type = {t}, .value = {t} }}", .{ self.type, self.value });
    }
};

const Variants = struct {
    normal: bool,
    reverse: bool,
    holo: bool,
    firstEdition: bool,

    pub fn format(
        self: Variants,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .normal = {}, .reverse = {}, .holo ={}, .firstEdition = {} }}", .{ self.normal, self.reverse, self.holo, self.firstEdition });
    }
};

//
// actual card types
//

const Pokemon = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?Image = null,
    illustrator: ?[]const u8 = null,
    rarity: ?enums.Rarity = null,
    set: Set.Brief,
    variants: Variants,
    boosters: ?[]const Booster = null,
    pricing: ?Pricing = null,
    updated: []const u8,

    //

    dexId: ?DexId = null,
    hp: ?usize = null,
    types: ?[]const enums.Type = null,
    evolveFrom: ?[]const u8 = null,
    description: ?[]const u8 = null,
    level: ?[]const u8 = null,
    stage: ?enums.Stage = null,
    suffix: ?enums.Suffix = null,
    item: ?Item = null,
    abilities: ?[]const Ability = null,
    attacks: ?[]const Attack = null,
    weaknesses: ?[]const Effectiveness = null,
    resistances: ?[]const Effectiveness = null,
    retreat: ?u8 = null,

    const Item = struct {
        name: []const u8,
        effect: []const u8,

        pub fn format(
            self: Item,
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .name = {s}, .effect = {s} }}", .{ self.name, self.effect });
        }
    };

    pub fn format(
        self: Pokemon,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        if (self.dexId) |dexId| {
            try writer.print(" .dexId = {f},", .{dexId});
        }

        if (self.hp) |hp| {
            try writer.print(" .hp = {d},", .{hp});
        }

        if (self.types) |types| {
            try writer.print(" .types = ", .{});
            try fmt.printSlice(enums.Type, writer, "{t}", types);
            try writer.writeByte(',');
        }

        if (self.evolveFrom) |evolveFrom| {
            try writer.print(" .evolveFrom = {s},", .{evolveFrom});
        }

        if (self.description) |description| {
            try writer.print(" .description = {s},", .{description});
        }

        if (self.level) |level| {
            try writer.print(" .level = {s},", .{level});
        }

        if (self.stage) |stage| {
            try writer.print(" .stage = {t},", .{stage});
        }

        if (self.suffix) |suffix| {
            try writer.print(" .suffix = {t},", .{suffix});
        }

        if (self.item) |item| {
            try writer.print(" .item = {f},", .{item});
        }

        if (self.abilities) |abilities| {
            try writer.print(" .abilities = ", .{});
            try fmt.printSlice(Ability, writer, "{f}", abilities);
            try writer.writeByte(',');
        }

        if (self.attacks) |attacks| {
            try writer.print(" .attacks = ", .{});
            try fmt.printSlice(Attack, writer, "{f}", attacks);
            try writer.writeByte(',');
        }

        if (self.weaknesses) |weaknesses| {
            try writer.print(" .weaknesses = ", .{});
            try fmt.printSlice(Effectiveness, writer, "{f}", weaknesses);
            try writer.writeByte(',');
        }

        if (self.resistances) |resistances| {
            try writer.print(" .resistances = ", .{});
            try fmt.printSlice(Effectiveness, writer, "{f}", resistances);
            try writer.writeByte(',');
        }

        if (self.retreat) |retreat| {
            try writer.print(" .retreat = {d},", .{retreat});
        }
    }
};

const Trainer = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?Image = null,
    illustrator: ?[]const u8 = null,
    rarity: ?enums.Rarity = null,
    set: Set.Brief,
    variants: Variants,
    boosters: ?[]const Booster = null,
    pricing: ?Pricing = null,
    updated: []const u8,

    //

    // FIXME: these should be required (?)
    effect: ?[]const u8 = null,
    trainerType: ?enums.TrainerType = null,

    pub fn format(
        self: Trainer,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        if (self.effect) |effect| {
            try writer.print(" .effect = {s},", .{ effect });
        }

        if (self.trainerType) |trainerType| {
            try writer.print(" .trainerType = {t},", .{ trainerType });
        }
    }
};

const Energy = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?Image = null,
    illustrator: ?[]const u8 = null,
    rarity: ?enums.Rarity = null,
    set: Set.Brief,
    variants: Variants,
    boosters: ?[]const Booster = null,
    pricing: ?Pricing = null,
    updated: []const u8,

    //

    effect: []const u8,
    energyType: enums.EnergyType,

    pub fn format(
        self: Energy,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print(" .effect = {s}, .type = {t},", .{ self.effect, self.energyType });
    }
};

pub const Card = union(enum) {
    pub const url = "cards";

    pokemon: Pokemon,
    trainer: Trainer,
    energy: Energy,

    // dummy type just to parse the category from the API's response
    const Raw = struct {
        category: enums.Category,
    };

    pub fn get(allocator: std.mem.Allocator, language: enums.Language, params: query.Get) !Card {
        const q: query.Q(Card, .one) = .{ .params = params };
        return q.run(allocator, language);
    }

    pub fn all(language: enums.Language, params: query.Params(Brief)) query.Iterator(Brief) {
        return Brief.iterator(language, params);
    }

    pub const Brief = struct {
        pub const url = Card.url;

        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image = null,

        pub fn iterator(language: enums.Language, params: query.Params(Brief)) query.Iterator(Brief) {
            return .new(language, params);
        }

        pub fn format(
            self: Brief,
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .id = {s}, .localId = {s}, .name = {s},", .{ self.id, self.localId, self.name });

            if (self.image) |image| {
                try writer.print(" .image = {f},", .{image});
            }

            try writer.print(" }}", .{});
        }
    };

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) std.json.ParseFromValueError!Card {
        const common = try std.json.parseFromValue(Raw, allocator, source, options);
        defer common.deinit();

        switch (common.value.category) {
            .Pokemon => {
                const parsed = try std.json.parseFromValue(Pokemon, allocator, source, options);
                defer parsed.deinit();

                return .{ .pokemon = parsed.value };
            },
            .Energy => {
                const parsed = try std.json.parseFromValue(Energy, allocator, source, options);
                defer parsed.deinit();

                return .{ .energy = parsed.value };
            },
            .Trainer => {
                const parsed = try std.json.parseFromValue(Trainer, allocator, source, options);
                defer parsed.deinit();

                return .{ .trainer = parsed.value };
            },
        }
    }

    fn commonFormat(comptime T: type, value: T, writer: *std.Io.Writer) std.Io.Writer.Error!void {
        std.debug.assert(T == Pokemon or T == Energy or T == Trainer);

        try writer.print(".id = {s}, .local_id = {s}, .name = {s},", .{
            value.id,
            value.localId,
            value.name,
        });

        if (value.image) |image| {
            try writer.print(" .image = {f},", .{image});
        }

        if (value.illustrator) |illustrator| {
            try writer.print(" .illustrator = {s},", .{illustrator});
        }

        if (value.rarity) |rarity| {
            try writer.print(" .rarity = {t},", .{rarity});
        }

        try writer.print(" .set = {f}, .variants = {f},", .{ value.set, value.variants });

        if (value.boosters) |boosters| {
            try writer.print(" .boosters = ", .{});
            try fmt.printSlice(Booster, writer, "{f}", boosters);
            try writer.writeByte(',');
        }

        if (value.pricing) |pricing| {
            try writer.print(" .pricing = {f},", .{pricing});
        }

        try writer.print(" .updated = {s},", .{value.updated});
    }

    pub fn format(
        self: Card,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{t}{{", .{self});

        switch (self) {
            .pokemon => |value| {
                try commonFormat(Pokemon, value, writer);
                try writer.print("{f}", .{value});
            },
            .energy => |value| {
                try commonFormat(Energy, value, writer);
                try writer.print("{f}", .{value});
            },
            .trainer => |value| {
                try commonFormat(Trainer, value, writer);
                try writer.print("{f}", .{value});
            },
        }

        try writer.print(" }}", .{});
    }
};
