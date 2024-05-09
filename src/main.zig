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
const Cylinder = @import("Cylinder.zig").Cylinder;
const Scene = @import("Scene.zig");
const ColorRGB = @import("ColorRGB.zig").ColorRGB;
const Material = @import("Material.zig").Material;
const Config = @import("Config.zig").Config;
const zmath = @import("zmath");
const Payload = @import("Payload.zig").Payload;

const EPSILON: f32 = 0.00001;

pub fn compute_lighting(intersection: Vec3, normal: Vec3, scene: *Scene.Scene, ray: Ray, material: Material) ColorRGB {
    var lighting: ColorRGB = zmath.f32x4(0, 0, 0, 255);
    var tmp_pl: Payload = .{
        .intersection_point_world = zmath.f32x4(std.math.floatMax(f32), 0, 0, 0),
        .intersection_point_obj = zmath.f32x4(std.math.floatMax(f32), 0, 0, 0),
        .obj = &scene.objects.items[0],
    };
    for (scene.lights.items) |light| {
        switch (light) {
            .point_light => |item| {
                const L = zmath.normalize3(item.position - intersection);
                const closest_hit = find_closest_intersection(scene, Ray{ .direction = L, .origin = zmath.mulAdd(@as(Vec3, @splat(EPSILON)), normal, intersection) }, EPSILON, zmath.length3(item.position - intersection)[0], &tmp_pl);
                if (closest_hit) {
                    continue;
                }
                const n_dot_l = zmath.dot3(normal, L);
                const em = (n_dot_l / (zmath.length3(normal) * zmath.length3(L))) * @as(Vec3, @splat(item.intensity)); // TODO: store item intensity cleanly
                if (em[0] < 0) {
                    continue;
                }
                lighting += item.color * em;
                if (material.specular != -1) {
                    const R = reflect(L, normal);
                    const V = zmath.normalize3(-ray.direction);
                    const r_dot_v = zmath.dot3(R, V);
                    if (r_dot_v[0] > 0) {
                        const i = @as(Vec3, @splat(item.intensity * std.math.pow(f32, r_dot_v[0] / (zmath.length3(R)[0] * zmath.length3(V)[0]), material.specular)));
                        lighting += item.color * i;
                    }
                }
            },
            .ambient_light => |item| {
                lighting += item.color * @as(Vec3, @splat(item.intensity));
            },
        }
    }
    return zmath.clampFast(lighting, @as(ColorRGB, @splat(0)), @as(ColorRGB, @splat(255)));
}

fn find_closest_intersection(scene: *Scene.Scene, ray: Ray, t_min: f32, t_max: f32, closest_hit: *Payload) bool {
    var hit = false;
    var tmp_pl: Payload = .{
        .intersection_point_world = zmath.f32x4(std.math.floatMax(f32), 0, 0, 0),
        .intersection_point_obj = zmath.f32x4(std.math.floatMax(f32), 0, 0, 0),
        .obj = &scene.objects.items[0],
    };
    for (scene.objects.items) |object| {
        tmp_pl.obj = &object;
        hit = hit or object.fetch_closest_object(closest_hit, ray, t_min, t_max, &tmp_pl);
    }
    return hit;
}

fn reflect(v: Vec3, n: Vec3) Vec3 {
    return zmath.mulAdd(n * @as(Vec3, @splat(2)), zmath.dot3(v, n), -v);
}

fn get_pixel_color(ray: Ray, scene: *Scene.Scene, height: u32, width: u32, recursion_depth: usize) ColorRGB {
    var closest_hit: Payload = .{
        .intersection_point_world = zmath.f32x4(std.math.floatMax(f32), 0, 0, 0),
        .intersection_point_obj = zmath.f32x4(std.math.floatMax(f32), 0, 0, 0),
        .obj = &scene.objects.items[0],
    };
    if (!find_closest_intersection(scene, ray, std.math.floatMin(f32), std.math.floatMax(f32), &closest_hit))
        return zmath.f32x4s(0);

    const hitRecord = closest_hit.obj.to_hitRecord(&closest_hit.intersection_point_obj);
    const norm = zmath.normalize3(hitRecord.normal);
    const inter = hitRecord.intersection_point;
    const material = hitRecord.material;
    const light_color = compute_lighting(inter, norm, scene, ray, material);
    const color = material.color * light_color / @as(zmath.Vec, @splat(255));
    const reflective = hitRecord.material.reflective;
    if (recursion_depth <= 0 or reflective <= 0) {
        return color;
    }

    const R = reflect(-ray.direction, norm);
    const new_origin = zmath.mulAdd(@as(Vec3, @splat(EPSILON)), norm, hitRecord.intersection_point);
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
    return color * @as(Vec3, @splat(1 - reflective)) + reflected_color * @as(Vec3, @splat(reflective));
}

var current_height: std.atomic.Value(u32) = std.atomic.Value(u32).init(0);

fn calculate_image_worker(pixels: []qoi.Color, scene: *Scene.Scene, height: u32, width: u32) !void {
    const recursion_depth = 5;
    while (true) {
        const y = current_height.fetchAdd(1, .monotonic);
        if (y >= height)
            return;
        for (0..width) |x| {
            const scaled_x: f32 = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(width));
            const scaled_y: f32 = @as(f32, @floatFromInt((height - 1) - y)) / @as(f32, @floatFromInt(height));
            const ray: Ray = scene.camera.createRay(scaled_x, scaled_y);
            const pixel_color: ColorRGB = get_pixel_color(ray, scene, height, width, recursion_depth);
            pixels[x + y * width] = .{
                .r = @as(u8, @intFromFloat(pixel_color[0])),
                .g = @as(u8, @intFromFloat(pixel_color[1])),
                .b = @as(u8, @intFromFloat(pixel_color[2])),
                .a = 255,
            };
        }
    }
}

fn calculate_image(pixels: []qoi.Color, scene: *Scene.Scene, height: u32, width: u32, allocator: std.mem.Allocator) !void {
    const num_threads = try std.Thread.getCpuCount();
    var threads = try allocator.alloc(std.Thread, num_threads);

    for (0..num_threads) |i|
        threads[i] = try std.Thread.spawn(.{ .allocator = allocator }, calculate_image_worker, .{ pixels, scene, height, width });
    for (threads) |thread|
        thread.join();
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const config = try Config.fromFilePath("config.json", allocator);

    var scene = Scene.Scene.init(allocator, config.camera);
    defer scene.deinit();

    for (config.objects) |obj| {
        try scene.objects.append(obj);
    }
    for (config.lights) |obj| {
        try scene.lights.append(obj);
    }

    const height: u32 = config.camera.height;
    const width: u32 = config.camera.width;

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
