const algebra = @import("algebra.zig");
const game = @import("game.zig");
const main = @import("main.zig");
const mesh = @import("mesh.zig");

const sdl = @import("zsdl2");

const std = @import("std");

// I think keeping them as global variables is good for
// performance since I won't have to pass them as function
// parameters each time I try to render something.
// TODO: Needs researching.
//

var g_renderer: *sdl.Renderer = undefined;
var g_camera: algebra.Mat4x4 = undefined;
var g_world_to_camera: algebra.Mat4x4 = undefined;

pub fn renderSetCamera(camera: algebra.Mat4x4) void {
    g_camera = camera;
    g_world_to_camera = algebra.mat4x4Inverse(g_camera);
}

pub fn renderSetSDLRenderer(renderer: *sdl.Renderer) void {
    g_renderer = renderer;
}

pub fn renderDrawBackground(color: sdl.Color) !void {
    try g_renderer.setDrawColor(color);
    try g_renderer.clear();
}

pub fn renderDrawGameObjectWireframe(object: game.GameObject, color: sdl.Color) !void {
    if (object.active == false) return;

    // Iterate over every face.
    //

    const m = object.mesh;

    for (0..m.number_of_faces) |i| {
        const a_world = algebra.vec3MulByMat4x4(m.vertices[m.indices[i * 3 + 0]], object.transform);
        const b_world = algebra.vec3MulByMat4x4(m.vertices[m.indices[i * 3 + 1]], object.transform);
        const c_world = algebra.vec3MulByMat4x4(m.vertices[m.indices[i * 3 + 2]], object.transform);

        // Back face culling.
        //
        {
            const ba = b_world - a_world;
            const ca = c_world - a_world;
            const face_normal = algebra.vec3Cross(ba, ca);

            const view_direction = algebra.Vec3{
                g_camera[2][0],
                g_camera[2][1],
                g_camera[2][2],
            };

            if (algebra.vec3Dot(view_direction, face_normal) < 0) continue;
        }

        const a_camera = algebra.vec3MulByMat4x4(a_world, g_world_to_camera);
        const b_camera = algebra.vec3MulByMat4x4(b_world, g_world_to_camera);
        const c_camera = algebra.vec3MulByMat4x4(c_world, g_world_to_camera);

        const a_projected = algebra.Vec2{
            a_camera[0] / if (a_camera[2] == 0) 1 else -a_camera[2],
            a_camera[1] / if (a_camera[2] == 0) 1 else -a_camera[2],
        };
        const b_projected = algebra.Vec2{
            b_camera[0] / if (b_camera[2] == 0) 1 else -b_camera[2],
            b_camera[1] / if (b_camera[2] == 0) 1 else -b_camera[2],
        };
        const c_projected = algebra.Vec2{
            c_camera[0] / if (c_camera[2] == 0) 1 else -c_camera[2],
            c_camera[1] / if (c_camera[2] == 0) 1 else -c_camera[2],
        };

        const a_ndc = algebra.Vec2{
            (a_projected[0] + 0.5) / 1,
            (a_projected[1] + 0.5) / 1,
        };
        const b_ndc = algebra.Vec2{
            (b_projected[0] + 0.5) / 1,
            (b_projected[1] + 0.5) / 1,
        };
        const c_ndc = algebra.Vec2{
            (c_projected[0] + 0.5) / 1,
            (c_projected[1] + 0.5) / 1,
        };

        const a_raster = @Vector(2, i32){
            @as(i32, @intFromFloat(@floor(a_ndc[0] * main.window_width))),
            @as(i32, @intFromFloat(@floor((1 - a_ndc[1]) * main.window_height))),
        };
        const b_raster = @Vector(2, i32){
            @as(i32, @intFromFloat(@floor(b_ndc[0] * main.window_width))),
            @as(i32, @intFromFloat(@floor((1 - b_ndc[1]) * main.window_height))),
        };
        const c_raster = @Vector(2, i32){
            @as(i32, @intFromFloat(@floor(c_ndc[0] * main.window_width))),
            @as(i32, @intFromFloat(@floor((1 - c_ndc[1]) * main.window_height))),
        };

        try g_renderer.setDrawColor(color);
        try g_renderer.drawLine(a_raster[0], a_raster[1], b_raster[0], b_raster[1]);
        try g_renderer.drawLine(b_raster[0], b_raster[1], c_raster[0], c_raster[1]);
        try g_renderer.drawLine(c_raster[0], c_raster[1], a_raster[0], a_raster[1]);
    }
}