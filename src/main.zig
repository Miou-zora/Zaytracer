const std = @import("std");
const Vec3 = @import("Vec3.zig").Vec3;
const Pt3 = @import("Pt3.zig").Pt3;
const Ray = @import("Ray.zig").Ray;
const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const qoi = @import("qoi.zig");
const Light = @import("Light.zig").Light;
const AmbientLight = @import("AmbientLight.zig").AmbientLight;
const Plane = @import("Plane.zig").Plane;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Transformation = @import("Transformation.zig");
const Cylinder = @import("Cylinder.zig").Cylinder;
const Scene = @import("Scene.zig");
const ColorRGB = @import("ColorRGB.zig").ColorRGB;

pub fn compute_lighting(intersection: Vec3, normal: Vec3, scene: *Scene.Scene) ColorRGB {
    var lighting: ColorRGB = ColorRGB{ .red = 0, .green = 0, .blue = 0 };
    for (scene.lights.items) |light| {
        switch (light) {
            .point_light => |item| {
                const L = intersection.to(item.position);
                const n_dot_l = normal.dot(L);
                const em = n_dot_l / (normal.length() * L.length());
                if (em < 0) {
                    continue;
                }
                lighting.blue += item.color.blue * em * item.intensity;
                lighting.green += item.color.green * em * item.intensity;
                lighting.red += item.color.red * em * item.intensity;
            },
            .ambient_light => |item| {
                lighting.blue += item.color.blue * item.intensity;
                lighting.green += item.color.green * item.intensity;
                lighting.red += item.color.red * item.intensity;
            },
        }
    }
    return ColorRGB{
        .blue = std.math.clamp(lighting.blue, 0.0, 255.0),
        .green = std.math.clamp(lighting.green, 0.0, 255.0),
        .red = std.math.clamp(lighting.red, 0.0, 255.0),
    };
}

fn get_pixel_color(x: usize, y: usize, scene: *Scene.Scene, height: u32, width: u32, list_of_hits: []HitRecord) qoi.Color {
    const scaled_x: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(width));
    const scaled_y: f32 = @as(f32, @floatFromInt((height - 1) - y)) / @as(f32, @floatFromInt(height));
    const ray: Ray = scene.camera.createRay(scaled_x, scaled_y);

    for (scene.objects.items, 0..) |object, i| {
        switch (object) {
            .cylinder => |item| {
                list_of_hits[i] = item.hits(ray);
            },
            .sphere => |item| {
                list_of_hits[i] = item.hits(ray);
            },
            .plane => |item| {
                list_of_hits[i] = item.hits(ray);
            },
        }
    }

    var closest_hit: HitRecord = HitRecord.nil();
    for (list_of_hits) |hit| {
        if (hit.hit and (!closest_hit.hit or hit.t < closest_hit.t)) {
            closest_hit = hit;
        }
    }

    if (closest_hit.hit) {
        closest_hit.intersection_point.x = closest_hit.intersection_point.x + closest_hit.normal.x * 0.001;
        closest_hit.intersection_point.y = closest_hit.intersection_point.y + closest_hit.normal.y * 0.001;
        closest_hit.intersection_point.z = closest_hit.intersection_point.z + closest_hit.normal.z * 0.001;
        const norm = closest_hit.normal;
        const inter = closest_hit.intersection_point;
        const light_color = compute_lighting(inter, norm, scene);
        return .{
            .r = @as(u8, @intFromFloat(light_color.red)),
            .g = @as(u8, @intFromFloat(light_color.green)),
            .b = @as(u8, @intFromFloat(light_color.blue)),
            .a = 255,
        };
    }

    return .{
        .r = 0,
        .g = 0,
        .b = 0,
        .a = 255,
    };
}

fn calculate_image(pixels: []qoi.Color, scene: *Scene.Scene, height: u32, width: u32, allocator: std.mem.Allocator) !void {
    var list_of_hits: []HitRecord = try allocator.alloc(HitRecord, scene.objects.items.len);
    defer allocator.free(list_of_hits);
    for (0..height) |y| {
        for (0..width) |x| {
            pixels[x + y * width] = get_pixel_color(x, y, scene, height, width, list_of_hits);
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
    const cylinder_translation = Transformation.Transformation{ .rotation = .{ .x = 0.5, .y = 0.2, .z = 0 } };
    const light = Light{
        .color = .{ .blue = 100, .green = 100, .red = 255 },
        .intensity = 1,
        .position = .{ .x = 0, .y = 1, .z = 2 },
    };
    const ambiant_light: AmbientLight = .{
        .color = .{ .blue = 255, .green = 255, .red = 255 },
        .intensity = 0.1,
    };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var scene = Scene.Scene.init(allocator, camera);
    defer scene.deinit();

    try scene.objects.append(.{ .cylinder = .{ .radius = 0.5, .origin = Pt3{
        .x = 2,
        .y = 2,
        .z = 10,
    } } });
    try scene.objects.append(.{ .sphere = .{ .center = Pt3{
        .x = -0.2,
        .y = 0,
        .z = 2,
    }, .radius = 0.5 } });
    try scene.objects.append(.{ .plane = .{ .normal = Vec3{
        .x = 0,
        .y = 1,
        .z = 0,
    }, .origin = Pt3{
        .x = 0,
        .y = -1,
        .z = 1,
    } } });
    try scene.lights.append(.{ .point_light = light });
    try scene.lights.append(.{ .ambient_light = ambiant_light });
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

    try calculate_image(image.pixels, &scene, height, width, allocator);

    var file = try std.fs.cwd().createFile("out.qoi", .{});
    defer file.close();

    const buffer = try qoi.encodeBuffer(allocator, image.asConst());
    defer allocator.free(buffer);
    try file.writeAll(buffer);
}

test {
    std.testing.refAllDecls(@This());
}
