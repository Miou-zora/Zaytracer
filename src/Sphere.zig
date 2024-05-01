const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const Transformation = @import("Transformation.zig").Transformation;

pub const Sphere = struct {
    const Self = @This();

    origin: Pt3,
    radius: f32,
    material: Material,
    transform: ?Transformation,

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        const a: f32 = ray.direction.dot(ray.direction);
        const b: f32 =
            2 * (ray.direction.x * (ray.origin.x - self.origin.x) +
            ray.direction.y * (ray.origin.y - self.origin.y) +
            ray.direction.z * (ray.origin.z - self.origin.z));
        const ro_minus_origin = ray.origin.subVec3(self.origin);
        const c: f32 = ro_minus_origin.mulVec3(ro_minus_origin).sum() - self.radius * self.radius; // Precalculate r*r
        const delta: f32 = b * b - 4 * a * c;
        if (delta < 0) {
            return HitRecord.nil();
        } else if (delta == 0) {
            const t = -b / (2 * a);
            const intersection_point = ray.origin.addVec3(ray.direction.mulf32(t));
            if (t < 0) {
                return HitRecord.nil();
            } else {
                return HitRecord{
                    .hit = true,
                    .normal = intersection_point.subVec3(self.origin),
                    .intersection_point = intersection_point,
                    .t = intersection_point.distance(ray.origin),
                    .material = self.material,
                };
            }
        } else {
            const t1 = (-b + @sqrt(delta)) / (2 * a);
            const t2 = (-b - @sqrt(delta)) / (2 * a);
            if (t1 < 0 and t2 < 0) {
                return HitRecord.nil();
            }
            const t = if (t1 < t2 and t1 > 0) t1 else t2;
            const intersection_point = ray.origin.addVec3(ray.direction.mulf32(t));
            if (t < 0) {
                return HitRecord.nil();
            } else {
                return HitRecord{
                    .hit = true,
                    .normal = intersection_point.subVec3(self.origin),
                    .intersection_point = intersection_point,
                    .t = intersection_point.distance(ray.origin),
                    .material = self.material,
                };
            }
        }
    }
};

test "hit" {
    const sphere = Sphere{
        .origin = Pt3{ .x = 0, .y = 0, .z = 0 },
        .radius = 1,
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = Pt3{ .x = 0, .y = 0, .z = 2 },
        .direction = Pt3{ .x = 0, .y = 0, .z = -1 },
    };

    const hit = sphere.hits(ray);
    try std.testing.expect(hit.hit);
    try std.testing.expect(hit.intersection_point.x == 0);
    try std.testing.expect(hit.intersection_point.y == 0);
    try std.testing.expect(hit.intersection_point.z == 1);
    try std.testing.expect(hit.normal.x == 0);
    try std.testing.expect(hit.normal.y == 0);
    try std.testing.expect(hit.normal.z == 1);
}

test "dontHit" {
    const sphere = Sphere{
        .origin = Pt3{ .x = 100, .y = 100, .z = 100 },
        .radius = 1,
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = Pt3{ .x = 0, .y = 0, .z = 0 },
        .direction = Pt3{ .x = 0, .y = 0, .z = -1 },
    };

    const hit = sphere.hits(ray);
    try std.testing.expect(!hit.hit);
}

test "limit" {
    const sphere = Sphere{
        .origin = Pt3{ .x = 0, .y = 0, .z = 0 },
        .radius = 1,
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = Pt3{ .x = 0, .y = -1, .z = -1 },
        .direction = Pt3{ .x = 0, .y = 0, .z = 1 },
    };

    const hit = sphere.hits(ray);
    try std.testing.expect(hit.hit);
    try std.testing.expect(hit.intersection_point.x == 0);
    try std.testing.expect(hit.intersection_point.y == -1);
    try std.testing.expect(hit.intersection_point.z == 0);
    try std.testing.expect(hit.normal.x == 0);
    try std.testing.expect(hit.normal.y == -1);
    try std.testing.expect(hit.normal.z == 0);
}

test {
    std.testing.refAllDecls(@This());
}
