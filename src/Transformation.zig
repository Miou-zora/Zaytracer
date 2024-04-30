const Translation = @import("Translation.zig").Translation;
const Rotation = @import("Rotation.zig").Rotation;
const Ray = @import("Ray.zig").Ray;
const HitRecord = @import("HitRecord.zig").HitRecord;
const Cylinder = @import("Cylinder.zig").Cylinder;
const Pt3 = @import("Pt3.zig").Pt3;

pub const Transformation = struct {
    const Self = @This();

    ptr: *const anyopaque,
    rayGlobalToObjectFn: *const fn (*const anyopaque, Ray, Pt3) Ray,
    hitRecordObjectToGlobalFn: *const fn (*const anyopaque, HitRecord, Pt3) HitRecord,

    pub fn init(ptr: anytype) Self {
        const Ptr = @TypeOf(ptr);
        const ptr_info = @typeInfo(Ptr);

        if (ptr_info != .Pointer) @compileError("ptr must be a pointer");
        if (ptr_info.Pointer.size != .One) @compileError("ptr must be a single item pointer");

        const gen = struct {
            pub fn rayGlobalToObjectImpl(pointer: *const anyopaque, ray: Ray, origin: Pt3) Ray {
                const self = @as(Ptr, @ptrCast(@alignCast(pointer)));

                return @call(
                    .always_inline,
                    ptr_info.Pointer.child.ray_global_to_object,
                    .{ self, ray, origin },
                );
            }

            pub fn hitRecordObjectToGlobalImpl(pointer: *const anyopaque, hit_record: HitRecord, origin: Pt3) HitRecord {
                const self = @as(Ptr, @ptrCast(@alignCast(pointer)));

                return @call(
                    .always_inline,
                    ptr_info.Pointer.child.hitRecord_object_to_global,
                    .{ self, hit_record, origin },
                );
            }
        };

        return .{
            .ptr = ptr,
            .rayGlobalToObjectFn = gen.rayGlobalToObjectImpl,
            .hitRecordObjectToGlobalFn = gen.hitRecordObjectToGlobalImpl,
        };
    }

    pub inline fn ray_global_to_object(self: *const Self, ray: Ray, origin: Pt3) Ray {
        return self.rayGlobalToObjectFn(self.ptr, ray, origin);
    }

    pub inline fn hitRecord_object_to_global(self: *const Self, hit_record: HitRecord, origin: Pt3) HitRecord {
        return self.hitRecordObjectToGlobalFn(self.ptr, hit_record, origin);
    }
};
