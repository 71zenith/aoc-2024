const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var split = std.mem.splitSequence(u8, file_contents, " ");
    var grid = std.ArrayList(usize).init(allocator);

    while (split.next()) |l| {
        try grid.append(try std.fmt.parseInt(usize, l, 10));
    }
    var cache = std.AutoArrayHashMap(usize, usize).init(allocator);
    for (grid.items) |it| {
        try cache.put(it, 1);
    }
    const start_time = nanoTimestamp();
    for (0..75) |_| {
        var newcache = try cache.clone();
        cache.clearRetainingCapacity();
        var it = newcache.iterator();
        while (it.next()) |i| {
            if (i.key_ptr.* == 0) {
                const already = try cache.getOrPutValue(1, i.value_ptr.*);
                if (already.found_existing) {
                    _ = try cache.put(1, i.value_ptr.* + already.value_ptr.*);
                }
                continue;
            }
            const n = std.math.log10_int(i.key_ptr.*) + 1;
            if (n & 1 == 0) {
                const a = i.key_ptr.* / std.math.pow(usize, 10, n / 2);
                const b = i.key_ptr.* % std.math.pow(usize, 10, n / 2);
                var already = try cache.getOrPutValue(a, i.value_ptr.*);
                if (already.found_existing) {
                    _ = try cache.put(a, i.value_ptr.* + already.value_ptr.*);
                }
                already = try cache.getOrPutValue(b, i.value_ptr.*);
                if (already.found_existing) {
                    _ = try cache.put(b, i.value_ptr.* + already.value_ptr.*);
                }
                continue;
            }
            const already = try cache.getOrPutValue(i.key_ptr.* * 2024, i.value_ptr.*);
            if (already.found_existing) {
                _ = try cache.put(i.key_ptr.* * 2024, i.value_ptr.* + already.value_ptr.*);
            }
        }
    }
    var ze = cache.iterator();
    var counter: usize = 0;
    while (ze.next()) |j| {
        counter += j.value_ptr.*;
    }
    print("final: {}", .{counter});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Time {d:.5} ms\n", .{input_time});
}
