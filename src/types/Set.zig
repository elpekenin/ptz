const std = @import("std");

pub const url = "sets";

pub const Brief = struct {
    const CardCount = struct {
        official: usize,
        total: usize,
    };

    id: []const u8,
    name: []const u8,
    logo: ?[]const u8 = null,
    symbol: ?[]const u8 = null,
    cardCount: CardCount,

    pub fn format(
        self: Brief,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        _ = self;
        _ = writer;
    }
};
