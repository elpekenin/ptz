const std = @import("std");

// TODO: configure language using an option?
// pro: simple setup, cleaner code
// con: same exe can't query cards in different languages

pub fn build(b: *std.Build) void {
    // options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // deps
    const graphqlz = b.dependency("graphqlz", .{
        .target = target,
        .optimize = optimize,
    });

    _ = b.addModule("sdk", .{
        .root_source_file = b.path("src/sdk.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "graphqlz", .module = graphqlz.module("graphqlz") },
        },
    });

    // steps
    const g2z = b.step("g2z", "run g2z");
    const run_g2z = b.addRunArtifact(graphqlz.artifact("g2z"));
    g2z.dependOn(&run_g2z.step);
    if (b.args) |args| run_g2z.addArgs(args);
}
