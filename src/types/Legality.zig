const std = @import("std");
const Writer = std.Io.Writer;

const Legality = @This();

standard: bool,
expanded: bool,

pub fn format(self: Legality, writer: *Writer) Writer.Error!void {
    try writer.print("{{ .standard = {}, .expanded = {} }}", .{ self.standard, self.expanded });
}
