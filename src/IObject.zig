const Translation = @import("Translation.zig").Translation;
const Rotation = @import("Rotation.zig").Rotation;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Vec3 = @import("Vec3.zig").Vec3;
const Transformation = @import("Transformation.zig").Transformation;

pub const IObject = struct {
    hitsFn: *const fn (self: *const IObject, ray: Ray) HitRecord,
    getTransformFn: *const fn (self: *const IObject) ?*const Transformation,
    getOriginFn: *const fn (self: *const IObject) Vec3,

    pub fn hits(self: *const IObject, ray: Ray) HitRecord {
        return self.hitsFn(self, ray);
    }

    pub fn getTransform(self: *const IObject) ?*const Transformation {
        return self.getTransformFn(self);
    }

    pub fn getOrigin(self: *const IObject) Vec3 {
        return self.getOriginFn(self);
    }
};
