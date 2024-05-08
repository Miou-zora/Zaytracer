const std = @import("std");
const zmath = @import("zmath");

pub const ColorRGB = zmath.Vec;

test {
    std.testing.refAllDecls(@This());
}
