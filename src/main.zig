const std = @import("std");

const Frame = struct {
    const Self = @This();

    height: u32,
    width: u32,
    pixels: []u8,
    allocator: *const std.mem.Allocator,

    pub fn init(height: u32, width: u32, allocator: *const std.mem.Allocator) !Self {
        var self: Frame = undefined;

        self.height = height;
        self.width = width;
        self.pixels = try allocator.alloc(u8, @as(usize, height * width * 4));
        self.allocator = allocator;

        return self;
    }

    pub fn deinit(self: *Frame) void {
        self.allocator.free(self.pixels);
    }
};

const Vec3 = struct {
    const Self = @This();

    x: f32,
    y: f32,
    z: f32,

    pub fn subVec3(self: *const Self, other: Self) Vec3 {
        return Vec3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.y,
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

const Pt3 = Vec3;

const Ray = struct {
    const Self = @This();

    origin: Pt3,
    direction: Vec3,
};

const Sphere = struct {
    const Self = @This();

    center: Pt3,
    radius: f32,

    pub fn hits(self: *const Self, ray: Ray) bool {
        const a: f32 =
            std.math.pow(f32, ray.direction.x, 2) +
            std.math.pow(f32, ray.direction.y, 2) +
            std.math.pow(f32, ray.direction.z, 2);
        const b: f32 =
        2 * (ray.direction.x * (ray.origin.x - self.center.x) +
             ray.direction.y * (ray.origin.y - self.center.y) +
             ray.direction.z * (ray.origin.z - self.center.z));
        const c: f32 =
            std.math.pow(f32, (ray.origin.x - self.center.x), 2) +
            std.math.pow(f32, (ray.origin.y - self.center.y), 2) +
            std.math.pow(f32, (ray.origin.z - self.center.z), 2) -
            std.math.pow(f32, self.radius, 2);
        const delta: f32 = std.math.pow(f32, b, 2) - 4 * a * c;
        return !(delta < 0);
    }
};

const Rect3 = struct {
    const Self = @This();

    origin: Pt3,
    bottom: Vec3,
    left: Vec3,

    pub fn pointAt(self: *const Self, u: f32, v: f32) Pt3 {
        return self.origin.addVec3(self.bottom.mulf32(u)).addVec3(self.left.mulf32(v));
    }
};

const Camera = struct {
    const Self = @This();

    origin: Pt3,
    screen: Rect3,

    pub fn createRayFromAngles(self: *const Self, u: f32, v: f32) Ray {
        return Ray{
            .origin = self.origin,
            .direction = self.screen.pointAt(u, v).subVec3(self.origin),
        };
    }
};

pub fn main() !void {
    const cam = Camera{
        .origin = Vec3.nil(),
        .screen = .{
            .origin = .{
                .x = -0.5,
                .y = 1,
                .z = -0.5,
            },
            .left = .{
                .x = 1,
                .y = 0,
                .z = 0,
            },
            .bottom = .{
                .x = 0,
                .y = 0,
                .z = 1,
            },
        },
    };
    const sphere = Sphere{ .center = .{ .x = 0, .y = 2, .z = 0 }, .radius = 0.5 };
    const max_y = 100;
    const max_x = 100;
    var out = std.io.getStdOut().writer();
    try out.print("P3\n", .{});
    try out.print("{d} {d}\n", .{ max_x, max_y });
    try out.print("255\n", .{});
    for (0..max_y) |y| {
        for (0..max_x) |x| {
            const scaled_x: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(max_x));
            const scaled_y: f32 = @as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(max_y));
            const ray = cam.createRayFromAngles(scaled_x, scaled_y);
            if (sphere.hits(ray)) {
                try out.print("255 0 0\n", .{});
            } else {
                try out.print("255 255 255\n", .{});
            }
        }
    }
}
