const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const Light = @import("Light.zig").Light;
const AmbientLight = @import("AmbientLight.zig").AmbientLight;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Plane = @import("Plane.zig").Plane;
const Transformation = @import("Transformation.zig").Transformation;
const std = @import("std");
const Triangle = @import("Triangle.zig").Triangle;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Ray = @import("Ray.zig").Ray;
const rl = @cImport({
    @cInclude("raylib.h");
});

fn fetch_closest_object_with_transform(obj: anytype, closest_hit: *HitRecord, ray: Ray, t_min: f32, t_max: f32) void {
    if (obj.transform) |transform| {
        const new_ray = transform.ray_global_to_object(&ray, &obj.origin);
        const record = transform.hitRecord_object_to_global(obj.hits(new_ray), &obj.origin);
        if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
            closest_hit.* = record;
        }
    } else {
        const record = obj.hits(ray);
        if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
            closest_hit.* = record;
        }
    }
}

fn fetch_closest_object_without_transform(obj: anytype, closest_hit: *HitRecord, ray: Ray, t_min: f32, t_max: f32) void {
    const record = obj.hits(ray);
    if (record.hit and (!closest_hit.hit or record.t < closest_hit.t) and record.t > t_min and record.t < t_max) {
        closest_hit.* = record;
    }
}

pub const SceneObject = union(enum) {
    const Self = @This();

    sphere: Sphere,
    plane: Plane,
    cylinder: Cylinder,
    triangle: Triangle,

    pub inline fn fetch_closest_object(self: *const Self, current_closest_hit: *HitRecord, ray: Ray, t_min: f32, t_max: f32) void {
        switch (self.*) {
            .sphere => |item| {
                fetch_closest_object_with_transform(item, current_closest_hit, ray, t_min, t_max);
            },
            .plane => |item| {
                fetch_closest_object_with_transform(item, current_closest_hit, ray, t_min, t_max);
            },
            .cylinder => |item| {
                fetch_closest_object_with_transform(item, current_closest_hit, ray, t_min, t_max);
            },
            .triangle => |item| {
                fetch_closest_object_without_transform(item, current_closest_hit, ray, t_min, t_max);
            },
        }
    }
};

pub const SceneLight = union(enum) {
    point_light: Light,
    ambient_light: AmbientLight,
};

pub const Image = struct {
    rlImage: rl.Image,
    rlColors: [*]rl.Color,
};

pub const Asset = union(enum) {
    image: Image,
};

pub const Scene = struct {
    const Self = @This();

    camera: Camera,
    objects: std.ArrayList(SceneObject),
    lights: std.ArrayList(SceneLight),

    pub fn init(allocator: std.mem.Allocator, camera: Camera) Self {
        return Self{
            .camera = camera,
            .objects = std.ArrayList(SceneObject).init(allocator),
            .lights = std.ArrayList(SceneLight).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.objects.deinit();
        self.lights.deinit();
    }
};
