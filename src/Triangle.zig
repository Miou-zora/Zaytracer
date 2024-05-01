const Vertex = @import("Vertex.zig").Vertex;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;
const Material = @import("Material.zig").Material;

pub const Triangle = struct {
    const Self = @This();

    va: Vertex,
    vb: Vertex,
    vc: Vertex,

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

        const colorVA = (Vec3{ .x = self.va.color.r, .y = self.va.color.g, .z = self.va.color.b }).normalized();
        const colorVB = (Vec3{ .x = self.vb.color.r, .y = self.vb.color.g, .z = self.vb.color.b }).normalized();
        const colorVC = (Vec3{ .x = self.vc.color.r, .y = self.vc.color.g, .z = self.vc.color.b }).normalized();
        const color = colorVA.mulf32(u).addVec3(colorVB.mulf32(v)).addVec3(colorVC.mulf32(w)).mulf32(255).divf32(u + v + w);
        const colorRGB = .{ .r = color.x, .g = color.y, .b = color.z };
        const material: Material = .{
            .color = colorRGB,
            .reflective = 0.5,
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
