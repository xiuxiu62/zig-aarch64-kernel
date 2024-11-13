const pic = @import("pic.zig");
const uart = @import("uart.zig");

const KEYBOARD_DATA = 0x09000060; // Updated for MMIO

pub const InterruptState = struct {
    var enabled: bool = false;
};

pub fn enable_interrupts() void {
    asm volatile ("msr daifclr, #2"); // Enable IRQ
    InterruptState.enabled = true;
}

pub fn disable_interrupts() void {
    asm volatile ("msr daifset, #2"); // Disable IRQ
    InterruptState.enabled = false;
}

pub fn are_interrupts_enabled() bool {
    return InterruptState.enabled;
}

export fn handle_irq() void {
    // Read IRQ number from PIC
    const irq = pic.get_interrupt();

    if (irq) |irq_num| {
        switch (irq_num) {
            1 => handle_keyboard(), // IRQ 1 is keyboard
            else => {},
        }

        // Send EOI (End Of Interrupt)
        pic.send_eoi(irq_num);
    }
}

pub fn handle_scancode(scancode: u8) void {
    // For now, just print the scancode
    const hex_chars = "0123456789ABCDEF";
    uart.puts("Scancode: 0x");
    uart.putc(hex_chars[scancode >> 4]);
    uart.putc(hex_chars[scancode & 0xF]);
    uart.putc('\n');
}

fn handle_keyboard() void {
    // Read from keyboard data port using MMIO
    const kbd_data: *volatile u8 = @ptrFromInt(KEYBOARD_DATA);
    const scancode = kbd_data.*;
    handle_scancode(scancode);
}
