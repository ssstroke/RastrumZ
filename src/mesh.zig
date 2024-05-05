const Vec3 = @import("algebra.zig").Vec3;

const std = @import("std");

pub const Mesh = struct {
    vertices: []Vec3,
    indices: []u32,
    number_of_faces: u32,
    number_of_vertices: u32,
    color: u32,
};

// TODO: Try using @embedFile() builtin.
pub fn meshLoadFromObj(comptime filename: []const u8) !*Mesh {
    // Open a file.
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buffered = std.io.bufferedReader(file.reader());
    var reader = buffered.reader();

    var buffer: [128]u8 = undefined;

    var number_of_vertices: u32 = 0;
    var number_of_faces: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        switch (line[0]) {
            'v'  => number_of_vertices += 1,
            'f'  => number_of_faces += 1,
            else => {},
        }
    }

    // Init allocator.
    const allocator = std.heap.page_allocator;

    var mesh: *Mesh = try allocator.create(Mesh);
    errdefer allocator.destroy(mesh); // This is super cool!

    mesh.number_of_faces = number_of_faces;
    mesh.number_of_vertices = number_of_vertices;

    mesh.vertices = try allocator.alloc(Vec3, number_of_vertices * 3);
    mesh.indices = try allocator.alloc(u32, number_of_faces * 3);
    mesh.color = 0xff00ffff;

    try file.seekTo(0);

    var current_vertex: u32 = 0;
    var current_index: u32 = 0;

    while (try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        std.debug.print("[DEBUG]: {s}\n", .{line});

        switch (line[0]) {
            'v'  => {
                var iter = std.mem.splitScalar(u8, line, ' ');

                // This will skip 'v' itself and will return an error
                // if there is no more data in the line.
                if (iter.next() == null) {
                    std.debug.print("File `{s}` is corrupted!\n", .{filename});
                    return error.FileCorrupted;
                }

                // Parse numbers.
                for (0..3) |i_xyz| {
                    const number_string = iter.next() orelse {
                        std.debug.print("File `{s}` is corrupted!\n", .{filename});
                        return error.FileCorrupted;
                    };

                    if (std.fmt.parseFloat(f32, number_string)) |number| {
                        mesh.vertices[current_vertex][i_xyz] = number;
                        current_vertex += 1;
                    } else |err| {
                        std.debug.print("File `{s}` is corrupted!\n", .{filename});
                        return err;
                    }
                }
            },

            'f'  => {
                var iter = std.mem.splitScalar(u8, line, ' ');

                // This will skip 'f' itself and will return an error
                // if there is no more data in the line.
                if (iter.next() == null) {
                    std.debug.print("File `{s}` is corrupted!\n", .{filename});
                    return error.FileCorrupted;
                }

                // Parse numbers.
                for (0..3) |_| {
                    const number_string = iter.next() orelse {
                        std.debug.print("File `{s}` is corrupted!\n", .{filename});
                        return error.FileCorrupted;
                    };

                    if (std.fmt.parseUnsigned(u32, number_string, 10)) |number| {
                        mesh.indices[current_index] = number;
                        current_index += 1;
                    } else |err| {
                        std.debug.print("File `{s}` is corrupted!\n", .{filename});
                        return err;
                    }
                }
            },

            else => {},
        }
    }

    return mesh;
}

pub fn meshFree(mesh: *Mesh) void {
    const allocator = std.heap.page_allocator;
    allocator.free(mesh.vertices);
    allocator.free(mesh.indices);
    allocator.destroy(mesh);
}
