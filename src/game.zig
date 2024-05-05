const algebra = @import("algebra.zig");
const m = @import("mesh.zig");

const sdl = @import("zsdl2");

pub const GameObject = struct {
    active: bool,
    entity: bool,
    mesh: *m.Mesh,
    transform: algebra.Mat4x4,
    color: sdl.Color,
};
