const UART_DR = 0x09000000; // QEMU UART Data Register

pub fn puts(str: []const u8) void {
    for (str) |c| {
        putc(c);
    }
}

pub fn putc(c: u8) void {
    const uart: *volatile u8 = @ptrFromInt(UART_DR);
    uart.* = c;
}
