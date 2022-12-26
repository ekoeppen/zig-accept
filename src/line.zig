pub const Buffer = struct {
    buffer: []u8,

    fn insert(self: *Buffer, index: usize, c: u8) void {
        if (index > self.buffer.len - 1) return;
        var n = self.buffer.len - 1;
        while (n > index) {
            self.buffer[n] = self.buffer[n - 1];
            n -= 1;
        }
        self.buffer[index] = c;
    }

    fn deleteRight(self: *Buffer, index: usize) void {
        if (index == self.buffer.len - 1) return;
        var n = index;
        while (n < self.buffer.len - 2) {
            self.buffer[n] = self.buffer[n + 1];
            n += 1;
        }
    }

    fn deleteLeft(self: *Buffer, index: usize) void {
        if (index == 0) return;
        var n = index - 1;
        while (n < self.buffer.len - 2) {
            self.buffer[n] = self.buffer[n + 1];
            n += 1;
        }
    }
};

pub const Line = struct {
    buffer: Buffer,
    pos: usize,
    length: usize,

    pub fn init(self: *Line, buffer: []u8) void {
        self.buffer.buffer = buffer;
        self.pos = 0;
        self.length = 0;
    }

    pub fn home(self: *Line) void {
        self.pos = 0;
    }

    pub fn end(self: *Line) void {
        self.pos = self.length;
    }

    pub fn left(self: *Line) void {
        if (self.pos > 0) self.pos -= 1;
    }

    pub fn right(self: *Line) void {
        if (self.pos < self.length) self.pos += 1;
    }

    pub fn deleteRight(self: *Line) void {
        if (self.pos < self.length) {
            self.buffer.deleteRight(self.pos);
            self.length -= 1;
        }
    }

    pub fn deleteLeft(self: *Line) void {
        if (self.pos > 0) {
            self.buffer.deleteLeft(self.pos);
            self.pos -= 1;
            self.length -= 1;
        }
    }

    pub fn insert(self: *Line, c: u8) void {
        self.buffer.insert(self.pos, c);
        if (self.length < self.buffer.buffer.len) {
            self.pos += 1;
            self.length += 1;
        }
    }

    pub fn print(self: *Line, comptime write: fn (u8) void) void {
        write(27);
        write('[');
        write('1');
        write('G');
        for (self.current()) |b| write(b);
        write(' ');

        write(27);
        write('[');
        write(@truncate(u8, 48 + (self.pos + 1) / 10));
        write(@truncate(u8, 48 + (self.pos + 1) % 10));
        write('G');
    }

    pub fn current(self: *Line) []u8 {
        return self.buffer.buffer[0..self.length];
    }
};
