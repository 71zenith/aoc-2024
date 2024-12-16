const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();
const Order = std.math.Order;

const pos = @Vector(2, usize);
const dir = enum { n, s, e, w };
const mov = struct { pos: pos, dir: dir, score: usize, prev: std.ArrayList(pos) };
const last = struct { pos: pos, dir: dir };
const Context = struct {
    fn lessThan(context: @This(), a: mov, b: mov) Order {
        _ = context;
        return std.math.order(a.score, b.score);
    }
};

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var split = std.mem.splitSequence(u8, file_contents, "\n");
    var gridray = std.ArrayList([]u8).init(allocator);
    while (split.next()) |l| {
        try gridray.append(try allocator.dupe(u8, l));
    }
    var rein: mov = undefined;
    const grid = try gridray.toOwnedSlice();
    var queue = std.PriorityQueue(mov, Context, Context.lessThan).init(allocator, Context{});

    for (grid, 0..) |l, x| {
        for (l, 0..) |c, y| {
            if (c == 'S') {
                rein = mov{ .pos = pos{ x, y }, .dir = .e, .score = 0, .prev = std.ArrayList(pos).init(allocator) };
                break;
            }
        }
    }

    try queue.add(rein);
    grid[rein.pos[0]][rein.pos[1]] = '.';
    var all = std.AutoArrayHashMap(pos, void).init(allocator);

    var visited = std.AutoArrayHashMap(last, void).init(allocator);
    const start_time = nanoTimestamp();
    while (queue.count() > 0) {
        const s = queue.remove();
        try visited.put(last{ .pos = s.pos, .dir = s.dir }, {});
        if (grid[s.pos[0]][s.pos[1]] == 'E') {
            if (s.score == 101492) {
                for (s.prev.items) |x| {
                    try all.put(x, {});
                }
            }
        }
        {
            var newpos: pos = undefined;
            switch (s.dir) {
                .e => newpos = pos{ s.pos[0], s.pos[1] + 1 },
                .n => newpos = pos{ s.pos[0] - 1, s.pos[1] },
                .s => newpos = pos{ s.pos[0] + 1, s.pos[1] },
                .w => newpos = pos{ s.pos[0], s.pos[1] - 1 },
            }
            switch (grid[newpos[0]][newpos[1]]) {
                '#' => {},
                else => {
                    const get = visited.get(last{ .pos = newpos, .dir = s.dir });
                    if (get == null) {
                        var x = try s.prev.clone();
                        try x.append(s.pos);
                        try queue.add(mov{ .pos = newpos, .dir = s.dir, .score = s.score + 1, .prev = x });
                    }
                },
            }
            switch (s.dir) {
                .e, .w => {
                    if (grid[s.pos[0] + 1][s.pos[1]] != '#') {
                        const get = visited.get(last{ .pos = pos{ s.pos[0] + 1, s.pos[1] }, .dir = .s });
                        if (get == null) try queue.add(mov{ .pos = s.pos, .dir = .s, .score = s.score + 1000, .prev = try s.prev.clone() });
                    }
                    if (grid[s.pos[0] - 1][s.pos[1]] != '#') {
                        const get = visited.get(last{ .pos = pos{ s.pos[0] - 1, s.pos[1] }, .dir = .n });
                        if (get == null) try queue.add(mov{ .pos = s.pos, .dir = .n, .score = s.score + 1000, .prev = try s.prev.clone() });
                    }
                },
                .n, .s => {
                    if (grid[s.pos[0]][s.pos[1] + 1] != '#') {
                        const get = visited.get(last{ .pos = pos{ s.pos[0], s.pos[1] + 1 }, .dir = .e });
                        if (get == null) try queue.add(mov{ .pos = s.pos, .dir = .e, .score = s.score + 1000, .prev = try s.prev.clone() });
                    }
                    if (grid[s.pos[0]][s.pos[1] - 1] != '#') {
                        const get = visited.get(last{ .pos = pos{ s.pos[0], s.pos[1] - 1 }, .dir = .w });
                        if (get == null) try queue.add(mov{ .pos = s.pos, .dir = .w, .score = s.score + 1000, .prev = try s.prev.clone() });
                    }
                },
            }
        }
    }

    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("Final: {}\n", .{all.count() + 1});
    print("Time {d:.5} ms\n", .{input_time});
}
