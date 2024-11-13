.section ".text.vectors"
.align 11  // 2048 byte alignment for vector table

.global vectors
vectors:
    // Current EL with SP0
    .align 7
    b       _start          // Synchronous
    .align 7
    b       el1_irq        // IRQ
    .align 7
    b       hang           // FIQ
    .align 7
    b       hang           // SError

    // Current EL with SPx
    .align 7
    b       hang           // Synchronous
    .align 7
    b       el1_irq        // IRQ
    .align 7
    b       hang           // FIQ
    .align 7
    b       hang           // SError

    // Lower EL using AArch64
    .align 7
    b       hang           // Synchronous
    .align 7
    b       hang           // IRQ
    .align 7
    b       hang           // FIQ
    .align 7
    b       hang           // SError

    // Lower EL using AArch32
    .align 7
    b       hang           // Synchronous
    .align 7
    b       hang           // IRQ
    .align 7
    b       hang           // FIQ
    .align 7
    b       hang           // SError

hang:
    b       hang

// Debug macro to print number in x0
.macro debug_x0
    stp     x0, x1, [sp, #-16]!
    stp     x29, x30, [sp, #-16]!
    bl      debug_print_num
    ldp     x29, x30, [sp], #16
    ldp     x0, x1, [sp], #16
.endm

// IRQ handler
el1_irq:
    // Save all registers
    sub     sp, sp, #(32 * 8)
    stp     x0, x1, [sp, #(0 * 16)]
    stp     x2, x3, [sp, #(1 * 16)]
    stp     x4, x5, [sp, #(2 * 16)]
    stp     x6, x7, [sp, #(3 * 16)]
    stp     x8, x9, [sp, #(4 * 16)]
    stp     x10, x11, [sp, #(5 * 16)]
    stp     x12, x13, [sp, #(6 * 16)]
    stp     x14, x15, [sp, #(7 * 16)]
    stp     x16, x17, [sp, #(8 * 16)]
    stp     x18, x19, [sp, #(9 * 16)]
    stp     x20, x21, [sp, #(10 * 16)]
    stp     x22, x23, [sp, #(11 * 16)]
    stp     x24, x25, [sp, #(12 * 16)]
    stp     x26, x27, [sp, #(13 * 16)]
    stp     x28, x29, [sp, #(14 * 16)]
    str     x30, [sp, #(15 * 16)]
    
    bl      handle_irq     // Call our Zig IRQ handler
    
    // Restore all registers
    ldp     x0, x1, [sp, #(0 * 16)]
    ldp     x2, x3, [sp, #(1 * 16)]
    ldp     x4, x5, [sp, #(2 * 16)]
    ldp     x6, x7, [sp, #(3 * 16)]
    ldp     x8, x9, [sp, #(4 * 16)]
    ldp     x10, x11, [sp, #(5 * 16)]
    ldp     x12, x13, [sp, #(6 * 16)]
    ldp     x14, x15, [sp, #(7 * 16)]
    ldp     x16, x17, [sp, #(8 * 16)]
    ldp     x18, x19, [sp, #(9 * 16)]
    ldp     x20, x21, [sp, #(10 * 16)]
    ldp     x22, x23, [sp, #(11 * 16)]
    ldp     x24, x25, [sp, #(12 * 16)]
    ldp     x26, x27, [sp, #(13 * 16)]
    ldp     x28, x29, [sp, #(14 * 16)]
    ldr     x30, [sp, #(15 * 16)]
    add     sp, sp, #(32 * 8)

    eret                   // Return from exception
