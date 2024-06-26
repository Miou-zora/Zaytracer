const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const Transform = @import("Transform.zig").Transform;
const zmath = @import("zmath");

pub const Sphere = struct {
    const Self = @This();

    origin: Pt3,
    radius: f32,
    material: Material,
    transform: ?Transform = null,

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        const a: f32 = zmath.dot3(ray.direction, ray.direction)[0];
        const b: f32 = 2 * zmath.dot3(ray.direction, ray.origin - self.origin)[0];
        const c: f32 = zmath.lengthSq3(ray.origin - self.origin)[0] - self.radius * self.radius;
        const delta: f32 = b * b - 4 * a * c;
        if (delta < 0) {
            return HitRecord.nil();
        }
        const t = (-b - @sqrt(delta)) / (2 * a);
        if (t < 0)
            return HitRecord.nil();
        const intersection_point = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);
        return HitRecord{
            .hit = true,
            .normal = intersection_point - self.origin,
            .intersection_point = intersection_point,
            .t = 0,
            .material = self.material,
        };
    }
};

test "hit" {
    const sphere = Sphere{
        .origin = zmath.f32x4(0, 0, 0, 1),
        .radius = 1,
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = zmath.f32x4(0, 0, 2, 1),
        .direction = zmath.f32x4(0, 0, -1, 0),
    };
    const hit = sphere.hits(ray);
    try std.testing.expect(hit.hit);
    try std.testing.expect(hit.intersection_point[0] == 0);
    try std.testing.expect(hit.intersection_point[1] == 0);
    try std.testing.expect(hit.intersection_point[2] == 1);
    try std.testing.expect(hit.normal[0] == 0);
    try std.testing.expect(hit.normal[1] == 0);
    try std.testing.expect(hit.normal[2] == 1);
}

test "dontHit" {
    const sphere = Sphere{
        .origin = zmath.f32x4(100, 100, 100, 1),
        .radius = 1,
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = zmath.f32x4(0, 0, 0, 1),
        .direction = zmath.f32x4(0, 0, -1, 0),
    };

    const hit = sphere.hits(ray);
    try std.testing.expect(!hit.hit);
}

test "limit" {
    const sphere = Sphere{
        .origin = zmath.f32x4(0, 0, 0, 1),
        .radius = 1,
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = zmath.f32x4(0, -1, -1, 1),
        .direction = zmath.f32x4(0, 0, 1, 0),
    };

    const hit = sphere.hits(ray);
    try std.testing.expect(hit.hit);
    try std.testing.expect(hit.intersection_point[0] == 0);
    try std.testing.expect(hit.intersection_point[1] == -1);
    try std.testing.expect(hit.intersection_point[2] == 0);
    try std.testing.expect(hit.normal[0] == 0);
    try std.testing.expect(hit.normal[1] == -1);
    try std.testing.expect(hit.normal[2] == 0);
}

test {
    std.testing.refAllDecls(@This());
}
