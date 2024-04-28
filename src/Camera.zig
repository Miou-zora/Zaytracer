const Pt3 = @import("Pt3.zig").Pt3;
const Rect3 = @import("Rect3.zig").Rect3;
const Ray = @import("Ray.zig").Ray;
const std = @import("std");

pub const Camera = struct {
    const Self = @This();

    width: u32,
    height: u32,
    fov: f32,

    pub fn createRay(self: *const Self, x: f32, y: f32) Ray {
        const aspectRatio = @as(f32, @floatFromInt(self.height)) / @as(f32, @floatFromInt(self.width));
        const halfWidth = aspectRatio / 2;
        const TO_RAD = std.math.pi / 180.0;
        const distance = (halfWidth * @sin((180.0 - self.fov / 2 - 90.0) * TO_RAD)) / @sin(self.fov * TO_RAD);
        const screen = Rect3{
            .origin = Pt3{ .x = -0.5, .y = -halfWidth, .z = distance },
            .left = Pt3{ .x = 1, .y = 0, .z = 0 },
            .top = Pt3{ .x = 0, .y = aspectRatio, .z = 0 },
        };
        return Ray{
            .origin = Pt3.nil(),
            .direction = screen.pointAt(x, y).subVec3(Pt3.nil()),
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
