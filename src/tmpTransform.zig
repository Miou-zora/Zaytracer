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
        const zmath_origin = zmath.F32x4{ ray.origin.x, ray.origin.y, ray.origin.z, 1.0 };
        const transformed_origin = zmath.mul(zmath_origin, self.mat);

        const zmath_direction = zmath.F32x4{ ray.direction.x, ray.direction.y, ray.direction.z, 0.0 };
        const transformed_direction = zmath.mul(zmath_direction, self.inv_trans_mat);

        return Ray{
            .origin = .{
                .x = transformed_origin[0],
                .y = transformed_origin[1],
                .z = transformed_origin[2],
            },
            .direction = .{
                .x = transformed_direction[0],
                .y = transformed_direction[1],
                .z = transformed_direction[2],
            },
        };
    }

    pub fn hitRecord_object_to_global(self: *const Self, ray: HitRecord) HitRecord {
        const intersection_point = zmath.F32x4{ ray.intersection_point.x, ray.intersection_point.y, ray.intersection_point.z, 1.0 };
        const transformed_intersection_point = zmath.mul(intersection_point, self.inv_mat);

        const normal = zmath.F32x4{ ray.normal.x, ray.normal.y, ray.normal.z, 0.0 };
        const transformed_normal = zmath.mul(normal, self.inv_mat);

        return HitRecord{
            .hit = ray.hit,
            .intersection_point = .{
                .x = transformed_intersection_point[0],
                .y = transformed_intersection_point[1],
                .z = transformed_intersection_point[2],
            },
            .normal = .{
                .x = transformed_normal[0],
                .y = transformed_normal[1],
                .z = transformed_normal[2],
            },
            .t = ray.t,
            .material = ray.material,
        };
    }
};
