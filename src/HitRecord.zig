const Vec3 = @import("Vec3.zig").Vec3;
const Pt3 = @import("Pt3.zig").Pt3;
const Material = @import("Material.zig").Material;
const zmath = @import("zmath");

pub const HitRecord = struct {
    const Self = @This();

    hit: bool,
    normal: Vec3,
    intersection_point: Pt3,
    t: f32,
    material: Material,

    pub inline fn nil() Self {
        return Self{
            .hit = false,
            .normal = zmath.f32x4s(0),
            .intersection_point = zmath.f32x4s(0),
            .t = 0,
            .material = Material.nil(),
        };
    }
};
