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

pub fn Card(comptime language: Language) type {
    const LangQuery = Query(language);
    const LangEnum = Enums(language);
    const LangPricing = Pricing(language);

    const Ability = struct {
        type: LangEnum.AbilityType,
        // FIXME: these 2 should be required
        name: ?[]const u8 = null,
        effect: ?[]const u8 = null,

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .type = {t}", .{self.type});

            if (self.name) |name| {
                try writer.print(", .name = {s}", .{name});
            }

            if (self.effect) |effect| {
                try writer.print(", .effect = {s}", .{effect});
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
        cost: []const LangEnum.Type,
        name: []const u8,
        effect: ?[]const u8 = null,
        damage: ?Damage = null,

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .cost = ", .{});

            try fmt.printSlice(LangEnum.Type, writer, "{t}", self.cost);

            try writer.print(", .name = {s}", .{self.name});

            if (self.effect) |effect| {
                try writer.print(", .effect = {s}", .{effect});
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

        type: LangEnum.Type,
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

    const VariantDetailed = struct {
        type: []const u8,
        size: ?[]const u8 = null,
        stamp: ?[]const []const u8 = null,
        foil: ?[]const u8 = null,

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
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

    // common args
    const Common = struct {
        const Self = @This();

        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image,
        illustrator: ?[]const u8,
        rarity: ?LangEnum.Rarity,
        set: Set(language).Brief,
        variants: Variants,
        variant_detailed: ?[]const VariantDetailed,
        boosters: ?[]const Booster,
        pricing: ?LangPricing,
        updated: []const u8, // date
        legal: Legality,
        regulationMark: ?LangEnum.RegulationMark,

        fn from(value: anytype) Self {
            return . {
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

        fn formatFields(value: anytype, writer: *std.Io.Writer) std.Io.Writer.Error!void {
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
                try writer.print(", .rarity = {t}", .{rarity});
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
                try writer.print(", .regulationMark = {t}", .{regulation_mark});
            }
        }
    };

    // Pokemon
    const P = struct {
        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image = null,
        illustrator: ?[]const u8 = null,
        rarity: ?LangEnum.Rarity = null,
        set: Set(language).Brief,
        variants: Variants,
        variant_detailed: ?[]const VariantDetailed = null,
        boosters: ?[]const Booster = null,
        pricing: ?LangPricing = null,
        updated: []const u8,
        legal: Legality,
        regulationMark: ?LangEnum.RegulationMark = null,

        //

        dexId: ?DexId = null,
        hp: ?usize = null,
        types: ?[]const LangEnum.Type = null,
        evolveFrom: ?[]const u8 = null,
        description: ?[]const u8 = null,
        level: ?[]const u8 = null,
        stage: ?LangEnum.Stage = null,
        suffix: ?LangEnum.Suffix = null,
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
                try fmt.printSlice(LangEnum.Type, writer, "{t}", types);
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
                try writer.print(", .stage = {t}", .{stage});
            }

            if (self.suffix) |suffix| {
                try writer.print(", .suffix = {t}", .{suffix});
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

    // Trainer
    const T = struct {
        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image = null,
        illustrator: ?[]const u8 = null,
        rarity: ?LangEnum.Rarity = null,
        set: Set(language).Brief,
        variants: Variants,
        variant_detailed: ?[]const VariantDetailed = null,
        boosters: ?[]const Booster = null,
        pricing: ?LangPricing = null,
        updated: []const u8,
        legal: Legality,
        regulationMark: ?LangEnum.RegulationMark = null,

        //

        // FIXME: these should be required (?)
        effect: ?[]const u8 = null,
        trainerType: ?LangEnum.TrainerType = null,

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ ", .{});

            try Common.formatFields(self, writer);

            if (self.effect) |effect| {
                try writer.print(", .effect = {s}", .{effect});
            }

            if (self.trainerType) |trainerType| {
                try writer.print(", .trainerType = {t}", .{trainerType});
            }

            try writer.print(" }}", .{});
        }
    };

    // Energy
    const E = struct {
        id: []const u8,
        localId: []const u8,
        name: []const u8,
        image: ?Image = null,
        illustrator: ?[]const u8 = null,
        rarity: ?LangEnum.Rarity = null,
        set: Set(language).Brief,
        variants: Variants,
        variant_detailed: ?[]const VariantDetailed = null,
        boosters: ?[]const Booster = null,
        pricing: ?LangPricing = null,
        updated: []const u8,
        legal: Legality,
        regulationMark: ?LangEnum.RegulationMark = null,

        //

        effect: []const u8,
        energyType: LangEnum.EnergyType,

        pub fn format(
            self: @This(),
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ ", .{});

            try Common.formatFields(self, writer);

            try writer.print(", .effect = {s}, .type = {t}", .{ self.effect, self.energyType });

            try writer.print(" }}", .{});
        }
    };

    // assert that types have all the common fields, and they are the right type
    comptime {
        for (.{ P, T, E }) |Type| {
            for (@typeInfo(Common).@"struct".fields) |field| {
                if (!@hasField(Type, field.name)) {
                    const msg = std.fmt.comptimePrint("{} is missing field {s}", .{ Type, field.name });
                    @compileError(msg);
                }

                if (@FieldType(Type, field.name) != field.type) {
                    const msg = std.fmt.comptimePrint("{}.{s} must be of type {}", .{ Type, field.name, field.type });
                    @compileError(msg);
                }
            }
        }
    }

    return union(enum) {
        const Self = @This();

        pub const Pokemon = P;
        pub const Trainer = T;
        pub const Energy = E;

        pub const url = "cards";

        pokemon: Pokemon,
        trainer: Trainer,
        energy: Energy,

        // dummy type just to parse the category from the API's response
        const Raw = struct {
            category: LangEnum.Category,
        };

        pub fn get(allocator: std.mem.Allocator, params: LangQuery.Get) !Self {
            const q: LangQuery.Q(Self, .one) = .{ .params = params };
            return q.run(allocator);
        }

        pub fn all(params: LangQuery.Params(Brief)) LangQuery.Iterator(Brief) {
            return Brief.iterator(params);
        }

        pub const Brief = struct {
            pub const url = Self.url;

            id: []const u8,
            localId: []const u8,
            name: []const u8,
            image: ?Image = null,

            pub fn iterator(params: LangQuery.Params(Brief)) LangQuery.Iterator(Brief) {
                return .new(params);
            }

            pub fn format(
                self: Brief,
                writer: *std.Io.Writer,
            ) std.Io.Writer.Error!void {
                try writer.print("{{ .id = {s}, .localId = {s}, .name = {s}", .{ self.id, self.localId, self.name });

                if (self.image) |image| {
                    try writer.print(", .image = {f}", .{image});
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

        pub fn format(
            self: Self,
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .{t} = ", .{self});

            switch (self) {
                .pokemon => |value| try writer.print("{f}", .{value}),
                .energy => |value| try writer.print("{f}", .{value}),
                .trainer => |value| try writer.print("{f}", .{value}),
            }

            try writer.print(" }}", .{});
        }
    };
}
