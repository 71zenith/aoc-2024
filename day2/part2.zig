const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const file_contents = try std.fs.cwd().readFileAlloc(allocator, "example.txt", 1024 * 1024);
    defer allocator.free(file_contents);
    var it = std.mem.splitSequence(u8, file_contents, "\n");
    var arr1 = std.ArrayList(std.ArrayList(isize)).init(allocator);
    defer {
        for (arr1.items) |*def| {
            def.deinit();
        }
        arr1.deinit();
    }
    var c: usize = 0;
    while (it.next()) |x| : (c += 1) {
        var it2 = std.mem.splitSequence(u8, x, " ");
        while (it2.next()) |x2| {
            if (x2.len > 0) {
                try arr1.append(std.ArrayList(isize).init(allocator));
                try arr1.items[c].append(try std.fmt.parseInt(isize, x2, 10));
            }
        }
    }
    var k: usize = 0;
    for (arr1.items) |*def| {
        if (try reactor(def)) {
            k += 1;
        }
    }
    print("{}\n", .{k});
}
fn reactor(arr: *std.ArrayList(isize)) !bool {
    var k = false;
    for (0..arr.items.len) |x| {
        var prev: ?isize = null;
        var r: usize = 0;
        var l: usize = 0;
        const p = arr.orderedRemove(x);
        for (arr.items) |h| {
            if (prev != null) {
                if (((h - prev.?) < 4) and ((h - prev.?) >= 1)) {
                    r += 1;
                }
                if (((prev.? - h) < 4) and ((prev.? - h) >= 1)) {
                    l += 1;
                }
            }
            prev = h;
        }
        if ((arr.items.len - l == 1) or arr.items.len - r == 1) {
            k = true;
            break;
        }
        try arr.insert(x, p);
    }
    return k;
}
