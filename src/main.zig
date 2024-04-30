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
const Translation = @import("Translation.zig").Translation;

pub fn compute_lighting(intersection: Vec3, normal: Vec3, scene: *Scene.Scene, ray: Ray, material: Material) ColorRGB {
    var lighting: ColorRGB = ColorRGB{ .r = 0, .g = 0, .b = 0 };
    var t_max: f32 = std.math.floatMax(f32);
    for (scene.lights.items) |light| {
        t_max = std.math.floatMax(f32);
        switch (light) {
            .point_light => |item| {
                const L = intersection.to(item.position).normalized();
                t_max = intersection.to(item.position).length();
                const closest_hit = find_closest_intersection(scene, Ray{ .direction = L, .origin = intersection.addVec3(normal.mulf32(0.0001)) }, 0.0001, t_max);
                if (closest_hit.hit) {
                    continue;
                }
                const n_dot_l = normal.dot(L);
                const em = n_dot_l / (normal.length() * L.length()) * item.intensity;
                if (em < 0) {
                    continue;
                }
                lighting.b += item.color.b * em;
                lighting.g += item.color.g * em;
                lighting.r += item.color.r * em;
                if (material.specular != -1) {
                    const R = L.reflect(normal);
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

fn find_closest_intersection(scene: *Scene.Scene, ray: Ray, t_min: f32, t_max: f32) HitRecord {
    var closest_hit: HitRecord = HitRecord.nil();
    for (scene.objects.items) |object| {
        switch (object) {
            .cylinder => |item| {
                const new_ray = item.transform.global_to_object(ray);
                const record = item.transform.object_to_global(item.hits(new_ray));
                if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                    closest_hit = record;
                }
            },
            .sphere => |item| {
                const record = item.hits(ray);
                if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                    closest_hit = record;
                }
            },
            .plane => |item| {
                const record = item.hits(ray);
                if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                    closest_hit = record;
                }
            },
        }
    }
    return closest_hit;
}

fn get_pixel_color(ray: Ray, scene: *Scene.Scene, height: u32, width: u32, recursion_depth: usize) qoi.Color {
    const closest_hit = find_closest_intersection(scene, ray, std.math.floatMin(f32), std.math.floatMax(f32));

    if (!closest_hit.hit) {
        return .{
            .r = 0,
            .g = 0,
            .b = 0,
            .a = 255,
        };
    }
    const norm = closest_hit.normal.normalized();
    const inter = closest_hit.intersection_point;
    const material = closest_hit.material;
    const light_color = compute_lighting(inter, norm, scene, ray, material);
    const color = .{
        .r = @as(u8, @intFromFloat(material.color.r * light_color.r / 255)),
        .g = @as(u8, @intFromFloat(material.color.g * light_color.g / 255)),
        .b = @as(u8, @intFromFloat(material.color.b * light_color.b / 255)),
        .a = 255,
    };
    const reflective = closest_hit.material.reflective;
    if (recursion_depth <= 0 or reflective <= 0) {
        return color;
    }

    const R = ray.direction.inv().reflect(norm);
    const new_origin = closest_hit.intersection_point.addVec3(norm.mulf32(0.0001));
    const reflected_color = get_pixel_color(
        Ray{
            .direction = R,
            .origin = new_origin,
        },
        scene,
        height,
        width,
        recursion_depth - 1,
    );
    return .{
        .r = @as(u8, @intFromFloat(@as(f32, @floatFromInt(color.r)) * (1 - reflective) + @as(f32, @floatFromInt(reflected_color.r)) * reflective)),
        .g = @as(u8, @intFromFloat(@as(f32, @floatFromInt(color.g)) * (1 - reflective) + @as(f32, @floatFromInt(reflected_color.g)) * reflective)),
        .b = @as(u8, @intFromFloat(@as(f32, @floatFromInt(color.b)) * (1 - reflective) + @as(f32, @floatFromInt(reflected_color.b)) * reflective)),
        .a = 255,
    };
}

fn calculate_image(pixels: []qoi.Color, scene: *Scene.Scene, height: u32, width: u32) !void {
    const recursion_depth = 5;
    for (0..height) |y| {
        for (0..width) |x| {
            const scaled_x: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(width));
            const scaled_y: f32 = @as(f32, @floatFromInt((height - 1) - y)) / @as(f32, @floatFromInt(height));
            const ray: Ray = scene.camera.createRay(scaled_x, scaled_y);
            pixels[x + y * width] = get_pixel_color(ray, scene, height, width, recursion_depth);
        }
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const cylinder_translation = Translation.init(2, 2, 10);
    const light = Light{
        .color = .{ .b = 255, .g = 255, .r = 255 },
        .intensity = 0.6,
        .position = .{ .x = 0, .y = 1, .z = 2 },
    };
    const ambiant_light: AmbientLight = .{
        .color = .{ .b = 255, .g = 255, .r = 255 },
        .intensity = 0.2,
    };

    const camera = Camera{
        .width = 1920,
        .height = 1080,
        .fov = 40,
    };

    var scene = Scene.Scene.init(allocator, camera);
    defer scene.deinit();

    try scene.objects.append(.{ .cylinder = .{
        .radius = 0.5,
        .origin = Pt3{
            .x = 0,
            .y = 0,
            .z = 0,
        },
        .material = .{
            .specular = 100,
            .color = .{ .b = 255, .g = 0, .r = 0 },
            .reflective = 0.5,
        },
        .transform = &cylinder_translation.interface,
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
            .reflective = 0.5,
        },
        .transform = null,
    } });
    try scene.lights.append(.{ .point_light = light });
    try scene.lights.append(.{ .ambient_light = ambiant_light });

    const height: u32 = 1000;
    const width: u32 = 1000;

    var image = qoi.Image{
        .width = width,
        .height = height,
        .colorspace = .sRGB,
        .pixels = try allocator.alloc(qoi.Color, width * height),
    };
    defer image.deinit(allocator);

    try calculate_image(image.pixels, &scene, height, width);

    var file = try std.fs.cwd().createFile("out.qoi", .{});
    defer file.close();

    const buffer = try qoi.encodeBuffer(allocator, image.asConst());
    defer allocator.free(buffer);
    try file.writeAll(buffer);
}

test {
    std.testing.refAllDecls(@This());
}
