const Pt3 = @import("Pt3.zig").Pt3;
const SceneObject = @import("Scene.zig").SceneObject;

pub const Payload = struct {
    const Self = @This();

    intersection_point_world: Pt3,
    intersection_point_obj: Pt3,
    obj: *const SceneObject,
};
