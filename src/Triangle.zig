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
        const bSuba = b - a;
        const cSuba = c - a;

        const normal = zmath.normalize3(zmath.cross3(bSuba, cSuba));
        const t: f32 = @reduce(.Add, (normal * (a - ray.origin))) / @reduce(.Add, normal * ray.direction);

        if (t < 0) {
            return HitRecord.nil();
        }

        const hit_point = zmath.mulAdd(ray.direction, @as(Vec3, @splat(t)), ray.origin);

        const aSubc = a - c;
        const cSubb = c - b;

        const u = @reduce(.Add, zmath.cross3(bSuba, hit_point - a) * normal);
        const v = @reduce(.Add, zmath.cross3(cSubb, hit_point - b) * normal);
        const w = @reduce(.Add, zmath.cross3(aSubc, hit_point - c) * normal);

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
            .t = zmath.length3(hit_point - ray.origin)[0],
            .intersection_point = hit_point,
            .normal = normal,
            .material = material,
        };
    }
};
