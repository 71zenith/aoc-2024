const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const loc = struct {
    x: u7,
    y: u7,
};
pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    // var count: usize = 0;
    var arr = std.ArrayList(isize).init(allocator);
    for (file_contents[0 .. file_contents.len - 1], 0..) |c, i| {
        const int = c - '0';
        if (i & 1 == 0) {
            for (0..int) |_| {
                arr.append(@as(isize, @intCast(i / 2))) catch unreachable;
            }
        } else {
            for (0..int) |_| {
                arr.append(-1) catch unreachable;
            }
        }
    }
    const items = try arr.toOwnedSlice();
    arr.deinit();
    // print("{any}\n", .{items});
    // print("{any}", .{arr.items});
    // for (arr.items) |x| {
    //     if (x == '.') {
    //         print(". ", .{});
    //     } else {
    //         print("{d} ", .{x});
    //     }
    // }
    // print("\n", .{});
    const start_time = nanoTimestamp();
    // // findNext(items, 9);
    // std.debug.print("DEBUGPRINT[1]: part2.zig:44: findNext(items, 9)={any}\n", .{findNext(items, 3)});
    // findBack(items, 9);
    // std.debug.print("DEBUGPRINT[2]: part2.zig:46: findBack(items, 9)={any}\n", .{findBack(items, 7)});
    // // findEmpty(items, 0);
    // std.debug.print("DEBUGPRINT[3]: part2.zig:49: findEmpty(items, 0)={any}\n", .{findEmpty(items, 5)});
    // var oldempty: struct { usize, usize, usize } = undefined;
    var last = findBack(items, items.len);
    l: while (true) {
        // print("last{}\n", .{last});
        // print("items: {any}, {any}\n", .{ items, items.len });
        var empty = findEmpty(items, 0);
        while (empty[2] < last[2] and empty[1] < last[0]) {
            empty = findEmpty(items, empty[1]);
            if (empty[0] == 0 and empty[1] == 0 and empty[2] == 0) {
                last = findBack(items, last[0]);
                continue :l;
            }
        }
        if (check(empty, last)) {
            for (last[0]..last[1], empty[0]..(empty[1] - (empty[2] - last[2]))) |x, y| {
                const temp = items[y];
                items[y] = items[x];
                items[x] = temp;
            }
        }
        last = findBack(items, last[0]);
        if (last[0] == 0 and last[1] == 0 and last[2] == 0) {
            break;
        }
        // last = findBack(items, items.len - last[2]);
        // std.debug.print("DEBUGPRINT[4]: part2.zig:69: last={any}\n", .{last});
        // print("{any}\n", .{items});
    }
    // print("{any}\n", .{items});

    var count: isize = 0;
    pp(items);
    // // print("{any}", .{arr});
    for (items, 0..) |x, k| {
        if (x == -1) continue;
        count += x * @as(isize, @intCast(k));
        // print("{d}x{d}={d}, {d}\n", .{ k, x / 2, (x / 2 * k), count });
    }
    // for (0..arr.items.len) |i| {
    // }
    // _ = arr.swapRemove(3);
    print("{any}\n", .{count});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.5} ms\n", .{input_time});
}
fn findNext(arr: []isize, val: isize) struct { usize, usize, usize } {
    for (arr, 0..) |x, i| {
        if (x == val) {
            for (arr[i + 1 ..], 0..) |y, j| {
                if (y != val) {
                    return .{ i, i + j + 1, j + 1 };
                }
            }
        }
    }
    return .{ 0, 0, 0 };
}
fn findBack(arr: []isize, pos: usize) struct { usize, usize, usize } {
    var rev = std.mem.reverseIterator(arr[0..pos]);
    while (rev.next()) |x| {
        if (x != -1) {
            const start = rev.index;
            while (rev.next()) |y| {
                if (y != x) {
                    return .{ rev.index + 1, start + 1, start - rev.index };
                }
            }
        }
    }
    return .{ 0, 0, 0 };
}
fn findEmpty(arr: []isize, pos: usize) struct { usize, usize, usize } {
    for (arr[pos..], 0..) |x, i| {
        if (x == -1) {
            for (arr[pos + i + 1 ..], 0..) |y, j| {
                if (y != -1) {
                    return .{ pos + i, pos + i + j + 1, j + 1 };
                }
            }
        }
    }
    return .{ 0, 0, 0 };
}
fn pp(arr: []isize) void {
    for (arr) |x| {
        if (x == -1) {
            print(".", .{});
        } else {
            print("{d}", .{x});
        }
    }
    print("\n", .{});
}
fn check(a1: struct { usize, usize, usize }, a2: struct { usize, usize, usize }) bool {
    if (a1[0] < a2[0] and a1[1] < a2[1] and a1[2] >= a2[2]) return true;
    return false;
}
