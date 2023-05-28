const std = @import("std");
const print = std.debug.print;

const nop = struct {};

pub fn main() !void {
    const debug = false;
    var general_purpose_alocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_alocator.allocator();
    const args = try std.process.argsAlloc(gpa);

    if (args.len > 1) {
        try runFile(args[1]);
    } else {
        try runPrompt();
    }

    // Debug
    if (debug) {
        listArgs(args);
    }
}

pub fn runPrompt() !void {
    print("Running prompt!\n", .{});
}

pub fn listArgs(args: anytype) !void {
    for (args, 0..) |arg, i| {
        print("{}: {s}\n", .{ i, arg });
    }
}

const Scanner = struct {
    tokens: [][]u8 = undefined,

    pub fn init(self: *Scanner, source: [][]u8) !void {
        self.tokens = source;
    }

    pub fn showToken(self: *Scanner) !void {
        for (self, 0..) |token, i| {
            print("{}: {s}\n", .{ i, token });
        }
    }
};

pub fn runFile(file_name: []u8) !void {
    var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    // Get the path
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const path = try std.fs.realpath(file_name, &path_buffer);

    // Open the file
    const file = try std.fs.openFileAbsolute(path, .{});
    defer file.close();

    // Read the contents
    const buffer_size = 2000;
    const file_buffer = try file.readToEndAlloc(allocator, buffer_size);
    defer allocator.free(file_buffer);

    // Split by "\n" and iterate through the resulting slices of "const []u8"
    var iter = std.mem.split(u8, file_buffer, "\n");

    var count: usize = 0;
    while (iter.next()) |line| : (count += 1) {
        std.log.info("line - {d:>2}: {s}", .{ count, line });
    }
}

fn is_valid_filename(file_name: []u8) !bool {
    if (file_name) {
        return true;
    }
}

test "simple test" {}
