const vga_buf: [*]volatile u16 = @ptrFromInt(0xB8000);
const vga_width = 80;
const vga_height = 25;

pub fn putch(char: u8, color: u8, x: u8, y: u8) void {
        const pos: usize = (y * vga_width) + x;
        vga_buf[pos] = (@as(u16, color) << 8) | char;
}

pub fn putsz(str: []const u8, color: u8, x: u8, y: u8) void {
        var pos: usize = (y * vga_width) + x;
        for(str) |char| {
                vga_buf[pos] = (@as(u16, color) << 8) | char;
                pos += 1;
        }
}
