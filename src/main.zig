const std = @import("std");
const Vec3 = @import("Vec3.zig").Vec3;
const Ray = @import("Ray.zig").Ray;
const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const qoi = @import("qoi.zig");

const ColorRGB = struct {
    red: f16,
    green: f16,
    blue: f16,
};

const Pt3 = @import("Pt3.zig");
const Light = struct {
    intensity: u8,
    color: ColorRGB,
    position: Pt3,
};

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
    const sphere = Sphere{
        .center = .{ .x = 0, .y = 0, .z = 2 },
        .radius = 0.5,
    };
    const light = Light{
        .color = .{ .blue = 255, .green = 255, .red = 255 },
        .intensity = 1,
        .position = .{ .x = 2, .y = 0, .z = 2 },
    };
    const ambiant_color_intensity = 0.1;
    const height = 1080;
    const width = 1920;
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
            const record = sphere.hits(ray);
            if (record.hit) {
                const obstacle = sphere.hits(Ray{ .direction = record.intersection_point.to(sphere.center), .origin = record.intersection_point });
                if (obstacle.hit) {
                    image.pixels[index] = .{
                        .r = 255 * ambiant_color_intensity,
                        .g = 0,
                        .b = 0,
                        .a = 255,
                    };
                } else {
                    
                }
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
