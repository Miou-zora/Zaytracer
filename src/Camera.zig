const Pt3 = @import("Pt3.zig").Pt3;
const Rect3 = @import("Rect3.zig").Rect3;
const Ray = @import("Ray.zig").Ray;

pub const Camera = struct {
    const Self = @This();

    origin: Pt3,
    screen: Rect3,

    pub fn createRay(self: *const Self, u: f32, v: f32) Ray {
        return Ray{
            .origin = self.origin,
            .direction = self.screen.pointAt(u, v).subVec3(self.origin),
        };
    }
};

test "casual" {
    const std = @import("std");
    const camera = Camera{
        .origin = Pt3.nil(),
        .screen = .{
            .origin = .{
                .x = -0.5,
                .y = 1,
                .z = -0.5,
            },
            .left = .{
                .x = 1,
                .y = 0,
                .z = 0,
            },
            .top = .{
                .x = 0,
                .y = 0,
                .z = 1,
            },
        },
    };
    try std.testing.expectEqual(camera.createRay(0.5, 0.5), Ray{ .direction = .{ .x = 0, .y = 1, .z = 0 }, .origin = .{ .x = 0, .y = 0, .z = 0 } });
    try std.testing.expectEqual(camera.createRay(1, 1), Ray{ .direction = .{ .x = 0.5, .y = 1, .z = 0.5 }, .origin = .{ .x = 0, .y = 0, .z = 0 } });
    try std.testing.expectEqual(camera.createRay(0, 0), Ray{ .direction = .{ .x = -0.5, .y = 1, .z = -0.5 }, .origin = .{ .x = 0, .y = 0, .z = 0 } });
}
