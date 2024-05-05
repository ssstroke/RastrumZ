const algebra = @import("algebra.zig");
const input = @import("input.zig");
const mesh = @import("mesh.zig");

const sdl = @import("zsdl2");
const zmath = @import("zmath");

const std = @import("std");

pub fn main() !void {
    std.debug.print("\n", .{});

    try sdl.init(.{ .video = true, .events = true });
    defer sdl.quit();

    var window = try sdl.Window.create(
        "zig-gamedev-window",
        sdl.Window.pos_undefined,
        sdl.Window.pos_undefined,
        640,
        640,
        .{},
    );
    defer window.destroy();

    var renderer = try sdl.Renderer.create(
        window,
        -1,
        .{ .accelerated = true },
    );
    defer renderer.destroy();
    
    try sdl.showCursor(.disable);
    // TODO: There is no SDL_SetRelativeMouseMode...

    const mesh_rect = try mesh.meshLoadFromObj("assets/rectangle.obj");
    std.debug.print("mesh is... {any}\n", .{mesh_rect.*});

    main_loop: while (true) {
        if (input.inputProcess() == true) break :main_loop;
    }

    mesh.meshFree(mesh_rect);
}
