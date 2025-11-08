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
    const token: std.json.Token = try source.nextAlloc(allocator, options.allocate orelse .alloc_always);
    switch (token) {
        .string, .allocated_string => |str| {
            return .{
                .raw = str,
            };
        },
        else => return error.UnexpectedToken,
    }
}

pub fn format(self: Image, writer: *Writer) Writer.Error!void {
    try self.toUrl(writer, .high, .jpg);
}
