const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Sphere = struct {
    const Self = @This();

    center: Pt3,
    radius: f32,

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        const a: f32 = ray.direction.dot(ray.direction);
        const b: f32 =
            2 * (ray.direction.x * (ray.origin.x - self.center.x) +
            ray.direction.y * (ray.origin.y - self.center.y) +
            ray.direction.z * (ray.origin.z - self.center.z));
        const c: f32 =
            std.math.pow(f32, (ray.origin.x - self.center.x), 2) +
            std.math.pow(f32, (ray.origin.y - self.center.y), 2) +
            std.math.pow(f32, (ray.origin.z - self.center.z), 2) -
            std.math.pow(f32, self.radius, 2);
        const delta: f32 = std.math.pow(f32, b, 2) - 4 * a * c;
        if (delta < 0) {
            return HitRecord{ .hit = false, .normal = Vec3.nil(), .intersection_point = Vec3.nil() };
        } else if (delta == 0) {
            const t = -b / (2 * a);
            const intersection_point = ray.origin.addVec3(ray.direction.mulf32(t));
            const distance = ray.origin.distance(intersection_point);
            if (distance < 0) {
                return HitRecord{ .hit = false, .normal = Vec3.nil(), .intersection_point = Vec3.nil() };
            } else {
                return HitRecord{ .hit = true, .normal = intersection_point.subVec3(self.center), .intersection_point = intersection_point };
            }
        } else {
            const t1 = (-b + std.math.sqrt(delta)) / (2 * a);
            const t2 = (-b - std.math.sqrt(delta)) / (2 * a);
            if (t1 < 0 and t2 < 0) {
                return HitRecord{ .hit = false, .normal = Vec3.nil(), .intersection_point = Vec3.nil() };
            }
            const t = if (@fabs(t1) < @fabs(t2)) t1 else t2;
            const intersection_point = ray.origin.addVec3(ray.direction.mulf32(t));
            const distance = ray.origin.distance(intersection_point);
            if (distance < 0) {
                return HitRecord{ .hit = false, .normal = Vec3.nil(), .intersection_point = Vec3.nil() };
            } else {
                return HitRecord{ .hit = true, .normal = intersection_point.subVec3(self.center), .intersection_point = intersection_point };
            }
        }
    }
};

test "hit" {
    const sphere = Sphere{
        .center = Pt3{ .x = 0, .y = 0, .z = 0 },
        .radius = 1,
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
        .center = Pt3{ .x = 100, .y = 100, .z = 100 },
        .radius = 1,
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
        .center = Pt3{ .x = 0, .y = 0, .z = 0 },
        .radius = 1,
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
