const std = @import("std");
const ptz = @import("ptz");

fn exit(msg: []const u8) u8 {
    std.debug.print("{s}\n", .{msg});
    std.debug.print("---\n", .{});
    std.debug.print(
        \\usage: ptz <name>
        \\
        \\Example CLI to search for cards
        \\
        \\  <name>: Name to look for (lax equality)
    ,
        .{},
    );

    return 1;
}

pub fn main() !u8 {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    var args = std.process.args();
    _ = args.skip(); // exe name

    const name = args.next() orelse {
        return exit("missing argument");
    };

    if (args.next()) |_| {
        return exit("a single argument is expected");
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

            std.debug.print("{f}\n\n", .{card});
        }
    }

    return 0;
}
