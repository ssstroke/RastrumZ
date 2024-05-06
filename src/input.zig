const sdl = @import("zsdl2");

const speed: f32 = 0.02;

pub fn inputProcess() bool {
    var event: sdl.Event = undefined;
    
    while (sdl.pollEvent(&event) == true) {
        if (event.type == .quit or
           (event.type == .keydown and
           event.key.keysym.sym == .escape)) return true;
    }

    return false;
}
