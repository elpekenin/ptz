const std = @import("std");

const Image = @This();

raw: []const u8,

pub const Resolution = enum {
    low,
    high,
};

pub const Extension = enum {
    png,
    webp,
    jpg,
};

pub fn toUrl(self: *const Image, writer: *std.Io.Writer, resolution: Resolution, extension: Extension) !void {
    try writer.print("{s}/{t}.{t}", .{ self.raw, resolution, extension });
}

pub fn jsonParseFromValue(
    allocator: std.mem.Allocator,
    source: std.json.Value,
    options: std.json.ParseOptions,
) std.json.ParseFromValueError!Image {
    _ = allocator;
    _ = options;

    const url = switch (source) {
        .string => |val| val,
        else => return error.UnexpectedToken,
    };

    return .{
        .raw = url,
    };
}

pub fn format(
    self: Image,
    writer: *std.Io.Writer,
) std.Io.Writer.Error!void {
    try self.toUrl(writer, .high, .jpg);
}
