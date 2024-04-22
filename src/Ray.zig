const std = @import("std");
const Pt3 = @import("Pt3.zig").Pt3;
const Vec3 = @import("Vec3.zig").Vec3;
pub const Ray = struct {
    const Self = @This();

    origin: Pt3,
    direction: Vec3,

    pub fn at(self: Self, t: f32) Pt3 {
        return self.origin.addVec3(self.direction.mulf32(t));
    }
};

test {
    std.testing.refAllDecls(@This());
}
