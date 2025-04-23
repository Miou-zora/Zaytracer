const std = @import("std");
const Camera = @import("Camera.zig").Camera;
const Material = @import("Material.zig").Material;
// const Pt3 = @import("Pt3.zig").Pt3;
// const zmath = @import("zmath");
// const Vec = zmath.Vec;
const Scene = @import("Scene.zig");
const Sphere = @import("Sphere.zig").Sphere;
const Object = Scene.SceneObject;
const AmbientLight = @import("AmbientLight.zig").AmbientLight;
const PointLight = @import("Light.zig").Light;
const Light = Scene.SceneLight;
const Vertex = @import("Vertex.zig").Vertex;
const Image = Scene.Image;
const rl = @import("raylib");
const ColorRGB = @import("ColorRGB.zig").ColorRGB;
const Transform = @import("Transform.zig").Transform;

const Vec3Proxy = struct {
    x: f32,
    y: f32,
    z: f32,
};
const Pt3Proxy = struct {
    x: f32,
    y: f32,
    z: f32,
};

const VertexProxy = struct {
    position: Pt3Proxy,
    texCoord: @Vector(2, f32),
};

const ObjectProxy = struct {
    sphere: ?struct {
        origin: Pt3Proxy,
        radius: f32,
        material: usize,
        transforms: ?[]TransformProxy = null,
    } = null,
    plane: ?struct {
        normal: Vec3Proxy,
        origin: Pt3Proxy,
        material: usize,
        transforms: ?[]TransformProxy = null,
    } = null,
    cylinder: ?struct {
        origin: Pt3Proxy,
        radius: f32,
        material: usize,
        transforms: ?[]TransformProxy = null,
    } = null,
    triangle: ?struct {
        va: VertexProxy,
        vb: VertexProxy,
        vc: VertexProxy,
        textIdx: usize,
        transforms: ?[]TransformProxy = null,
    } = null,
};

const ColorRGBProxy = struct {
    r: f32,
    g: f32,
    b: f32,
};

const AmbientLightProxy = struct {
    color: ColorRGBProxy,
    intensity: f32,
};

const PointLightProxy = struct {
    color: ColorRGBProxy,
    intensity: f32,
    position: Pt3Proxy,
};

const LightProxy = struct {
    ambient: ?AmbientLightProxy = null,
    point: ?PointLightProxy = null,
};

const AssetProxy = struct {
    imageName: [:0]const u8,
};

const MaterialProxy = struct {
    color: ColorRGBProxy,
    specular: f32,
    reflective: f32,
};

const ConfigProxy = struct {
    camera: Camera,
    materials: []MaterialProxy,
    objects: []ObjectProxy,
    lights: []LightProxy,
    assets: []AssetProxy,
};

const TransformProxy = struct {
    translation: ?struct {
        x: f32 = 0,
        y: f32 = 0,
        z: f32 = 0,
    } = null,
    rotation: ?struct {
        pitch: f32 = 0,
        yaw: f32 = 0,
        roll: f32 = 0,
    } = null,
    scale: ?struct {
        x: f32 = 1,
        y: f32 = 1,
        z: f32 = 1,
    } = null,
};

fn transform_proxy_to_transform(transforms: []TransformProxy) Transform {
    var custom_transform = Transform{};
    for (transforms) |tr| {
        if (tr.translation) |t| {
            custom_transform.translate(t.x, t.y, t.z);
        } else if (tr.rotation) |r| {
            custom_transform.rotate(r.pitch, r.yaw, r.roll);
        } else if (tr.scale) |s| {
            custom_transform.scale(s.x, s.y, s.z);
        } else {
            unreachable;
        }
    }
    return custom_transform;
}

fn load_material(proxy: MaterialProxy) Material {
    return Material{
        .color = ColorRGB{ proxy.color.r, proxy.color.g, proxy.color.b, 0 },
        .specular = proxy.specular,
        .reflective = proxy.reflective,
    };
}

