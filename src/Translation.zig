const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Transformation = @import("Transformation.zig").Transformation;

pub const Translation = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    interface: Transformation,

    pub fn init(x: f32, y: f32, z: f32) Self {
        return Self{
            .x = x,
            .y = y,
            .z = z,
            .interface = .{
                .ray_global_to_object = &ray_global_to_object,
                .hitRecord_object_to_global = &hitRecord_object_to_global,
            },
        };
    }

    pub fn ray_global_to_object(transformation: *const Transformation, ray: Ray) Ray {
        const self: *const Translation = @fieldParentPtr("interface", transformation);
        return Ray{
            .origin = ray.origin.subVec3(Vec3{ .x = self.x, .y = self.y, .z = self.z }),
            .direction = ray.direction,
        };
    }

    pub fn hitRecord_object_to_global(transformation: *const Transformation, ray: HitRecord) HitRecord {
        const self: *const Translation = @fieldParentPtr("interface", transformation);
        return HitRecord{
            .hit = ray.hit,
            .intersection_point = ray.intersection_point.addVec3(Vec3{ .x = self.x, .y = self.y, .z = self.z }),
            .normal = ray.normal,
            .t = ray.t,
            .material = ray.material,
        };
    }
};
