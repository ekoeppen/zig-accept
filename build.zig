const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("accept", "src/main.zig");
    lib.setBuildMode(mode);
    lib.install();
}
