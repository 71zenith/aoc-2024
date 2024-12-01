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

    var unique_set = std.AutoHashMap(isize, isize).init(allocator);
    defer unique_set.deinit();
    for (arr1.items) |num| {
        var c: isize = 0;
        for (arr2.items) |num2| {
            if (num == num2) {
                c += 1;
            }
        }
        try unique_set.put(num, ((unique_set.get(num) orelse 0) + c));
    }
    var iterator = unique_set.keyIterator();
    var c: i64 = 0;
    while (iterator.next()) |x| {
        c += x.* * unique_set.get(x.*).?;
    }
    print("{}\n", .{c});
}
