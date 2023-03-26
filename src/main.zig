const debug = @import("std").debug;
const os = @import("std").os;
const mem = @import("std").mem;
const heap = @import("std").heap;
const fs = @import("std").fs;

// ! Part One (Command arguments)
// * Get the command arguments
// * Print the command arguments
// * Use the first command argument to determine which function should be executed

// ! Part Two (Reading a file)
// * Open a file
// * Read the contents of the file
// * Output its contents

pub fn main() !void {
    // Get the command arguments, using std.os.argv
    // This solution will not work for WASI or Windows
    // use std.process.argsAlloc for a cross-platform solution
    const argv = os.argv;

    // Use the first command argument to determie which function should be executed
    for (argv[1..]) |arg| {
        // Convert arg to []u8 and compare it using mem.eql
        const val: []u8 = arg[0..mem.len(arg)];
        if ((mem.eql(u8, val, "--help") or mem.eql(u8, val, "-h"))) {
            return debug.print("deez nuts\n", .{});
        } else {
            // Create a general purpose allocator
            var gpa = heap.GeneralPurposeAllocator(.{}){};
            defer _ = gpa.deinit();
            const allocator = gpa.allocator();

            // Open a file in the current working directory
            var file = try fs.cwd().openFile(val, .{});

            // Read the contents of the file
            const file_content = try file.readToEndAlloc(allocator, 10 * 1024 * 1024); // 10MB max read
            defer allocator.free(file_content);

            debug.print("{!s}\n", .{file_content});
        }
    }
}
