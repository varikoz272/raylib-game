const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "horror",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // exe.linkSystemLibrary("c");
    exe.linkLibC();

    exe.addIncludePath(.{ .path = "./include" });
    exe.addLibraryPath(.{ .path = "./lib" });

    // exe.linkSystemLibrary("opengl32");
    // exe.linkSystemLibrary("glfw3");
    // exe.linkSystemLibrary("gdi32");
    // exe.linkSystemLibrary("winmm");
    exe.linkSystemLibrary("raylibdll");

    b.installFile("lib/raylib.dll", "bin/raylib.dll");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
