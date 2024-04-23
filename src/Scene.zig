const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const Light = @import("Light.zig").Light;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Plane = @import("Plane.zig").Plane;
const Transformation = @import("Transformation.zig").Transformation;
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
    const Self = @This();

    camera: Camera,
    objects: std.ArrayList(SceneObject),
    lights: std.ArrayList(SceneLight),
    transforms: std.ArrayList(Transformation),

    pub fn init(allocator: std.mem.Allocator, camera: Camera) Self {
        return Self{
            .camera = camera,
            .objects = std.ArrayList(SceneObject).init(allocator),
            .lights = std.ArrayList(SceneLight).init(allocator),
            .transforms = std.ArrayList(Transformation).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.objects.deinit();
        self.lights.deinit();
        self.transforms.deinit();
    }
};
