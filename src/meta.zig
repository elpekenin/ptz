//! Some hacky code to parse JSON into our custom types, having a `deinit()` method in them instead of returning a `std.json.Parsed(T)`
//!
//! Note: We store the pointer to the `ArenaAllocator` on a `*Empty` because `*ArenAllocator`, `*anyopaque` or `*void` would fail

const std = @import("std");
const ArenaAllocator = std.heap.ArenaAllocator;

pub const Empty = struct {};

fn fail(comptime fmt: []const u8, args: anytype) noreturn {
    const msg = std.fmt.comptimePrint(fmt, args);
    @compileError(msg);
}

/// confirm that types used in `Query` have the machinery in-place to parse/free them
pub fn validateType(comptime T: type) void {
    switch (@typeInfo(T)) {
        .@"struct" => {
            const ArenaType = ?*Empty;
            if (!@hasField(T, "__arena")) fail("missing __arena field in {}", .{T});
            if (@FieldType(T, "__arena") != ArenaType) fail("invalid __arena in {}, expected {}", .{ T, ArenaType });
        },
        .@"union" => {
            const SetArenaType = fn (*T, *Empty) void;
            if (!@hasDecl(T, "__setArena")) fail("missing __setArena method in {}", .{T});
            if (@TypeOf(T.__setArena) != SetArenaType) fail("invalid __setArena in {}, expected {}", .{ T, SetArenaType });
        },
        else => fail("unsupported type {}", .{T}),
    }

    const DeinitType = fn (T) void;
    if (!@hasDecl(T, "deinit")) fail("missing deinit method in {}", .{T});
    if (@TypeOf(T.deinit) != DeinitType) fail("invalid deinit in {}, expected {}", .{ T, DeinitType });
}

pub fn setArena(comptime T: type, value: *T, arena: *ArenaAllocator) void {
    const ptr: *Empty = @ptrCast(arena);
    switch (@typeInfo(T)) {
        .@"struct" => value.__arena = ptr,
        .@"union" => value.__setArena(ptr),
        else => unreachable,
    }
}

/// shared logic to deinit a "model"
pub fn deinit(comptime T: type, self: T) void {
    switch (@typeInfo(T)) {
        .@"struct" => |info| {
            // traverse children to deinit them too
            inline for (info.fields) |field| {
                deinit(field.type, @field(self, field.name));
            }

            // WARNING: must happen *after* iterating children, otherwise use-after-free
            // if this is a ptz type, deinit based on the arena
            if (@hasField(T, "__arena")) {
                if (self.__arena) |ptr| {
                    const arena: *ArenaAllocator = @ptrCast(@alignCast(ptr));

                    const allocator = arena.child_allocator;
                    arena.deinit();
                    allocator.destroy(arena);
                }
            }
        },
        .@"union" => {
            // if this is a ptz type, deinit the active tag
            if (@hasDecl(T, "__setArena")) {
                self.deinit();
            }
        },
        // iterate slices to free children
        .pointer => |info| {
            if (info.size == .slice) {
                for (self) |item| {
                    deinit(info.child, item);
                }
            }
        },
        else => {},
    }
}
