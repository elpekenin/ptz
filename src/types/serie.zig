const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;

const fmt = @import("../fmt.zig");
const meta = @import("../meta.zig");
const Query = @import("../query.zig").Query;
const Language = @import("../language.zig").Language;
const Image = @import("Image.zig");
const Set = @import("set.zig").Set;

pub fn Serie(comptime language: Language) type {
    const query = Query(language);

    return struct {
        const S = @This();

        pub const url = "series";

        __arena: ?*meta.Empty = null,

        sets: []const Set(language).Brief,
        id: []const u8,
        name: []const u8,
        logo: ?Image = null,

        pub fn deinit(self: S) void {
            meta.deinit(S, self);
        }

        pub fn get(allocator: Allocator, params: query.Get) !S {
            var q: query.Q(S, .one) = .init(allocator, params);
            return q.run();
        }

        pub fn all(allocator: Allocator, params: Brief.Params) query.Iterator(Brief) {
            return Brief.iterator(allocator, params);
        }

        pub fn format(self: S, writer: *Writer) Writer.Error!void {
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
            pub const url = S.url;
            pub const Params = query.ParamsFor(Brief);

            id: []const u8,
            name: []const u8,
            logo: ?Image = null,

            pub fn get(allocator: Allocator, params: query.Get) !Brief {
                var q: query.Q(Brief, .one) = .init(allocator, params);
                return q.run();
            }

            pub fn iterator(allocator: Allocator, params: Params) query.Iterator(Brief) {
                return .new(allocator, params);
            }

            pub fn format(self: Brief, writer: *Writer) Writer.Error!void {
                try writer.print("{{ .id = {s}, .name = {s},", .{ self.id, self.name });

                if (self.logo) |logo| {
                    try writer.print(" .logo = {f},", .{logo});
                }

                try writer.print(" }}", .{});
            }
        };
    };
}
