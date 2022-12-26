const fsm = @import("fsm.zig");

const Type = enum {
    plain,
    c0,
    c1,
    csi,
    vt_app,
    incomplete,
};

pub const Result = union(Type) {
    plain: u8,
    c0: u8,
    c1: u8,
    csi: Csi,
    vt_app: u8,
    incomplete,
};

pub const Csi = struct {
    params: [3]u8,
    num_params: usize,
    final: u8,
};

const State = enum {
    input,
    esc,
    esc_csi_param,
    vt_app,
};

const Action = enum {
    plain,
    c1,
    start_param,
    update_param,
    param_done,
    vt_app,
};

var csi: Csi = undefined;

var key_fsm = fsm.Fsm(u8, State, Action){
    .state = .input,
    .transitions = &.{ .{
        .state = .input,
        .actions = &.{
            .{ .event = 27, .new_state = .esc },
            .{ .action = .plain },
        },
    }, .{
        .state = .esc,
        .actions = &.{
            .{ .event = '[', .action = .start_param, .new_state = .esc_csi_param },
            .{ .event = 'O', .new_state = .vt_app },
            .{ .action = .c1, .new_state = .input },
        },
    }, .{
        .state = .esc_csi_param,
        .actions = &.{
            .{ .event = ';', .action = .param_done, .new_state = .esc_csi_param },
            .{ .action = .update_param },
        },
    }, .{
        .state = .vt_app,
        .actions = &.{
            .{ .action = .vt_app, .new_state = .input },
        },
    } },
};

pub fn handle(c: u8) Result {
    if (key_fsm.input(c)) |action| {
        switch (action) {
            .plain => return if (c >= ' ' and c != 127) .{ .plain = c } else .{ .c0 = c },
            .c1 => return .{ .c1 = c },
            .start_param => {
                csi.num_params = 0;
                csi.params = .{ 0, 0, 0 };
            },
            .update_param => {
                if (c < '0' or c > '9') {
                    csi.final = c;
                    key_fsm.state = .input;
                    return .{ .csi = csi };
                } else if (csi.num_params < csi.params.len) {
                    csi.params[csi.num_params] = csi.params[csi.num_params] * 10 + c - '0';
                }
            },
            .param_done => csi.num_params += 1,
            .vt_app => return .{ .vt_app = c },
        }
    }
    return .{ .incomplete = {} };
}
