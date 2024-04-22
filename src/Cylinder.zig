const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");
const HitRecord = @import("HitRecord.zig").HitRecord;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Cylinder = struct {
    const Self = @This();

    radius: f32,
    origin: Pt3,

    // RayTracer::HitRecord hit_record;

    // double a = pow(ray._direction._x, 2) + pow(ray._direction._y, 2);
    // double b = 2 * (ray._direction._x * (ray._origin._x - this->getPosition()._x) +
    //                 ray._direction._y * (ray._origin._y - this->getPosition()._y));
    // double c = pow((ray._origin._x - this->getPosition()._x), 2) +
    //            pow((ray._origin._y - this->getPosition()._y), 2) -
    //            pow(_radius, 2);
    // double discriminant = b * b - 4 * a * c;

    // hit_record.setHit(false);
    // if (discriminant < 0)
    //     return hit_record;
    // if (discriminant == 0) {
    //     double t = -b / (2 * a);
    //     hit_record.setIntersectionPoint(ray._origin + ray._direction * t);
    //     double distance = Maths::MathsUtils::distance(ray._origin, hit_record.getIntersectionPoint());
    //     if (distance < 0)
    //         return hit_record;
    //     hit_record.setHit(true);
    //     hit_record.setDistance(distance);
    //     hit_record.setNormal(Maths::Vector(hit_record.getIntersectionPoint()._x - this->getPosition()._x,
    //                                        hit_record.getIntersectionPoint()._y - this->getPosition()._y,
    //                                        0));
    //     hit_record.setFrontFace(ray._direction.dot(hit_record.getNormal()) < 0);
    //     hit_record.setMaterial(this->getMaterial());

    //     return hit_record;
    // }
    // double t1 = (-b + sqrt(discriminant)) / (2 * a);
    // double t2 = (-b - sqrt(discriminant)) / (2 * a);
    // if (t1 < 0 && t2 < 0) {
    //     hit_record.setHit(false);
    //     return hit_record;
    // }
    // double t = (abs(t1) < abs(t2)) ? t1 : t2;
    // hit_record.setIntersectionPoint(ray._origin + ray._direction * t);
    // double distance = Maths::MathsUtils::distance(ray._origin, hit_record.getIntersectionPoint());
    // hit_record.setDistance(distance);
    // if (distance < 0)
    //     return hit_record;
    // hit_record.setHit(true);
    // hit_record.setNormal(Maths::Vector(hit_record.getIntersectionPoint()._x - this->getPosition()._x,
    //                                     hit_record.getIntersectionPoint()._y - this->getPosition()._y,
    //                                     0));
    // hit_record.setFrontFace(true);
    // hit_record.setMaterial(this->getMaterial());
    // return hit_record;

    pub fn hits(self: *const Self, ray: Ray) HitRecord {
        const rx_minus_cx = ray.origin.x - self.origin.x;
        const ry_minus_cy = ray.origin.y - self.origin.y;
        const a = ray.direction.x * ray.direction.x + ray.direction.y * ray.direction.y;
        const b = 2.0 * (ray.direction.x * rx_minus_cx + ray.direction.y * ry_minus_cy);
        const c = rx_minus_cx * rx_minus_cx + ry_minus_cy * ry_minus_cy - self.radius * self.radius;

        const delta = b * b - 4.0 * a * c;
        if (delta < 0.0) {
            return HitRecord.nil();
        } else if (delta == 0) {
            const t = -b / (2.0 * a);
            const intersection_point = ray.origin.addVec3(ray.direction.mulf32(t));
            const distance = ray.origin.distance(intersection_point);
            if (distance < 0.0) {
                return HitRecord.nil();
            } else {
                return HitRecord{ .hit = true, .normal = Vec3{ .x = intersection_point.x - self.origin.x, .y = intersection_point.y - self.origin.y, .z = 0 }, .intersection_point = intersection_point };
            }
        } else {
            const t1 = (-b + std.math.sqrt(delta)) / (2.0 * a);
            const t2 = (-b - std.math.sqrt(delta)) / (2.0 * a);
            if (t1 < 0 and t2 < 0) {
                return HitRecord.nil();
            }
            const t = if (@fabs(t1) < @fabs(t2)) t1 else t2;
            if (t < 0.0) {
                return HitRecord.nil();
            }
            const intersection_point = ray.origin.addVec3(ray.direction.mulf32(t));
            const distance = ray.origin.distance(intersection_point);
            if (distance < 0.0) {
                return HitRecord.nil();
            } else {
                return HitRecord{ .hit = true, .normal = Vec3{ .x = intersection_point.x - self.origin.x, .y = intersection_point.y - self.origin.y, .z = 0 }, .intersection_point = intersection_point };
            }
        }
    }
};

test "hit" {
    const cylinder = Cylinder{ .radius = 1.0, .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 } };
    const ray = Ray{ .origin = Pt3{ .x = 0.0, .y = 2.0, .z = 0.0 }, .direction = Vec3{ .x = 0.0, .y = -1.0, .z = 0.0 } };
    const hit_record = cylinder.hits(ray);
    try std.testing.expect(hit_record.hit);
    try std.testing.expect(hit_record.intersection_point.x == 0.0);
    try std.testing.expect(hit_record.intersection_point.y == 1.0);
    try std.testing.expect(hit_record.intersection_point.z == 0.0);
    try std.testing.expect(hit_record.normal.x == 0.0);
    try std.testing.expect(hit_record.normal.y == 1.0);
    try std.testing.expect(hit_record.normal.z == 0.0);
}

test "dontHit" {
    const cylinder = Cylinder{ .radius = 1.0, .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 } };
    const ray = Ray{ .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 }, .direction = Vec3{ .x = 1.0, .y = 1.0, .z = 0.0 } };
    const hit_record = cylinder.hits(ray);
    try std.testing.expect(!hit_record.hit);
}

test "limit" {
    const cylinder = Cylinder{ .radius = 1.0, .origin = Pt3{ .x = 0.0, .y = 0.0, .z = 0.0 } };
    const ray = Ray{ .origin = Pt3{ .x = 0.0, .y = 2.0, .z = 0.0 }, .direction = Vec3{ .x = 0.0, .y = -1.0, .z = 0.0 } };
    const hit_record = cylinder.hits(ray);
    try std.testing.expect(hit_record.hit);
    try std.testing.expect(hit_record.intersection_point.x == 0.0);
    try std.testing.expect(hit_record.intersection_point.y == 1.0);
    try std.testing.expect(hit_record.intersection_point.z == 0.0);
    try std.testing.expect(hit_record.normal.x == 0.0);
    try std.testing.expect(hit_record.normal.y == 1.0);
    try std.testing.expect(hit_record.normal.z == 0.0);
}

test {
    std.testing.refAllDecls(@This());
}
