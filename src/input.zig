const algebra = @import("algebra.zig");
const game = @import("game.zig");
const main = @import("main.zig");

const sdl = @import("zsdl2");

pub const speed: f32 = 0.075;

pub fn inputProcess(player: *game.GameObject, camera: *algebra.Mat4x4) bool {
    var event: sdl.Event = undefined;
    
    while (sdl.pollEvent(&event) == true) {
        if (event.type == .quit or
           (event.type == .keydown and
           event.key.keysym.sym == .escape)) return true;

        if (event.type == .mousemotion) {
            const width_half: f32 = main.window_width / 2;
            const float_motion: f32 = @floatFromInt(event.motion.x);
            
            player.transform[3][0] = ((float_motion - width_half) / width_half) * 6;
            camera[3][0] = ((float_motion - width_half) / width_half) * 2;
        }
    }

    return false;
}
