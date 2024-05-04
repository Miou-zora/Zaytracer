const Vertex = @import("Vertex.zig").Vertex;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;
const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

pub const Triangle = struct {
    const Self = @This();

    va: Vertex,
    vb: Vertex,
    vc: Vertex,
    imageColor: [*]rl.Color,
    image: rl.Image,

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

        const texCordA: @Vector(2, f32) = .{ 1, 1 };
        const texCordB: @Vector(2, f32) = .{ 0, 1 };
        const texCordC: @Vector(2, f32) = .{ 0.5, 0 };
        const posInImage: @Vector(2, usize) = .{
            @as(usize, @intFromFloat((u * texCordA[0] + v * texCordB[0] + w * texCordC[0]) / (u + v + w) * @as(f32, @floatFromInt(self.image.width)))),
            @as(usize, @intFromFloat((u * texCordA[1] + v * texCordB[1] + w * texCordC[1]) / (u + v + w) * @as(f32, @floatFromInt(self.image.height)))),
        };
        const cInt_to_usize = @as(usize, @intCast(self.image.width));
        const color: rl.Color = self.imageColor[posInImage[1] * cInt_to_usize + posInImage[0]];
        const colorRGB = .{
            .r = @as(f32, @floatFromInt(color.r)),
            .g = @as(f32, @floatFromInt(color.g)),
            .b = @as(f32, @floatFromInt(color.b)),
        };

        const material: Material = .{
            .color = colorRGB,
            .reflective = 0.9,
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
