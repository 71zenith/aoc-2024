const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const loc = @Vector(2, usize);
const edloc = struct { loc, dir };
const dir = enum { u, d, l, r };

const Context = struct {
    k: []loc,
    pub fn lessThan(self: @This(), a: usize, b: usize) bool {
        if (self.k[a][0] < self.k[b][0]) return true;
        if (self.k[a][1] + self.k[a][0] < self.k[b][1] + self.k[b][0]) return true;
        return false;
    }
};

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var split = std.mem.splitSequence(u8, file_contents, "\n");
    var grid = std.ArrayList([]const u8).init(allocator);

    while (split.next()) |l| {
        if (l.len == 0) break;
        try grid.append(l);
    }
    var region = std.AutoArrayHashMap(loc, bool).init(allocator);
    defer region.deinit();
    var all = std.AutoArrayHashMap(loc, void).init(allocator);
    defer all.deinit();
    var edges = std.AutoArrayHashMap(edloc, void).init(allocator);
    defer edges.deinit();
    var seen = std.AutoArrayHashMap(edloc, void).init(allocator);
    defer seen.deinit();
    var total: usize = 0;
    var new = try region.clone();
    const start_time = nanoTimestamp();
    for (grid.items, 0..) |o, row| {
        for (o, 0..) |_, col| {
            if (all.get(loc{ row, col }) != null) continue;
            region.put(loc{ row, col }, false) catch unreachable;
            m: while (true) {
                var c: usize = 0;
                new = try region.clone();
                for (new.keys()) |k| {
                    var cor: usize = 0;
                    const x = k[0];
                    const y = k[1];

                    if (x > 0) {
                        if (grid.items[x - 1][y] == grid.items[x][y]) {
                            _ = region.getOrPutValue(loc{ x - 1, y }, false) catch unreachable;
                            _ = all.getOrPutValue(loc{ x - 1, y }, {}) catch unreachable;
                            c += 1;
                            cor += 1;
                        }
                    }
                    if (x < grid.items.len - 1) {
                        if (grid.items[x + 1][y] == grid.items[x][y]) {
                            _ = region.getOrPutValue(loc{ x + 1, y }, false) catch unreachable;
                            _ = all.getOrPutValue(loc{ x + 1, y }, {}) catch unreachable;
                            c += 1;
                            cor += 1;
                        }
                    }
                    if (y > 0) {
                        if (grid.items[x][y - 1] == grid.items[x][y]) {
                            _ = region.getOrPutValue(loc{ x, y - 1 }, false) catch unreachable;
                            _ = all.getOrPutValue(loc{ x, y - 1 }, {}) catch unreachable;
                            c += 1;
                            cor += 1;
                        }
                    }
                    if (y < grid.items.len - 1) {
                        if (grid.items[x][y + 1] == grid.items[x][y]) {
                            _ = region.getOrPutValue(loc{ x, y + 1 }, false) catch unreachable;
                            _ = all.getOrPutValue(loc{ x, y + 1 }, {}) catch unreachable;
                            c += 1;
                            cor += 1;
                        }
                    }
                }
                if (region.count() == new.count()) {
                    var it = region.iterator();
                    var side_count: usize = 0;
                    while (it.next()) |kv| {
                        const x1 = kv.key_ptr.*[0];
                        const y1 = kv.key_ptr.*[1];
                        if (x1 == 0) try edges.put(edloc{ loc{ x1, y1 }, dir.u }, {});
                        if (y1 == 0) try edges.put(edloc{ loc{ x1, y1 }, dir.l }, {});
                        if (region.get(loc{ x1, y1 + 1 }) == null) {
                            try edges.put(edloc{ loc{ x1, y1 }, dir.r }, {});
                        }
                        if (y1 > 0 and region.get(loc{ x1, y1 - 1 }) == null) {
                            try edges.put(edloc{ loc{ x1, y1 }, dir.l }, {});
                        }
                        if (region.get(loc{ x1 + 1, y1 }) == null) {
                            try edges.put(edloc{ loc{ x1, y1 }, dir.d }, {});
                        }
                        if (x1 > 0 and region.get(loc{ x1 - 1, y1 }) == null) {
                            try edges.put(edloc{ loc{ x1, y1 }, dir.u }, {});
                        }
                    }
                    var it2 = edges.iterator();
                    k: while (it2.next()) |kv2| {
                        const cur = kv2.key_ptr.*[0];
                        const d = kv2.key_ptr.*[1];
                        if (seen.get(edloc{ cur, d }) != null) continue :k;
                        try seen.put(edloc{ cur, d }, {});
                        side_count += 1;
                        switch (d) {
                            .l, .r => {
                                var newrow = cur[0] + 1;
                                while (edges.get(edloc{ loc{ newrow, cur[1] }, d }) != null) {
                                    try seen.put(edloc{ loc{ newrow, cur[1] }, d }, {});
                                    newrow += 1;
                                }
                                if (cur[0] == 0) continue;
                                newrow = cur[0] - 1;
                                x: while (edges.get(edloc{ loc{ newrow, cur[1] }, d }) != null) {
                                    try seen.put(edloc{ loc{ newrow, cur[1] }, d }, {});
                                    if (newrow == 0) break :x;
                                    newrow -= 1;
                                }
                            },
                            .u, .d => {
                                var newcol = cur[1] + 1;
                                while (edges.get(edloc{ loc{ cur[0], newcol }, d }) != null) {
                                    try seen.put(edloc{ loc{ cur[0], newcol }, d }, {});
                                    newcol += 1;
                                }

                                if (cur[1] == 0) continue;
                                newcol = cur[1] - 1;
                                x: while (edges.get(edloc{ loc{ cur[0], newcol }, d }) != null) {
                                    try seen.put(edloc{ loc{ cur[0], newcol }, d }, {});
                                    if (newcol == 0) break :x;
                                    newcol -= 1;
                                }
                            },
                        }
                    }
                    total += side_count * region.count();
                    edges.clearRetainingCapacity();
                    region.clearRetainingCapacity();
                    break :m;
                }
            }
        }
    }

    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("total: {}", .{total});
    print("Time {d:.5} ms\n", .{input_time});
}
