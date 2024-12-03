const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const file_contents = try std.fs.cwd().readFileAlloc(allocator, "example.txt", 1024 * 1024);
    defer allocator.free(file_contents);

    var p: usize = 0;
    var f: usize = 0;
    p += try matches(file_contents);
    f += try culprit(file_contents);
    print("disabled: {d}\n", .{f});
    print("all: {d}\n", .{p});
    print("enabled: {d}\n", .{p - f});
}
pub fn culprit(str: []const u8) !usize {
    var c: usize = 0;
    var new_str = str;
    while (std.mem.indexOf(u8, new_str, "don't()")) |i| {
        var k = std.mem.indexOf(u8, new_str[i..], "do()");
        if (k == null) {
            k = new_str[i..].len;
        }
        c += try matches(new_str[i .. i + k.?]);
        new_str = new_str[i + k.? ..];
    }
    return c;
}

pub fn matches(str: []const u8) !usize {
    var c: usize = 0;
    var new_str = str;
    while (std.mem.indexOf(u8, new_str, "mul(")) |i| {
        var l: usize = 0;
        var r: usize = 0;
        var sw: usize = 0;
        var z: usize = 0;
        for (i + 4..new_str.len) |j| {
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
