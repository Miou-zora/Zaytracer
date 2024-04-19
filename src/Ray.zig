const std = @import("std");
pub const Ray = struct {
    const Self = @This();

    origin: @import("Pt3.zig").Pt3,
    direction: @import("Vec3.zig").Vec3,
};

test {
    std.testing.refAllDecls(@This());
}
