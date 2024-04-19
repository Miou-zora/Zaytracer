const std = @import("std");
const Vec3 = @import("Vec3.zig").Vec3;
const Ray = @import("Ray.zig").Ray;
const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;

pub fn main() !void {
    const camera = Camera{
        .origin = Vec3.nil(),
        .screen = .{
            .origin = .{
                .x = -0.5,
                .y = -0.5,
                .z = 1,
            },
            .left = .{
                .x = 1,
                .y = 0,
                .z = 0,
            },
            .top = .{
                .x = 0,
                .y = 1,
                .z = 0,
            },
        },
    };
    const sphere = Sphere{ .center = .{ .x = 0, .y = 0, .z = 2 }, .radius = 0.5 };
    const max_y = 100;
    const max_x = 100;
    var buffered_out = std.io.bufferedWriter(std.io.getStdOut().writer());
    var out = buffered_out.writer();
    try out.print("P3\n", .{});
    try out.print("{d} {d}\n", .{ max_x, max_y });
    try out.print("255\n", .{});
    for (0..max_y) |y| {
        for (0..max_x) |x| {
            const scaled_x: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(max_x));
            const scaled_y: f32 = @as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(max_y));
            const ray: Ray = camera.createRay(scaled_x, scaled_y);
            if (sphere.hits(ray)) {
                try out.print("255 0 0\n", .{});
            } else {
                try out.print("255 255 255\n", .{});
            }
        }
    }
    try buffered_out.flush();
}

test {
    std.testing.refAllDecls(@This());
}
