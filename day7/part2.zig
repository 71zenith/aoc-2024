const std = @import("std");
const print = std.debug.print;
const utils = @import("utils.zig");
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;
const eqn = struct { t: usize, xs: []usize };
const mode = enum { add, mul };

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
var fmtbuf = std.ArrayList([]u8).init(allocator);

pub fn main() !void {
    const start_time = nanoTimestamp();
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var arrh = std.ArrayList(eqn).init(allocator);
    var split = std.mem.tokenizeSequence(u8, file_contents, "\n");

    while (split.next()) |l| {
        // print("{s}\n", .{l});
        var seq = std.mem.tokenizeSequence(u8, l, " ");
        const total = try std.fmt.parseInt(usize, seq.peek().?[0 .. seq.next().?.len - 1], 10);
        var arr = std.ArrayList(usize).init(allocator);
        while (seq.next()) |z| {
            try arr.append(try std.fmt.parseInt(usize, z, 10));
        }
        try arrh.append(eqn{ .t = total, .xs = try arr.toOwnedSlice() });
    }
    defer fmtbuf.deinit();

    var x: usize = 0;
    for (arrh.items) |j| {
        try per(j.xs.len - 1, "012", "");
        x += calc(j, try fmtbuf.toOwnedSlice());
    }

    print("{d}\n", .{x});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.2} ms\n", .{input_time});
}
fn calc(j: eqn, p: [][]u8) usize {
    for (p) |x| {
        var prev = j.xs[0];
        for (0..j.xs.len - 1) |y| {
            switch (x[y]) {
                '0' => {
                    prev = add(prev, j.xs[y + 1]);
                },
                '1' => {
                    prev = mul(prev, j.xs[y + 1]);
                },
                '2' => {
                    prev = conc(prev, j.xs[y + 1]) catch unreachable;
                },
                else => {},
            }
            continue;
        }
        if (prev == j.t) {
            return j.t;
        }
    }
    return 0;
}
fn per(n: usize, char: []const u8, cur: []const u8) !void {
    if (cur.len == n) {
        try fmtbuf.append(try std.fmt.allocPrint(allocator, "{s}", .{cur}));
        return;
    }
    for (char) |ch| {
        try per(n, char, try std.fmt.allocPrint(allocator, "{s}{c}", .{ cur, ch }));
    }
}
fn add(x: usize, y: usize) usize {
    return x + y;
}
fn mul(x: usize, y: usize) usize {
    return x * y;
}
fn conc(x: usize, y: usize) !usize {
    return (try std.fmt.parseInt(usize, (try std.fmt.allocPrint(allocator, "{d}{d}", .{ x, y })), 10));
}
