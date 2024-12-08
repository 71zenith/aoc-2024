const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const loc = struct {
    x: u8,
    y: u8,
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

    var xcoord: u8 = 0;
    while (split.next()) |l| : (xcoord += 1) {
        try grid.append(l);
        for (l, 0..) |c, ycoord| {
            if (c != '.') {
                const val = try map.getOrPut(c);
                if (!val.found_existing) {
                    val.value_ptr.* = std.ArrayList(loc).init(allocator);
                    defer val.value_ptr.*.deinit();
                }
                val.value_ptr.append(.{ .x = xcoord, .y = @as(u8, @intCast(ycoord)) }) catch unreachable;
            }
        }
    }
    var antennas = std.AutoHashMap(loc, bool).init(allocator);
    var keyit = map.iterator();
    while (keyit.next()) |kv| {
        const val = kv.value_ptr.*;
        for (0..val.items.len - 1) |num| {
            const x = val.items[num].x;
            const y = val.items[num].y;
            for (0..val.items.len - 1) |num2| {
                const x2 = val.items[num2 + 1].x;
                const y2 = val.items[num2 + 1].y;
                const dist = loc{ .x = x2 - x, .y = y2 - y };
                if (dist.x != 0 and dist.y != 0) {
                    if (checkcoords(x - dist.x, y - dist.y, grid.items.len)) {
                        try antennas.put(loc{ .x = x - dist.x, .y = y - dist.y }, true);
                    }
                    if (checkcoords(x2 + dist.x, y2 + dist.y, grid.items.len)) {
                        try antennas.put(loc{ .x = x2 + dist.x, .y = y2 + dist.y }, true);
                    }
                }
            }
        }
    }

    print("Count: {d}\n", .{antennas.count()});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.5} ms\n", .{input_time});
}
fn checkcoords(x: u8, y: u8, gridmax: usize) bool {
    if (x < gridmax and y < gridmax) {
        return true;
    }
    return false;
}
