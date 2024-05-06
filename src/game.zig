const algebra = @import("algebra.zig");
const speed = @import("input.zig").speed;
const m = @import("mesh.zig");

const sdl = @import("zsdl2");

const std = @import("std");

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

var entities_destroyed: u4 = 0;

pub fn gameUpdate(objects: []GameObject, ball: *GameObject, ball_direction: *algebra.Vec2) void {
    for (0..objects.len) |i| {
        if (objects[i].active == false or &objects[i] == ball) continue;

        const current = &objects[i];

        const ball_origin = algebra.Vec3{
            ball.transform[3][0],
            ball.transform[3][1],
            ball.transform[3][2],
        };
        const ball_radius: f32 = 1;

        for (0..current.mesh.number_of_faces) |j| {
            var outside_vertices = false;
            var outside_edges = false;

            const a = algebra.vec3MulByMat4x4(current.mesh.vertices[current.mesh.indices[j * 3 + 0]], current.transform);
            const b = algebra.vec3MulByMat4x4(current.mesh.vertices[current.mesh.indices[j * 3 + 1]], current.transform);
            const c = algebra.vec3MulByMat4x4(current.mesh.vertices[current.mesh.indices[j * 3 + 2]], current.transform);

            // Check for plane intersection.
            //

            const u = b - a;
            const v = c - a;
            const abc_normal = algebra.vec3Normalize(algebra.vec3Cross(u, v));

            if (@abs(abc_normal[1]) > 0.1)
                continue;

            const abc_average = algebra.vec3ScalarMul(a + b + c, -(1.0 / 3.0));

            const d = algebra.vec3Dot(abc_average, abc_normal);

            const point_to_plane_distance = algebra.vec3Dot(abc_normal, ball_origin) + d;

            if (@abs(point_to_plane_distance) > ball_radius)
                continue;

            // Check for vertices intersections.
            //

            // const outside_a = if (algebra.vec3Dot(a - ball_origin, a - ball_origin) > ball_radius) true else false;
            // const outside_b = if (algebra.vec3Dot(b - ball_origin, b - ball_origin) > ball_radius) true else false;
            // const outside_c = if (algebra.vec3Dot(c - ball_origin, c - ball_origin) > ball_radius) true else false;

            const a_to_ball = a - ball_origin;
            const b_to_ball = b - ball_origin;
            const c_to_ball = c - ball_origin;

            const outside_a: bool = algebra.vec3Dot(a_to_ball, a_to_ball) > ball_radius;
            const outside_b: bool = algebra.vec3Dot(b_to_ball, b_to_ball) > ball_radius;
            const outside_c: bool = algebra.vec3Dot(c_to_ball, c_to_ball) > ball_radius;

            if (outside_a and outside_b and outside_c)
                outside_vertices = true;

            // Check for edges intersections.
            //

            const bma = b - a;
            const cmb = c - b;
            const amc = a - c;

            if (intersectRaySegmentSphere(a, bma, ball_origin, ball_radius) == false and
                intersectRaySegmentSphere(b, cmb, ball_origin, ball_radius) == false and
                intersectRaySegmentSphere(c, amc, ball_origin, ball_radius) == false)
                outside_edges = true;
            
            if (outside_edges and outside_vertices)
                continue;

            // If we are still here, there is a collision. Calculate new direction for the ball.
            //

            const mesh_center_to_ball = algebra.Vec2{
                current.transform[3][0] - ball.transform[3][0],
                current.transform[3][2] - ball.transform[3][2],
            };
            const abc_normal_v2 = algebra.Vec2{
                abc_normal[0],
                abc_normal[2],
            };
            const unit_x = algebra.Vec2{1, 0};

            // If we hit plane that points left (right), simply inverse x direction.
            //

            if (@abs(algebra.vec2Dot(abc_normal_v2, unit_x)) == 1) {
                ball_direction[0] *= -1;
            } else {
                // We hit plane that points forward (back), calculate new direction.
                //

                const hit_angle_cos: f32 = algebra.vec2Dot(mesh_center_to_ball, abc_normal_v2) / algebra.vec2Length(mesh_center_to_ball);
                const hit_angle_sin: f32 = @as(f32, @sqrt(1 - hit_angle_cos * hit_angle_cos));

                ball_direction[0] = (ball_direction[0] * hit_angle_cos) - (ball_direction[1] * hit_angle_sin);
                ball_direction[1] = (ball_direction[1] * hit_angle_cos) + (ball_direction[0] * hit_angle_sin);

                if (algebra.vec2Dot(mesh_center_to_ball, unit_x) / algebra.vec2Length(mesh_center_to_ball) < 0)
                    ball_direction[0] *= -1;
            }

            ball_direction.* = algebra.vec2Normalize(ball_direction.*);

            if (current.entity == true) {
                current.active = false;

                // Reset game if all entities have been destroyed.
                //

                entities_destroyed += 1;
                if (entities_destroyed == 8) {
                    entities_destroyed = 0;
                    for (0..objects.len) |k| {
                        objects[k].active = true;
                        ball_direction[0] = 0;
                        ball_direction[1] = 0.5;
                        ball.transform[3][0] = 0;
                        ball.transform[3][2] = -7;
                    }
                }
            }

            break;
        }
    }

    // Move ball.
    //
    ball.transform[3][0] += ball_direction[0] * speed;
    ball.transform[3][2] += ball_direction[1] * speed;
}

fn intersectRaySegmentSphere(o: algebra.Vec3, d: algebra.Vec3, so: algebra.Vec3, radius2: f32) bool {
    const d_normalized = algebra.vec3Normalize(d);

    const mm = o - so;
    const b = algebra.vec3Dot(mm, d_normalized);
    const c = algebra.vec3Dot(mm, mm) - radius2;

    // Exit if r's origin outside s (c > 0) and r pointing away from s (b > 0).
    if (c > 0 and b > 0) return false;

    const discr: f32 = b * b - c;

    if (discr < 0) return false;

    const t: f32 = @max(0, -b - @sqrt(discr));

    if (t > algebra.vec3Length(d)) return false;

    return true;
}
