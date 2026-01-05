const std = @import("std");

// TODO: configure language using an option?
// pro: simple setup, cleaner code
// con: same exe can't query cards in different languages

pub fn build(b: *std.Build) void {
    // options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("sdk", .{
        .root_source_file = b.path("src/sdk.zig"),
        .target = target,
        .optimize = optimize,
    });
}
