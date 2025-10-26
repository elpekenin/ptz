const std = @import("std");

const enums = @import("enums.zig");
const query = @import("../query.zig");
const Attack = @import("Attack.zig");
const Booster = @import("Booster.zig");
const Effectiveness = @import("Effectiveness.zig");
const Legality = @import("Legality.zig");
const Set = @import("Set.zig");
const Pricing = @import("Pricing.zig");
const Variants = @import("Variants.zig");

const Common = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?[]const u8 = null,
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

const Pokemon = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?[]const u8 = null,
    illustrator: ?[]const u8 = null,
    rarity: ?enums.Rarity = null,
    set: Set.Brief,
    variants: Variants,
    boosters: ?[]const Booster = null,
    pricing: ?Pricing = null,
    updated: []const u8,

    //

    dexId: ?[]const u8 = null, // sometimes text, sometimes array of values
    hp: ?usize = null,
    types: ?[]const enums.PokemonType = null,
    evolveFrom: ?[]const u8 = null,
    description: ?[]const u8 = null,
    level: ?[]const u8 = null,
    stage: ?enums.Stage = null,
    suffix: ?[]const u8 = null, // TODO: enum
    item: ?Item = null,

    const Item = struct {
        name: []const u8,
        effect: []const u8,
    };

    pub fn format(
        self: Pokemon,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        if (self.dexId) |dexId| {
            try writer.print(" .dexId = {s},", .{dexId});
        }

        if (self.hp) |hp| {
            try writer.print(" .hp = {d},", .{hp});
        }

        if (self.types) |types| {
            try writer.print(" .types = {{", .{});

            for (types) |typ| {
                try writer.print(" {t},", .{typ});
            }

            try writer.writeByte('}');
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
            try writer.print(" .suffix = {s},", .{suffix});
        }

        if (self.item) |item| {
            try writer.print(" .item = {any},", .{item});
        }
    }
};

const Trainer = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?[]const u8 = null,
    illustrator: ?[]const u8 = null,
    rarity: ?enums.Rarity = null,
    set: Set.Brief,
    variants: Variants,
    boosters: ?[]const Booster = null,
    pricing: ?Pricing = null,
    updated: []const u8,

    //

    effect: ?[]const u8 = null, // FIXME: not nullable according to docs
    trainerType: enums.TrainerType,

    pub fn format(
        self: Trainer,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print(" .effect = {?s}, .type = {t},", .{ self.effect, self.trainerType });
    }
};

const Energy = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?[]const u8 = null,
    illustrator: ?[]const u8 = null,
    rarity: ?enums.Rarity = null,
    set: Set.Brief,
    variants: Variants,
    boosters: ?[]const Booster = null,
    pricing: ?Pricing = null,
    updated: []const u8,

    //

    effect: []const u8,
    energyType: enums.EnergyKind,

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

    pub fn get(allocator: std.mem.Allocator, params: query.Get) !Card {
        const q: query.Q(Card, .one) = .{ .params = params };
        return q.run(allocator);
    }

    pub fn all(params: query.Params(Brief)) query.Iterator(Brief) {
        return Brief.iterator(params);
    }

    pub const Brief = struct {
        pub const url = Card.url;

        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?[]const u8 = null, // shouldn't be missing, but sometimes is

        pub fn iterator(params: query.Params(Brief)) query.Iterator(Brief) {
            return .new(params);
        }
    };

    pub fn jsonParseFromValue(
        allocator: std.mem.Allocator,
        source: std.json.Value,
        options: std.json.ParseOptions,
    ) std.json.ParseFromValueError!Card {
        // TODO: try and speed up parsing
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
            try writer.print(" .image = {s},", .{image});
        }

        if (value.illustrator) |illustrator| {
            try writer.print(" .illustrator = {s},", .{illustrator});
        }

        if (value.rarity) |rarity| {
            try writer.print(" .rarity = {t},", .{rarity});
        }

        try writer.print(" .set = {f}, .variants = {any},", .{ value.set, value.variants });

        if (value.boosters) |boosters| {
            try writer.print(" .boosters = {{", .{});

            for (boosters) |booster| {
                try writer.print(" {},", .{booster});
            }

            _ = try writer.write("},");
        }

        if (value.pricing) |pricing| {
            try writer.print(" .pricing = {any},", .{pricing});
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

// TODO: shown on example but not docummented
// abilities: []const []const u8,
// attacks: []const Attack,
// weaknesses: []const Effectiveness,
// retreat: u8,
// legal: Legality,
// regulationMark: ?[]const u8 = null, // TODO: enum
// variants_detailed: []Variants.Detailed,
