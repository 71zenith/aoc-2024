const std = @import("std");
const print = std.debug.print;
const utils = @import("utils.zig");
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;
const pos = struct { x: usize, y: usize };
const dir = enum { north, south, east, west };

pub fn main() !void {
    const start_time = nanoTimestamp();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var arrh: [][]const u8 = allocator.alloc([]const u8, std.mem.count(u8, file_contents, "\n")) catch unreachable;
    defer allocator.free(arrh);

    arrh = utils.splitLines(file_contents);
    var manpos: pos = undefined;
    for (0..arrh.len) |x| {
        if (std.mem.indexOfScalar(u8, arrh[x], '^')) |y| {
            manpos = pos{ .x = x, .y = y };
            break;
        }
    }
    var mandir: dir = .north;

    var visited = std.AutoHashMap(pos, bool).init(allocator);
    defer visited.deinit();
    while (true) {
        print("Manpos {any} Mandir {any}\n", .{ manpos, mandir });
        switch (mandir) {
            .north => {
                if ((manpos.x - 1 >= arrh.len) or (manpos.y >= arrh[manpos.x].len)) {
                    break;
                }
                if ((arrh[manpos.x - 1][manpos.y]) == '.' or (arrh[manpos.x][manpos.y]) == '^') {
                    manpos = .{ .x = manpos.x - 1, .y = manpos.y };
                    visited.put(manpos, true) catch unreachable;
                } else {
                    mandir = .east;
                }
            },
            .east => {
                if ((manpos.x >= arrh.len) or (manpos.y + 1 >= arrh[manpos.x].len)) {
                    break;
                }
                if ((arrh[manpos.x][manpos.y + 1]) == '.' or (arrh[manpos.x][manpos.y + 1]) == '^') {
                    manpos = .{ .x = manpos.x, .y = manpos.y + 1 };
                    visited.put(manpos, true) catch unreachable;
                } else {
                    mandir = .south;
                }
            },
            .south => {
                if ((manpos.x + 1 >= arrh.len) or (manpos.y >= arrh[manpos.x].len)) {
                    break;
                }
                if ((arrh[manpos.x + 1][manpos.y]) == '.' or (arrh[manpos.x][manpos.y]) == '^') {
                    manpos = .{ .x = manpos.x + 1, .y = manpos.y };
                    visited.put(manpos, true) catch unreachable;
                } else {
                    mandir = .west;
                }
            },
            .west => {
                if ((manpos.x >= arrh.len) or (manpos.y - 1 >= arrh[manpos.x].len)) {
                    break;
                }
                if ((arrh[manpos.x][manpos.y - 1]) == '.' or (arrh[manpos.x][manpos.y - 1]) == '^') {
                    manpos = .{ .x = manpos.x, .y = manpos.y - 1 };
                    visited.put(manpos, true) catch unreachable;
                } else {
                    mandir = .north;
                }
            },
        }
    }

    print("Count {any}\n", .{visited.count()});

    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Part 1: {d:.2} ms\n", .{input_time});
}
