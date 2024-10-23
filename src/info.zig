const arch_info = @import("arch/info.zig");

pub const entries = arch_info.page_size / @sizeOf(usize);
pub const page_size = arch_info.page_size;
