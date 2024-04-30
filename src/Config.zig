const std = @import("std");
const Camera = @import("Camera.zig").Camera;
const Material = @import("Material.zig").Material;
const Pt3 = @import("Pt3.zig").Pt3;
const Vec3 = @import("Vec3.zig").Vec3;
const Scene = @import("Scene.zig");
const Sphere = @import("Sphere.zig").Sphere;
const Object = Scene.SceneObject;
const AmbientLight = @import("AmbientLight.zig").AmbientLight;
const PointLight = @import("Light.zig").Light;
const Light = Scene.SceneLight;
const Transformation = @import("Transformation.zig").Transformation;
const Translation = @import("Translation.zig").Translation;
const Rotation = @import("Rotation.zig").Rotation;

const TransformationProxy = struct {
    translation: ?Translation = null,
    rotation: ?Rotation = null,
};

const ObjectProxy = struct {
    sphere: ?struct {
        origin: Pt3,
        radius: f32,
        material: usize,
        transform: ?TransformationProxy = null,
    } = null,
    plane: ?struct {
        normal: Vec3,
        origin: Pt3,
        material: usize,
        transform: ?TransformationProxy = null,
    } = null,
    cylinder: ?struct {
        origin: Pt3,
        radius: f32,
        material: usize,
        transform: ?TransformationProxy = null,
    } = null,
};

const LightProxy = struct {
    ambient: ?AmbientLight = null,
    point: ?PointLight = null,
};

const ConfigProxy = struct {
    camera: Camera,
    materials: []Material,
    objects: []ObjectProxy,
    lights: []LightProxy,
};

fn transform_proxy_to_transform(transform: ?TransformationProxy, alloc: std.mem.Allocator) !?Transformation {
    if (transform) |t| {
        const y = try alloc.create(TransformationProxy);
        if (t.translation) |i| {
            y.translation = i;
            return y.translation.?.transform();
        } else if (t.rotation) |i| {
            y.rotation = i;
            return y.rotation.?.transform();
        } else {
            unreachable;
        }
    }
    return null;
}

pub const Config = struct {
    const Self = @This();

    pub fn fromFilePath(path: []const u8, allocator: std.mem.Allocator) !Self {
        // TODO: Check if there is a better way to do that
        // Cause right now it looks a little bit silly :3
        const data = try std.fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
        defer allocator.free(data);
        return fromSlice(data, allocator);
    }

    fn fromSlice(data: []const u8, allocator: std.mem.Allocator) !Self {
        const proxy = try std.json.parseFromSliceLeaky(ConfigProxy, allocator, data, .{
            .allocate = .alloc_always,
            .ignore_unknown_fields = true,
        });
        var conf = Self{
            .camera = proxy.camera,
            .objects = try allocator.alloc(Object, proxy.objects.len),
            .lights = try allocator.alloc(Light, proxy.lights.len),
        };
        for (proxy.objects, 0..) |obj, i| {
            if (obj.sphere) |item| {
                conf.objects[i] = Object{ .sphere = .{
                    .origin = item.origin,
                    .radius = item.radius,
                    .material = proxy.materials[item.material],
                    .transform = try transform_proxy_to_transform(item.transform, allocator),
                } };
            } else if (obj.plane) |item| {
                conf.objects[i] = Object{ .plane = .{
                    .origin = item.origin,
                    .normal = item.normal,
                    .material = proxy.materials[item.material],
                    .transform = try transform_proxy_to_transform(item.transform, allocator),
                } };
            } else if (obj.cylinder) |item| {
                conf.objects[i] = Object{ .cylinder = .{
                    .origin = item.origin,
                    .radius = item.radius,
                    .material = proxy.materials[item.material],
                    .transform = try transform_proxy_to_transform(item.transform, allocator),
                } };
            } else {
                unreachable;
            }
        }
        for (proxy.lights, 0..) |obj, i| {
            if (obj.point) |item| {
                conf.lights[i] = Light{ .point_light = item };
            } else if (obj.ambient) |item| {
                conf.lights[i] = Light{ .ambient_light = item };
            } else {
                unreachable;
            }
        }
        return conf;
    }

    camera: Camera,
    objects: []Object,
    lights: []Light,
};
