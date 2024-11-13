const uart = @import("uart.zig");

pub const HEAP_SIZE = 1024 * 1024;

var heap_memory: [HEAP_SIZE]u8 align(16) linksection(".heap") = undefined;

pub const BumpAllocator = @This();

const Error = error{
    OutOfMemory,
};

next_addr: usize,
heap_end: usize,

pub fn create() BumpAllocator {
    return .{
        .next_addr = @intFromPtr(&heap_memory),
        .heap_end = @intFromPtr(&heap_memory) + HEAP_SIZE,
    };
}

pub fn alloc(allocator: *BumpAllocator, size: usize, alignment: usize) Error![]u8 {
    const current_addr = allocator.next_addr;

    // Calculate aligned address
    const aligned_addr = align_forward(current_addr, alignment);
    const next_addr = aligned_addr + size;

    // Check if we have enough space
    if (next_addr > allocator.heap_end) {
        return Error.OutOfMemory;
    }

    // Update allocation pointer
    allocator.next_addr = next_addr;

    // Return slice of allocated memory
    return @as([*]u8, @ptrFromInt(aligned_addr))[0..size];
}

// pub fn free(allocator: *BumpAllocator) void {}

fn align_forward(addr: usize, alignment: usize) usize {
    return (addr + (alignment - 1)) & ~(alignment - 1);
}
