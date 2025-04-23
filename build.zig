const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "Zaytracer",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zmath = b.dependency("zmath", .{ .optimize = optimize, .target = target });
    const qoi = b.dependency("qoi", .{ .optimize = optimize, .target = target });
    const raylib = b.dependency("raylib_zig", .{ .optimize = optimize, .target = target });
    exe.root_module.addImport("zmath", zmath.module("root"));
    exe.root_module.addImport("qoi", qoi.module("qoi"));
    exe.root_module.addImport("raylib", raylib.module("raylib"));
    exe.linkLibrary(raylib.artifact("raylib"));
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_unit_tests.root_module.addImport("zmath", zmath.module("root"));
    exe_unit_tests.root_module.addImport("qoi", qoi.module("qoi"));
    exe_unit_tests.root_module.addImport("raylib", raylib.module("raylib"));
    exe_unit_tests.linkLibrary(raylib.artifact("raylib"));
    exe_unit_tests.linkLibC();

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
