const std = @import("std");
const StdWriter = std.Io.Writer;

pub const Writer = struct {
    _wrapped: *StdWriter,
    _writer: StdWriter,

    fn writeEncodedChar(w: *StdWriter, c: u8) StdWriter.Error!usize {
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

    fn writeEncodedSlice(w: *StdWriter, slice: []const u8) StdWriter.Error!usize {
        var n: usize = 0;

        for (slice) |c| {
            n += try writeEncodedChar(w, c);
        }

        return n;
    }

    fn drain(io_w: *StdWriter, data: []const []const u8, splat: usize) StdWriter.Error!usize {
        const self: *Writer = @fieldParentPtr("_writer", io_w);

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

    pub fn init(w: *StdWriter) Writer {
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

    pub fn writer(self: *Writer) *StdWriter {
        return &self._writer;
    }
};
