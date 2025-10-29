const std = @import("std");

const fmt = @import("../fmt.zig");
const Query = @import("../query.zig").Query;
const Language = @import("../language.zig").Language;
const Image = @import("Image.zig");
const Set = @import("set.zig").Set;

pub fn Serie(comptime language: Language) type {
    const query = Query(language);

    return struct {
        const Self = @This();

        pub const url = "series";

        sets: []const Set(language).Brief,
        id: []const u8,
        name: []const u8,
        logo: ?Image = null,

        pub fn get(allocator: std.mem.Allocator, params: query.Get) !Self {
            const q: query.Q(Self, .one) = .{ .params = params };
            return q.run(allocator);
        }

        pub fn all(params: query.Params(Brief)) query.Iterator(Brief) {
            return Brief.iterator(params);
        }

        pub fn format(
            self: Self,
            writer: *std.Io.Writer,
        ) std.Io.Writer.Error!void {
            try writer.print("{{ ", .{});

            try writer.print(" .sets = ", .{});
            try fmt.printSlice(Set(language).Brief, writer, "{f}", self.sets);
            try writer.writeByte(',');

            try writer.print(" .id = {s}, .name = {s},", .{ self.id, self.name });

            if (self.logo) |logo| {
                try writer.print(" .logo = {f},", .{logo});
            }

            try writer.print(" }}", .{});
        }

        pub const Brief = struct {
            pub const url = Self.url;

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
                try writer.print("{{ .id = {s}, .name = {s},", .{ self.id, self.name });

                if (self.logo) |logo| {
                    try writer.print(" .logo = {f},", .{logo});
                }

                try writer.print(" }}", .{});
            }
        };
    };
}
