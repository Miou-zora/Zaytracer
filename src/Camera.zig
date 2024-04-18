const Pt3 = @import("Pt3.zig").Pt3;
const Rect3 = @import("Rect3.zig").Rect3;
const Ray = @import("Ray.zig").Ray;

pub const Camera = struct {
    const Self = @This();

    origin: Pt3,
    screen: Rect3,

    pub fn createRayFromAngles(self: *const Self, u: f32, v: f32) Ray {
        return Ray{
            .origin = self.origin,
            .direction = self.screen.pointAt(u, v).subVec3(self.origin),
        };
    }
};
