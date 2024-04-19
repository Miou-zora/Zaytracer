const Vec3 = @import("Vec3.zig").Vec3;
const Pt3 = @import("Pt3.zig").Pt3;

pub const HitRecord = struct {
    hit: bool,
    normal: Vec3,
    intersection_point: Pt3,
};
