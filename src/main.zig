const std = @import("std");
const s = @cImport(
    @cInclude("SDL.h"),
);

pub fn main() !void {
    std.debug.print("Hello, SDL2!\n", .{});

    _ = s.SDL_Init(s.SDL_INIT_VIDEO | s.SDL_INIT_EVENTS);
    defer s.SDL_Quit();
}
