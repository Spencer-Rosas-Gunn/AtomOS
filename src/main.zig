const tty = @import("arch/tty.zig");
const pmm = @import("pmm.zig");
const info = @import("info.zig");

inline fn hlt() void {
    while (true) {
        asm volatile ("hlt");
    }
}

const mmap_entry = packed struct {
    size: u32,
    base_addr: u32,
    length: u32,
    mem_type: u32,
};

export fn kmain(magic: u32, raw_info: u32) callconv(.C) void {
    if (magic != 0x1BADB002) {
        tty.putsz("Multiboot Error!", 0x07, 0, 0);
        hlt();
    }

    // Initialize memory map
    const boot_info: [*]u32 = @ptrFromInt(@as(usize, raw_info));
    const mmap_length = boot_info[11];
    // Shift four bytes left as to capture the first size value
    const mmap_addr: [*]u8 = @ptrFromInt(@as(usize, @intFromPtr(&boot_info[12])) - 4);

    var i: usize = 0;
    while (i < mmap_length) {
        const entry = @as(*mmap_entry, @alignCast(@ptrCast(&mmap_addr[i])));
        i += entry.size;

        // Only process usable memory
        if (entry.mem_type != 1) {
            continue;
        }

        // Add mmap entry to freelist
        var j: usize = 0;
        while (j < entry.length / info.page_size) : (j += 1) {
            pmm.free(entry.base_addr / info.page_size + j);
        }
    }

    // Print "Hello World!"
    tty.putsz("Hello World!", 0x07, 0, 0);

    hlt();
}
