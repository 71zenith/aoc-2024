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
        try gridray.append(try allocator.dupe(u8, l));
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
    grid[robot[0]][robot[1]] = '.';
    const start_time = nanoTimestamp();
    for (dirs) |d| {
        // grid[robot[0]][robot[1]] = '.';
        // print("d: {}\n", .{d});
        switch (d) {
            .u => {
                const newpos = pos{ robot[0] - 1, robot[1] };
                switch (grid[newpos[0]][newpos[1]]) {
                    '#' => {},
                    '.' => {
                        robot = newpos;
                    },
                    'O' => {
                        var c: usize = 1;
                        var shift = false;
                        k: while (true) {
                            switch (grid[newpos[0] - c][newpos[1]]) {
                                '#' => {
                                    break :k;
                                },
                                '.' => {
                                    shift = true;
                                    break :k;
                                },
                                'O' => {
                                    c += 1;
                                },
                                else => {},
                            }
                        }
                        if (shift) {
                            for (1..c + 1) |x| {
                                grid[newpos[0] - x][newpos[1]] = 'O';
                                grid[newpos[0]][newpos[1]] = '.';
                            }
                            robot = newpos;
                        }
                        // print("c: {} shift: {}\n", .{ c, shift });
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
                    'O' => {
                        var c: usize = 1;
                        var shift = false;
                        k: while (true) {
                            switch (grid[newpos[0] + c][newpos[1]]) {
                                '#' => {
                                    break :k;
                                },
                                '.' => {
                                    shift = true;
                                    break :k;
                                },
                                'O' => {
                                    c += 1;
                                },
                                else => {},
                            }
                        }
                        if (shift) {
                            for (1..c + 1) |x| {
                                grid[newpos[0] + x][newpos[1]] = 'O';
                                grid[newpos[0]][newpos[1]] = '.';
                            }
                            robot = newpos;
                        }
                        // print("c: {} shift: {}\n", .{ c, shift });
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
                    'O' => {
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
                                'O' => {
                                    c += 1;
                                },
                                else => {},
                            }
                        }
                        if (shift) {
                            for (1..c + 1) |x| {
                                grid[newpos[0]][newpos[1] - x] = 'O';
                                grid[newpos[0]][newpos[1]] = '.';
                            }
                            robot = newpos;
                        }
                        // print("c: {} shift: {}\n", .{ c, shift });
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
                    'O' => {
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
                                'O' => {
                                    c += 1;
                                },
                                else => {},
                            }
                        }
                        if (shift) {
                            for (1..c + 1) |x| {
                                grid[newpos[0]][newpos[1] + x] = 'O';
                                grid[newpos[0]][newpos[1]] = '.';
                            }
                            robot = newpos;
                        }
                        // print("c: {} shift: {}\n", .{ c, shift });
                    },
                    else => {},
                }
            },
        }
        // grid[robot[0]][robot[1]] = '@';
        // for (grid) |x| {
        //     print("{s}\n", .{x});
        // }
    }
    var total: usize = 0;
    for (grid, 0..) |r, x| {
        for (r, 0..) |c, y| {
            if (c == 'O') {
                total += (100 * x) + y;
            }
        }
    }
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("total: {}\n", .{total});
    print("Time {d:.5} ms\n", .{input_time});
}
