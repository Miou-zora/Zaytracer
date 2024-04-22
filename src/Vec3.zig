const std = @import("std");

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

    pub fn collapse(self: *const Self) f32 {
        return self.x + self.y + self.z;
    }

    pub fn inv(self: *const Self) Vec3 {
        return Vec3{
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
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

    pub fn distance(self: *const Self, other: Self) f32 {
        return std.math.sqrt(std.math.pow(f32, self.x - other.x, 2) + std.math.pow(f32, self.y - other.y, 2) + std.math.pow(f32, self.z - other.z, 2));
    }

    pub fn to(self: *const Self, other: Self) Vec3 {
        return other.subVec3(self.*);
    }

    pub fn angleBetween(self: *const Self, other: Self) f32 {
        return std.math.acos(self.dot(other) / (self.length() * other.length()));
    }

    pub fn length(self: *const Self) f32 {
        return std.math.sqrt(std.math.pow(f32, self.x, 2) + std.math.pow(f32, self.y, 2) + std.math.pow(f32, self.z, 2));
    }

    pub fn dot(self: *const Self, other: Self) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};

test "subVec3" {
    const test_vec3 = Vec3{ .x = 5, .y = 4, .z = -3 };
    try std.testing.expectEqual(Vec3{ .x = 3, .y = 7, .z = 1 }, test_vec3.subVec3(Vec3{ .x = 2, .y = -3, .z = -4 }));
}

test "addVec3" {
    const test_vec3 = Vec3{ .x = 5, .y = 4, .z = -3 };
    try std.testing.expectEqual(Vec3{ .x = 3, .y = 7, .z = 1 }, test_vec3.addVec3(Vec3{ .x = -2, .y = 3, .z = 4 }));
}

test "mulVec3" {
    const test_vec3 = Vec3{ .x = 5, .y = 4, .z = -3 };
    try std.testing.expectEqual(Vec3{ .x = 35, .y = 28, .z = -21 }, test_vec3.mulf32(7));
}

test {
    std.testing.refAllDecls(@This());
}
