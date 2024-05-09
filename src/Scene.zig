const Sphere = @import("Sphere.zig").Sphere;
const Camera = @import("Camera.zig").Camera;
const Light = @import("Light.zig").Light;
const AmbientLight = @import("AmbientLight.zig").AmbientLight;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Plane = @import("Plane.zig").Plane;
const std = @import("std");
const Triangle = @import("Triangle.zig").Triangle;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Payload = @import("Payload.zig").Payload;
const Ray = @import("Ray.zig").Ray;
const zmath = @import("zmath");
const Pt3 = @import("Pt3.zig").Pt3;
const rl = @cImport({
    @cInclude("raylib.h");
});

fn compute_record_with_transform(obj: anytype, ray: Ray, tmp_payload: *Payload) bool {
    if (obj.transform) |transform| {
        if (obj.hits(transform.ray_global_to_object(&ray), tmp_payload)) {
            transform.compute_pl_world_pt(tmp_payload);
            return true;
        }
        return false;
    } else {
        return obj.hits(ray, tmp_payload);
    }
}

fn fetch_closest_object_with_transform(obj: anytype, closest_hit: *Payload, ray: Ray, t_min: f32, t_max: f32, tmp_payload: *Payload) bool {
    if (!compute_record_with_transform(obj, ray, tmp_payload)) {
        return false;
    }
    const dist: f32 = zmath.length3(tmp_payload.intersection_point_world - ray.origin)[0];
    const current_dist: f32 = zmath.length3(closest_hit.intersection_point_world - ray.origin)[0]; // do not compute this all the time
    if ((dist < current_dist) and dist > t_min and dist < t_max) {
        closest_hit.intersection_point_obj = tmp_payload.intersection_point_obj;
        closest_hit.intersection_point_world = tmp_payload.intersection_point_world;
    }
    return true;
}

pub const SceneObject = union(enum) {
    const Self = @This();

    sphere: Sphere,
    plane: Plane,
    cylinder: Cylinder,
    triangle: Triangle,

    pub inline fn fetch_closest_object(self: *const Self, current_closest_hit: *Payload, ray: Ray, t_min: f32, t_max: f32, tmp_payload: *Payload) bool {
        switch (self.*) {
            .sphere => |item| {
                return fetch_closest_object_with_transform(item, current_closest_hit, ray, t_min, t_max, tmp_payload);
            },
            .plane => |item| {
                return fetch_closest_object_with_transform(item, current_closest_hit, ray, t_min, t_max, tmp_payload);
            },
            .cylinder => |item| {
                return fetch_closest_object_with_transform(item, current_closest_hit, ray, t_min, t_max, tmp_payload);
            },
            .triangle => |item| {
                return fetch_closest_object_with_transform(item, current_closest_hit, ray, t_min, t_max, tmp_payload);
            },
        }
    }

    fn load_hitRecord(obj: anytype, obj_pt: *const Pt3) HitRecord {
        if (obj.transform) |transform| {
            return transform.hitRecord_object_to_global(obj.to_hitRecord(obj_pt));
        } else {
            return obj.to_hitRecord(obj_pt);
        }
    }

    pub inline fn to_hitRecord(self: *const Self, obj_pt: *const Pt3) HitRecord {
        switch (self.*) {
            .sphere => |item| {
                return load_hitRecord(item, obj_pt);
            },
            .plane => |item| {
                return load_hitRecord(item, obj_pt);
            },
            .cylinder => |item| {
                return load_hitRecord(item, obj_pt);
            },
            .triangle => |item| {
                return load_hitRecord(item, obj_pt);
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
