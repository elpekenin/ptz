const std = @import("std");
const Allocator = std.mem.Allocator;
const ParseError = std.json.ParseError;
const ParseOptions = std.json.ParseOptions;
const Value = std.json.Value;
const Writer = std.Io.Writer;

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

pub fn toUrl(self: *const Image, writer: *Writer, resolution: Resolution, extension: Extension) !void {
    try writer.print("{s}/{t}.{t}", .{ self.raw, resolution, extension });
}

pub fn jsonParse(
    allocator: Allocator,
    source: anytype,
    options: ParseOptions,
) ParseError(@TypeOf(source.*))!Image {
    return switch (try source.nextAlloc(allocator, options.allocate orelse .alloc_always)) {
        .string, .allocated_string => |url| .{ .raw = url },
        else => error.UnexpectedToken,
    };
}

pub fn format(self: Image, writer: *Writer) Writer.Error!void {
    try self.toUrl(writer, .high, .jpg);
}
