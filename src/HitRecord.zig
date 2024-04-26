const Vec3 = @import("Vec3.zig").Vec3;
const Pt3 = @import("Pt3.zig").Pt3;
const Material = @import("Material.zig").Material;

pub const HitRecord = struct {
    const Self = @This();

    hit: bool,
    normal: Vec3,
    intersection_point: Pt3,
    t: f32,
    material: Material,

    pub fn nil() Self {
        return Self{
            .hit = false,
            .normal = Vec3.nil(),
            .intersection_point = Pt3.nil(),
            .t = 0,
            .material = Material.nil(),
        };
    }
};
