const std = @import("std");

const Legality = @This();

standard: bool,
expanded: bool,

pub fn format(
    self: Legality,
    writer: *std.Io.Writer,
) std.Io.Writer.Error!void {
    try writer.print("{{ .standard = {}, .expanded = {} }}", .{ self.standard, self.expanded });
}