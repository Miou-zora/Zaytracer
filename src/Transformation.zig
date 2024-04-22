const Translation = @import("Translation.zig").Translation;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;

pub const Transformation = union(enum) {
    translation: Translation,
};

pub fn ray_global_to_object(ray: Ray, transformation: Transformation) Ray {
    switch (transformation) {
        Transformation.translation => |value| {
            return value.ray_global_to_object(ray);
        },
    }
}

pub fn hitRecord_object_to_global(ray: HitRecord, transformation: Transformation) HitRecord {
    switch (transformation) {
        Transformation.translation => |value| {
            return value.hitRecord_object_to_global(ray);
        },
    }
}
