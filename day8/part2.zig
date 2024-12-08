const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const loc = struct {
    x: i7,
    y: i7,
};
pub fn main() !void {
    const start_time = nanoTimestamp();
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var grid = std.ArrayList([]const u8).init(allocator);
    var split = std.mem.tokenizeSequence(u8, file_contents, "\n");
    var map = std.AutoHashMap(u8, std.ArrayList(loc)).init(allocator);
    defer {
        map.deinit();
        grid.deinit();
    }

    var xcoord: i7 = 0;
    while (split.next()) |l| : (xcoord += 1) {
        try grid.append(l);
        for (l, 0..) |c, ycoord| {
            if (c != '.') {
                const val = try map.getOrPut(c);
                if (!val.found_existing) {
                    val.value_ptr.* = std.ArrayList(loc).init(allocator);
                    defer val.value_ptr.*.deinit();
                }
                val.value_ptr.append(.{ .x = xcoord, .y = @as(i7, @intCast(ycoord)) }) catch unreachable;
            }
        }
    }
    var part1 = std.AutoHashMap(loc, bool).init(allocator);
    var part2 = std.AutoHashMap(loc, bool).init(allocator);
    defer part1.deinit();
    defer part2.deinit();

    var keyit = map.iterator();
    while (keyit.next()) |kv| {
        const val = kv.value_ptr.*;
        for (0..val.items.len - 1) |num| {
            const x = val.items[num].x;
            const y = val.items[num].y;
            for (num..val.items.len - 1) |num2| {
                const x2 = val.items[num2 + 1].x;
                const y2 = val.items[num2 + 1].y;
                try part2.put(loc{ .x = x, .y = y }, true);
                try part2.put(loc{ .x = x2, .y = y2 }, true);
                var dist = loc{ .x = x2 - x, .y = y2 - y };
                var newx = x;
                var newy = y;
                if (checkcoords(newx - dist.x, newy - dist.y, grid.items.len)) {
                    try part1.put(loc{ .x = newx - dist.x, .y = newy - dist.y }, true);
                }
                loop: while (true) {
                    if (checkcoords(newx - dist.x, newy - dist.y, grid.items.len)) {
                        try part2.put(loc{ .x = newx - dist.x, .y = newy - dist.y }, true);
                    } else {
                        break :loop;
                    }
                    newx = newx - dist.x;
                    newy = newy - dist.y;
                }
                var newxp = x2;
                var newyp = y2;
                dist = loc{ .x = newxp - x, .y = newyp - y };

                if (checkcoords(newxp + dist.x, newyp + dist.y, grid.items.len)) {
                    try part1.put(loc{ .x = newxp + dist.x, .y = newyp + dist.y }, true);
                }
                loop: while (true) {
                    if (checkcoords(newxp + dist.x, newyp + dist.y, grid.items.len)) {
                        try part2.put(loc{ .x = newxp + dist.x, .y = newyp + dist.y }, true);
                    } else {
                        break :loop;
                    }
                    newxp = newxp + dist.x;
                    newyp = newyp + dist.y;
                }
            }
        }
    }
    print("Part1: {d}\n", .{part1.count()});
    print("Part2: {d}\n", .{part2.count()});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.5} ms\n", .{input_time});
}
fn checkcoords(x: i7, y: i7, gridmax: usize) bool {
    if (x >= 0 and y >= 0 and x < gridmax and y < gridmax) {
        return true;
    }
    return false;
}
