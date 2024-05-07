const zmath = @import("zmath");
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;

pub const Transform = struct {
    const Self = @This();

    mat: zmath.Mat = zmath.identity(),
    inv_mat: zmath.Mat = zmath.identity(),
    inv_trans_mat: zmath.Mat = zmath.identity(),

    pub fn translate(self: *Self, x: f32, y: f32, z: f32) void {
        self.mat = zmath.mul(self.mat, zmath.translation(-x, -y, -z));
        self.inv_mat = zmath.inverse(self.mat);
        self.inv_trans_mat = zmath.transpose(zmath.inverse(self.mat));
    }

    pub fn rotate(self: *Self, pitch: f32, yaw: f32, roll: f32) void {
        self.mat = zmath.mul(self.mat, zmath.matFromRollPitchYaw(-pitch, -yaw, -roll));
        self.inv_mat = zmath.inverse(self.mat);
        self.inv_trans_mat = zmath.transpose(zmath.inverse(self.mat));
    }

    pub fn ray_global_to_object(self: *const Self, ray: *const Ray) Ray {
        const transformed_origin = zmath.mul(zmath.f32x4(ray.origin[0], ray.origin[1], ray.origin[2], 1), self.mat);
        const transformed_direction = zmath.mul(zmath.f32x4(ray.direction[0], ray.direction[1], ray.direction[2], 0), self.mat);

        return Ray{
            .origin = transformed_origin,
            .direction = transformed_direction,
        };
    }

    pub fn hitRecord_object_to_global(self: *const Self, ray: HitRecord) HitRecord {
        // const transformed_intersection_point = zmath.mul(ray.intersection_point, self.inv_mat);
        // const transformed_normal = zmath.mul(ray.normal, self.inv_mat);
        const transformed_intersection_point = zmath.mul(zmath.f32x4(ray.intersection_point[0], ray.intersection_point[1], ray.intersection_point[2], 1), self.inv_mat);
        const transformed_normal = zmath.mul(zmath.f32x4(ray.normal[0], ray.normal[1], ray.normal[2], 0), self.inv_mat);

        return HitRecord{
            .hit = ray.hit,
            .intersection_point = transformed_intersection_point,
            .normal = transformed_normal,
            .t = ray.t,
            .material = ray.material,
        };
    }
};
