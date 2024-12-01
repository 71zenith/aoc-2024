const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const file_contents = try std.fs.cwd().readFileAlloc(allocator, "example.txt", 1024 * 1024);
    defer allocator.free(file_contents);
    var it = std.mem.splitSequence(u8, file_contents, "\n");
    var arr1 = std.ArrayList(isize).init(allocator);
    defer arr1.deinit();
    var arr2 = std.ArrayList(isize).init(allocator);
    defer arr2.deinit();
    while (it.next()) |x| {
        var it2 = std.mem.splitSequence(u8, x, "   ");
        if (it2.next()) |x2| {
            if (x2.len > 0) {
                try arr1.append(try std.fmt.parseInt(isize, x2, 10));
            }
        }
        if (it2.next()) |x2| {
            if (x2.len > 0) {
                try arr2.append(try std.fmt.parseInt(isize, x2, 10));
            }
        }
    }
    std.mem.sort(isize, arr1.items, {}, std.sort.asc(isize));
    std.mem.sort(isize, arr2.items, {}, std.sort.asc(isize));
    var c: i64 = 0;
    for (arr1.items, arr2.items) |a, b| {
        c += @intCast(@abs(a - b));
    }
    print("{}\n", .{c});
}
