const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const zmath = @import("zmath");

pub const Translation = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    pub inline fn ray_global_to_object(self: *const Self, ray: *const Ray) Ray {
        const matrix = zmath.matFromArr(.{
            1.0, 0.0, 0.0, -self.x,
            0.0, 1.0, 0.0, -self.y,
            0.0, 0.0, 1.0, -self.z,
            0.0, 0.0, 0.0, 1.0,
        });

        // Transform the ray's origin
        const origin = zmath.F32x4{ ray.origin.x, ray.origin.y, ray.origin.z, 1.0 };
        const transformed_origin = zmath.mul(matrix, origin);

        // Construct the inverse transpose of the transformation matrix
        const inv_trans_matrix = zmath.inverse(zmath.transpose(matrix));

        // Transform the ray's direction (normal)
        const direction = zmath.F32x4{ ray.direction.x, ray.direction.y, ray.direction.z, 0.0 };
        const transformed_direction = zmath.mul(inv_trans_matrix, direction);

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

    pub inline fn hitRecord_object_to_global(self: *const Self, ray: *const HitRecord) HitRecord {
        const matrix = zmath.matFromArr(.{
            1.0, 0.0, 0.0, self.x,
            0.0, 1.0, 0.0, self.y,
            0.0, 0.0, 1.0, self.z,
            0.0, 0.0, 0.0, 1.0,
        });
        const intersection_point = zmath.F32x4{ ray.intersection_point.x, ray.intersection_point.y, ray.intersection_point.z, 1.0 };
        const transformed_intersection_point = zmath.mul(matrix, intersection_point);
        const normal = zmath.F32x4{ ray.normal.x, ray.normal.y, ray.normal.z, 0.0 };
        const transformed_normal = zmath.mul(matrix, normal);
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
        // return HitRecord{
        //     .hit = ray.hit,
        //     .intersection_point = ray.intersection_point.addVec3(Vec3{ .x = self.x, .y = self.y, .z = self.z }),
        //     .normal = ray.normal,
        //     .t = ray.t,
        //     .material = ray.material,
        // };
    }
};
