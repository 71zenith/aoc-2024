const std = @import("std");
const print = std.debug.print;
const utils = @import("utils.zig");
const nanoTimestamp = std.time.nanoTimestamp;
const st = struct { l: u8, r: u8 };

const ns_per_ms: f64 = std.time.ns_per_ms;
pub fn main() !void {
    const start_time = nanoTimestamp();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var arrh = allocator.alloc([]const u8, utils.count(u8, file_contents, '\n')) catch unreachable;

    var sz: []st = allocator.alloc(st, 1176) catch unreachable;
    defer allocator.free(arrh);
    arrh = utils.splitLines(file_contents);
    var j = false;
    for (arrh, 0..) |line, i| {
        if (line.len == 0) {
            break;
        }
        const l = utils.parseInt(u8, line[0..2]);
        const r = utils.parseInt(u8, line[3..5]);
        sz[i] = st{ .l = l, .r = r };
    }
    var final: usize = 0;

    for (arrh) |line| {
        if (line.len == 0) {
            j = true;
            continue;
        }
        if (j) {
            var k: []u8 = allocator.alloc(u8, (utils.count(u8, line, ',') + 1)) catch unreachable;
            var z: usize = 0;
            var spl = std.mem.split(u8, line, ",");
            while (spl.next()) |elem| : (z += 1) {
                k[z] = utils.parseInt(u8, elem);
            }
            var t = false;
            for (0..k.len) |eal| {
                const te = k;
                _ = eal;
                for (0..k.len) |el| {
                    for ((el + 1)..k.len) |el2| {
                        if (utils.countStruct(st, sz, st{ .l = k[el], .r = k[el2] }) == 0) {
                            t = true;
                            if (utils.countStruct(st, sz, st{ .l = k[el2], .r = k[el] }) != 0) {
                                const temp = k[el2];
                                k[el2] = k[el];
                                k[el] = temp;
                                break;
                            }
                        }
                        if (std.mem.eql(u8, te, k)) {
                            break;
                        }
                    }
                }
            }
            if (t) {
                final += k[k.len / 2];
            }
        }
    }
    print("{d}\n", .{final});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Part 1: {d:.2} ms\n", .{input_time});
}
