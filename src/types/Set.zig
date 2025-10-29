const std = @import("std");

const fmt = @import("../fmt.zig");
const query = @import("../query.zig");
const Language = @import("enums.zig").Language;
const Booster = @import("Booster.zig");
const Card = @import("card.zig").Card;
const Legality = @import("Legality.zig");
const Image = @import("Image.zig");
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
logo: ?Image = null,
symbol: ?[]const u8 = null,
cardCount: CardCount,
serie: Serie.Brief,
tcgOnline: ?[]const u8 = null,
releaseDate: []const u8,
legal: Legality,
cards: []const Card.Brief,
boosters: ?[]const Booster = null,

pub fn get(allocator: std.mem.Allocator, language: Language, params: query.Get) !Set {
    const q: query.Q(Set, .one) = .{ .params = params };
    return q.run(allocator, language);
}

pub fn all(language: Language, params: query.Params(Brief)) query.Iterator(Brief) {
    return Brief.iterator(language, params);
}

pub fn format(
    self: Set,
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
    try fmt.printSlice(Card.Brief, writer, "{f}", self.cards);
    try writer.writeByte(',');

    if (self.boosters) |boosters| {
        try writer.print(" .boosters = ", .{});
        try fmt.printSlice(Booster, writer, "{f}", boosters);
        try writer.writeByte(',');
    }

    try writer.print(" }}", .{});
}

pub const Brief = struct {
    pub const url = Set.url;

    id: []const u8,
    name: []const u8,
    logo: ?Image = null,
    symbol: ?[]const u8 = null,
    cardCount: CardCount,

    pub fn iterator(language: Language, params: query.Params(Brief)) query.Iterator(Brief) {
        return .new(language, params);
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
