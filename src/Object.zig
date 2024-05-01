const Transformation = @import("Transformation.zig").Transformation;
const Plane = @import("Plane.zig").Plane;
const Sphere = @import("Sphere.zig").Sphere;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Triangle = @import("Triangle.zig").Triangle;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Object = struct {
    const Self = @This();

    pub const Shape = union(enum) {
        plane: Plane,
        sphere: Sphere,
        cylinder: Cylinder,
        triangle: Triangle,
    };

    shape: Shape,
    transform: ?Transformation,
    // maybe material

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        switch (self.shape) {
            Shape.plane => {
                return self.shape.plane.hits(ray);
            },
            Shape.sphere => {
                return self.shape.sphere.hits(ray);
            },
            Shape.cylinder => {
                return self.shape.cylinder.hits(ray);
            },
            Shape.triangle => {
                return self.shape.triangle.hits(ray);
            },
        }
    }

    pub fn getOrigin(self: *const Self) Vec3 {
        switch (self.shape) {
            Shape.plane => {
                return self.shape.plane.origin;
            },
            Shape.sphere => {
                return self.shape.sphere.origin;
            },
            Shape.cylinder => {
                return self.shape.cylinder.origin;
            },
            else => {
                @panic("getOrigin not implemented for others shapes");
            },
        }
    }
};

test {
    @import("std").testing.refAllDecls(@This());
}
