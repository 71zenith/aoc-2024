const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const loc = @Vector(2, usize);
pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var split = std.mem.splitSequence(u8, file_contents, "\n");
    var grid = std.ArrayList([]const u8).init(allocator);

    while (split.next()) |l| {
        if (l.len == 0) break;
        try grid.append(l);
    }
    var region = std.AutoArrayHashMap(loc, void).init(allocator);
    defer region.deinit();
    var all = std.AutoArrayHashMap(loc, void).init(allocator);
    defer all.deinit();
    var total: usize = 0;
    var new = try region.clone();
    const start_time = nanoTimestamp();
    for (grid.items, 0..) |o, row| {
        for (o, 0..) |_, col| {
            if (all.get(loc{ row, col }) != null) continue;
            region.put(loc{ row, col }, {}) catch unreachable;
            m: while (true) {
                var c: usize = 0;
                new = try region.clone();
                for (new.keys()) |k| {
                    const x = k[0];
                    const y = k[1];

                    if (x > 0) {
                        if (grid.items[x - 1][y] == grid.items[x][y]) {
                            _ = region.getOrPutValue(loc{ x - 1, y }, {}) catch unreachable;
                            _ = all.getOrPutValue(loc{ x - 1, y }, {}) catch unreachable;
                            c += 1;
                        }
                    }
                    if (x < grid.items.len - 1) {
                        if (grid.items[x + 1][y] == grid.items[x][y]) {
                            _ = region.getOrPutValue(loc{ x + 1, y }, {}) catch unreachable;
                            _ = all.getOrPutValue(loc{ x + 1, y }, {}) catch unreachable;
                            c += 1;
                        }
                    }
                    if (y > 0) {
                        if (grid.items[x][y - 1] == grid.items[x][y]) {
                            _ = region.getOrPutValue(loc{ x, y - 1 }, {}) catch unreachable;
                            _ = all.getOrPutValue(loc{ x, y - 1 }, {}) catch unreachable;
                            c += 1;
                        }
                    }
                    if (y < grid.items.len - 1) {
                        if (grid.items[x][y + 1] == grid.items[x][y]) {
                            _ = region.getOrPutValue(loc{ x, y + 1 }, {}) catch unreachable;
                            _ = all.getOrPutValue(loc{ x, y + 1 }, {}) catch unreachable;
                            c += 1;
                        }
                    }
                }
                if (region.count() == new.count()) {
                    total += ((region.count() * 4) - c) * region.count();
                    region.clearRetainingCapacity();
                    break :m;
                }
            }
        }
    }
    print("total: {}", .{total});

    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.5} ms\n", .{input_time});
}
fn neigh(x: usize, y: usize, grid: [][]const u8) usize {
    var c: usize = 0;
    const p = grid[x][y];
    if (x == 0) c += 1;
    if (x == grid.len) c += 1;
    if (y == grid.len) c += 1;
    if (y == 0) c += 1;
    if (x > 0 and grid[x - 1][y] != p) c += 1;
    if (x < grid.len - 1 and grid[x + 1][y] != p) c += 1;
    if (y > 0 and grid[x][y - 1] != p) c += 1;
    if (y < grid.len - 1 and grid[x][y + 1] != p) c += 1;
    return c;
}

// fn neigh(x: usize, y: usize, grid: [][]const u8) struct { usize, []loc } {
//     var c: usize = 0;
//     var besides = std.AutoArrayHashMap(loc, void).init(allocator);
//     const p = grid[x][y];
//     if (x == 0) c += 1;
//     if (x == grid.len) c += 1;
//     if (y == grid.len) c += 1;
//     if (y == 0) c += 1;
//     if (x > 0 and grid[x - 1][y] != p) {
//         c += 1;
//         _ = besides.getOrPutValue(@Vector(2, usize){ x - 1, y }, {}) catch unreachable;
//     }
//     if (x < grid.len - 1 and grid[x + 1][y] != p) {
//         c += 1;
//         _ = besides.getOrPutValue(@Vector(2, usize){ x + 1, y }, {}) catch unreachable;
//     }
//     if (y > 0 and grid[x][y - 1] != p) {
//         c += 1;
//         _ = besides.getOrPutValue(@Vector(2, usize){ x, y - 1 }, {}) catch unreachable;
//     }
//     if (y < grid.len - 1 and grid[x][y + 1] != p) {
//         c += 1;
//         _ = besides.getOrPutValue(@Vector(2, usize){ x, y + 1 }, {}) catch unreachable;
//     }
//     return .{ c, besides.keys() };
// }
