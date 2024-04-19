const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");

pub const Sphere = struct {
    const Self = @This();

    center: Pt3,
    radius: f32,

    pub fn hits(self: *const Self, ray: Ray) bool {
        const a: f32 =
            std.math.pow(f32, ray.direction.x, 2) +
            std.math.pow(f32, ray.direction.y, 2) +
            std.math.pow(f32, ray.direction.z, 2);
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
        return !(delta < 0);
    }
};

test "hit" {
    const sphere = Sphere{
        .center = Pt3{ .x = 0, .y = 0, .z = 0 },
        .radius = 1,
    };
    const ray = Ray{
        .origin = Pt3{ .x = 0, .y = 0, .z = 0 },
        .direction = Pt3{ .x = 0, .y = 0, .z = 1 },
    };

    const hit = sphere.hits(ray);
    try std.testing.expect(hit);
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
    try std.testing.expect(!hit);
}

test "limit" {
    const sphere = Sphere{
        .center = Pt3{ .x = 0, .y = 0, .z = 0 },
        .radius = 1,
    };
    const ray = Ray{
        .origin = Pt3{ .x = 0, .y = -1, .z = 0 },
        .direction = Pt3{ .x = 0, .y = 0, .z = 1 },
    };

    const hit = sphere.hits(ray);
    try std.testing.expect(hit);
}

test {
    std.testing.refAllDecls(@This());
}
