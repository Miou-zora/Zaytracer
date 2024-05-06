const Vertex = @import("Vertex.zig").Vertex;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const std = @import("std");
const Image = @import("Scene.zig").Image;
const rl = @cImport({
    @cInclude("raylib.h");
});
const zmath = @import("zmath");
const Pt3 = @import("Pt3.zig").Pt3;

pub const Transform = struct {
    const Self = @This();

    mat: zmath.Mat = zmath.identity(),
    inv_mat: zmath.Mat = zmath.identity(),
    inv_trans_mat: zmath.Mat = zmath.identity(),

    pub fn translate(self: *Self, x: f32, y: f32, z: f32) void {
        self.mat = zmath.mul(zmath.translation(-x, -y, -z), self.mat);
        // std.debug.print("rgto: {any}\n", .{self.mat});
        self.inv_mat = zmath.inverse(self.mat);
        // std.debug.print("hrotg: {any}\n", .{self.inv_mat});
        self.inv_trans_mat = zmath.transpose(zmath.inverse(self.mat));
    }

    pub fn ray_global_to_object(self: *const Self, ray: *const Ray) Ray {
        // Transform the ray's origin
        // std.debug.print("rgto: {any}\n", .{self.mat});
        const zmath_origin = zmath.F32x4{ ray.origin.x, ray.origin.y, ray.origin.z, 1.0 };
        const transformed_origin = zmath.mul(zmath_origin, self.mat);
        // std.debug.print("Matrix: {any}\nrgtobefore: {any}\nrgto: {any}\n", .{ self.mat, zmath_origin, transformed_origin });

        // Transform the ray's direction (normal)
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
        // std.debug.print("hrotg: {any}\n", .{self.inv_mat});
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

pub const Triangle = struct {
    const Self = @This();

    va: Vertex,
    vb: Vertex,
    vc: Vertex,
    text: *const Image,
    transform: ?Transform = null,

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        // TODO: add bvh + compute this only one time
        const a = self.va.position;
        const b = self.vb.position;
        const c = self.vc.position;
        const bSuba = b.subVec3(a);
        const cSuba = c.subVec3(a);

        const normal = bSuba.cross(cSuba).normalized();
        const t = normal.dot(a.subVec3(ray.origin)) / normal.dot(ray.direction);

        if (t < 0) {
            return HitRecord.nil();
        }

        const hit_point = ray.at(t);

        const aSubc = a.subVec3(c);
        const cSubb = c.subVec3(b);

        const u = bSuba.cross(hit_point.subVec3(a)).dot(normal);
        const v = cSubb.cross(hit_point.subVec3(b)).dot(normal);
        const w = aSubc.cross(hit_point.subVec3(c)).dot(normal);

        if (u < 0 or v < 0 or w < 0) {
            return HitRecord.nil();
        }

        const posInImage: @Vector(2, usize) = .{
            @as(usize, @intFromFloat((u * self.va.texCoord[0] + v * self.vb.texCoord[0] + w * self.vc.texCoord[0]) / (u + v + w) * @as(f32, @floatFromInt(self.text.rlImage.width)))),
            @as(usize, @intFromFloat((u * self.va.texCoord[1] + v * self.vb.texCoord[1] + w * self.vc.texCoord[1]) / (u + v + w) * @as(f32, @floatFromInt(self.text.rlImage.height)))),
        };
        const cInt_to_usize = @as(usize, @intCast(self.text.rlImage.width));
        const color: rl.Color = self.text.rlColors[posInImage[1] * cInt_to_usize + posInImage[0]];
        const colorRGB = .{
            .r = @as(f32, @floatFromInt(color.r)),
            .g = @as(f32, @floatFromInt(color.g)),
            .b = @as(f32, @floatFromInt(color.b)),
        };

        const material: Material = .{
            .color = colorRGB,
            .reflective = 0.75,
            .specular = 0,
        };
        return HitRecord{
            .hit = true,
            .t = hit_point.distance(ray.origin),
            .intersection_point = hit_point,
            .normal = normal,
            .material = material,
        };
    }
};
