const Translation = @import("Translation.zig").Translation;
const Rotation = @import("Rotation.zig").Rotation;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Pt3 = @import("Pt3.zig").Pt3;

pub const Transformation = union(enum) {
    const Self = @This();
    translation: Translation,
    rotation: Rotation,

    pub fn ray_global_to_object(self: *const Self, ray: Ray, origin: *const Pt3) Ray {
        switch (self.*) {
            .translation => |value| {
                return value.ray_global_to_object(ray);
            },
            .rotation => |value| {
                return value.ray_global_to_object(ray, origin);
            },
        }
    }

    pub fn hitRecord_object_to_global(self: *const Self, ray: HitRecord, origin: *const Pt3) HitRecord {
        switch (self.*) {
            .translation => |value| {
                return value.hitRecord_object_to_global(ray);
            },
            .rotation => |value| {
                return value.hitRecord_object_to_global(ray, origin);
            },
        }
    }
};
