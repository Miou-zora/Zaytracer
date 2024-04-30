const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const Transformation = @import("Transformation.zig").Transformation;

pub const Plane = struct {
    const Self = @This();

    normal: Vec3,
    origin: Pt3,
    material: Material,
    transform: ?Transformation,

    pub fn deinit(self: *Self) void {
        self.transform.deinit();
    }

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        const denom = self.normal.dot(ray.direction);

        if (denom == 0.0) {
            return HitRecord.nil();
        }

        const t = (self.origin.subVec3(ray.origin)).dot(self.normal) / denom;

        if (t < 0.0) {
            return HitRecord.nil();
        }

        const hit_point = ray.at(t);
        return HitRecord{
            .hit = true,
            .intersection_point = hit_point,
            .normal = self.normal,
            .t = t,
            .material = self.material,
        };
    }
};

test "hit" {
    const plane = Plane{
        .normal = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .material = Material.nil(),
        .transform = null,
    };

    const ray = Ray{
        .origin = Pt3{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .direction = Vec3{ .x = 0.0, .y = -1.0, .z = 0.0 },
    };

    const hit_record = plane.hits(ray);

    try std.testing.expect(hit_record.hit);
    try std.testing.expect(hit_record.intersection_point.x == 0.0);
    try std.testing.expect(hit_record.intersection_point.y == 0.0);
    try std.testing.expect(hit_record.intersection_point.z == 0.0);
    try std.testing.expect(hit_record.normal.x == 0.0);
    try std.testing.expect(hit_record.normal.y == 1.0);
    try std.testing.expect(hit_record.normal.z == 0.0);
}

test "dontHit" {
    const plane = Plane{
        .normal = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .material = Material.nil(),
        .transform = null,
    };

    const ray = Ray{
        .origin = Pt3{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .direction = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
    };

    const hit_record = plane.hits(ray);

    try std.testing.expect(!hit_record.hit);
}

test "parallel" {
    const plane = Plane{
        .normal = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .material = Material.nil(),
        .transform = null,
    };

    const ray = Ray{
        .origin = Pt3{ .x = 0.0, .y = 1.0, .z = 0.0 },
        .direction = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
    };

    const hit_record = plane.hits(ray);

    try std.testing.expect(!hit_record.hit);
}

test {
    std.testing.refAllDecls(@This());
}
