const std = @import("std");

pub const ColorRGB = struct {
    r: f32,
    g: f32,
    b: f32,
};

test {
    std.testing.refAllDecls(@This());
}
