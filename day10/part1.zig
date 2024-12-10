const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
var hash = std.AutoHashMap(loc, void).init(allocator);
const loc = struct { x: usize, y: usize };

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var grid = std.ArrayList([]u8).init(allocator);
    var split = std.mem.tokenizeSequence(u8, file_contents, "\n");
    var stpos = std.ArrayList(loc).init(allocator);

    var x: usize = 0;
    while (split.next()) |l| : (x += 1) {
        var hor = std.ArrayList(u8).init(allocator);
        for (l, 0..) |n, y| {
            hor.append(n - '0') catch unreachable;
            if (n - '0' == 0) {
                try stpos.append(.{ .x = x, .y = y });
            }
        }
        try grid.append(try hor.toOwnedSlice());
    }
    // print("{any}\n", .{grid});
    // print("{any}\n", .{stpos});
    // findNext(grid.items, stpos[0]);
    // std.debug.print("{any}", .{try findNext(grid.items, stpos.items[0])});
    var c: usize = 0;
    for (stpos.items) |st| {
        try find(st, grid.items);
        c += hash.count();
        hash.clearRetainingCapacity();
    }
    print("final: {d}", .{c});

    const start_time = nanoTimestamp();
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.5} ms\n", .{input_time});
}
fn find(pos: loc, grid: [][]u8) !void {
    if (grid[pos.x][pos.y] == 9) {
        try hash.put(pos, {});
    }
    const next = try findNext(grid, pos);
    for (next) |p| {
        // print("next: {any}, pos: {any} {any} {d}\n", .{ p, pos, grid[pos.x][pos.y], c });
        try find(p, grid);
    }
}
fn findNext(grid: [][]u8, cur: loc) ![]loc {
    const num = grid[cur.x][cur.y];
    var locarry = std.ArrayList(loc).init(allocator);

    if (cur.x > 0) {
        if (grid[cur.x - 1][cur.y] == num + 1) {
            try locarry.append(.{ .x = cur.x -| 1, .y = cur.y });
        }
    }
    if (cur.x < grid.len - 1) {
        if (grid[cur.x + 1][cur.y] == num + 1) {
            try locarry.append(.{ .x = cur.x +| 1, .y = cur.y });
        }
    }
    if (cur.y > 0) {
        if (grid[cur.x][cur.y - 1] == num + 1) {
            try locarry.append(.{ .x = cur.x, .y = cur.y -| 1 });
        }
    }
    if (cur.y < grid[0].len - 1) {
        if (grid[cur.x][cur.y + 1] == num + 1) {
            try locarry.append(.{ .x = cur.x, .y = cur.y +| 1 });
        }
    }
    return try locarry.toOwnedSlice();
}
// fn checkcoords(x: u7, y: u7, gridmax: usize) bool {
//     if (x < gridmax and y < gridmax) {
//         return true;
//     }
//     return false;
// }
