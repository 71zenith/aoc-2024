const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const file_contents = try std.fs.cwd().readFileAlloc(allocator, "example.txt", 1024 * 1024);
    defer allocator.free(file_contents);

    var it = std.mem.splitSequence(u8, file_contents, "\n");
    var p: usize = 0;
    while (it.next()) |x| {
        p += try matches(x);
    }
    print("correct: {d}\n", .{p});
}
pub fn matches(str: []const u8) !usize {
    var c: usize = 0;
    var new_str = str;
    while (std.mem.indexOf(u8, new_str, "mul(")) |i| {
        var l: usize = 0;
        var r: usize = 0;
        var sw: usize = 0;
        var z: usize = 0;
        for ((i + 4)..(i + 13)) |j| {
            switch (new_str[j]) {
                '0'...'9' => {
                    if (sw > 0) {
                        r += 1;
                    } else {
                        l += 1;
                    }
                },
                ',' => {
                    sw = j;
                },
                ')' => {
                    z = j + 1;
                    break;
                },
                else => {
                    l = 0;
                    r = 0;
                    sw = 0;
                    z = j;
                    break;
                },
            }
        }
        if (l > 0 and r > 0 and sw != 0 and z != 0) {
            c += (try std.fmt.parseInt(usize, new_str[(i + 4)..sw], 10) *
                try std.fmt.parseInt(usize, new_str[sw + 1 .. z - 1], 10));
        }
        new_str = new_str[z..];
    }
    return c;
}
