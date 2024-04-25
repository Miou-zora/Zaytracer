const std = @import("std");
const Color = @import("ColorRGB.zig").ColorRGB;

pub const Material = struct {
    const Self = @This();
    color: Color,
    specular: f32,

    pub fn nil() Self {
        return Material{
            .color = .{ .red = 0.0, .green = 0.0, .blue = 0.0 },
            .specular = 0.0,
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
