const std = @import("std");

pub const ColorRGB = struct {
    red: f16,
    green: f16,
    blue: f16,
};

test {
    std.testing.refAllDecls(@This());
}
