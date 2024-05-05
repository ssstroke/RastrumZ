const algebra = @import("algebra.zig");
const game = @import("game.zig");
const input = @import("input.zig");
const mesh = @import("mesh.zig");
const render = @import("render.zig");

const sdl = @import("zsdl2");
const zmath = @import("zmath");

const std = @import("std");

pub const window_width = 640;
pub const window_height = 640;

pub fn main() !void {
    std.debug.print("\nHello, face in a crowd!\n", .{});

    // SDL init.
    //

    try sdl.init(
        .{ .video = true, .events = true }
    );
    defer sdl.quit();

    var window = try sdl.Window.create(
        "zig-gamedev-window",
        sdl.Window.pos_undefined,
        sdl.Window.pos_undefined,
        @as(i32, window_width),
        @as(i32, window_height),
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

    // Load meshes.
    //

    const mesh_rect = try mesh.meshLoadFromObj("assets/rectangle.obj");

    // Create game objects.
    //

    const player = game.GameObject{
        .active = true,
        .entity = false,
        .mesh = mesh_rect,
        .transform = .{
            algebra.Vec4{1, 0,  0, 0},
            algebra.Vec4{0, 1,  0, 0},
            algebra.Vec4{0, 0,  1, 0},
            algebra.Vec4{0, 0, -1, 1},
        },
        .color = .{.r = 255, .g = 0, .b = 255, .a = 255},
    };

    // Create camera.
    //

    const camera_angle_x = algebra.degreesToRadians(-45);
    const camera = algebra.Mat4x4{
        algebra.Vec4{1, 0, 0, 0},
        algebra.Vec4{0, @cos(camera_angle_x), @sin(camera_angle_x), 0},
        algebra.Vec4{0, -@sin(camera_angle_x), @cos(camera_angle_x), 0},
        algebra.Vec4{0, 16, 7, 1},
    };

    render.renderSetCamera(camera);
    render.renderSetSDLRenderer(renderer);

    main_loop: while (true) {
        if (input.inputProcess() == true) break :main_loop;

        try render.renderDrawBackground(.{.r = 0x18, .g = 0x18, .b = 0x18, .a = 255});
        try render.renderDrawGameObjectWireframe(player, player.color);
        renderer.present();
    }

    mesh.meshFree(mesh_rect);
}
