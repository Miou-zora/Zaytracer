const std = @import("std");
const zlm = @import("zlm");

const Frame = struct {
    height: f32,
    width: f32,
    pixels: []u8,

    pub fn init(height: f32, width: f32, allocator: *const std.mem.Allocator) !Frame {
        var self: Frame = undefined;

        self.height = height;
        self.width = width;
        self.pixels = try allocator.alloc(u8, @as(usize, @intFromFloat(height * width * 4)));

        return self;
    }

    pub fn free(self: *Frame, allocator: *const std.mem.Allocator) void {
        allocator.free(self.pixels);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
	const allocator = gpa.allocator();


    var frame = try Frame.init(10, 10, &allocator);
    defer frame.free(&allocator);
}
