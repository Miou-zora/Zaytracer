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
const Material = @import("Material.zig").Material;
const Config = @import("Config.zig").Config;

pub fn compute_lighting(intersection: Vec3, normal: Vec3, scene: *Scene.Scene, ray: Ray, material: Material) ColorRGB {
    var lighting: ColorRGB = ColorRGB{ .r = 0, .g = 0, .b = 0 };
    for (scene.lights.items) |light| {
        switch (light) {
            .point_light => |item| {
                const L = intersection.to(item.position).normalized();
                const n_dot_l = normal.dot(L);
                const em = n_dot_l / (normal.length() * L.length()) * item.intensity;
                if (em < 0) {
                    continue;
                }
                lighting.b += item.color.b * em;
                lighting.g += item.color.g * em;
                lighting.r += item.color.r * em;
                if (material.specular != -1) {
                    const R = normal.mulf32(n_dot_l * 2.0).subVec3(L);
                    const V = ray.direction.inv().normalized();
                    const r_dot_v = R.dot(V);
                    if (r_dot_v > 0) {
                        const i = item.intensity * std.math.pow(f32, r_dot_v / (R.length() * V.length()), material.specular);
                        lighting.b += item.color.b * i;
                        lighting.g += item.color.g * i;
                        lighting.r += item.color.r * i;
                    }
                }
            },
            .ambient_light => |item| {
                lighting.b += item.color.b * item.intensity;
                lighting.g += item.color.g * item.intensity;
                lighting.r += item.color.r * item.intensity;
            },
        }
    }
    return ColorRGB{
        .b = std.math.clamp(lighting.b, 0.0, 255.0),
        .g = std.math.clamp(lighting.g, 0.0, 255.0),
        .r = std.math.clamp(lighting.r, 0.0, 255.0),
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
        const norm = closest_hit.normal.normalized();
        const inter = closest_hit.intersection_point;
        const material = closest_hit.material;
        const light_color = compute_lighting(inter, norm, scene, ray, material);
        return .{
            .r = @as(u8, @intFromFloat(material.color.r * light_color.r / 255)),
            .g = @as(u8, @intFromFloat(material.color.g * light_color.g / 255)),
            .b = @as(u8, @intFromFloat(material.color.b * light_color.b / 255)),
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
    const list_of_hits: []HitRecord = try allocator.alloc(HitRecord, scene.objects.items.len);
    defer allocator.free(list_of_hits);
    for (0..height) |y| {
        for (0..width) |x| {
            pixels[x + y * width] = get_pixel_color(x, y, scene, height, width, list_of_hits);
        }
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const config = try Config.fromFilePath("config.json", allocator);
    std.debug.print("{any}\n", .{config.materials});
    const cylinder_translation = Transformation.Transformation{ .rotation = .{ .x = 0.5, .y = 0.2, .z = 0 } };
    const light = Light{
        .color = .{ .b = 255, .g = 255, .r = 255 },
        .intensity = 0.6,
        .position = .{ .x = 0, .y = 1, .z = 2 },
    };
    const ambiant_light: AmbientLight = .{
        .color = .{ .b = 255, .g = 255, .r = 255 },
        .intensity = 0.2,
    };

    var scene = Scene.Scene.init(allocator, config.camera);
    defer scene.deinit();

    try scene.objects.append(.{ .cylinder = .{
        .radius = 0.5,
        .origin = Pt3{
            .x = 2,
            .y = 2,
            .z = 10,
        },
        .material = .{
            .specular = 100,
            .color = .{ .b = 255, .g = 0, .r = 0 },
        },
    } });
    try scene.objects.append(.{ .sphere = .{
        .center = Pt3{
            .x = -0.2,
            .y = -0.5,
            .z = 2,
        },
        .radius = 0.5,
        .material = .{
            .specular = 100,
            .color = .{ .b = 0, .g = 0, .r = 255 },
        },
    } });
    try scene.objects.append(.{ .plane = .{
        .normal = Vec3{
            .x = 0,
            .y = 1,
            .z = 0,
        },
        .origin = Pt3{
            .x = 0,
            .y = -1,
            .z = 1,
        },
        .material = .{
            .specular = 100,
            .color = .{ .b = 0, .g = 255, .r = 0 },
        },
    } });
    try scene.lights.append(.{ .point_light = light });
    try scene.lights.append(.{ .ambient_light = ambiant_light });
    try scene.transforms.append(cylinder_translation);

    const height: u32 = 1000;
    const width: u32 = 1000;

    var image = qoi.Image{
        .width = width,
        .height = height,
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
