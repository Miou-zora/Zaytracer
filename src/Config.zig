const std = @import("std");
const Camera = @import("Camera.zig").Camera;

pub const Config = struct {
    const Self = @This();

    pub fn fromFilePath(path: []const u8, allocator: std.mem.Allocator) !std.json.Parsed(Self) {
        // TODO: Check if there is a better way to do that
        // Cause right now it looks a little bit silly :3
        const data = try std.fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
        defer allocator.free(data);
        return fromSlice(data, allocator);
    }

    fn fromSlice(data: []const u8, allocator: std.mem.Allocator) !std.json.Parsed(Self) {
        return std.json.parseFromSlice(Self, allocator, data, .{ .allocate = .alloc_always });
    }

    camera: Camera,
};