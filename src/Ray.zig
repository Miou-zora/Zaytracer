const std = @import("std");
const Pt3 = @import("Pt3.zig").Pt3;
const Vec3 = @import("Vec3.zig").Vec3;
pub const Ray = struct {
    const Self = @This();

    origin: Pt3,
    direction: Vec3,
};

test {
    std.testing.refAllDecls(@This());
}
