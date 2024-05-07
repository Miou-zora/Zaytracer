const std = @import("std");
const Pt3 = @import("Pt3.zig").Pt3;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Rect3 = struct {
    const Self = @This();

    origin: Pt3,
    top: Vec3,
    left: Vec3,

    pub fn pointAt(self: *const Self, x: f32, y: f32) Pt3 {
        return self.origin + self.top * @as(Vec3, @splat(y)) + self.left * @as(Vec3, @splat(x));
    }
};

test {
    std.testing.refAllDecls(@This());
}
