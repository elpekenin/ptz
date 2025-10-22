const std = @import("std");
const enums = @import("enums.zig");

const Pricing = @This();

cardmarket: ?Cardmarket = null,
tcgplayer: ?Tcgplayer = null,

const Cardmarket = struct {
    updated: ?[]const u8 = null, // date
    unit: ?enums.MoneyUnit = null,

    avg: ?f32 = null,
    low: ?f32 = null,
    trend: ?f32 = null,
    avg1: ?f32 = null,
    avg7: ?f32 = null,
    avg30: ?f32 = null,
    @"avg-holo": ?f32 = null,
    @"low-holo": ?f32 = null,
    @"trend-holo": ?f32 = null,
    @"avg1-holo": ?f32 = null,
    @"avg7-holo": ?f32 = null,
    @"avg30-holo": ?f32 = null,
};

const Tcgplayer = struct {
    const Price = struct {
        lowPrice: ?f32 = null,
        midPrice: ?f32 = null,
        highPrice: ?f32 = null,
        marketPrice: ?f32 = null,
        directLowPrice: ?f32 = null,
    };

    updated: []const u8, // date
    unit: enums.MoneyUnit,

    // optional
    normal: ?Price = null,
    holofoil: ?Price = null,
    @"reverse-holofoil": ?Price = null,
    @"1st-edition": ?Price = null,
    @"1st-edition-holofoild": ?Price = null,
    unlimited: ?Price = null,
    @"unlimited-holofoil": ?Price = null,
};

pub fn format(
    self: Pricing,
    writer: *std.Io.Writer,
) std.Io.Writer.Error!void {
    _ = self;
    _ = writer;
}
