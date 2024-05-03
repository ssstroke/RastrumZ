const std = @import("std");
const sdl = @import("zsdl2");

pub fn main() !void {
    try sdl.init(.{ .video = true, .events = true });
    defer sdl.quit();

    const window = try sdl.Window.create(
        "zig-gamedev-window",
        sdl.Window.pos_undefined,
        sdl.Window.pos_undefined,
        640,
        640,
        .{},
    );
    defer window.destroy();
}
