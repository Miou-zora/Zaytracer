const std = @import("std");
pub const Pt3 = @import("Vec3.zig").Vec3;

test {
    std.testing.refAllDecls(@This());
}
