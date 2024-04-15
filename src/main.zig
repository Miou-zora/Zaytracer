const std = @import("std");
const zlm = @import("zlm");

pub fn main() void {
    std.debug.print("Hello World!", .{});
    const a = zlm.vec3(2, 1, 3);

    std.debug.print("{d}", .{a.x});
}
