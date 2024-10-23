const info = @import("info.zig");

const freelist_init: [info.entries]usize = undefined;
const to_freelist_init: *[info.entries]usize = &freelist_init;

var head: struct {
    page: usize = undefined,
    index: usize = 1,
} = .{};

fn ptoptr(page: usize, result: type) [*]result {
    return @as([*]result, @ptrFromInt(@as(result, @bitCast(@as(usize, page)))));
}

pub fn init() void {
    head.page = @intFromPtr(&freelist_init);
}

pub fn free(page: usize) void {
    if (head.index < info.entries) {
        ptoptr(head.page, usize)[head.index] = page;
        head.index += 1;
        return;
    }

    const top = ptoptr(head.page, usize)[info.entries];
    ptoptr(head.page, usize)[info.entries] = page;
    ptoptr(top, usize)[0] = head.page;
    head.page = top;
}

pub fn alloc() usize {
    const out = ptoptr(head.page, usize)[head.index];

    if (head.index > 0) {
        head.index -= 1;
        return out;
    }

    head.page = out;
    head.index = info.entries;

    const ptr = &ptoptr(head.page, usize)[info.entries];
    const top = ptr.*;
    ptr.* = out;

    return top;
}
