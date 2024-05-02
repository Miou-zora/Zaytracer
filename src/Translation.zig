const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Translation = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    pub inline fn ray_global_to_object(self: *const Self, ray: *const Ray) Ray {
        return Ray{
            .origin = ray.origin.subVec3(Vec3{ .x = self.x, .y = self.y, .z = self.z }),
            .direction = ray.direction,
        };
    }

    pub inline fn hitRecord_object_to_global(self: *const Self, ray: HitRecord) HitRecord {
        return HitRecord{
            .hit = ray.hit,
            .intersection_point = ray.intersection_point.addVec3(Vec3{ .x = self.x, .y = self.y, .z = self.z }),
            .normal = ray.normal,
            .t = ray.t,
            .material = ray.material,
        };
    }
};
