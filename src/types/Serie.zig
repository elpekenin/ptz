const Set = @import("Set.zig");

sets: []const Set.Brief,
id: []const u8,
name: []const u8,
logo: ?[]const u8 = null,

pub const Brief = struct {
    id: []const u8,
    name: []const u8,
    logo: ?[]const u8 = null,
};
