const std = @import("std");
const sdk = @import("ptz").Sdk(.en);

const Type = enum {
    card,
    serie,
    set,
};

fn usage(msg: []const u8) !void {
    var stderr_writer: std.fs.File.Writer = .init(.stderr(), &.{});
    const stderr = &stderr_writer.interface;

    try stderr.print("{s}\n", .{msg});
    try stderr.print("---\n", .{});
    try stderr.print(
        \\usage: ptz <type> <name>
        \\
        \\Example CLI to search for cards
        \\
        \\  <type>: Type to query (Card, Serie, Set)
        \\  <name>: Name to look for (lax equality)
    ,
        .{},
    );

    try stderr.flush();
}

fn handleCard(allocator: std.mem.Allocator, stdout: *std.Io.Writer, name: []const u8) !void {
    var iterator = sdk.Card.all(.{
        .where = &.{
            .like(.name, name),
        },
    });

    while (try iterator.next(allocator)) |briefs| {
        for (briefs) |brief| {
            const card: sdk.Card = try .get(allocator, .{
                .id = brief.id,
            });

            try stdout.print("{f}\n\n", .{card});
        }
    }
}

fn handleSerie(allocator: std.mem.Allocator, stdout: *std.Io.Writer, name: []const u8) !void {
    var iterator = sdk.Serie.all(.{
        .where = &.{
            .like(.name, name),
        },
    });

    while (try iterator.next(allocator)) |briefs| {
        for (briefs) |brief| {
            const serie: sdk.Serie = try .get(allocator, .{
                .id = brief.id,
            });

            try stdout.print("{f}\n\n", .{serie});
        }
    }
}

fn handleSet(allocator: std.mem.Allocator, stdout: *std.Io.Writer, name: []const u8) !void {
    var iterator = sdk.Set.all(.{
        .where = &.{
            .like(.name, name),
        },
    });

    while (try iterator.next(allocator)) |briefs| {
        for (briefs) |brief| {
            const set: sdk.Set = try .get(allocator, .{
                .id = brief.id,
            });

            try stdout.print("{f}\n\n", .{set});
        }
    }
}

pub fn main() !u8 {
    var stdout_writer: std.fs.File.Writer = .init(.stdout(), &.{});
    const stdout = &stdout_writer.interface;

    var gpa: std.heap.DebugAllocator(.{}) = .init;
    const allocator = gpa.allocator();

    var args = std.process.args();
    _ = args.skip(); // exe name

    const typ: Type = blk: {
        const str = args.next() orelse {
            try usage("missing argument");
            return 1;
        };

        const typ = std.meta.stringToEnum(Type, str) orelse {
            try usage("unknown type");
            return 1;
        };

        break :blk typ;
    };

    const name = args.next() orelse {
        try usage("missing argument");
        return 1;
    };

    if (args.next()) |_| {
        try usage("a single argument is expected");
        return 1;
    }

    switch (typ) {
        .card => try handleCard(allocator, stdout, name),
        .serie => try handleSerie(allocator, stdout, name),
        .set => try handleSet(allocator, stdout, name),
    }

    try stdout.flush();

    return 0;
}
