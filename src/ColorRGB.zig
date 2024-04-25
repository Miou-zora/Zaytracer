const std = @import("std");

pub const ColorRGB = struct {
    red: f32,
    green: f32,
    blue: f32,
};

test {
    std.testing.refAllDecls(@This());
}