pub const Config = struct {
    const Self = @This();

    camera: Camera,
    objects: []Object,
    lights: []Light,
    assets: []Image,

    pub fn fromFilePath(path: []const u8, allocator: std.mem.Allocator) !Self {
        // TODO: Check if there is a better way to do that
        // Cause right now it looks a little bit silly :3
        const data = try std.fs.cwd().readFileAlloc(allocator, path, std.math.maxInt(usize));
        defer allocator.free(data);
        return fromSlice(data, allocator);
    }

    fn fromSlice(data: []const u8, allocator: std.mem.Allocator) !Self {
        const proxy = try std.json.parseFromSliceLeaky(ConfigProxy, allocator, data, .{
            .allocate = .alloc_always,
            .ignore_unknown_fields = true,
        });
        var conf = Self{
            .camera = proxy.camera,
            .objects = try allocator.alloc(Object, proxy.objects.len),
            .lights = try allocator.alloc(Light, proxy.lights.len),
            .assets = try allocator.alloc(Image, proxy.assets.len),
        };
        for (proxy.assets, 0..) |obj, i| {
            const image = try rl.loadImage(obj.imageName);
            conf.assets[i] = Image{
                .rlImage = image,
                .rlColors = try rl.loadImageColors(image),
            };
        }
        for (proxy.objects, 0..) |obj, i| {
            if (obj.sphere) |item| {
                if (item.transforms) |trs| {
                    conf.objects[i] = Object{
                        .sphere = .{
                            .origin = .{ item.origin.x, item.origin.y, item.origin.z, 1 },
                            .radius = item.radius,
                            .material = load_material(proxy.materials[item.material]),
                            .transform = transform_proxy_to_transform(trs),
                        },
                    };
                } else {
                    conf.objects[i] = Object{
                        .sphere = .{
                            .origin = .{ item.origin.x, item.origin.y, item.origin.z, 1 },
                            .radius = item.radius,
                            .material = load_material(proxy.materials[item.material]),
                        },
                    };
                }
            } else if (obj.plane) |item| {
                if (item.transforms) |trs| {
                    conf.objects[i] = Object{
                        .plane = .{
                            .origin = .{ item.origin.x, item.origin.y, item.origin.z, 1 },
                            .normal = .{ item.normal.x, item.normal.y, item.normal.z, 1 },
                            .material = load_material(proxy.materials[item.material]),
                            .transform = transform_proxy_to_transform(trs),
                        },
                    };
                } else {
                    conf.objects[i] = Object{
                        .plane = .{
                            .origin = .{ item.origin.x, item.origin.y, item.origin.z, 1 },
                            .normal = .{ item.normal.x, item.normal.y, item.normal.z, 0 },
                            .material = load_material(proxy.materials[item.material]),
                        },
                    };
                }
            } else if (obj.cylinder) |item| {
                if (item.transforms) |trs| {
                    conf.objects[i] = Object{
                        .cylinder = .{
                            .origin = .{ item.origin.x, item.origin.y, item.origin.z, 1 },
                            .radius = item.radius,
                            .material = load_material(proxy.materials[item.material]),
                            .transform = transform_proxy_to_transform(trs),
                        },
                    };
                } else {
                    conf.objects[i] = Object{
                        .cylinder = .{
                            .origin = .{ item.origin.x, item.origin.y, item.origin.z, 1 },
                            .radius = item.radius,
                            .material = load_material(proxy.materials[item.material]),
                        },
                    };
                }
            } else if (obj.triangle) |item| {
                if (item.transforms) |trs| {
                    conf.objects[i] = Object{ .triangle = .{
                        .va = .{
                            .position = .{ item.va.position.x, item.va.position.y, item.va.position.z, 1 },
                            .texCoord = item.va.texCoord,
                        },
                        .vb = .{
                            .position = .{ item.vb.position.x, item.vb.position.y, item.vb.position.z, 1 },
                            .texCoord = item.vb.texCoord,
                        },
                        .vc = .{
                            .position = .{ item.vc.position.x, item.vc.position.y, item.vc.position.z, 1 },
                            .texCoord = item.vc.texCoord,
                        },
                        .text = &conf.assets[item.textIdx],
                        .transform = transform_proxy_to_transform(trs),
                    } };
                } else {
                    conf.objects[i] = Object{ .triangle = .{
                        .va = .{
                            .position = .{ item.va.position.x, item.va.position.y, item.va.position.z, 1 },
                            .texCoord = item.va.texCoord,
                        },
                        .vb = .{
                            .position = .{ item.vb.position.x, item.vb.position.y, item.vb.position.z, 1 },
                            .texCoord = item.vb.texCoord,
                        },
                        .vc = .{
                            .position = .{ item.vc.position.x, item.vc.position.y, item.vc.position.z, 1 },
                            .texCoord = item.vc.texCoord,
                        },
                        .text = &conf.assets[item.textIdx],
                    } };
                }
            } else {
                unreachable;
            }
        }
        for (proxy.lights, 0..) |obj, i| {
            if (obj.point) |item| {
                conf.lights[i] = Light{ .point_light = .{
                    .color = .{ item.color.r, item.color.g, item.color.b, 0 },
                    .intensity = item.intensity,
                    .position = .{ item.position.x, item.position.y, item.position.z, 1 },
                } };
            } else if (obj.ambient) |item| {
                conf.lights[i] = Light{ .ambient_light = .{
                    .color = .{ item.color.r, item.color.g, item.color.b, 0 },
                    .intensity = item.intensity,
                } };
            } else {
                unreachable;
            }
        }
        return conf;
    }
};
