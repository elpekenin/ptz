const std = @import("std");

const fmt = @import("../fmt.zig");
const Language = @import("../language.zig").Language;
const Query = @import("../query.zig").Query;
const Enums = @import("enums.zig").Enums;
const Booster = @import("Booster.zig");
const Image = @import("Image.zig");
const Legality = @import("Legality.zig");
const Set = @import("set.zig").Set;
const Pricing = @import("pricing.zig").Pricing;

// TODO:
// legal: Legality,
// regulationMark: ?[]const u8 = null, // TODO: enum
// variants_detailed: []Variants.Detailed,

pub fn Card(comptime language: Language) type {
    const query = Query(language);
    const E = Enums(language);
    const P = Pricing(language);

    const Ability = struct {
        type: E.AbilityType,
        // FIXME: these 2 should be required
        name: ?[]const u8 = null,
        effect: ?[]const u8 = null,

        pub fn format(
            self: @This(),
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

    const Damage = union(enum) {
        const Self = @This();

        str: []const u8,
        int: usize,

        pub fn format(
            self: Self,
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
        ) std.json.ParseFromValueError!Self {
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

    const Attack = struct {
        cost: []const E.Type,
        name: []const u8,
        effect: ?[]const u8 = null,
        damage: ?Damage = null,

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .cost = ", .{});

            try fmt.printSlice(E.Type, writer, "{t}", self.cost);

            try writer.print(", .name = {s},", .{self.name});

            if (self.effect) |effect| {
                try writer.print(" .effect = {s},", .{effect});
            }

            try writer.print(" }}", .{});
        }
    };

    // TODO: remove/simplify when values get unified upstream
    const DexId = union(enum) {
        const Self = @This();

        str: []const u8,
        int: usize,

        pub fn format(
            self: Self,
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
        ) std.json.ParseFromValueError!Self {
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

        type: E.Type,
        value: Value,

        pub fn format(
            self: @This(),
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
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .normal = {}, .reverse = {}, .holo ={}, .firstEdition = {} }}", .{ self.normal, self.reverse, self.holo, self.firstEdition });
        }
    };

    const Common = struct {
        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image = null,
        illustrator: ?[]const u8 = null,
        rarity: ?E.Rarity = null,
        set: Set(language).Brief,
        variants: Variants,
        boosters: ?[]const Booster = null,
        pricing: ?P = null,
        updated: []const u8, // date
    };

    const Pokemon = struct {
        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image = null,
        illustrator: ?[]const u8 = null,
        rarity: ?E.Rarity = null,
        set: Set(language).Brief,
        variants: Variants,
        boosters: ?[]const Booster = null,
        pricing: ?P = null,
        updated: []const u8,

        //

        dexId: ?DexId = null,
        hp: ?usize = null,
        types: ?[]const E.Type = null,
        evolveFrom: ?[]const u8 = null,
        description: ?[]const u8 = null,
        level: ?[]const u8 = null,
        stage: ?E.Stage = null,
        suffix: ?E.Suffix = null,
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
            self: @This(),
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
                try fmt.printSlice(E.Type, writer, "{t}", types);
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
        rarity: ?E.Rarity = null,
        set: Set(language).Brief,
        variants: Variants,
        boosters: ?[]const Booster = null,
        pricing: ?P = null,
        updated: []const u8,

        //

        // FIXME: these should be required (?)
        effect: ?[]const u8 = null,
        trainerType: ?E.TrainerType = null,

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            if (self.effect) |effect| {
                try writer.print(" .effect = {s},", .{effect});
            }

            if (self.trainerType) |trainerType| {
                try writer.print(" .trainerType = {t},", .{trainerType});
            }
        }
    };

    const Energy = struct {
        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image = null,
        illustrator: ?[]const u8 = null,
        rarity: ?E.Rarity = null,
        set: Set(language).Brief,
        variants: Variants,
        boosters: ?[]const Booster = null,
        pricing: ?P = null,
        updated: []const u8,

        //

        effect: []const u8,
        energyType: E.EnergyType,

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print(" .effect = {s}, .type = {t},", .{ self.effect, self.energyType });
        }
    };

    // assert that types have all the common fields, and they are the right type
    comptime {
        for (.{ Pokemon, Trainer, Energy }) |T| {
            for (@typeInfo(Common).@"struct".fields) |field| {
                std.debug.assert(@FieldType(T, field.name) == field.type);
            }
        }
    }

    return union(enum) {
        const Self = @This();

        pub const url = "cards";

        pokemon: Pokemon,
        trainer: Trainer,
        energy: Energy,

        // dummy type just to parse the category from the API's response
        const Raw = struct {
            category: E.Category,
        };

        pub fn get(allocator: std.mem.Allocator, params: query.Get) !Self {
            const q: query.Q(Self, .one) = .{ .params = params };
            return q.run(allocator);
        }

        pub fn all(params: query.Params(Brief)) query.Iterator(Brief) {
            return Brief.iterator(params);
        }

        pub const Brief = struct {
            pub const url = Self.url;

            id: []const u8,
            localId: []const u8,
            name: []const u8,
            image: ?Image = null,

            pub fn iterator(params: query.Params(Brief)) query.Iterator(Brief) {
                return .new(params);
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
        ) std.json.ParseFromValueError!Self {
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
            self: Self,
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .{t} = {{ ", .{self});

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

            try writer.print(" }} }}", .{});
        }
    };
}
