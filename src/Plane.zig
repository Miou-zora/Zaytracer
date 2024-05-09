const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const zmath = @import("zmath");
const Vec = zmath.Vec;
const Material = @import("Material.zig").Material;
const Transform = @import("Transform.zig").Transform;
const Vec3 = @import("Vec3.zig").Vec3;
const Payload = @import("Payload.zig").Payload;

pub const Plane = struct {
    const Self = @This();

    normal: Vec,
    origin: Pt3,
    material: Material,
    transform: ?Transform = null,

    pub fn deinit(self: *Self) void {
        self.transform.deinit();
    }

    pub fn hits(self: *const Self, ray: Ray, payload: *Payload) bool {
        const denom: Vec3 = zmath.dot3(self.normal, ray.direction);

        if (denom[0] == 0.0) {
            return false;
        }

        const t = zmath.dot3(self.origin - ray.origin, self.normal) / denom;

        if (t[0] < 0.0) {
            return false;
        }

        const hit_point = zmath.mulAdd(ray.direction, t, ray.origin);
        payload.intersection_point_obj = hit_point;
        return true;
    }

    pub fn to_hitRecord(self: *const Self, obj_pt: Pt3) HitRecord {
        return HitRecord{
            .intersection_point = obj_pt,
            .normal = self.normal,
            .material = self.material,
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
