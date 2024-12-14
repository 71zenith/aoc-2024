const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const pos = @Vector(2, isize);
const min = @Vector(2, usize);
const info = struct {
    pos: pos,
    vel: pos,
};

const Context = struct {
    pub fn lessThan(self: @This(), a: info, b: info) bool {
        _ = self;
        if (a.pos[0] < b.pos[0]) return true;
        if (a.pos[1] + a.pos[0] < b.pos[1] + b.pos[0]) return true;
        return false;
    }
};

const width = 101;
const height = 103;
const grid = pos{ width, height };

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var split = std.mem.splitSequence(u8, file_contents, "\n");
    var vec = std.ArrayList(info).init(allocator);
    // var freq = std.AutoArrayHashMap(isize, usize).init(allocator);

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
        try vec.append(info{ .pos = pos{ x, y }, .vel = pos{ vx, vy } });
    }

    const start_time = nanoTimestamp();
    var u: usize = 1;
    var p2: usize = 1000000000;
    while (u < 10000) : (u += 1) {
        var x_mean: usize = 0;
        var y_mean: usize = 0;
        for (vec.items) |o| {
            const newpos = @mod((o.pos + (@as(pos, @splat(@intCast(u))) * o.vel)), grid);
            x_mean += @as(usize, @intCast(newpos[0]));
            y_mean += @as(usize, @intCast(newpos[1]));
        }
        x_mean /= vec.items.len;
        y_mean /= vec.items.len;

        var x_sq_diff: usize = 0;
        var y_sq_diff: usize = 0;

        for (vec.items) |o| {
            const newpos = @mod((o.pos + (@as(pos, @splat(@intCast(u))) * o.vel)), grid);
            x_sq_diff += (@as(usize, @intCast(newpos[0])) - x_mean) * (@as(usize, @intCast(newpos[0])) - x_mean);
            y_sq_diff += (@as(usize, @intCast(newpos[1])) - y_mean) * (@as(usize, @intCast(newpos[1])) - y_mean);
        }
        const x_dev = std.math.sqrt(x_sq_diff / vec.items.len);
        const y_dev = std.math.sqrt(y_sq_diff / vec.items.len);
        if (x_dev < 25 and y_dev < 25) {
            p2 = @min(p2, u);
        }
    }

    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Part2 {d}\n", .{p2});
    print("Time {d:.5} ms\n", .{input_time});
}
