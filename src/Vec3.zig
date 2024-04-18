pub const Vec3 = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    pub fn subVec3(self: *const Self, other: Self) Vec3 {
        return Vec3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn mulf32(self: *const Self, other: f32) Vec3 {
        return Vec3{
            .x = self.x * other,
            .y = self.y * other,
            .z = self.z * other,
        };
    }

    pub fn addVec3(self: *const Self, other: Self) Vec3 {
        return Vec3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn nil() Vec3 {
        return Vec3{
            .x = 0,
            .y = 0,
            .z = 0,
        };
    }
};

test "subVec3" {
    const std = @import("std");

    const test_vec3 = Vec3{ .x = 5, .y = 4, .z = -3 };
    try std.testing.expectEqual(Vec3{ .x = 3, .y = 7, .z = 1 }, test_vec3.subVec3(Vec3{ .x = 2, .y = -3, .z = -4 }));
}

test "addVec3" {
    const std = @import("std");

    const test_vec3 = Vec3{ .x = 5, .y = 4, .z = -3 };
    try std.testing.expectEqual(Vec3{ .x = 3, .y = 7, .z = 1 }, test_vec3.addVec3(Vec3{ .x = -2, .y = 3, .z = 4 }));
}

test "mulVec3" {
    const std = @import("std");

    const test_vec3 = Vec3{ .x = 5, .y = 4, .z = -3 };
    try std.testing.expectEqual(Vec3{ .x = 35, .y = 28, .z = -21 }, test_vec3.mulf32(7));
}

