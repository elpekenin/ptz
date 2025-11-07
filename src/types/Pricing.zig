const std = @import("std");
const Writer = std.Io.Writer;

const Pricing = @This();

// TODO: There might be others
const Currency = enum {
    EUR,
    USD,
};

const Cardmarket = struct {
    updated: ?[]const u8 = null, // date
    unit: ?[]const u8 = null,

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

    pub fn format(self: Cardmarket, writer: *Writer) Writer.Error!void {
        try writer.writeByte('{');

        if (self.updated) |updated| {
            try writer.print(" .updated = {s},", .{updated});
        }

        if (self.unit) |unit| {
            try writer.print(" .unit = {s},", .{unit});
        }

        if (self.avg) |avg| {
            try writer.print(" .avg = {d},", .{avg});
        }

        if (self.low) |low| {
            try writer.print(" .low = {d},", .{low});
        }

        if (self.trend) |trend| {
            try writer.print(" .trend = {d},", .{trend});
        }

        if (self.avg1) |avg1| {
            try writer.print(" .avg1 = {d},", .{avg1});
        }

        if (self.avg7) |avg7| {
            try writer.print(" .avg7 = {d},", .{avg7});
        }

        if (self.avg30) |avg30| {
            try writer.print(" .avg30 = {d},", .{avg30});
        }

        if (self.@"avg-holo") |avg_holo| {
            try writer.print(" .avg-holo = {d},", .{avg_holo});
        }

        if (self.@"low-holo") |low_holo| {
            try writer.print(" .low-holo = {d},", .{low_holo});
        }

        if (self.@"trend-holo") |trend_holo| {
            try writer.print(" .trend-holo = {d},", .{trend_holo});
        }

        if (self.@"avg1-holo") |avg1_holo| {
            try writer.print(" .avg1-holo = {d},", .{avg1_holo});
        }

        if (self.@"avg7-holo") |avg7_holo| {
            try writer.print(" .avg7-holo = {d},", .{avg7_holo});
        }

        if (self.@"avg30-holo") |avg30_holo| {
            try writer.print(" .avg30-holo = {d},", .{avg30_holo});
        }

        try writer.print(" }}", .{});
    }
};

const Tcgplayer = struct {
    const Price = struct {
        lowPrice: ?f32 = null,
        midPrice: ?f32 = null,
        highPrice: ?f32 = null,
        marketPrice: ?f32 = null,
        directLowPrice: ?f32 = null,

        pub fn format(self: Price, writer: *Writer) Writer.Error!void {
            try writer.writeByte('{');

            if (self.lowPrice) |lowPrice| {
                try writer.print(" .lowPrice = {d},", .{lowPrice});
            }

            if (self.midPrice) |midPrice| {
                try writer.print(" .midPrice = {d},", .{midPrice});
            }

            if (self.highPrice) |highPrice| {
                try writer.print(" .highPrice = {d},", .{highPrice});
            }

            if (self.marketPrice) |marketPrice| {
                try writer.print(" .marketPrice = {d},", .{marketPrice});
            }

            if (self.directLowPrice) |directLowPrice| {
                try writer.print(" .directLowPrice = {d},", .{directLowPrice});
            }

            try writer.print(" }}", .{});
        }
    };

    updated: []const u8, // date
    unit: Currency,

    // optional
    normal: ?Price = null,
    holofoil: ?Price = null,
    @"reverse-holofoil": ?Price = null,
    @"1st-edition": ?Price = null,
    @"1st-edition-holofoil": ?Price = null,
    unlimited: ?Price = null,
    @"unlimited-holofoil": ?Price = null,

    pub fn format(self: Tcgplayer, writer: *Writer) Writer.Error!void {
        try writer.print("{{ .updated = {s}, .unit = {t},", .{ self.updated, self.unit });

        if (self.normal) |normal| {
            try writer.print(" .normal = {f},", .{normal});
        }

        if (self.holofoil) |holofoil| {
            try writer.print(" .holofoil = {f},", .{holofoil});
        }

        if (self.@"reverse-holofoil") |reverse_holofoil| {
            try writer.print(" .reverse-holofoil = {f},", .{reverse_holofoil});
        }

        if (self.@"1st-edition") |fist_edition| {
            try writer.print(" .1st-edition = {f},", .{fist_edition});
        }

        if (self.@"1st-edition-holofoil") |fist_edition_holo| {
            try writer.print(" .1st-edition-holofoil = {f},", .{fist_edition_holo});
        }

        if (self.unlimited) |unlimited| {
            try writer.print(" .unlimited = {f},", .{unlimited});
        }

        if (self.@"unlimited-holofoil") |unlimited_holo| {
            try writer.print(" .unlimited-holofoil = {f},", .{unlimited_holo});
        }

        try writer.print(" }}", .{});
    }
};

cardmarket: ?Cardmarket = null,
tcgplayer: ?Tcgplayer = null,

pub fn format(self: Pricing, writer: *Writer) Writer.Error!void {
    try writer.writeByte('{');

    if (self.cardmarket) |cardmarket| {
        try writer.print(" .cardmarket = {f},", .{cardmarket});
    }

    if (self.tcgplayer) |tcgplayer| {
        try writer.print(" .tcgplayer = {f},", .{tcgplayer});
    }

    try writer.print(" }}", .{});
}
