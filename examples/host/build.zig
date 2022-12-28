const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const stdout = std.io.getStdOut().writer();
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const target_info = try std.zig.system.NativeTargetInfo.detect(target);

    const exe = b.addExecutable("host", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addPackagePath("accept", "../../src/main.zig");
    exe.install();

    switch (target_info.target.os.tag) {
        .linux => exe.addPackagePath("terminal", "src/terminal_linux.zig"),
        .macos => exe.addPackagePath("terminal", "src/terminal_macos.zig"),
        else => {
            try stdout.print("\nUnsupported target: {}\n", .{target_info.target});
            return error.NotSupported;
        },
    }

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
