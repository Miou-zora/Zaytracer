const std = @import("std");
const Vec3 = @import("Vec3.zig").Vec3;
const Ray = @import("Ray.zig").Ray;
const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const qoi = @import("qoi.zig");

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
    const height = 1000;
    const width = 1000;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();
    var image = qoi.Image{
        .width = std.math.cast(u32, width) orelse return error.Overflow,
        .height = std.math.cast(u32, height) orelse return error.Overflow,
        .colorspace = .sRGB,
        .pixels = try allocator.alloc(qoi.Color, width * height),
    };
    defer image.deinit(allocator);

    var index: usize = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            const scaled_x: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(width));
            const scaled_y: f32 = @as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(height));
            const ray: Ray = camera.createRay(scaled_x, scaled_y);
            if (sphere.hits(ray)) {
                image.pixels[index] = .{
                    .r = 255,
                    .g = 0,
                    .b = 0,
                    .a = 255,
                };
            } else {
                image.pixels[index] = .{
                    .r = 255,
                    .g = 255,
                    .b = 255,
                    .a = 255,
                };
            }
            index += 1;
        }
    }

    var file = try std.fs.cwd().createFile("out.qoi", .{});
    defer file.close();

    const buffer = try qoi.encodeBuffer(allocator, image.asConst());
    defer allocator.free(buffer);
    try file.writeAll(buffer);
}

test {
    std.testing.refAllDecls(@This());
}
