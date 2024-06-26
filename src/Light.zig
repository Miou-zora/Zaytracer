const Pt3 = @import("Pt3.zig").Pt3;
const ColorRGB = @import("ColorRGB.zig").ColorRGB;
const std = @import("std");

pub const Light = struct {
    intensity: f32,
    color: ColorRGB,
    position: Pt3,
};

test {
    std.testing.refAllDecls(@This());
}
