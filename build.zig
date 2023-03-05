const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    _ = b.standardTargetOptions(.{});
    _ = b.standardOptimizeOption(.{});
    _ = b.addModule("accept", .{ .source_file = .{ .path = "src/main.zig" } });
}
