const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const std = @import("std");
const Transformation = @import("Transformation.zig");

pub const Translation = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    pub fn init(alloc: std.mem.Allocator) !*Self {
        return try alloc.create(Self);
    }

    pub fn transform(self: *const Self) Transformation.Transformation {
        return Transformation.Transformation.init(self);
    }

    pub fn ray_global_to_object(self: *const Self, ray: Ray, origin: Vec3) Ray {
        comptime {
            _ = origin;
        }
        return Ray{
            .origin = ray.origin.subVec3(Vec3{ .x = self.x, .y = self.y, .z = self.z }),
            .direction = ray.direction,
        };
    }

    pub fn hitRecord_object_to_global(self: *const Self, ray: HitRecord, origin: Vec3) HitRecord {
        comptime {
            _ = origin;
        }
        return HitRecord{
            .hit = ray.hit,
            .intersection_point = ray.intersection_point.addVec3(Vec3{ .x = self.x, .y = self.y, .z = self.z }),
            .normal = ray.normal,
            .t = ray.t,
            .material = ray.material,
        };
    }
};
