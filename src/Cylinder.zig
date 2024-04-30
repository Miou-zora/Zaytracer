const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const Transformation = @import("Transformation.zig").Transformation;
const IObject = @import("IObject.zig").IObject;

pub const Cylinder = struct {
    const Self = @This();

    radius: f32,
    origin: Pt3,
    material: Material,
    transform: ?*const Transformation,

    iObject: IObject,

    pub fn init(radius: f32, origin: Pt3, material: Material, transform: ?*const Transformation) Self {
        return Self{
            .radius = radius,
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
        const self: *const Cylinder = @fieldParentPtr("iObject", iObject);
        return self.transform;
    }

    pub fn getOrigin(iObject: *const IObject) Pt3 {
        const self: *const Cylinder = @fieldParentPtr("iObject", iObject);
        return self.origin;
    }

    pub fn hits(iObject: *const IObject, ray: Ray) HitRecord {
        const self: *const Cylinder = @fieldParentPtr("iObject", iObject);
        const rx_minus_cx = ray.origin.x - self.origin.x;
        const ry_minus_cy = ray.origin.y - self.origin.y;
        const a = ray.direction.x * ray.direction.x + ray.direction.y * ray.direction.y;
        const b = 2.0 * (ray.direction.x * rx_minus_cx + ray.direction.y * ry_minus_cy);
        const c = rx_minus_cx * rx_minus_cx + ry_minus_cy * ry_minus_cy - self.radius * self.radius;

        const delta = b * b - 4.0 * a * c;
        if (delta < 0.0 or a == 0.0) {
            return HitRecord.nil();
        } else if (delta == 0) {
            const t = -b / (2.0 * a);
            const intersection_point = ray.origin.addVec3(ray.direction.mulf32(t));
            if (t < 0.0) {
                return HitRecord.nil();
            } else {
                return HitRecord{
                    .hit = true,
                    .normal = Vec3{ .x = intersection_point.x - self.origin.x, .y = intersection_point.y - self.origin.y, .z = 0 },
                    .intersection_point = intersection_point,
                    .t = t,
                    .material = self.material,
                };
            }
        } else {
            const t1 = (-b + @sqrt(delta)) / (2.0 * a);
            const t2 = (-b - @sqrt(delta)) / (2.0 * a);
            if (t1 < 0 and t2 < 0) {
                return HitRecord.nil();
            }
            const t = if (t1 < t2 and t1 > 0) t1 else t2;
            const intersection_point = ray.origin.addVec3(ray.direction.mulf32(t));
            return HitRecord{
                .hit = true,
                .normal = Vec3{ .x = intersection_point.x - self.origin.x, .y = intersection_point.y - self.origin.y, .z = 0 },
                .intersection_point = intersection_point,
                .t = t,
                .material = self.material,
            };
        }
    }
};

test "hit" {
    const cylinder = Cylinder{
        .radius = 1.0,
        .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = Pt3{ .x = 0.0, .y = 2.0, .z = 0.0 },
        .direction = Vec3{ .x = 0.0, .y = -1.0, .z = 0.0 },
    };
    const hit_record = cylinder.hits(ray);
    try std.testing.expect(hit_record.hit);
    try std.testing.expect(hit_record.intersection_point.x == 0.0);
    try std.testing.expect(hit_record.intersection_point.y == 1.0);
    try std.testing.expect(hit_record.intersection_point.z == 0.0);
    try std.testing.expect(hit_record.normal.x == 0.0);
    try std.testing.expect(hit_record.normal.y == 1.0);
    try std.testing.expect(hit_record.normal.z == 0.0);
}

test "dontHit" {
    const cylinder = Cylinder{
        .radius = 1.0,
        .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = Pt3{ .x = 1.0, .y = 1.0, .z = 0.0 },
        .direction = Vec3{ .x = 1.0, .y = 1.0, .z = 0.0 },
    };
    const hit_record = cylinder.hits(ray);
    try std.testing.expect(!hit_record.hit);
}

test "limit" {
    const cylinder = Cylinder{
        .radius = 1.0,
        .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 },
        .material = Material.nil(),
        .transform = null,
    };
    const ray = Ray{
        .origin = Pt3{ .x = 0.0, .y = 2.0, .z = 0.0 },
        .direction = Vec3{ .x = 0.0, .y = -1.0, .z = 0.0 },
    };
    const hit_record = cylinder.hits(ray);
    try std.testing.expect(hit_record.hit);
    try std.testing.expect(hit_record.intersection_point.x == 0.0);
    try std.testing.expect(hit_record.intersection_point.y == 1.0);
    try std.testing.expect(hit_record.intersection_point.z == 0.0);
    try std.testing.expect(hit_record.normal.x == 0.0);
    try std.testing.expect(hit_record.normal.y == 1.0);
    try std.testing.expect(hit_record.normal.z == 0.0);
}

test {
    std.testing.refAllDecls(@This());
}
