const Vec3 = @import("Vec3.zig").Vec3;
const Pt3 = @import("Pt3.zig").Pt3;

pub const HitRecord = struct {
    const Self = @This();

    hit: bool,
    normal: Vec3,
    intersection_point: Pt3,

    pub fn nil() Self {
        return Self{ .hit = false, .normal = Vec3.nil(), .intersection_point = Pt3.nil() };
    }
};
