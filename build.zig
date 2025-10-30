const std = @import("std");

// TODO: configure language using an option?
// pro: simple setup, clean code
// con: same exe can't query cards in different languages

pub fn build(b: *std.Build) void {
    _ = b.addModule("ptz", .{
        .root_source_file = b.path("src/root.zig"),
    });
}
