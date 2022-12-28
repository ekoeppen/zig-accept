const std = @import("std");

var termios: std.os.termios = undefined;

pub fn makeRaw(fd: std.os.fd_t) !void {
    termios = try std.os.tcgetattr(fd);
    var raw = termios;
    raw.cflag |= std.c.CLOCAL | std.c.CREAD | std.c.HUPCL;
    raw.cflag &= ~(std.c.IXON | std.c.IXOFF);
    raw.lflag = 0;
    try std.os.tcsetattr(fd, .NOW, raw);
}

pub fn restore(fd: std.os.fd_t) void {
    std.os.tcsetattr(fd, .NOW, termios) catch {};
}
