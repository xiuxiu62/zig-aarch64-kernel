// PIC (Programmable Interrupt Controller) constants
// Memory-mapped I/O addresses for QEMU virt machine
const MMIO_BASE = 0x09000000; // Base address for MMIO
const PIC1_COMMAND = MMIO_BASE + 0x20;
const PIC1_DATA = MMIO_BASE + 0x21;
const PIC2_COMMAND = MMIO_BASE + 0xA0;
const PIC2_DATA = MMIO_BASE + 0xA1;

const ICW1_ICW4 = 0x01;
const ICW1_INIT = 0x10;
const ICW4_8086 = 0x01;

// Remap PIC interrupts to avoid conflicts
const PIC1_OFFSET = 0x20;
const PIC2_OFFSET = 0x28;

pub fn init() void {
    // Save masks
    const mask1 = mmio_read8(PIC1_DATA);
    const mask2 = mmio_read8(PIC2_DATA);

    // Start initialization sequence
    mmio_write8(PIC1_COMMAND, ICW1_INIT | ICW1_ICW4);
    io_wait();
    mmio_write8(PIC2_COMMAND, ICW1_INIT | ICW1_ICW4);
    io_wait();

    // Set vector offsets
    mmio_write8(PIC1_DATA, PIC1_OFFSET);
    io_wait();
    mmio_write8(PIC2_DATA, PIC2_OFFSET);
    io_wait();

    // Tell PICs about each other
    mmio_write8(PIC1_DATA, 4);
    io_wait();
    mmio_write8(PIC2_DATA, 2);
    io_wait();

    // Set 8086 mode
    mmio_write8(PIC1_DATA, ICW4_8086);
    io_wait();
    mmio_write8(PIC2_DATA, ICW4_8086);
    io_wait();

    // Restore masks
    mmio_write8(PIC1_DATA, mask1);
    mmio_write8(PIC2_DATA, mask2);
}

fn get_pic_port(irq: u8) struct { addr: usize, adjusted_irq: u3 } {
    if (irq >= 8) {
        return .{ .addr = PIC2_DATA, .adjusted_irq = @truncate(irq - 8) };
    } else {
        return .{ .addr = PIC1_DATA, .adjusted_irq = @truncate(irq) };
    }
}

pub fn set_mask(irq: u8) void {
    if (irq >= 16) return; // Invalid IRQ

    const pic_info = get_pic_port(irq);
    const value = mmio_read8(pic_info.addr) | (@as(u8, 1) << @as(u3, pic_info.adjusted_irq));
    mmio_write8(pic_info.addr, value);
}

pub fn clear_mask(irq: u8) void {
    if (irq >= 16) return; // Invalid IRQ

    const pic_info = get_pic_port(irq);
    const value = mmio_read8(pic_info.addr) & ~(@as(u8, 1) << @as(u3, pic_info.adjusted_irq));
    mmio_write8(pic_info.addr, value);
}

pub fn get_interrupt() ?u8 {
    // Read Interrupt Request Register
    mmio_write8(PIC1_COMMAND, 0x0B);
    const irr = mmio_read8(PIC1_COMMAND);
    if (irr == 0) return null;

    // Find first set bit (limited to 0-7 for PIC1)
    var i: u3 = 0;
    while (i < 8) : (i += 1) {
        if ((irr & (@as(u8, 1) << i)) != 0) {
            return i;
        }
    }
    return null;
}

pub fn send_eoi(irq: u8) void {
    if (irq >= 8) {
        mmio_write8(PIC2_COMMAND, 0x20);
    }
    mmio_write8(PIC1_COMMAND, 0x20);
}

fn mmio_write8(addr: usize, value: u8) void {
    const ptr: *volatile u8 = @ptrFromInt(addr);
    ptr.* = value;
}

fn mmio_read8(addr: usize) u8 {
    const ptr: *volatile u8 = @ptrFromInt(addr);
    return ptr.*;
}

fn io_wait() void {
    // Simple delay - in real hardware you might want to use a timer
    var i: usize = 0;
    while (i < 1000) : (i += 1) {
        asm volatile ("" ::: "memory");
    }
}
