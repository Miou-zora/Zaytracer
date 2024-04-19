const std = @import("std");
pub const Pt3 = @import("Vec3.zig").Vec3;
// TODO: rename Pt3 to Vertex
test {
    std.testing.refAllDecls(@This());
}
