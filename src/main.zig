const keys = @import("keys.zig");
const Line = @import("line.zig").Line;

const State = enum {
    accepted,
    editing,
    up,
    down,
    tab,
    canceled,
};

pub const Result = union(State) {
    accepted: []u8,
    editing,
    up,
    down,
    tab,
    canceled,
};

pub var line: Line = undefined;

pub fn init(buffer: []u8) void {
    line.init(buffer);
}

pub fn handle(comptime write: fn (u8) void, c: u8) Result {
    switch (keys.handle(c)) {
        .plain => |char| line.insert(char),
        .c0 => |c0| switch (c0) {
            1 => line.home(),
            3 => return .canceled,
            4 => line.deleteRight(),
            8, 127 => line.deleteLeft(),
            5 => line.end(),
            9 => return .tab,
            10 => return Result{ .accepted = line.current() },
            else => {},
        },
        .csi => |csi| switch (csi.final) {
            'A' => return .up,
            'B' => return .down,
            'C' => line.right(),
            'D' => line.left(),
            '~' => switch (csi.params[0]) {
                1, 7 => line.home(),
                4, 8 => line.end(),
                3 => line.deleteRight(),
                else => {},
            },
            else => {},
        },
        else => {},
    }
    line.print(write);
    return .editing;
}

pub fn handleMinimal(comptime write: fn (u8) void, c: u8) Result {
    switch (keys.handle(c)) {
        .plain => |char| if (line.length < line.buffer.buffer.len) {
            write(c);
            line.buffer.buffer[line.length] = char;
            line.length += 1;
        },
        .c0 => |c0| switch (c0) {
            3 => return .canceled,
            9 => return .tab,
            10 => return .{ .accepted = line.current() },
            8, 127 => if (line.length > 0) {
                write(8);
                write(' ');
                write(8);
                line.length -= 1;
            },
            else => {},
        },
        .csi => |csi| switch (csi.final) {
            'A' => return .up,
            'B' => return .down,
            else => {},
        },
        else => {},
    }
    return .editing;
}
