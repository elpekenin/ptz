const enums = @import("enums.zig");

cost: []const enums.EnergyKind,
name: []const u8,
effect: []const u8, // TODO: optional
damage: usize, // TODO: optional
