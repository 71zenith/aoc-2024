const std = @import("std");
const print = std.debug.print;
const utils = @import("utils.zig");
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

pub fn main() !void {
    var start_time = nanoTimestamp();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var arrh: [][]const u8 = allocator.alloc([]const u8, utils.count(u8, file_contents, '\n')) catch unreachable;
    defer allocator.free(arrh);

    var input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("After input {d:.2} ms\n", .{input_time});

    arrh = utils.splitLines(file_contents);
    start_time = nanoTimestamp();

    input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("split: {d:.2} ms\n", .{input_time});

    start_time = nanoTimestamp();
    print("{any}\n", .{do(arrh)});

    input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Part 1: {d:.2} ms\n", .{input_time});
}
pub fn ismas(s1: u8, s2: u8) bool {
    if ((s1 == 'M' and s2 == 'S') or (s1 == 'S' and s2 == 'M')) {
        return true;
    }
    return false;
}

pub fn do(arr: [][]const u8) usize {
    var c: usize = 0;
    for (arr, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col == 'A') {
                if (x >= 1 and y >= 1 and x <= 138 and y <= 138) {
                    if (ismas(arr[y - 1][x - 1], arr[y + 1][x + 1]) and
                        ismas(arr[y - 1][x + 1], arr[y + 1][x - 1]))
                    {
                        c += 1;
                    }
                }
            }
        }
    }
    return c;
}
