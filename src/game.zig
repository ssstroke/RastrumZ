const algebra = @import("algebra.zig");
const m = @import("mesh.zig");

const sdl = @import("zsdl2");

pub const RGBA_COLOR_GRUVBOX_BLACK = sdl.Color{
    .r = 0x28, .g = 0x28, .b = 0x28, .a = 0xff
};
pub const RGBA_COLOR_GRUVBOX_RED = sdl.Color{
    .r = 0xcc, .g = 0x24, .b = 0x1d, .a = 0xff
};
pub const RGBA_COLOR_GRUVBOX_GREEN = sdl.Color{
    .r = 0xb8, .g = 0xbb, .b = 0x26, .a = 0xff
};
pub const RGBA_COLOR_GRUVBOX_YELLOW = sdl.Color{
    .r = 0xfa, .g = 0xbd, .b = 0x2f, .a = 0xff
};
pub const RGBA_COLOR_GRUVBOX_BLUE = sdl.Color{
    .r = 0x83, .g = 0xa5, .b = 0x98, .a = 0xff
};
pub const RGBA_COLOR_MAGENTA = sdl.Color{
    .r = 0xff, .g = 0x00, .b = 0xff, .a = 0xff
};

pub const GameObject = struct {
    active: bool = true,
    entity: bool = true,
    mesh: *m.Mesh,
    transform: algebra.Mat4x4,
    color: sdl.Color = RGBA_COLOR_MAGENTA,
};
