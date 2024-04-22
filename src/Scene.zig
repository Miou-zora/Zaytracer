const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const Light = @import("Light.zig").Light;

const SceneObject = union(enum) {
    sphere: Sphere,
};

const SceneLight = union(enum) {
    point_light: Light,
    ambient_light: f32, // TODO: Have a properly defined ambient_light type
};

const Scene = struct {
    camera: Camera,
    objects: []SceneObject,
    lights: []SceneLight,
};
