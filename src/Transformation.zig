const Translation = @import("Translation.zig").Translation;
const Rotation = @import("Rotation.zig").Rotation;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Cylinder = @import("Cylinder.zig").Cylinder;

pub const Transformation = struct {
    ray_global_to_object: *const fn (transformation: *const Transformation, ray: Ray) Ray,
    hitRecord_object_to_global: *const fn (transformation: *const Transformation, ray: HitRecord) HitRecord,

    pub fn global_to_object(transformation: *const Transformation, ray: Ray) Ray {
        return transformation.ray_global_to_object(transformation, ray);
    }

    pub fn object_to_global(transformation: *const Transformation, ray: HitRecord) HitRecord {
        return transformation.hitRecord_object_to_global(transformation, ray);
    }
};
