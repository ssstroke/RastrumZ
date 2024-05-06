const algebra = @import("algebra.zig");
const game = @import("game.zig");
const input = @import("input.zig");
const mesh = @import("mesh.zig");
const render = @import("render.zig");

const sdl = @import("zsdl2");
const zmath = @import("zmath");

const std = @import("std");

const colors = game.Color;

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

    const mesh_ball = try mesh.meshLoadFromObj("assets/ball.obj");
    defer mesh.meshFree(mesh_ball);

    const mesh_rect = try mesh.meshLoadFromObj("assets/rectangle.obj");
    defer mesh.meshFree(mesh_rect);

    const mesh_wall_back = try mesh.meshLoadFromObj("assets/wall_back.obj");
    defer mesh.meshFree(mesh_wall_back);

    const mesh_wall_side = try mesh.meshLoadFromObj("assets/wall_side.obj");
    defer mesh.meshFree(mesh_wall_side);

    // Create game objects.
    //

    var objects: [3 + 1 + 1 + 8]game.GameObject = undefined;

    {
        // Left wall.
        //
        objects[0].mesh = mesh_wall_side;
        objects[0].entity = false;
        objects[0].active = true;
        objects[0].transform = algebra.initIdentityMatrix();
        objects[0].transform[3][0] = -9;
        objects[0].transform[3][1] = 0;
        objects[0].transform[3][2] = -14;
        objects[0].color = game.RGBA_COLOR_GRUVBOX_YELLOW;

        // Right wall.
        //
        objects[1].mesh = mesh_wall_side;
        objects[1].entity = false;
        objects[1].active = true;
        objects[1].transform = algebra.initIdentityMatrix();
        objects[1].transform[3][0] = 9;
        objects[1].transform[3][1] = 0;
        objects[1].transform[3][2] = -14;
        objects[1].color = game.RGBA_COLOR_GRUVBOX_YELLOW;

        // Back  wall.
        //
        objects[2].mesh = mesh_wall_back;
        objects[2].entity = false;
        objects[2].active = true;
        objects[2].transform = algebra.initIdentityMatrix();
        objects[2].transform[3][0] = 0;
        objects[2].transform[3][1] = 0;
        objects[2].transform[3][2] = -27;
        objects[2].color = game.RGBA_COLOR_GRUVBOX_YELLOW;

        // Ball.
        //
        objects[3].mesh = mesh_ball;
        objects[3].entity = false;
        objects[3].active = true;
        objects[3].transform = algebra.initIdentityMatrix();
        objects[3].transform[3][0] = 0;
        objects[3].transform[3][1] = 0;
        objects[3].transform[3][2] = -4;
        objects[3].color = game.RGBA_COLOR_GRUVBOX_GREEN;

        // Player.
        //
        objects[4].mesh = mesh_rect;
        objects[4].entity = false;
        objects[4].active = true;
        objects[4].transform = algebra.initIdentityMatrix();
        objects[4].transform[3][0] = 0;
        objects[4].transform[3][1] = 0;
        objects[4].transform[3][2] = -1;
        objects[4].color = game.RGBA_COLOR_MAGENTA;

        // Entities.
        //
        objects[5].mesh = mesh_rect;
        objects[5].active = true;
        objects[5].entity = true;
        objects[5].transform = algebra.initIdentityMatrix();
        objects[5].transform[3][0] = -6;
        objects[5].transform[3][1] = 0;
        objects[5].transform[3][2] = -24;
        objects[5].color = game.RGBA_COLOR_GRUVBOX_RED;
        objects[6].mesh = mesh_rect;
        objects[6].active = true;
        objects[6].entity = true;
        objects[6].transform = algebra.initIdentityMatrix();
        objects[6].transform[3][0] = -2;
        objects[6].transform[3][1] = 0;
        objects[6].transform[3][2] = -24;
        objects[6].color = game.RGBA_COLOR_GRUVBOX_RED;
        objects[7].mesh = mesh_rect;
        objects[7].active = true;
        objects[7].entity = true;
        objects[7].transform = algebra.initIdentityMatrix();
        objects[7].transform[3][0] = 2;
        objects[7].transform[3][1] = 0;
        objects[7].transform[3][2] = -24;
        objects[7].color = game.RGBA_COLOR_GRUVBOX_RED;
        objects[8].mesh = mesh_rect;
        objects[8].active = true;
        objects[8].entity = true;
        objects[8].transform = algebra.initIdentityMatrix();
        objects[8].transform[3][0] = 6;
        objects[8].transform[3][1] = 0;
        objects[8].transform[3][2] = -24;
        objects[8].color = game.RGBA_COLOR_GRUVBOX_RED;
        objects[9].mesh = mesh_rect;
        objects[9].active = true;
        objects[9].entity = true;
        objects[9].transform = algebra.initIdentityMatrix();
        objects[9].transform[3][0] = -6;
        objects[9].transform[3][1] = 0;
        objects[9].transform[3][2] = -22;
        objects[9].color = game.RGBA_COLOR_GRUVBOX_RED;
        objects[10].mesh = mesh_rect;
        objects[10].active = true;
        objects[10].entity = true;
        objects[10].transform = algebra.initIdentityMatrix();
        objects[10].transform[3][0] = -2;
        objects[10].transform[3][1] = 0;
        objects[10].transform[3][2] = -22;
        objects[10].color = game.RGBA_COLOR_GRUVBOX_RED;
        objects[11].mesh = mesh_rect;
        objects[11].active = true;
        objects[11].entity = true;
        objects[11].transform = algebra.initIdentityMatrix();
        objects[11].transform[3][0] = 2;
        objects[11].transform[3][1] = 0;
        objects[11].transform[3][2] = -22;
        objects[11].color = game.RGBA_COLOR_GRUVBOX_RED;
        objects[12].mesh = mesh_rect;
        objects[12].active = true;
        objects[12].entity = true;
        objects[12].transform = algebra.initIdentityMatrix();
        objects[12].transform[3][0] = 6;
        objects[12].transform[3][1] = 0;
        objects[12].transform[3][2] = -22;
        objects[12].color = game.RGBA_COLOR_GRUVBOX_RED;
    }

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

    // Some objects that we will need direct access to.
    //

    // const ball = &objects[3];
    // const player = &objects[4];
    // var ball_direction = algebra.Vec2{
    //     @as(f32, @sin(algebra.degreesToRadians(45))),
    //     -@as(f32, @sin(algebra.degreesToRadians(45))),
    // };

    main_loop: while (true) {
        if (input.inputProcess() == true) break :main_loop;

        try render.renderDrawBackground(game.RGBA_COLOR_GRUVBOX_BLACK);

        for (0..objects.len) |i|
            try render.renderDrawGameObjectWireframe(objects[i], objects[i].color);
        
        renderer.present();

        // break :main_loop;
    }
}
