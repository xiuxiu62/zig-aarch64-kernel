const uart = @import("uart.zig");
const pic = @import("pic.zig");
const irq = @import("irq.zig");
const BumpAlloctor = @import("alloc.zig");
const alloc = BumpAlloctor.alloc;

const mem = @import("std/mem.zig");

pub export fn kernel_main() callconv(.C) noreturn {
    uart.puts("##############\n");
    uart.puts("#            #\n");
    uart.puts("#   xiubox   #\n");
    uart.puts("#            #\n");
    uart.puts("##############\n\n");

    const allocator = BumpAlloctor.create();
    _ = allocator; // autofix

    // const things = alloc(&allocator, 256, 8) catch unreachable;
    // _ = things;
    // const message = "we did it";
    // @memcpy(things[0..message.len], message);
    // mem.copy(@ptrCast(things), @ptrCast(message), message.len);
    // uart.puts(things);
    // uart.putc(things[0]);

    pic.init();

    var i: u8 = 0;
    while (i < 16) : (i += 1) {
        pic.clear_mask(i);
    }

    // Enable keyboard IRQ
    pic.clear_mask(1);

    uart.puts("Enabling interrupts\n");
    irq.enable_interrupts();

    uart.puts("Ready for keyboard input\n");

    while (true) {
        halt();
    }
}

fn halt() void {
    asm volatile ("wfe");
}
