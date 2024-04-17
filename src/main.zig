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

const Sphere = struct {
    const Self = @This();

    center: Pt3,
    radius: f32,
};

const Ray = struct {
    const Self = @This();

    origin: Pt3,
    direction: Vec3,
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
    direction: Vec3,
    screen: Rect3,

    pub fn createRayFromAngles(self: *const Self, u: f32, v: f32) Ray {
        return Ray{
            .origin = self.origin,
            .direction = self.screen.pointAt(u, v).subVec3(self.origin),
        };
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var frame = try Frame.init(100, 100, &allocator);
    defer frame.deinit();

    const cam = Camera{
        .origin = Vec3.nil(),
        .screen = .{
            .origin = Vec3.nil(),
            .left = Vec3.nil(),
            .bottom = Vec3.nil(),
        },
        .direction = Vec3.nil(),
    };
    const some_ray = cam.createRayFromAngles(0, 0);
    std.debug.print("{}\n", .{some_ray});
}
