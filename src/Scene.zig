const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const Light = @import("Light.zig").Light;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Plane = @import("Plane.zig").Plane;
const std = @import("std");

pub const SceneObject = union(enum) {
    sphere: Sphere,
    plane: Plane,
    cylinder: Cylinder,
};

pub const SceneLight = union(enum) {
    point_light: Light,
    ambient_light: f32, // TODO: Have a properly defined ambient_light type
};

pub const Scene = struct {
    camera: Camera,
    objects: std.ArrayList(SceneObject),
    lights: std.ArrayList(SceneLight),
};
