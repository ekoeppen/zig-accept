const std = @import("std");
const accept = @import("accept");

var termios: std.os.termios = undefined;

const Mode = enum {
    full,
    minimal,
};

fn makeRaw(fd: std.os.fd_t) !void {
    termios = try std.os.tcgetattr(fd);
    var raw = termios;
    raw.cflag |= std.c.CLOCAL | std.c.CREAD | std.c.HUPCL;
    raw.cflag &= ~(std.c.IXON | std.c.IXOFF);
    raw.lflag = 0;
    try std.os.tcsetattr(fd, .NOW, raw);
}

fn restore(fd: std.os.fd_t) void {
    std.os.tcsetattr(fd, .NOW, termios) catch {};
}

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
    try makeRaw(0);
    defer restore(0);
    errdefer restore(0);

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
