.section ".text.boot"
.global _start

_start:
    // Check processor ID is 0
    mrs     x1, mpidr_el1
    and     x1, x1, #3
    cbz     x1, 2f
    // If we're not CPU 0, hang
1:  wfe
    b       1b

2:  // We are CPU 0
    // Set up the stack pointer
    ldr     x1, =_stack_top
    mov     sp, x1

    // Set up exception handlers
    ldr     x1, =vectors
    msr     vbar_el1, x1

    // Clear BSS
    ldr     x1, =__bss_start
    ldr     x2, =__bss_end
    sub     x2, x2, x1
3:  cbz     x2, 4f
    str     xzr, [x1], #8
    sub     x2, x2, #8
    b       3b

4:  // Jump to Zig code
    bl      kernel_main

    // Should never get here
5:  wfe
    b       5b

.section ".bss"
.align 16
.global _stack_bottom
_stack_bottom:
.zero 4096  // 4KB stack
.global _stack_top
_stack_top:
