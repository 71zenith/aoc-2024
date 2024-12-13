const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const eqn = @Vector(3, isize);
const eqns = struct {
    eqn1: eqn,
    eqn2: eqn,
};

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var split = std.mem.splitSequence(u8, file_contents, "\n\n");
    var set = std.ArrayList(eqns).init(allocator);

    while (split.next()) |l| {
        var part = std.mem.splitSequence(u8, l, "\n");
        var x1: isize = 0;
        var x2: isize = 0;
        var y1: isize = 0;
        var y2: isize = 0;
        var t1: isize = 0;
        var t2: isize = 0;
        var l2 = part.next().?;
        x1 = try std.fmt.parseInt(isize, l2[11..14], 10);
        y1 = try std.fmt.parseInt(isize, l2[18..], 10);
        l2 = part.next().?;
        x2 = try std.fmt.parseInt(isize, l2[11..14], 10);
        y2 = try std.fmt.parseInt(isize, l2[18..], 10);
        l2 = part.next().?;
        const comma = std.mem.indexOf(u8, l2, ",").?;
        t1 = try std.fmt.parseInt(isize, l2[std.mem.indexOf(u8, l2, "=").? + 1 .. comma], 10) + 10000000000000;
        t2 = try std.fmt.parseInt(isize, l2[comma..][std.mem.indexOf(u8, l2[comma..], "=").? + 1 ..], 10) + 10000000000000;
        try set.append(eqns{ .eqn1 = eqn{ x1, x2, t1 }, .eqn2 = eqn{ y1, y2, t2 } });
    }

    const start_time = nanoTimestamp();
    var total: isize = 0;
    for (set.items) |o| {
        const neweq1 = o.eqn1 * @as(eqn, @splat(o.eqn2[1]));
        const neweq2 = o.eqn2 * @as(eqn, @splat(o.eqn1[1]));
        const res = neweq1 - neweq2;
        const A = std.math.divExact(isize, res[2], res[0]) catch continue;
        if (A < 0) continue;

        const B = @divExact((o.eqn1[2] - (o.eqn1[0] * A)), o.eqn1[1]);

        if (B < 0) continue;
        total += (A * 3) + B;
    }
    print("total: {}\n", .{total});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;

    print("Time {d:.5} ms\n", .{input_time});
}
