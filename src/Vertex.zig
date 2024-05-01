const Pt3 = @import("Pt3.zig").Pt3;
const ColorRGB = @import("ColorRGB.zig").ColorRGB;
const Vec3 = @import("Vec3.zig").Vec3;

pub const Vertex = struct {
    const Self = @This();

    position: Pt3,
    color: ColorRGB,
    // normal: Vec3,
    // texCoord: Vec2, // TODO: have Vec2 (or VecX (useful for quaternion))
};
