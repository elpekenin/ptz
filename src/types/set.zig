const std = @import("std");
const Allocator = std.mem.Allocator;

const fmt = @import("../fmt.zig");
const Query = @import("../query.zig").Query;
const Language = @import("../language.zig").Language;
const Booster = @import("Booster.zig");
const Card = @import("card.zig").Card;
const Legality = @import("Legality.zig");
const Image = @import("Image.zig");
const Serie = @import("serie.zig").Serie;

pub const CardCount = struct {
    total: usize,
    official: usize,

    pub fn format(
        self: CardCount,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .total = {d}, .official = {d} }}", .{ self.total, self.official });
    }
};

pub fn Set(comptime language: Language) type {
    const query = Query(language);

    return struct {
        const Self = @This();

        pub const url = "sets";

        id: []const u8,
        name: []const u8,
        logo: ?Image = null,
        symbol: ?[]const u8 = null,
        cardCount: CardCount,
        serie: Serie(language).Brief,
        tcgOnline: ?[]const u8 = null,
        releaseDate: []const u8,
        legal: Legality,
        cards: []const Card(language).Brief,
        boosters: ?[]const Booster = null,

        pub fn get(allocator: Allocator, params: query.Get) !Self {
            var q: query.Q(Self, .one) = .init(allocator, params);
            return q.run();
        }

        pub fn all(allocator: Allocator, params: query.ParamsFor(Brief)) query.Iterator(Brief) {
            return Brief.iterator(allocator, params);
        }

        pub fn format(
            self: Self,
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ .id = {s}, .name = {s},", .{ self.id, self.name });

            if (self.logo) |logo| {
                try writer.print(" .logo = {f},", .{logo});
            }

            if (self.symbol) |symbol| {
                try writer.print(" .symbol = {s},", .{symbol});
            }

            try writer.print(" .cardCount = {f}, .serie = {f}", .{ self.cardCount, self.serie });

            if (self.tcgOnline) |tcg_online| {
                try writer.print(" .tcgOnline = {s},", .{tcg_online});
            }

            try writer.print(" .releaseDate = {s}, .legal = {f},", .{ self.releaseDate, self.legal });

            try writer.print(" .cards = ", .{});
            try fmt.printSlice(Card(language).Brief, writer, "{f}", self.cards);
            try writer.writeByte(',');

            if (self.boosters) |boosters| {
                try writer.print(" .boosters = ", .{});
                try fmt.printSlice(Booster, writer, "{f}", boosters);
                try writer.writeByte(',');
            }

            try writer.print(" }}", .{});
        }

        pub const Brief = struct {
            pub const url = Self.url;

            id: []const u8,
            name: []const u8,
            logo: ?Image = null,
            symbol: ?[]const u8 = null,
            cardCount: CardCount,

            pub fn iterator(allocator: Allocator, params: query.ParamsFor(Brief)) query.Iterator(Brief) {
                return .new(allocator, params);
            }

            pub fn format(
                self: Brief,
                writer: *std.Io.Writer,
            ) std.Io.Writer.Error!void {
                try writer.print("{{ .id = {s}, .name = {s},", .{ self.id, self.name });

                if (self.logo) |logo| {
                    try writer.print(" .logo = {f},", .{logo});
                }

                if (self.symbol) |symbol| {
                    try writer.print(" .symbol = {s},", .{symbol});
                }

                try writer.print(" .cardCount = {f} }}", .{self.cardCount});
            }
        };
    };
}
