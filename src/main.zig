const std = @import("std");
const ptz = @import("ptz");

fn usage(msg: []const u8) !void {
    var stderr_writer: std.fs.File.Writer = .init(.stderr(), &.{});
    const stderr = &stderr_writer.interface;

    try stderr.print("{s}\n", .{msg});
    try stderr.print("---\n", .{});
    try stderr.print(
        \\usage: ptz <name>
        \\
        \\Example CLI to search for cards
        \\
        \\  <name>: Name to look for (lax equality)
    ,
        .{},
    );

    try stderr.flush();
}

pub fn main() !u8 {
    var stdout_writer: std.fs.File.Writer = .init(.stdout(), &.{});
    const stdout = &stdout_writer.interface;

    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    var args = std.process.args();
    _ = args.skip(); // exe name

    const name = args.next() orelse {
        try usage("missing argument");
        return 1;
    };

    if (args.next()) |_| {
        try usage("a single argument is expected");
        return 1;
    }

    var iterator = ptz.Card.Brief.iterator(.{
        .where = &.{
            .like(.name, name),
        },
    });

    while (try iterator.next(allocator)) |cards| {
        for (cards) |c| {
            const card: ptz.Card = try .get(allocator, .{
                .id = c.id,
            });

            try stdout.print("{f}\n\n", .{card});
        }
    }

    try stdout.flush();

    return 0;
}
