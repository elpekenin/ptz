//! Formatting utilities

const std = @import("std");
const Writer = std.Io.Writer;

pub fn printSlice(
    comptime T: type,
    writer: *Writer,
    comptime format: []const u8,
    slice: []const T,
) Writer.Error!void {
    switch (slice.len) {
        0 => try writer.print("{{}}", .{}),
        1 => {
            try writer.print("{{ ", .{});
            try writer.print(format, .{slice[0]});
            try writer.print(" }}", .{});
        },
        else => |len| {
            try writer.print("{{ ", .{});

            for (slice[0 .. len - 1]) |item| {
                try writer.writeByte(' ');
                try writer.print(format, .{item});
                try writer.writeByte(',');
            }

            try writer.writeByte(' ');
            try writer.print(format, .{slice[len - 1]});

            try writer.print(" }}", .{});
        },
    }
}
