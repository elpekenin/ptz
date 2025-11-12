const std = @import("std");
const Allocator = std.mem.Allocator;
const Writer = std.Io.Writer;

const meta = @import("meta.zig");
const percent_encoding = @import("percent_encoding.zig");
const Language = @import("language.zig").Language;

const base_url = "https://api.tcgdex.net/v2";

const Quantity = enum {
    one,
    many,
};

fn Parse(comptime T: type, comptime quantity: Quantity) type {
    return switch (quantity) {
        .one => T,
        .many => []T,
    };
}

fn Return(comptime T: type, comptime quantity: Quantity) type {
    return switch (quantity) {
        .one => T,
        .many => []const T,
    };
}

pub fn Query(comptime language: Language) type {
    return struct {
        pub const Get = struct {
            id: []const u8,

            fn url(self: *const Get, writer: *Writer) !void {
                try writer.writeByte('/');

                // NOTE: id can contain to-be-escaped chars (eg: '-')
                var percent_writer: percent_encoding.Writer = .init(writer);
                const w = percent_writer.writer();
                try w.print("{s}", .{self.id});
            }
        };

        fn Field(comptime T: type) type {
            return std.meta.FieldEnum(T);
        }

        fn Filter(comptime T: type) type {
            const F = Field(T);

            // TODO: OR support?
            return struct {
                const Self = @This();

                const Operator = enum {
                    like,
                    not,
                    eq,
                    neq,
                    gte,
                    lte,
                    gt,
                    lt,
                    null,
                    not_null,
                };

                const Value = union(enum) {
                    const V = @This();

                    none: void,
                    str: []const u8,
                    int: usize,
                    float: f64,

                    pub fn from(value: anytype) V {
                        const Val = @TypeOf(value);
                        if (Val == []const u8) {
                            return .{ .str = value };
                        }

                        return switch (@typeInfo(Val)) {
                            .int => .{ .int = value },
                            .float => .{ .float = value },
                            else => unreachable,
                        };
                    }
                };

                field: F,
                op: Operator,
                value: Value,

                fn TypeOf(comptime field: F) type {
                    return @FieldType(T, @tagName(field));
                }

                /// laxist equality filter
                pub fn like(comptime field: F, value: TypeOf(field)) Self {
                    return .{
                        .field = field,
                        .op = .like,
                        .value = .from(value),
                    };
                }

                /// laxist different filter
                pub fn not(comptime field: F, value: TypeOf(field)) Self {
                    return .{
                        .field = field,
                        .op = .not,
                        .value = .from(value),
                    };
                }

                /// strict equality filter
                pub fn eq(comptime field: F, value: TypeOf(field)) Self {
                    return .{
                        .field = field,
                        .op = .eq,
                        .value = .from(value),
                    };
                }

                /// strict different filter
                pub fn neq(comptime field: F, value: TypeOf(field)) Self {
                    return .{
                        .field = field,
                        .op = .neq,
                        .value = .from(value),
                    };
                }

                /// greater or equal
                pub fn gte(comptime field: F, value: usize) Self {
                    return .{
                        .field = field,
                        .op = .gte,
                        .value = .from(value),
                    };
                }

                /// lesser or equal
                pub fn lte(comptime field: F, value: usize) Self {
                    return .{
                        .field = field,
                        .op = .lte,
                        .value = .from(value),
                    };
                }

                /// greater
                pub fn gt(comptime field: F, value: usize) Self {
                    return .{
                        .field = field,
                        .op = .gt,
                        .value = .from(value),
                    };
                }

                /// lesser
                pub fn lt(comptime field: F, value: usize) Self {
                    return .{
                        .field = field,
                        .op = .lt,
                        .value = .from(value),
                    };
                }

                /// is null
                pub fn isNull(comptime field: F) Self {
                    return .{
                        .field = field,
                        .op = .null,
                        .value = .none,
                    };
                }

                /// is not null
                pub fn notNull(comptime field: F) Self {
                    return .{
                        .field = field,
                        .op = .not_null,
                        .value = .none,
                    };
                }

                pub fn format(self: Self, writer: *Writer) Writer.Error!void {
                    var percent_writer: percent_encoding.Writer = .init(writer);
                    var percent = percent_writer.writer();

                    // field=
                    try writer.print("{t}=", .{self.field});

                    switch (self.op) {
                        .like => try writer.print("like:", .{}),
                        .not => try writer.print("not:", .{}),
                        .eq => try writer.print("eq:", .{}),
                        .neq => try writer.print("neq:", .{}),
                        .gte => try writer.print("gte:", .{}),
                        .lte => try writer.print("lte:", .{}),
                        .gt => try writer.print("gt:", .{}),
                        .lt => try writer.print("lt:", .{}),
                        .null => try writer.print("null:", .{}),
                        .not_null => try writer.print("notnull:", .{}),
                    }

                    switch (self.value) {
                        .none => {},
                        .str => |str| try percent.print("{s}", .{str}),
                        // numbers likely dont need to be escaped, but just in case
                        .int => |int| try percent.print("{d}", .{int}),
                        .float => |float| try percent.print("{d}", .{float}),
                    }
                }
            };
        }

        fn Order(comptime T: type) type {
            const F = Field(T);

            return struct {
                const Self = @This();

                field: F,
                direction: enum {
                    ascending,
                    descending,
                },

                pub fn asc(comptime field: F) Self {
                    return .{ .field = field, .direction = .ascending };
                }

                pub fn desc(comptime field: F) Self {
                    return .{ .field = field, .direction = .descending };
                }

                pub fn format(self: Self, writer: *Writer) Writer.Error!void {
                    switch (self) {
                        .ascending => {},
                        .descending => try writer.writeByte('-'),
                    }

                    switch (self) {
                        .ascending,
                        .descending,
                        => |field| try writer.print("{t}", .{field}),
                    }
                }
            };
        }

        pub fn ParamsFor(comptime T: type) type {
            return struct {
                const Self = @This();

                where: ?[]const Filter(T) = null,
                page: ?usize = null,
                page_size: ?usize = null,
                order_by: ?[]const Order(T) = null,

                fn isEmpty(self: *const Self) bool {
                    inline for (std.meta.fields(Self)) |field| {
                        if (@field(self, field.name)) |_| {
                            return false;
                        }
                    }

                    return true;
                }

                fn url(self: *const Self, writer: *Writer) !void {
                    if (self.isEmpty()) return;

                    try writer.writeByte('?');

                    var needs_ampersand = false;
                    if (self.where) |filters| {
                        for (filters) |filter| {
                            defer needs_ampersand = true;
                            if (needs_ampersand) try writer.writeByte('&');
                            try writer.print("{f}", .{filter});
                        }
                    }

                    if (self.page) |page| {
                        defer needs_ampersand = true;
                        if (needs_ampersand) try writer.writeByte('&');
                        try writer.print("pagination:page={d}", .{page});
                    }

                    if (self.page_size) |page_size| {
                        defer needs_ampersand = true;
                        if (needs_ampersand) try writer.writeByte('&');
                        try writer.print("pagination:itemsPerPage={d}", .{page_size});
                    }

                    if (self.order_by) |orders| {
                        for (orders) |order| {
                            defer needs_ampersand = true;
                            if (needs_ampersand) try writer.writeByte('&');

                            const value = switch (order.direction) {
                                .ascending => "ASC",
                                .descending => "DESC",
                            };
                            try writer.print("sort:field={t}&sort:order={s}", .{ order.field, value });
                        }
                    }
                }
            };
        }

        pub fn Iterator(comptime T: type) type {
            return struct {
                const Self = @This();

                pub const Params = ParamsFor(T);

                q: Q(T, .many),

                pub fn init(allocator: Allocator, params: Params) Self {
                    return .{
                        .q = .init(allocator, .{
                            .where = params.where,
                            .page = params.page orelse 1,
                            .page_size = params.page_size,
                            .order_by = params.order_by,
                        }),
                    };
                }

                pub fn next(self: *Self) !?[]const T {
                    // TODO?: optimize avoiding extra call to `run` if last query was empty already
                    const items = try self.q.run();
                    self.q.advancePage();

                    if (items.len == 0) {
                        return null;
                    }

                    return items;
                }
            };
        }

        pub fn Q(comptime T: type, comptime quantity: Quantity) type {
            meta.validateType(T);

            const QueryParams = switch (quantity) {
                .one => Get,
                .many => ParamsFor(T),
            };

            return struct {
                const Self = @This();

                allocator: Allocator,
                params: QueryParams,

                pub fn init(allocator: Allocator, params: QueryParams) Self {
                    return .{
                        .allocator = allocator,
                        .params = params,
                    };
                }

                /// used by Iterator
                pub fn advancePage(self: *Self) void {
                    const current_page = self.params.page orelse 0;
                    self.params.page = current_page + 1;
                }

                fn requestUrl(self: *const Self) ![]const u8 {
                    var writer: Writer.Allocating = .init(self.allocator);
                    defer writer.deinit();

                    const w = &writer.writer;

                    const url = comptime std.fmt.comptimePrint("{s}/{t}/{s}", .{ base_url, language, T.url });
                    _ = try w.write(url);

                    try self.params.url(w);

                    return writer.toOwnedSlice();
                }

                fn sendRequest(self: *const Self) ![]const u8 {
                    const url = try self.requestUrl();
                    defer self.allocator.free(url);

                    var http_client: std.http.Client = .{
                        .allocator = self.allocator,
                    };
                    defer http_client.deinit();

                    var writer: Writer.Allocating = .init(self.allocator);
                    defer writer.deinit();

                    const result = try http_client.fetch(.{
                        .method = .GET,
                        .location = .{ .url = url },
                        .response_writer = &writer.writer,
                    });

                    // don't bother trying to decode payload, we messed up
                    const status = result.status;
                    switch (status.class()) {
                        .informational,
                        .success,
                        .redirect,
                        => {},
                        .client_error,
                        .server_error,
                        => return error.ServerErrorStatus,
                    }

                    return writer.toOwnedSlice();
                }

                pub fn run(self: *Self) !Return(T, quantity) {
                    const body = try self.sendRequest();
                    defer self.allocator.free(body);

                    var scanner: std.json.Scanner = .initCompleteInput(self.allocator, body);
                    defer scanner.deinit();

                    const options: std.json.ParseOptions = .{
                        // dont want references into potentially-freed memory
                        .allocate = .alloc_always,
                        .ignore_unknown_fields = true,
                        .max_value_len = std.math.maxInt(usize),
                    };

                    var parsed = try std.json.parseFromTokenSource(
                        Parse(T, quantity),
                        self.allocator,
                        &scanner,
                        options,
                    );

                    switch (quantity) {
                        .one => meta.setArena(T, &parsed.value, parsed.arena),
                        // when querying multiple values, only set `__arena` to the last one
                        // this way, we only free after we are done with all of them
                        .many => {
                            switch (parsed.value.len) {
                                0 => {
                                    parsed.deinit();
                                    return &.{};
                                },
                                else => |len| meta.setArena(T, &parsed.value[len - 1], parsed.arena),
                            }
                        },
                    }

                    return parsed.value;
                }
            };
        }
    };
}
