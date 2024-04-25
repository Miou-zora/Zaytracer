const ColorRGB = @import("ColorRGB.zig").ColorRGB;
const std = @import("std");

pub const AmbientLight = struct {
    intensity: f32,
    color: ColorRGB,
};

test {
    std.testing.refAllDecls(@This());
}
