pub fn length(str: [*:0]const u8) usize {
    var i: usize = 0;
    while (str[i] != 0) : (i += 1) {}
    return i;
}

pub fn compare(str: [*:0]const u8, other: [*:0]const u8) i32 {
    var i: usize = 0;
    while (str[i] != 0 and other[i] != 0 and str[i] == other[i]) : (i += 1) {}
    return @as(i32, str[i]) - @as(i32, other[i]);
}
