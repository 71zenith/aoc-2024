const std = @import("std");
const print = std.debug.print;
const utils = @import("utils.zig");
const nanoTimestamp = std.time.nanoTimestamp;

const ns_per_ms: f64 = std.time.ns_per_ms;
const pos = struct { x: usize, y: usize };
const dir = enum { north, south, east, west };
const vec = struct { pos: pos, dir: dir };

pub fn main() !void {
    const start_time = nanoTimestamp();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file_contents = @embedFile("example.txt");
    var arrh: [][]const u8 = allocator.alloc([]const u8, std.mem.count(u8, file_contents, "\n")) catch unreachable;
    defer allocator.free(arrh);

    arrh = utils.splitLines(file_contents);
    var manvec: vec = undefined;
    manvec.dir = dir.north;
    for (0..arrh.len) |x| {
        if (std.mem.indexOfScalar(u8, arrh[x], '^')) |y| {
            manvec.pos = pos{ .x = x, .y = y };
            break;
        }
    }

    var visited = std.AutoArrayHashMap(pos, bool).init(allocator);
    defer visited.deinit();

    while (true) {
        switch (manvec.dir) {
            .north => {
                if ((manvec.pos.x - 1 >= arrh.len) or (manvec.pos.y >= arrh[manvec.pos.x].len)) {
                    break;
                }
                if ((arrh[manvec.pos.x - 1][manvec.pos.y]) == '.' or (arrh[manvec.pos.x - 1][manvec.pos.y]) == '^') {
                    manvec.pos = .{ .x = manvec.pos.x - 1, .y = manvec.pos.y };
                    visited.put(manvec.pos, true) catch unreachable;
                } else {
                    manvec.dir = .east;
                }
            },
            .east => {
                if ((manvec.pos.x >= arrh.len) or (manvec.pos.y + 1 >= arrh[manvec.pos.x].len)) {
                    break;
                }
                if ((arrh[manvec.pos.x][manvec.pos.y + 1]) == '.' or (arrh[manvec.pos.x][manvec.pos.y + 1]) == '^') {
                    manvec.pos = .{ .x = manvec.pos.x, .y = manvec.pos.y + 1 };
                    visited.put(manvec.pos, true) catch unreachable;
                } else {
                    manvec.dir = .south;
                }
            },
            .south => {
                if ((manvec.pos.x + 1 >= arrh.len) or (manvec.pos.y >= arrh[manvec.pos.x].len)) {
                    break;
                }
                if ((arrh[manvec.pos.x + 1][manvec.pos.y]) == '.' or (arrh[manvec.pos.x + 1][manvec.pos.y]) == '^') {
                    manvec.pos = .{ .x = manvec.pos.x + 1, .y = manvec.pos.y };
                    visited.put(manvec.pos, true) catch unreachable;
                } else {
                    manvec.dir = .west;
                }
            },
            .west => {
                if ((manvec.pos.x >= arrh.len) or (manvec.pos.y - 1 >= arrh[manvec.pos.x].len)) {
                    break;
                }
                if ((arrh[manvec.pos.x][manvec.pos.y - 1]) == '.' or (arrh[manvec.pos.x][manvec.pos.y - 1]) == '^') {
                    manvec.pos = .{ .x = manvec.pos.x, .y = manvec.pos.y - 1 };
                    visited.put(manvec.pos, true) catch unreachable;
                } else {
                    manvec.dir = .north;
                }
            },
        }
    }

    var a1 = std.ArrayList(u8).init(allocator);
    var a2 = std.ArrayList([]u8).init(allocator);
    defer a1.deinit();
    for (arrh) |x| {
        for (x) |y| {
            a1.append(y) catch unreachable;
        }
        a2.append(try a1.toOwnedSlice()) catch unreachable;
    }
    for (0..arrh.len) |x| {
        if (std.mem.indexOfScalar(u8, arrh[x], '^')) |y| {
            manvec.pos = pos{ .x = x, .y = y };
            break;
        }
    }
    const manvec_pos = manvec.pos;
    a2.items[manvec_pos.x][manvec_pos.y] = 'x';
    var count: usize = 0;

    var visit = visited.iterator();
    while (visit.next()) |key| {
        var obsvisited = std.AutoHashMap(vec, bool).init(allocator);
        defer obsvisited.deinit();
        manvec.dir = dir.north;
        manvec.pos = manvec_pos;
        print("Blocked {any}\n", .{key.key_ptr});
        a2.items[key.key_ptr.x][key.key_ptr.y] = '#';
        di: while (true) {
            a2.items[manvec.pos.x][manvec.pos.y] = 'x';
            a2.items[manvec.pos.x][manvec.pos.y] = '.';
            switch (manvec.dir) {
                .north => {
                    if (manvec.pos.x == 0) {
                        break;
                    }
                    if ((manvec.pos.x - 1 >= a2.items.len) or (manvec.pos.y >= a2.items[manvec.pos.x].len)) {
                        break;
                    }
                    if (is(a2.items[manvec.pos.x - 1][manvec.pos.y])) {
                        manvec.pos = .{ .x = manvec.pos.x - 1, .y = manvec.pos.y };
                    } else {
                        const a = try obsvisited.getOrPut(vec{ .pos = pos{ .x = manvec.pos.x - 1, .y = manvec.pos.y }, .dir = .north });
                        if (a.found_existing == true) {
                            count += 1;
                            print("{any}\n", .{key.key_ptr});
                            break :di;
                        }

                        manvec.dir = .east;
                    }
                },
                .east => {
                    if ((manvec.pos.x >= a2.items.len) or (manvec.pos.y + 1 >= a2.items[manvec.pos.x].len)) {
                        break;
                    }
                    if (is(a2.items[manvec.pos.x][manvec.pos.y + 1])) {
                        manvec.pos = .{ .x = manvec.pos.x, .y = manvec.pos.y + 1 };
                    } else {
                        const a = try obsvisited.getOrPut(vec{ .pos = pos{ .x = manvec.pos.x, .y = manvec.pos.y + 1 }, .dir = .east });
                        if (a.found_existing == true) {
                            count += 1;
                            print("{any}\n", .{key.key_ptr});
                            break :di;
                        }

                        manvec.dir = .south;
                    }
                },
                .south => {
                    if ((manvec.pos.x + 1 >= a2.items.len) or (manvec.pos.y >= a2.items[manvec.pos.x].len)) {
                        break;
                    }
                    if (is(a2.items[manvec.pos.x + 1][manvec.pos.y])) {
                        manvec.pos = .{ .x = manvec.pos.x + 1, .y = manvec.pos.y };
                    } else {
                        const a = try obsvisited.getOrPut(vec{ .pos = pos{ .x = manvec.pos.x + 1, .y = manvec.pos.y }, .dir = .south });
                        if (a.found_existing == true) {
                            count += 1;
                            print("{any}\n", .{key.key_ptr});
                            break :di;
                        }
                        manvec.dir = .west;
                    }
                },
                .west => {
                    if (manvec.pos.y == 0) {
                        break;
                    }
                    if ((manvec.pos.x >= a2.items.len) or (manvec.pos.y - 1 >= a2.items[manvec.pos.x].len)) {
                        break;
                    }
                    if (is(a2.items[manvec.pos.x][manvec.pos.y - 1])) {
                        manvec.pos = .{ .x = manvec.pos.x, .y = manvec.pos.y - 1 };
                    } else {
                        const a = try obsvisited.getOrPut(vec{ .pos = pos{ .x = manvec.pos.x, .y = manvec.pos.y - 1 }, .dir = .west });
                        if (a.found_existing == true) {
                            count += 1;
                            print("{any}\n", .{key.key_ptr});
                            break :di;
                        }
                        manvec.dir = .north;
                    }
                },
            }
        }
        a2.items[key.key_ptr.x][key.key_ptr.y] = '.';
    }
    print("{d}\n", .{count});
    const input_time = @as(f64, @floatFromInt(nanoTimestamp() - start_time)) / ns_per_ms;
    print("TIme {d:.2} ms\n", .{input_time});
}
fn is(char: u8) bool {
    switch (char) {
        'x', '.' => return true,
        else => return false,
    }
}
