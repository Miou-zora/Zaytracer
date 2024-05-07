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
const Transform = @import("Transform.zig").Transform;

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
