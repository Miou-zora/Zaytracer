const Translation = @import("Translation.zig").Translation;
const Rotation = @import("Rotation.zig").Rotation;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Pt3 = @import("Pt3.zig").Pt3;

pub const Transformation = union(enum) {
    translation: Translation,
    rotation: Rotation,
};

pub fn ray_global_to_object(ray: Ray, transformation: Transformation, origin: Pt3) Ray {
    switch (transformation) {
        inline else => |t| {
            return t.ray_global_to_object(ray, origin);
        },
    }
}

pub fn hitRecord_object_to_global(ray: HitRecord, transformation: Transformation, origin: Pt3) HitRecord {
    switch (transformation) {
        inline else => |t| {
            return t.hitRecord_object_to_global(ray, origin);
        },
    }
}
