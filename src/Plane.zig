const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const Transformation = @import("Transformation.zig").Transformation;
const IObject = @import("IObject.zig").IObject;

pub const Plane = struct {
    const Self = @This();

    normal: Vec3,
    origin: Pt3,
    material: Material,
    transform: ?*const Transformation,

    iObject: IObject,

    pub fn init(normal: Vec3, origin: Pt3, material: Material, transform: ?*const Transformation) Self {
        return Self{
            .normal = normal,
            .origin = origin,
            .material = material,
            .transform = transform,
            .iObject = .{
                .hitsFn = &hits,
                .getTransformFn = &getTransform,
                .getOriginFn = &getOrigin,
            },
        };
    }

    pub fn getTransform(iObject: *const IObject) ?*const Transformation {
        const self: *const Plane = @fieldParentPtr("iObject", iObject);
        return self.transform;
    }

    pub fn getOrigin(iObject: *const IObject) Pt3 {
        const self: *const Plane = @fieldParentPtr("iObject", iObject);
        return self.origin;
    }

    pub fn hits(iObject: *const IObject, ray: Ray) HitRecord {
        const self: *const Plane = @fieldParentPtr("iObject", iObject);
        const denom = self.normal.dot(ray.direction);

        if (denom == 0.0) {
            return HitRecord.nil();
        }

        const t = (self.origin.subVec3(ray.origin)).dot(self.normal) / denom;

        if (t < 0.0) {
            return HitRecord.nil();
        }

        const hit_point = ray.at(t);
        return HitRecord{
            .hit = true,
            .intersection_point = hit_point,
            .normal = self.normal,
            .t = t,
            .material = self.material,
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
