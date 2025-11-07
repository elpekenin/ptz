const std = @import("std");
const Writer = std.Io.Writer;

const Booster = @This();

id: []const u8,
name: []const u8,

pub fn format(self: Booster, writer: *Writer) Writer.Error!void {
    try writer.print("{{ .id = {s}, .name = {s} }}", .{ self.id, self.name });
}

// optional
// logo: []const u8,
// artwork_front: []const u8,
// artwork_back: []const u8,
