const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const Transform = @import("Transform.zig").Transform;
const Payload = @import("Payload.zig").Payload;
const zmath = @import("zmath");

pub const Sphere = struct {
    const Self = @This();

    origin: Pt3,
    radius: f32,
    material: Material,
    transform: ?Transform = null,

    pub fn hits(self: *const Self, ray: Ray, payload: *Payload) bool {
        const a: f32 = zmath.dot3(ray.direction, ray.direction)[0];
        const b: f32 = 2 * zmath.dot3(ray.direction, ray.origin - self.origin)[0];
        const c: f32 = zmath.lengthSq3(ray.origin - self.origin)[0] - self.radius * self.radius;
        const delta: f32 = b * b - 4 * a * c;
        if (delta < 0) {
            return false;
        }
        const t = (-b - @sqrt(delta)) / (2 * a);
        if (t < 0)
            return false;
        payload.intersection_point_obj = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);
        return true;
    }

    pub fn to_hitRecord(self: *const Self, obj_pt: *const Pt3) HitRecord {
        return HitRecord{
            .normal = obj_pt.* - self.origin,
            .intersection_point = obj_pt.*,
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
