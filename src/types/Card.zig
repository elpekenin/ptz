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

const Card = @This();

pub const url = "cards";

common: Common,
/// as per `common.category`
payload: Payload,

const Common = struct {
    id: []const u8,
    localId: []const u8,
    name: []const u8,
    image: ?[]const u8 = null,
    category: enums.Category,
    illustrator: ?[]const u8 = null,
    rarity: ?enums.Rarity = null,
    set: Set.Brief,
    variants: Variants,
    boosters: ?[]const Booster = null,
    pricing: ?Pricing = null,
    updated: []const u8, // date

    pub fn format(
        self: Common,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .id = {s}, .local_id = {s}, .name = {s},", .{
            self.id,
            self.localId,
            self.name,
        });

        if (self.image) |image| {
            try writer.print(" .image = {s},", .{image});
        }

        try writer.print(" .category = {t},", .{self.category});

        if (self.illustrator) |illustrator| {
            try writer.print(" .illustrator = {s},", .{illustrator});
        }

        if (self.rarity) |rarity| {
            try writer.print(" .rarity = {t},", .{rarity});
        }

        try writer.print(" .set = {f}, .variants = {any},", .{ self.set, self.variants });

        if (self.boosters) |boosters| {
            try writer.print(" .boosters = {{,", .{});

            for (boosters) |booster| {
                try writer.print(" {},", .{booster});
            }

            _ = try writer.write("},");
        }

        if (self.pricing) |pricing| {
            try writer.print(" .pricing = {any},", .{pricing});
        }

        try writer.print(" .updated = {s} }}", .{self.updated});
    }
};

const Payload = union {
    pokemon: Pokemon,
    trainer: Trainer,
    energy: Energy,
};

const Pokemon = struct {
    dexId: ?[]const u8 = null,
    hp: ?usize = null,
    types: ?[]const enums.PokemonType = null,
    evolveFrom: ?[]const u8 = null,
    description: ?[]const u8 = null,
    level: ?[]const u8 = null,
    stage: ?enums.Stage = null,
    suffix: ?[]const u8 = null, // TODO: enum
    item: ?struct {
        name: []const u8,
        effect: []const u8,
    } = null, // TODO: what is this

    pub fn format(
        self: Pokemon,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.writeByte('{');

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

        // if empty, don't need spacing
        if (std.mem.eql(u8, std.mem.asBytes(&self), std.mem.asBytes(&Pokemon{}))) {
            try writer.writeByte('}');
        } else {
            _ = try writer.write(" }");
        }
    }
};

const Trainer = struct {
    effect: ?[]const u8 = null, // FIXME: not nullable according to docs
    trainerType: enums.TrainerType,

    pub fn format(
        self: Trainer,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .effect = {?s}, .type = {t} }}", .{ self.effect, self.trainerType });
    }
};

const Energy = struct {
    effect: []const u8,
    energyType: enums.EnergyKind,

    pub fn format(
        self: Energy,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .effect = {s}, .type = {t} }}", .{ self.effect, self.energyType });
    }
};

pub fn jsonParseFromValue(
    allocator: std.mem.Allocator,
    source: std.json.Value,
    options: std.json.ParseOptions,
) std.json.ParseFromValueError!Card {
    // TODO: try and speed up parsing
    const common = try std.json.parseFromValue(Common, allocator, source, options);
    defer common.deinit();

    return .{
        .common = common.value,
        .payload = payload: switch (common.value.category) {
            .Pokemon => {
                const payload = try std.json.parseFromValue(Pokemon, allocator, source, options);
                defer payload.deinit();

                break :payload .{ .pokemon = payload.value };
            },
            .Trainer => {
                const payload = try std.json.parseFromValue(Trainer, allocator, source, options);
                defer payload.deinit();

                break :payload .{ .trainer = payload.value };
            },
            .Energy => {
                const payload = try std.json.parseFromValue(Energy, allocator, source, options);
                defer payload.deinit();

                break :payload .{ .energy = payload.value };
            },
        },
    };
}

pub fn format(
    self: Card,
    writer: *std.Io.Writer,
) std.Io.Writer.Error!void {
    try writer.print("{{ .common = {f}, .payload = {t}", .{ self.common, self.common.category });

    // TODO: format
    switch (self.common.category) {
        .Pokemon => try writer.print("{f}", .{self.payload.pokemon}),
        .Trainer => try writer.print("{f}", .{self.payload.trainer}),
        .Energy => try writer.print("{f}", .{self.payload.energy}),
    }

    try writer.print(" }}", .{});
}

// TODO: shown on example but not docummented
// abilities: []const []const u8,
// attacks: []const Attack,
// weaknesses: []const Effectiveness,
// retreat: u8,
// legal: Legality,
// regulationMark: ?[]const u8 = null, // TODO: enum
// variants_detailed: []Variants.Detailed,

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
