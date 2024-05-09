const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const zmath = @import("zmath");
const Transform = @import("Transform.zig").Transform;

pub const Cylinder = struct {
    const Self = @This();

    radius: f32,
    origin: Pt3,
    material: Material,
    transform: ?Transform = null,

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        const r_minus_c = ray.origin - self.origin;
        const a = zmath.dot2(ray.direction, ray.direction)[0] * 2; // Good luck to understand this, I don't
        const b = zmath.dot2(ray.direction, r_minus_c)[0] * 4;
        const c = zmath.dot2(r_minus_c, r_minus_c)[0] * 2 - self.radius * self.radius;

        const delta = b * b - 4.0 * a * c;
        if (delta < 0.0 or a == 0.0) {
            return HitRecord.nil();
        } else if (delta == 0) {
            const t = -b / (2.0 * a);
            const intersection_point = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);
            if (t < 0.0) {
                return HitRecord.nil();
            } else {
                const normal = intersection_point - self.origin;
                return HitRecord{
                    .hit = true,
                    .normal = zmath.f32x4(normal[0], normal[1], 0, 0),
                    .intersection_point = intersection_point,
                    .t = zmath.length3(intersection_point - ray.origin)[0],
                    .material = self.material,
                };
            }
        } else {
            const t1 = (-b + @sqrt(delta)) / (2.0 * a);
            const t2 = (-b - @sqrt(delta)) / (2.0 * a);
            if (t1 < 0 and t2 < 0) {
                return HitRecord.nil();
            }
            const t = if (t1 < t2 and t1 > 0) t1 else t2;
            const intersection_point = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);
            const normal = intersection_point - self.origin;
            return HitRecord{
                .hit = true,
                .normal = zmath.f32x4(normal[0], normal[1], 0, 0),
                .intersection_point = intersection_point,
                .t = zmath.length3(intersection_point - ray.origin)[0],
                .material = self.material,
            };
        }
    }
};

test {
    std.testing.refAllDecls(@This());
}
