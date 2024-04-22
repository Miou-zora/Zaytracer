const std = @import("std");
const Vec3 = @import("Vec3.zig").Vec3;
const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const qoi = @import("qoi.zig");
const Light = @import("Light.zig").Light;
const Plane = @import("Plane.zig").Plane;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Transformation = @import("Transformation.zig");
const Cylinder = @import("Cylinder.zig").Cylinder;
const Scene = @import("Scene.zig");

pub fn compute_lighting(intersection: Vec3, normal: Vec3, light: Pt3, ambient: f32) f32 {
    const L = intersection.to(light);
    const n_dot_l = normal.dot(L);
    // TODO: Check if adding the ambient is not just better
    return std.math.clamp(1.0 * n_dot_l / (normal.length() * L.length()), ambient, 1.0);
}

fn calculate_image(pixels: []qoi.Color, scene: *Scene.Scene, height: u32, width: u32) void {
    var index: usize = 0;
    for (0..height) |y| {
        for (0..width) |x| {
            const scaled_x: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(width));
            const scaled_y: f32 = @as(f32, @floatFromInt((height - 1) - y)) / @as(f32, @floatFromInt(height));
            const ray: Ray = scene.camera.createRay(scaled_x, scaled_y);
            const light = scene.lights.items[0].point_light;
            const cylinder = scene.objects.items[0].cylinder;
            const ambient_color_intensity = scene.lights.items[1].ambient_light;
            const cylinder_translation = scene.transforms.items[0];
            const ray_object = Transformation.ray_global_to_object(ray, cylinder_translation, cylinder);
            var record = cylinder.hits(ray_object);
            record = Transformation.hitRecord_object_to_global(record, cylinder_translation, cylinder);
            record.intersection_point.x = record.intersection_point.x + record.normal.x * 0.001;
            record.intersection_point.y = record.intersection_point.y + record.normal.y * 0.001;
            record.intersection_point.z = record.intersection_point.z + record.normal.z * 0.001;
            if (record.hit) {
                const vec_to_light = record.intersection_point.to(light.position);
                const vec_to_light_object = Transformation.ray_global_to_object(Ray{ .direction = vec_to_light, .origin = record.intersection_point }, cylinder_translation, cylinder);
                var obstacle = cylinder.hits(vec_to_light_object);
                obstacle = Transformation.hitRecord_object_to_global(obstacle, cylinder_translation, cylinder);
                if (obstacle.hit) {
                    pixels[index] = .{
                        .r = @as(u8, @intFromFloat(255.0 * ambient_color_intensity)),
                        .g = 0,
                        .b = 0,
                        .a = 255,
                    };
                } else {
                    const norm = record.normal;
                    const inter = record.intersection_point;
                    const light_color = 255.0 * compute_lighting(inter, norm, light.position, ambient_color_intensity);
                    pixels[index] = .{
                        .r = @as(u8, @intFromFloat(light_color)),
                        .g = 0,
                        .b = 0,
                        .a = 255,
                    };
                }
            } else {
                pixels[index] = .{
                    .r = 0,
                    .g = 0,
                    .b = 0,
                    .a = 255,
                };
            }
            index += 1;
        }
    }
}

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
    // const sphere = Sphere{
    //     .center = .{ .x = 0, .y = 0, .z = 2 },
    //     .radius = 0.5,
    // };
    // const sphere_translation = Transformation.Transformation{ .translation = .{ .x = -0.5, .y = 0.2, .z = 1.5 } };
    // const sphere = Plane{
    //     .normal = .{ .x = 0, .y = 1, .z = 0 },
    //     .origin = .{ .x = 0, .y = -1, .z = 1 },
    // };
    const cylinder = Cylinder{ .radius = 0.5, .origin = Pt3{ .x = 2, .y = 0, .z = 10 } };
    const cylinder_translation = Transformation.Transformation{ .rotation = .{ .x = 0.5, .y = 0.2, .z = 0 } };
    const light = Light{
        .color = .{ .blue = 255, .green = 255, .red = 255 },
        .intensity = 1,
        .position = .{ .x = 0, .y = 1, .z = 2 },
    };
    const ambient_color_intensity = 0.1;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var scene = Scene.Scene.init(allocator, camera);
    defer scene.deinit();

    try scene.objects.append(.{ .cylinder = cylinder });
    try scene.lights.append(.{ .point_light = light });
    try scene.lights.append(.{ .ambient_light = ambient_color_intensity });
    try scene.transforms.append(cylinder_translation);

    const height = 1000;
    const width = 1000;

    var image = qoi.Image{
        .width = std.math.cast(u32, width) orelse return error.Overflow,
        .height = std.math.cast(u32, height) orelse return error.Overflow,
        .colorspace = .sRGB,
        .pixels = try allocator.alloc(qoi.Color, width * height),
    };
    defer image.deinit(allocator);

    calculate_image(image.pixels, &scene, height, width);

    var file = try std.fs.cwd().createFile("out.qoi", .{});
    defer file.close();

    const buffer = try qoi.encodeBuffer(allocator, image.asConst());
    defer allocator.free(buffer);
    try file.writeAll(buffer);
}

test {
    std.testing.refAllDecls(@This());
}
