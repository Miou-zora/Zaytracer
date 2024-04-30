const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Cylinder = @import("Cylinder.zig").Cylinder;
const std = @import("std");
const Transformation = @import("Transformation.zig");

pub const Rotation = struct {
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
        var ray_in_object_space = Ray{
            .direction = ray.direction,
            .origin = ray.origin.subVec3(origin),
        };
        ray_in_object_space.direction.rotateX(self.x);
        ray_in_object_space.direction.rotateY(self.y);
        ray_in_object_space.direction.rotateZ(self.z);
        ray_in_object_space.origin.rotateX(self.x);
        ray_in_object_space.origin.rotateY(self.y);
        ray_in_object_space.origin.rotateZ(self.z);
        return Ray{
            .direction = ray_in_object_space.direction,
            .origin = ray_in_object_space.origin.addVec3(origin),
        };
    }

    pub fn hitRecord_object_to_global(self: *const Self, hitrecord: HitRecord, origin: Vec3) HitRecord {
        var hitrecord_in_object_space = HitRecord{
            .intersection_point = hitrecord.intersection_point.subVec3(origin),
            .normal = hitrecord.normal,
            .hit = hitrecord.hit,
            .t = hitrecord.t,
            .material = hitrecord.material,
        };
        hitrecord_in_object_space.normal.rotateZ(-self.z);
        hitrecord_in_object_space.normal.rotateY(-self.y);
        hitrecord_in_object_space.normal.rotateX(-self.x);
        hitrecord_in_object_space.intersection_point.rotateZ(-self.z);
        hitrecord_in_object_space.intersection_point.rotateY(-self.y);
        hitrecord_in_object_space.intersection_point.rotateX(-self.x);
        return HitRecord{
            .intersection_point = hitrecord_in_object_space.intersection_point.addVec3(origin),
            .normal = hitrecord_in_object_space.normal,
            .hit = hitrecord_in_object_space.hit,
            .t = hitrecord.t,
            .material = hitrecord.material,
        };
    }
};
