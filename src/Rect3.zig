const Pt3 = @import("Pt3.zig").Pt3;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Rect3 = struct {
    const Self = @This();

    origin: Pt3,
    bottom: Vec3,
    left: Vec3,

    pub fn pointAt(self: *const Self, u: f32, v: f32) Pt3 {
        return self.origin.addVec3(self.bottom.mulf32(u)).addVec3(self.left.mulf32(v));
    }
};
