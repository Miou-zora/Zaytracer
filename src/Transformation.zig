const Translation = @import("Translation.zig").Translation;
const Rotation = @import("Rotation.zig").Rotation;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Plane = @import("Plane.zig").Plane;

pub const Transformation = union(enum) {
    translation: Translation,
    rotation: Rotation,
};

pub fn ray_global_to_object(ray: Ray, transformation: Transformation, object: Plane) Ray {
    switch (transformation) {
        Transformation.translation => |value| {
            return value.ray_global_to_object(ray);
        },
        Transformation.rotation => |value| {
            return value.ray_global_to_object(ray, object);
        },
    }
}

pub fn hitRecord_object_to_global(ray: HitRecord, transformation: Transformation, object: Plane) HitRecord {
    switch (transformation) {
        Transformation.translation => |value| {
            return value.hitRecord_object_to_global(ray);
        },
        Transformation.rotation => |value| {
            return value.hitRecord_object_to_global(ray, object);
        },
    }
}
