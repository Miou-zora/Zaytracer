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

    pub fn normalized(self: *const Self) Vec3 {
        const vec_length = self.length();
        return Vec3{
            .x = self.x / vec_length,
            .y = self.y / vec_length,
            .z = self.z / vec_length,
        };
    }

    pub fn mulVec3(self: *const Self, other: Self) Vec3 {
        return Vec3{
            .x = self.x * other.x,
            .y = self.y * other.y,
            .z = self.z * other.z,
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
        const self_minus_other = self.subVec3(other);
        return @sqrt(self_minus_other.mulVec3(self_minus_other).sum());
    }

    pub fn to(self: *const Self, other: Self) Vec3 {
        return other.subVec3(self.*);
    }

    pub fn angleBetween(self: *const Self, other: Self) f32 {
        return std.math.acos(self.dot(other) / (self.length() * other.length()));
    }

    pub fn length(self: *const Self) f32 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }

    pub fn dot(self: *const Self, other: Self) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn rotateX(self: *Self, angle: f32) void {
        const y = self.y;
        const z = self.z;
        const cos_angle = @cos(angle);
        const sin_angle = @sin(angle);
        self.y = y * cos_angle - z * sin_angle;
        self.z = y * sin_angle + z * cos_angle;
    }

    pub fn rotateY(self: *Self, angle: f32) void {
        const x = self.x;
        const z = self.z;
        const cos_angle = @cos(angle);
        const sin_angle = @sin(angle);
        self.x = x * cos_angle + z * sin_angle;
        self.z = -x * sin_angle + z * cos_angle;
    }

    pub fn rotateZ(self: *Self, angle: f32) void {
        const x = self.x;
        const y = self.y;
        const cos_angle = @cos(angle);
        const sin_angle = @sin(angle);
        self.x = x * cos_angle - y * sin_angle;
        self.y = x * sin_angle + y * cos_angle;
    }

    pub fn sum(self: *const Self) f32 {
        return self.x + self.y + self.z;
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
