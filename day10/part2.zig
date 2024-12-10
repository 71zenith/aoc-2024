const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
const loc = struct { x: usize, y: usize };
var hash = std.AutoHashMap(loc, void).init(allocator);

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var grid = std.ArrayList([]usize).init(allocator);
    var split = std.mem.tokenizeSequence(u8, file_contents, "\n");
    var stpos = std.ArrayList(loc).init(allocator);

    var x: usize = 0;
    while (split.next()) |l| : (x += 1) {
        var hor = std.ArrayList(usize).init(allocator);
        for (l, 0..) |n, y| {
            hor.append(n - '0') catch unreachable;
            if (n - '0' == 0) {
                try stpos.append(.{ .x = x, .y = y });
            }
        }
        try grid.append(try hor.toOwnedSlice());
    }
    const start_time = nanoTimestamp();
    var part1: usize = 0;
    var part2: usize = 0;
    for (stpos.items) |st| {
        part2 += try find(st, grid.items);
        part1 += hash.count();
        hash.clearRetainingCapacity();
    }
    print("part1: {d}\n", .{part1});
    print("part2: {d}\n", .{part2});

    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.5} ms\n", .{input_time});
}
fn find(pos: loc, grid: [][]usize) !usize {
    var c: usize = 0;
    if (grid[pos.x][pos.y] == 9) {
        try hash.put(pos, {});
        c += 1;
        return c;
    }
    const next = try findNext(grid, pos);
    for (next) |p| {
        c += try find(p, grid);
    }
    return c;
}
fn findNext(grid: [][]usize, cur: loc) ![]loc {
    const num = grid[cur.x][cur.y];
    var locarry = std.ArrayList(loc).init(allocator);

    if (cur.x > 0) {
        if (grid[cur.x - 1][cur.y] == num + 1) {
            try locarry.append(.{ .x = cur.x - 1, .y = cur.y });
        }
    }
    if (cur.x < grid.len - 1) {
        if (grid[cur.x + 1][cur.y] == num + 1) {
            try locarry.append(.{ .x = cur.x + 1, .y = cur.y });
        }
    }
    if (cur.y > 0) {
        if (grid[cur.x][cur.y - 1] == num + 1) {
            try locarry.append(.{ .x = cur.x, .y = cur.y - 1 });
        }
    }
    if (cur.y < grid[0].len - 1) {
        if (grid[cur.x][cur.y + 1] == num + 1) {
            try locarry.append(.{ .x = cur.x, .y = cur.y + 1 });
        }
    }
    return try locarry.toOwnedSlice();
}
