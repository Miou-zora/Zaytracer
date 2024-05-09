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
const ColorRGB = @import("ColorRGB.zig").ColorRGB;

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
        const t = zmath.dot3(normal, (a - ray.origin)) / zmath.dot3(normal, ray.direction);

        if (t[0] < 0) {
            return HitRecord.nil();
        }

        const hit_point = zmath.mulAdd(ray.direction, t, ray.origin);

        const aSubc = a - c;
        const cSubb = c - b;

        const u = zmath.dot3(zmath.cross3(bSuba, hit_point - a), normal)[0];
        const v = zmath.dot3(zmath.cross3(cSubb, hit_point - b), normal)[0];
        const w = zmath.dot3(zmath.cross3(aSubc, hit_point - c), normal)[0];

        if (u < 0 or v < 0 or w < 0) {
            return HitRecord.nil();
        }
        const barycentric = zmath.f32x4(u, v, w, 0);
        const texCoord1 = zmath.f32x4(self.va.texCoord[0], self.vb.texCoord[0], self.vc.texCoord[0], 0); // Is it efficient to store this in tmp const?
        const texCoord2 = zmath.f32x4(self.va.texCoord[1], self.vb.texCoord[1], self.vc.texCoord[1], 0); // same
        const posInImage: @Vector(2, usize) = .{
            @as(usize, @intFromFloat(@reduce(.Add, barycentric * texCoord1) / @reduce(.Add, barycentric) * @as(f32, @floatFromInt(self.text.rlImage.width)))),
            @as(usize, @intFromFloat(@reduce(.Add, barycentric * texCoord2) / @reduce(.Add, barycentric) * @as(f32, @floatFromInt(self.text.rlImage.height)))),
        };
        const cInt_to_usize = @as(usize, @intCast(self.text.rlImage.width));
        const color: rl.Color = self.text.rlColors[posInImage[1] * cInt_to_usize + posInImage[0]];
        const colorRGB: ColorRGB = zmath.f32x4(@as(f32, @floatFromInt(color.r)), @as(f32, @floatFromInt(color.g)), @as(f32, @floatFromInt(color.b)), 0);

        const material: Material = .{
            .color = colorRGB,
            .reflective = 0.75,
            .specular = 0,
        };
        return HitRecord{
            .hit = true,
            .t = 0,
            .intersection_point = hit_point,
            .normal = normal,
            .material = material,
        };
    }
};
