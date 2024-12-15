const std = @import("std");
const print = std.debug.print;
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const pos = @Vector(2, usize);

const dir = enum { u, d, l, r };

pub fn main() !void {
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var split = std.mem.splitSequence(u8, file_contents, "\n\n");
    var gridray = std.ArrayList([]u8).init(allocator);
    var dirray = std.ArrayList(dir).init(allocator);
    var split2 = std.mem.splitSequence(u8, split.next().?, "\n");
    while (split2.next()) |l| {
        var line = std.ArrayList(u8).init(allocator);
        for (l) |c| {
            switch (c) {
                '#' => {
                    try line.append('#');
                    try line.append('#');
                },
                '.' => {
                    try line.append('.');
                    try line.append('.');
                },
                'O' => {
                    try line.append('[');
                    try line.append(']');
                },
                '@' => {
                    try line.append('@');
                    try line.append('.');
                },
                else => {},
            }
        }
        try gridray.append(try line.toOwnedSlice());
    }
    const grid = try gridray.toOwnedSlice();
    const split3 = split.next().?;
    var robot: pos = undefined;
    for (split3) |l| {
        switch (l) {
            'v' => try dirray.append(.d),
            '^' => try dirray.append(.u),
            '>' => try dirray.append(.r),
            '<' => try dirray.append(.l),
            else => {},
        }
    }
    const dirs = try dirray.toOwnedSlice();
    for (grid, 0..) |l, x| {
        for (l, 0..) |c, y| {
            if (c == '@') {
                robot = pos{ x, y };
                break;
            }
        }
    }
    const start_time = nanoTimestamp();
    g: for (dirs) |d| {
        grid[robot[0]][robot[1]] = '.';
        switch (d) {
            .u => {
                const newpos = pos{ robot[0] - 1, robot[1] };
                switch (grid[newpos[0]][newpos[1]]) {
                    '#' => {},
                    '.' => {
                        robot = newpos;
                    },
                    '[', ']' => {
                        var poss = std.AutoArrayHashMap(pos, void).init(allocator);
                        try poss.put(newpos, {});
                        if (grid[newpos[0]][newpos[1]] == '[') {
                            try poss.put(pos{ newpos[0], newpos[1] + 1 }, {});
                        } else {
                            try poss.put(pos{ newpos[0], newpos[1] - 1 }, {});
                        }
                        var newposs = try poss.clone();
                        var empty = std.AutoArrayHashMap(pos, void).init(allocator);
                        o: while (true) {
                            for (newposs.keys()) |x| {
                                if (x[0] == 0 or x[0] > grid.len) break :o;
                                const up = grid[x[0] - 1][x[1]];
                                switch (up) {
                                    ']' => {
                                        try poss.put(pos{ x[0] - 1, x[1] }, {});
                                        try poss.put(pos{ x[0] - 1, x[1] - 1 }, {});
                                        try empty.put(pos{ x[0] - 1, x[1] }, {});
                                        try empty.put(pos{ x[0] - 1, x[1] - 1 }, {});
                                    },
                                    '[' => {
                                        try poss.put(pos{ x[0] - 1, x[1] }, {});
                                        try poss.put(pos{ x[0] - 1, x[1] + 1 }, {});
                                        try empty.put(pos{ x[0] - 1, x[1] }, {});
                                        try empty.put(pos{ x[0] - 1, x[1] + 1 }, {});
                                    },
                                    '.' => {},
                                    else => {
                                        break :o;
                                    },
                                }
                            }
                            if (newposs.count() == 0) break :o;
                            newposs = try empty.clone();
                            empty.clearRetainingCapacity();
                        }
                        for (poss.keys()) |x| {
                            if (grid[x[0] - 1][x[1]] == '#') continue :g;
                        }
                        std.mem.reverse(pos, poss.keys());
                        for (poss.keys()) |x| {
                            const temp = grid[x[0] - 1][x[1]];
                            grid[x[0] - 1][x[1]] = grid[x[0]][x[1]];
                            grid[x[0]][x[1]] = temp;
                        }
                        robot = newpos;
                    },
                    else => {},
                }
            },
            .d => {
                const newpos = pos{ robot[0] + 1, robot[1] };
                switch (grid[newpos[0]][newpos[1]]) {
                    '#' => {},
                    '.' => {
                        robot = newpos;
                    },
                    '[', ']' => {
                        var poss = std.AutoArrayHashMap(pos, void).init(allocator);
                        try poss.put(newpos, {});
                        if (grid[newpos[0]][newpos[1]] == '[') {
                            try poss.put(pos{ newpos[0], newpos[1] + 1 }, {});
                        } else {
                            try poss.put(pos{ newpos[0], newpos[1] - 1 }, {});
                        }
                        var newposs = try poss.clone();
                        var empty = std.AutoArrayHashMap(pos, void).init(allocator);
                        o: while (true) {
                            for (newposs.keys()) |x| {
                                if (x[0] == 0 or x[0] > grid.len) break :o;
                                const down = grid[x[0] + 1][x[1]];
                                switch (down) {
                                    ']' => {
                                        try poss.put(pos{ x[0] + 1, x[1] }, {});
                                        try poss.put(pos{ x[0] + 1, x[1] - 1 }, {});
                                        try empty.put(pos{ x[0] + 1, x[1] }, {});
                                        try empty.put(pos{ x[0] + 1, x[1] - 1 }, {});
                                    },
                                    '[' => {
                                        try poss.put(pos{ x[0] + 1, x[1] }, {});
                                        try poss.put(pos{ x[0] + 1, x[1] + 1 }, {});
                                        try empty.put(pos{ x[0] + 1, x[1] }, {});
                                        try empty.put(pos{ x[0] + 1, x[1] + 1 }, {});
                                    },
                                    '.' => {},
                                    else => {
                                        break :o;
                                    },
                                }
                            }
                            if (newposs.count() == 0) break :o;
                            newposs = try empty.clone();
                            empty.clearRetainingCapacity();
                        }

                        for (poss.keys()) |x| {
                            if (grid[x[0] + 1][x[1]] == '#') continue :g;
                        }
                        std.mem.reverse(pos, poss.keys());
                        for (poss.keys()) |x| {
                            const temp = grid[x[0] + 1][x[1]];
                            grid[x[0] + 1][x[1]] = grid[x[0]][x[1]];
                            grid[x[0]][x[1]] = temp;
                        }
                        robot = newpos;
                    },
                    else => {},
                }
            },
            .l => {
                const newpos = pos{ robot[0], robot[1] - 1 };
                switch (grid[newpos[0]][newpos[1]]) {
                    '#' => {},
                    '.' => {
                        robot = newpos;
                    },
                    ']' => {
                        var c: usize = 1;
                        var shift = false;
                        k: while (true) {
                            switch (grid[newpos[0]][newpos[1] - c]) {
                                '#' => {
                                    break :k;
                                },
                                '.' => {
                                    shift = true;
                                    break :k;
                                },
                                '[', ']' => {
                                    c += 1;
                                },
                                else => {},
                            }
                        }
                        if (shift) {
                            for (1..c + 1) |x| {
                                const temp = grid[newpos[0]][newpos[1] - x];
                                grid[newpos[0]][newpos[1] - x] = grid[newpos[0]][newpos[1]];
                                grid[newpos[0]][newpos[1]] = temp;
                            }
                            robot = newpos;
                        }
                    },
                    else => {},
                }
            },
            .r => {
                const newpos = pos{ robot[0], robot[1] + 1 };
                switch (grid[newpos[0]][newpos[1]]) {
                    '#' => {},
                    '.' => {
                        robot = newpos;
                    },
                    '[' => {
                        var c: usize = 1;
                        var shift = false;
                        k: while (true) {
                            switch (grid[newpos[0]][newpos[1] + c]) {
                                '#' => {
                                    break :k;
                                },
                                '.' => {
                                    shift = true;
                                    break :k;
                                },
                                '[', ']' => {
                                    c += 1;
                                },
                                else => {},
                            }
                        }
                        if (shift) {
                            for (1..c + 1) |x| {
                                const temp = grid[newpos[0]][newpos[1] + x];
                                grid[newpos[0]][newpos[1] + x] = grid[newpos[0]][newpos[1]];
                                grid[newpos[0]][newpos[1]] = temp;
                            }
                            robot = newpos;
                        }
                    },
                    else => {},
                }
            },
        }
        grid[robot[0]][robot[1]] = '@';
    }
    var total: usize = 0;
    for (grid, 0..) |r, x| {
        for (r, 0..) |c, y| {
            if (c == '[') {
                total += (100 * x) + y;
            }
        }
    }
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("total: {}\n", .{total});
    print("Time {d:.5} ms\n", .{input_time});
}
