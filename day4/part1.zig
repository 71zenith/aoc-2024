const std = @import("std");
const print = std.debug.print;
const utils = @import("../utils.zig");
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
pub fn ismas(s1: u8, s2: u8, s3: u8) bool {
    if (s1 == 'M' and s2 == 'A' and s3 == 'S') {
        return true;
    }
    return false;
}

pub fn do(arr: [][]const u8) usize {
    var c: usize = 0;
    for (arr, 0..) |row, y| {
        for (row, 0..) |col, x| {
            if (col == 'X') {
                if (x >= 3) {
                    if (ismas(row[x - 1], row[x - 2], row[x - 3])) {
                        c += 1;
                    }
                }
                if (x < 137) {
                    if (ismas(row[x + 1], row[x + 2], row[x + 3])) {
                        c += 1;
                    }
                }
                if (y >= 3) {
                    if (ismas(arr[y - 1][x], arr[y - 2][x], arr[y - 3][x])) {
                        c += 1;
                    }
                }
                if (y < 137) {
                    if (ismas(arr[y + 1][x], arr[y + 2][x], arr[y + 3][x])) {
                        c += 1;
                    }
                }
                if ((x >= 3) and y >= 3) {
                    if (ismas(arr[y - 1][x - 1], arr[y - 2][x - 2], arr[y - 3][x - 3])) {
                        c += 1;
                    }
                }
                if ((x < 137) and y < 137) {
                    if (ismas(arr[y + 1][x + 1], arr[y + 2][x + 2], arr[y + 3][x + 3])) {
                        c += 1;
                    }
                }
                if ((x >= 3) and y < 137) {
                    if (ismas(arr[y + 1][x - 1], arr[y + 2][x - 2], arr[y + 3][x - 3])) {
                        c += 1;
                    }
                }
                if ((x < 137) and y >= 3) {
                    if (ismas(arr[y - 1][x + 1], arr[y - 2][x + 2], arr[y - 3][x + 3])) {
                        c += 1;
                    }
                }
            }
        }
    }
    return c;
}
