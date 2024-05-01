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

const EPSILON = 0.00001;

pub fn compute_lighting(intersection: Vec3, normal: Vec3, scene: *Scene.Scene, ray: Ray, material: Material) ColorRGB {
    var lighting: ColorRGB = ColorRGB{ .r = 0, .g = 0, .b = 0 };
    var t_max: f32 = std.math.floatMax(f32);
    for (scene.lights.items) |light| {
        t_max = std.math.floatMax(f32);
        switch (light) {
            .point_light => |item| {
                const L = intersection.to(item.position).normalized();
                t_max = intersection.to(item.position).length();
                const closest_hit = find_closest_intersection(scene, Ray{ .direction = L, .origin = intersection.addVec3(normal.mulf32(EPSILON)) }, EPSILON, t_max);
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
            .cylinder => {
                if (object.cylinder.transform) |transform| {
                    switch (transform) {
                        .translation => {
                            const new_ray = transform.translation.ray_global_to_object(ray);
                            const record = transform.translation.hitRecord_object_to_global(object.cylinder.hits(new_ray));
                            if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                                closest_hit = record;
                            }
                        },
                        .rotation => {
                            const new_ray = transform.rotation.ray_global_to_object(ray, object.cylinder.origin);
                            const record = transform.rotation.hitRecord_object_to_global(object.cylinder.hits(new_ray), object.cylinder.origin);
                            if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                                closest_hit = record;
                            }
                        },
                    }
                } else {
                    const record = object.cylinder.hits(ray);
                    if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                        closest_hit = record;
                    }
                }
            },
            .sphere => {
                if (object.sphere.transform) |transform| {
                    switch (transform) {
                        .translation => {
                            const new_ray = transform.translation.ray_global_to_object(ray);
                            const record = transform.translation.hitRecord_object_to_global(object.sphere.hits(new_ray));
                            if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                                closest_hit = record;
                            }
                        },
                        .rotation => {
                            const new_ray = transform.rotation.ray_global_to_object(ray, object.sphere.origin);
                            const record = transform.rotation.hitRecord_object_to_global(object.sphere.hits(new_ray), object.sphere.origin);
                            if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                                closest_hit = record;
                            }
                        },
                    }
                } else {
                    const record = object.sphere.hits(ray);
                    if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                        closest_hit = record;
                    }
                }
            },
            .plane => {
                if (object.plane.transform) |transform| {
                    switch (transform) {
                        .translation => {
                            const new_ray = transform.translation.ray_global_to_object(ray);
                            const record = transform.translation.hitRecord_object_to_global(object.plane.hits(new_ray));
                            if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                                closest_hit = record;
                            }
                        },
                        .rotation => {
                            const new_ray = transform.rotation.ray_global_to_object(ray, object.plane.origin);
                            const record = transform.rotation.hitRecord_object_to_global(object.plane.hits(new_ray), object.plane.origin);
                            if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                                closest_hit = record;
                            }
                        },
                    }
                } else {
                    const record = object.plane.hits(ray);
                    if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
                        closest_hit = record;
                    }
                }
            },
            .triangle => {
                const record = object.triangle.hits(ray);
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
            pixels[x + y * width] = get_pixel_color(ray, scene, height, width, recursion_depth);
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
    // const Object = @import("Object.zig").Object;
    // const ObjSphere: Object = .{
    //     .shape = Object.Shape{
    //         .sphere = .{
    //             .origin = .{
    //                 .x = 0,
    //                 .y = 0,
    //                 .z = 0,
    //             },
    //             .radius = 1,
    //             .material = Material{
    //                 .color = ColorRGB{ .r = 255, .g = 0, .b = 0 },
    //                 .reflective = 0.5,
    //                 .specular = 500,
    //             },
    //             .transform = null,
    //         },
    //     },
    //     .transform = null,
    // };

    // comptime {
    //     const rayToSphere = Ray{
    //         .direction = Vec3{ .x = 0, .y = 0, .z = -1 },
    //         .origin = Vec3{ .x = 0, .y = 0, .z = 2 },
    //     };
    //     const hit = ObjSphere.hits(rayToSphere);
    //     _ = hit;
    //     _ = ObjSphere.getOrigin();
    // }

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
