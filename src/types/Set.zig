const std = @import("std");

const Booster = @import("Booster.zig");
const Card = @import("card.zig").Card;
const Legality = @import("Legality.zig");
const Serie = @import("Serie.zig");
const Set = @This();

pub const url = "sets";

const CardCount = struct {
    total: usize,
    official: usize,

    pub fn format(
        self: CardCount,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .total = {d}, .official = {d} }}", .{ self.total, self.official });
    }
};

id: []const u8,
name: []const u8,
logo: ?[]const u8 = null,
symbol: ?[]const u8 = null,
cardCount: CardCount,
serie: Serie.Brief,
tcgOnline: ?[]const u8 = null,
releaseDate: []const u8,
legal: Legality,
cards: []const Card.Brief,
boosters: ?[]const Booster = null,

pub const Brief = struct {
    pub const url = Set.url;

    id: []const u8,
    name: []const u8,
    logo: ?[]const u8 = null,
    symbol: ?[]const u8 = null,
    cardCount: CardCount,

    pub fn format(
        self: Brief,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .id = {s}, .name = {s},", .{ self.id, self.name });

        if (self.logo) |logo| {
            try writer.print(" .logo = {s},", .{logo});
        }

        if (self.symbol) |symbol| {
            try writer.print(" .symbol = {s},", .{symbol});
        }

        try writer.print(" .cardCount = {f} }}", .{self.cardCount});
    }
};
