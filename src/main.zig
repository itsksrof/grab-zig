const debug = @import("std").debug;
const os = @import("std").os;
const mem = @import("std").mem;
const heap = @import("std").heap;
const fs = @import("std").fs;

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
            return debug.print("{s}\n", .{get_help()});
        } else {
            // Create a general purpose allocator
            var gpa = heap.GeneralPurposeAllocator(.{}){};
            defer _ = gpa.deinit();
            const allocator = gpa.allocator();

            // TODO: This should be a function
            // TODO: Need to learn about zig error handling
            // TODO: Need to learn about zig allocator
            // Open a file in the current working directory
            var file = try fs.cwd().openFile(val, .{});

            // Read the contents of the file
            const file_content = try file.readToEndAlloc(allocator, 10 * 1024 * 1024); // 10MB max read
            defer allocator.free(file_content);

            debug.print("{!s}\n", .{file_content});
        }
    }
}

// get_help returns an example of how this program might be used
fn get_help() []const u8 {
    return 
    \\Usage: grab [OPTION] ... [FILE] ...
    \\Grab FILE(s) content and show it through standard output
    \\
    \\--help, -h            display this help and exit
    \\
    \\Examples:
    \\
    \\grab foo.txt          Output 'foo.txt' contents
    \\grab foo.txt bar.txt  Output 'foo.txt' contents, then, output 'bar.txt' contents
    ;
}
