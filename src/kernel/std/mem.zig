pub fn copy(dest: [*]u8, src: [*]u8, n: usize) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        dest[i] = src[i];
    }
}

pub fn set(dest: [*]u8, value: u8, n: usize) void {
    var i: usize = 0;
    while (i < n) : (i += 1) {
        dest[i] = value;
    }
}

pub fn move(dest: [*]u8, source: [*]const u8, n: usize) void {
    if (@intFromPtr(dest) < @intFromPtr(source)) {
        // Copy forwards
        var i: usize = 0;
        while (i < n) : (i += 1) {
            dest[i] = source[i];
        }
    } else {
        // Copy backwards to handle overlapping regions
        var i: usize = n;
        while (i > 0) {
            i -= 1;
            dest[i] = source[i];
        }
    }
}
