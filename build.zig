const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("ptz", .{
        .root_source_file = b.path("src/root.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "ptz",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
        .use_llvm = true,
        .use_lld = true,
    });
    exe.root_module.addImport("ptz", mod);

    b.installArtifact(exe);

    const run_step = b.step("run", "run the binary");
    const run = b.addRunArtifact(exe);
    if (b.args) |args| {
        run.addArgs(args);
    }
    run_step.dependOn(&run.step);
}
