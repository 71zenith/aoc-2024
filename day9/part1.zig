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
    for (0..arr.items.len) |x| {
        if (x >= arr.items.len) {
            break;
        }
        while (arr.getLastOrNull().? == -1) {
            _ = arr.pop();
        }
        if (x >= arr.items.len) {
            break;
        }
        while (arr.items[x] == -1) {
            _ = arr.swapRemove(x);
        }
        // print("\n", .{});
    }
    // print("{}\n", .{arr.items.len});
    // for (arr.items) |x| {
    //     if (x == '.') {
    //         print(". ", .{});
    //     } else {
    //         print("{d} ", .{x});
    //     }
    // }
    // print("\n", .{});
    var count: isize = 0;
    // print("{any}", .{arr});
    for (arr.items, 0..) |x, k| {
        count += x * @as(isize, @intCast(k));
        // print("{d}x{d}={d}, {d}\n", .{ k, x / 2, (x / 2 * k), count });
    }
    // for (0..arr.items.len) |i| {
    // }
    // _ = arr.swapRemove(3);
    print("{any}\n", .{count});
    // var split = std.mem.tokenizeSequence(u32, file_contents, "\n");
    // var map = std.AutoHashMap(u32, std.ArrayList(loc)).init(allocator);
    // defer {
    //     map.deinit();
    //     grid.deinit();
    // }
    //
    // var xcoord: u7 = 0;
    // while (split.next()) |l| : (xcoord += 1) {
    //     try grid.append(l);
    //     for (l, 0..) |c, ycoord| {
    //         if (c != '.') {
    //             const val = try map.getOrPut(c);
    //             if (!val.found_existing) {
    //                 val.value_ptr.* = std.ArrayList(loc).init(allocator);
    //                 defer val.value_ptr.*.deinit();
    //             }
    //             val.value_ptr.append(.{ .x = xcoord, .y = @as(u7, @intCast(ycoord)) }) catch unreachable;
    //         }
    //     }
    // }
    // var antennas = std.AutoHashMap(loc, void).init(allocator);
    // var keyit = map.iterator();
    // while (keyit.next()) |kv| {
    //     const val = kv.value_ptr.*;
    //     for (0..val.items.len - 1) |num| {
    //         const x = val.items[num].x;
    //         const y = val.items[num].y;
    //         for (num..val.items.len - 1) |num2| {
    //             const x2 = val.items[num2 + 1].x;
    //             const y2 = val.items[num2 + 1].y;
    //             const dist = loc{ .x = x2 - x, .y = y2 - y };
    //             if (checkcoords(x - dist.x, y - dist.y, grid.items.len)) {
    //                 try antennas.put(loc{ .x = x - dist.x, .y = y - dist.y }, {});
    //             }
    //             if (checkcoords(x2 + dist.x, y2 + dist.y, grid.items.len)) {
    //                 try antennas.put(loc{ .x = x2 + dist.x, .y = y2 + dist.y }, {});
    //             }
    //         }
    //     }
    // }

    // print("Count: {d}\n", .{antennas.count()});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.5} ms\n", .{input_time});
}
// fn checkcoords(x: u7, y: u7, gridmax: usize) bool {
//     if (x < gridmax and y < gridmax) {
//         return true;
//     }
//     return false;
// }
