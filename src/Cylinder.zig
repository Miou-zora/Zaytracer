const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const zmath = @import("zmath");
const Transform = @import("Transform.zig").Transform;
const Payload = @import("Payload.zig").Payload;

pub const Cylinder = struct {
    const Self = @This();

    radius: f32,
    origin: Pt3,
    material: Material,
    transform: ?Transform = null,

    pub fn hits(self: *const Self, ray: Ray, payload: *Payload) bool {
        const r_minus_c = ray.origin - self.origin;
        const a = zmath.dot2(ray.direction, ray.direction)[0] * 2; // Good luck to understand this, I don't
        const b = zmath.dot2(ray.direction, r_minus_c)[0] * 4;
        const c = zmath.dot2(r_minus_c, r_minus_c)[0] * 2 - self.radius * self.radius;

        const delta = b * b - 4.0 * a * c;
        if (delta < 0.0 or a == 0.0) {
            return false;
        }
        const t = (-b - @sqrt(delta)) / (2.0 * a);
        if (t < 0)
            return false;
        const intersection_point = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);
        payload.intersection_point_obj = intersection_point;
        return true;
    }

    pub fn to_hitRecord(self: *const Self, obj_pt: Pt3) HitRecord {
        const normal = obj_pt - self.origin;
        return HitRecord{
            .normal = zmath.f32x4(normal[0], normal[1], 0, 0),
            .intersection_point = obj_pt,
            .material = self.material,
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
