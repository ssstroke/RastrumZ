const std = @import("std");
const math = std.math;
const pi = math.pi;

// Aliases.
//

pub const Vec2 = @Vector(2, f32);
pub const Vec3 = @Vector(3, f32);
pub const Vec4 = @Vector(4, f32);

pub const Mat4x4 = [4]Vec4;

// Functions.
//

// Misc functions.
//

pub fn degreesToRadians(degrees: f32) f32 {
    return (degrees * pi / 180);
}

pub fn radiansToDegrees(radians: f32) f32 {
    return (radians * 180 / pi);
}

// Vec2 functions.
//

pub fn vec2ScalarAdd(v: Vec2, s: f32) Vec2 {
    const vs: Vec2 = @splat(s);
    return v + vs;
}

pub fn vec2ScalarSub(v: Vec2, s: f32) Vec2 {
    const vs: Vec2 = @splat(s);
    return v - vs;
}

pub fn vec2Dot(v0: Vec2, v1: Vec2) f32 {
    const result = v0 * v1;
    return result[0] + result[1];
}

pub fn vec2Length(v: Vec2) f32 {
    const result = v * v;
    return @as(f32, @sqrt( result[0] + result[1] ));
}

pub fn vec2Normalize(v: Vec2) Vec2 {
    const len_inverse: Vec2 = @splat(@as(f32, 1 / vec2Length(v)));
    return v * len_inverse;
}

// Vec3 functions.
//

pub fn vec3ScalarAdd(v: Vec3, s: f32) Vec3 {
    const vs: Vec3 = @splat(s);
    return v + vs;
}

pub fn vec3ScalarSub(v: Vec3, s: f32) Vec3 {
    const vs: Vec3 = @splat(s);
    return v - vs;
}

pub fn vec3ScalarMul(v: Vec3, s: f32) Vec3 {
    const vs: Vec3 = @splat(s);
    return v * vs;
}

pub fn vec3Dot(v0: Vec3, v1: Vec3) f32 {
    const result = v0 * v1;
    return result[0] + result[1] + result[2];
}

pub fn vec3Cross(v0: Vec3, v1: Vec3) f32 {
    return Vec3{
        v0[1] * v1[2] - v0[2] * v1[1],
        v0[2] * v1[0] - v0[0] * v1[2],
        v0[0] * v1[1] - v0[1] * v1[0],
    };
}

pub fn vec3Length(v: Vec3) f32 {
    const result = v * v;
    return @as(f32, @sqrt( result[0] + result[1] + result[2] ));
}

pub fn vec3Normalize(v: Vec3) Vec3 {
    const len_inverse: Vec3 = @splat(@as(f32, 1 / vec3Length(v)));
    return v * len_inverse;
}

pub fn vec3MulByMat4x4(v: Vec3, m: Mat4x4) Vec3 {
    var result = Vec3{
        v[0] * m[0][0] + v[1] * m[1][0] + v[2] * m[2][0] + m[3][0],
        v[1] * m[0][1] + v[1] * m[1][1] + v[2] * m[2][1] + m[3][1],
        v[2] * m[0][2] + v[1] * m[1][2] + v[2] * m[2][2] + m[3][2],
    };

    const w_inverse: Vec3 = @splat(1 / ( v[0] * m[0][3] + v[1] * m[1][3] + v[2] * m[2][3] + m[3][3] ));
    if (w_inverse[0] != 1 and w_inverse[0] != 0) {
        result *= w_inverse;
    }

    return result;
}

// Mat4x4 functions.
//

pub fn initIdentityMatrix() Mat4x4 {
    return Mat4x4{
        Vec3{1, 0, 0, 0},
        Vec3{0, 1, 0, 0},
        Vec3{0, 0, 1, 0},
        Vec3{0, 0, 0, 1},
    };
}

pub fn mat4x4Mul(m0: Mat4x4, m1: Mat4x4) Mat4x4 {
    var result: Mat4x4 = undefined;
    for (0..5) |row| {
        for (0..5) |col| {
            result[row][col] =
                m0[row][0] * m1[0][col] +
                m0[row][1] * m1[1][col] +
                m0[row][2] * m1[2][col] +
                m0[row][3] * m1[3][col];
        }
    }
    return result;
}
