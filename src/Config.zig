const std = @import("std");
const Camera = @import("Camera.zig").Camera;
const Material = @import("Material.zig").Material;

const ConfigProxy = struct {
    camera: Camera,
    materials: []Material,
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
        return Self{
            .camera = proxy.camera,
            .materials = proxy.materials,
        };
    }

    camera: Camera,
    materials: []Material,
};
