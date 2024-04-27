const std = @import("std");
const Color = @import("ColorRGB.zig").ColorRGB;

pub const Material = struct {
    const Self = @This();
    color: Color,
    specular: f32,
    reflective: f32,

    pub fn nil() Self {
        return Material{
            .color = .{ .r = 0.0, .g = 0.0, .b = 0.0 },
            .specular = 0.0,
            .reflective = 0.0,
        };
    }
};

test {
    std.testing.refAllDecls(@This());
}
