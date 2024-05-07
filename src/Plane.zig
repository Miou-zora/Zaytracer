const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const zmath = @import("zmath");
const Vec = zmath.Vec;
const Material = @import("Material.zig").Material;
const Transform = @import("Transform.zig").Transform;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Plane = struct {
    const Self = @This();

    normal: Vec,
    origin: Pt3,
    material: Material,
    transform: ?Transform = null,

    pub fn deinit(self: *Self) void {
        self.transform.deinit();
    }

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        const denom = @reduce(.Add, self.normal * ray.direction);

        if (denom == 0.0) {
            return HitRecord.nil();
        }

        const t = @reduce(.Add, (self.origin - ray.origin) * self.normal) / denom;

        if (t < 0.0) {
            return HitRecord.nil();
        }

        const hit_point = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);
        return HitRecord{
            .hit = true,
            .intersection_point = hit_point,
            .normal = self.normal,
            .t = zmath.length3(hit_point - ray.origin)[0],
            .material = self.material,
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
