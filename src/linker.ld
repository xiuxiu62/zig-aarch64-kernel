ENTRY(_start)

SECTIONS {
    . = 0x40080000;    /* Standard AArch64 kernel load address */
    
    .text.boot : {
        *(.text.boot)
    }

    .text.vectors ALIGN(2048) : {
        *(.text.vectors)
    }
    
    .text : {
        *(.text)
        *(.text.*)
    }
    
    .rodata : ALIGN(4K) {
        *(.rodata)
        *(.rodata.*)
    }
    
    .data : ALIGN(4K) {
        *(.data)
        *(.data.*)
    }
    
    .bss : ALIGN(4K) {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(16);
        __bss_end = .;
    }

    .heap ALIGN(4K) : {
        __heap_start = .;
        *(.heap)
        . = ALIGN(4K);
        __heap_end = .;
    }
}
