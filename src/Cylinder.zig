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
        const rx_minus_cx = ray.origin[0] - self.origin[0];
        const ry_minus_cy = ray.origin[1] - self.origin[1];
        const a = ray.direction[0] * ray.direction[0] + ray.direction[1] * ray.direction[1];
        const b = 2.0 * (ray.direction[0] * rx_minus_cx + ray.direction[1] * ry_minus_cy);
        const c = rx_minus_cx * rx_minus_cx + ry_minus_cy * ry_minus_cy - self.radius * self.radius;

        const delta = b * b - 4.0 * a * c;
        if (delta < 0.0 or a == 0.0) {
            return HitRecord.nil();
        } else if (delta == 0) {
            const t = -b / (2.0 * a);
            const intersection_point = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);
            if (t < 0.0) {
                return HitRecord.nil();
            } else {
                return HitRecord{
                    .hit = true,
                    .normal = zmath.f32x4(intersection_point[0] - self.origin[0], intersection_point[1] - self.origin[1], 0, 0),
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
            return HitRecord{
                .hit = true,
                .normal = zmath.f32x4(intersection_point[0] - self.origin[0], intersection_point[1] - self.origin[1], 0, 0),
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
