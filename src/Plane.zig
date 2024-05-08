const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const zmath = @import("zmath");
const Vec = zmath.Vec;
const Material = @import("Material.zig").Material;
const Transform = @import("Transform.zig").Transform;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Plane = struct {
    const Self = @This();

    normal: Vec,
    origin: Pt3,
    material: Material,
    transform: ?Transform = null,

    pub fn deinit(self: *Self) void {
        self.transform.deinit();
    }

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        const denom: f32 = zmath.dot3(self.normal, ray.direction)[0];

        if (denom == 0.0) {
            return HitRecord.nil();
        }

        const t: f32 = zmath.dot3(self.origin - ray.origin, self.normal)[0] / denom;

        if (t < 0.0) {
            return HitRecord.nil();
        }

        const hit_point = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);
        return HitRecord{
            .hit = true,
            .intersection_point = hit_point,
            .normal = self.normal,
            .t = zmath.length3(hit_point - ray.origin)[0],
            .material = self.material,
        };
    }
};

// TODO: fix these tests
// test "hit" {
//     const plane = Plane{
//         .normal = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
//         .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
//         .material = Material.nil(),
//         .transform = null,
//     };

//     const ray = Ray{
//         .origin = Pt3{ .x = 0.0, .y = 1.0, .z = 0.0 },
//         .direction = Vec3{ .x = 0.0, .y = -1.0, .z = 0.0 },
//     };

//     const hit_record = plane.hits(ray);

//     try std.testing.expect(hit_record.hit);
//     try std.testing.expect(hit_record.intersection_point.x == 0.0);
//     try std.testing.expect(hit_record.intersection_point.y == 0.0);
//     try std.testing.expect(hit_record.intersection_point.z == 0.0);
//     try std.testing.expect(hit_record.normal.x == 0.0);
//     try std.testing.expect(hit_record.normal.y == 1.0);
//     try std.testing.expect(hit_record.normal.z == 0.0);
// }

// test "dontHit" {
//     const plane = Plane{
//         .normal = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
//         .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
//         .material = Material.nil(),
//         .transform = null,
//     };

//     const ray = Ray{
//         .origin = Pt3{ .x = 0.0, .y = 1.0, .z = 0.0 },
//         .direction = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
//     };

//     const hit_record = plane.hits(ray);

//     try std.testing.expect(!hit_record.hit);
// }

// test "parallel" {
//     const plane = Plane{
//         .normal = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
//         .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
//         .material = Material.nil(),
//         .transform = null,
//     };

//     const ray = Ray{
//         .origin = Pt3{ .x = 0.0, .y = 1.0, .z = 0.0 },
//         .direction = Vec3{ .x = 0.0, .y = 1.0, .z = 0.0 },
//     };

//     const hit_record = plane.hits(ray);

//     try std.testing.expect(!hit_record.hit);
// }

test {
    std.testing.refAllDecls(@This());
}
