const std = @import("std");
const Writer = std.Io.Writer;

pub const PercentEncodedWriter = struct {
    _wrapped: *Writer,
    _writer: Writer,

    fn writeEncodedChar(w: *Writer, c: u8) Writer.Error!usize {
        switch (c) {
            // keep as is
            'a'...'z',
            'A'...'Z',
            '0'...'9',
            '.',
            '-',
            '_',
            '=',
            '&',
            => {
                return w.vtable.drain(w, &.{&.{c}}, 1);
            },
            // encode
            else => {
                var n = try w.vtable.drain(w, &.{"%"}, 1);

                const hex = std.fmt.bytesToHex(&[_]u8{c}, .upper);
                n += try w.vtable.drain(w, &.{&hex}, 1);

                return n;
            },
        }
    }

    fn writeEncodedSlice(w: *Writer, slice: []const u8) Writer.Error!usize {
        var n: usize = 0;

        for (slice) |c| {
            n += try writeEncodedChar(w, c);
        }

        return n;
    }

    fn drain(io_w: *Writer, data: []const []const u8, splat: usize) Writer.Error!usize {
        const self: *PercentEncodedWriter = @fieldParentPtr("_writer", io_w);

        var n: usize = 0;
        for (data[0 .. data.len - 1]) |slice| {
            n += try writeEncodedSlice(self._wrapped, slice);
        }

        const last = data[data.len - 1];
        for (0..splat) |_| {
            n += try writeEncodedSlice(self._wrapped, last);
        }

        return n;
    }

    pub fn init(w: *Writer) PercentEncodedWriter {
        return .{
            ._wrapped = w,
            ._writer = .{
                .buffer = &.{},
                .vtable = &.{
                    .drain = drain,
                },
            },
        };
    }

    pub fn writer(self: *PercentEncodedWriter) *Writer {
        return &self._writer;
    }
};
