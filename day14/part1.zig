const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const pos = @Vector(2, isize);
const vel = @Vector(2, isize);
const info = struct {
    pos: pos,
    vel: vel,
};

const width = 101;
const height = 103;
const grid = pos{ width, height };

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var split = std.mem.splitSequence(u8, file_contents, "\n");
    var vec = std.ArrayList(info).init(allocator);
    var final = std.ArrayList(pos).init(allocator);

    while (split.next()) |l| {
        if (l.len == 0) break;
        var x: isize = 0;
        var y: isize = 0;
        var vx: isize = 0;
        var vy: isize = 0;
        var comma = std.mem.indexOf(u8, l, ",").?;
        x = try std.fmt.parseInt(isize, l[2..comma], 10);
        const space = std.mem.indexOf(u8, l, " ").?;
        y = try std.fmt.parseInt(isize, l[comma + 1 .. space], 10);
        const equal = std.mem.indexOf(u8, l, "v=").?;
        comma = std.mem.indexOf(u8, l[equal..], ",").?;
        vx = try std.fmt.parseInt(isize, l[equal + 2 ..][0 .. comma - 2], 10);
        vy = try std.fmt.parseInt(isize, l[equal + 2 ..][comma - 1 ..], 10);
        try vec.append(info{ .pos = pos{ x, y }, .vel = vel{ vx, vy } });
    }

    const start_time = nanoTimestamp();
    for (vec.items) |o| {
        var newpos = o.pos;
        newpos = @mod((newpos + (o.vel * @as(pos, @splat(100)))), grid);
        try final.append(newpos);
    }
    var q1: usize = 0;
    var q2: usize = 0;
    var q3: usize = 0;
    var q4: usize = 0;
    for (final.items) |o| {
        const midwidth = (width - 1) / 2;
        const midheight = (height - 1) / 2;
        const x = o[0];
        const y = o[1];
        if (x < midwidth and y < midheight) {
            q1 += 1;
        }
        if (x > midwidth and y < midheight) {
            q2 += 1;
        }
        if (x > midwidth and y > midheight) {
            q3 += 1;
        }
        if (x < midwidth and y > midheight) {
            q4 += 1;
        }
    }
    const total = q1 * q2 * q3 * q4;

    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("total: {}\n", .{total});
    print("Time {d:.5} ms\n", .{input_time});
}
