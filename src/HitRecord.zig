const Vec3 = @import("Vec3.zig").Vec3;
const Pt3 = @import("Pt3.zig").Pt3;
const Material = @import("Material.zig").Material;
const zmath = @import("zmath");

pub const HitRecord = struct {
    const Self = @This();

    normal: Vec3,
    intersection_point: Pt3,
    material: Material,

    pub fn nil() Self {
        return Self{
            .normal = zmath.f32x4s(0),
            .intersection_point = zmath.f32x4s(0),
            .material = Material.nil(),
        };
    }
};
