const std = @import("std");
const accept = @import("accept");
const terminal = @import("terminal");

const Mode = enum {
    full,
    minimal,
};

fn read() u8 {
    var b: [1]u8 = .{0};
    _ = std.os.read(0, &b) catch {
        return 0;
    };
    return b[0];
}

fn write(c: u8) void {
    var b: [1]u8 = .{c};
    _ = std.os.write(1, &b) catch {};
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const mode: Mode = .full;
    try terminal.makeRaw(0);
    defer terminal.restore(0);
    errdefer terminal.restore(0);

    var line: [10]u8 = .{0} ** 10;
    accept.init(&line);
    while (true) {
        const result = switch (mode) {
            .full => accept.handle(write, read()),
            .minimal => accept.handleMinimal(write, read()),
        };
        switch (result) {
            .canceled => break,
            .accepted => |l| {
                try stdout.print("\nAccepted: {s}\n", .{l});
                break;
            },
            else => {},
        }
    }
}
