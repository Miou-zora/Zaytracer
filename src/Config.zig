const std = @import("std");
const Camera = @import("Camera.zig").Camera;
const Material = @import("Material.zig").Material;
const Pt3 = @import("Pt3.zig").Pt3;
const Scene = @import("Scene.zig");
const Sphere = @import("Sphere.zig").Sphere;
const Object = Scene.SceneObject;

const ObjectProxy = struct {
    sphere: ?struct {
        origin: Pt3,
        radius: f32,
        material: usize,
    },
};

const ConfigProxy = struct {
    camera: Camera,
    materials: []Material,
    objects: []ObjectProxy,
};

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
        };
        for (proxy.objects, 0..) |obj, i| {
            if (obj.sphere) |item| {
                conf.objects[i] = Object{ .sphere = .{
                    .origin = item.origin,
                    .radius = item.radius,
                    .material = proxy.materials[item.material],
                    .transform = null,
                } };
            } else {
                unreachable;
            }
        }
        return conf;
    }

    camera: Camera,
    objects: []Object,
};
