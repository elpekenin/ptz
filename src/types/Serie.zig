const std = @import("std");

const fmt = @import("../fmt.zig");
const query = @import("../query.zig");
const Image = @import("Image.zig");
const Set = @import("Set.zig");

const Serie = @This();

pub const url = "series";

sets: []const Set.Brief,
id: []const u8,
name: []const u8,
logo: ?Image = null,

pub fn get(allocator: std.mem.Allocator, params: query.Get) !Serie {
    const q: query.Q(Serie, .one) = .{ .params = params };
    return q.run(allocator);
}

pub fn all(params: query.Params(Brief)) query.Iterator(Brief) {
    return Brief.iterator(params);
}

pub fn format(
    self: Serie,
    writer: *std.Io.Writer,
) std.Io.Writer.Error!void {
    try writer.print("{{ ", .{});

    try writer.print(" .sets = ", .{});
    try fmt.printSlice(Set.Brief, writer, "{f}", self.sets);
    try writer.writeByte(',');

    try writer.print(" .id = {s}, .name = {s},", .{self.id, self.name});

    if (self.logo) |logo| {
        try writer.print(" .logo = {f},", .{logo});
    }

    try writer.print(" }}", .{});
}

pub const Brief = struct {
    pub const url = Serie.url;

    id: []const u8,
    name: []const u8,
    logo: ?Image = null,

    pub fn iterator(params: query.Params(Brief)) query.Iterator(Brief) {
        return .new(params);
    }

    pub fn format(
        self: Brief,
        writer: *std.Io.Writer,
    ) std.Io.Writer.Error!void {
        try writer.print("{{ .id = {s}, .name = {s},", .{self.id, self.name});

        if (self.logo) |logo| {
            try writer.print(" .logo = {f},", .{logo});
        }

        try writer.print(" }}", .{});
    }
};
