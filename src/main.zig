const debug = @import("std").debug;
const os = @import("std").os;
const mem = @import("std").mem;
const heap = @import("std").heap;
const fs = @import("std").fs;
const testing = @import("std").testing;

pub fn main() !void {
    // Get the command arguments, using std.os.argv
    // This solution will not work for WASI or Windows
    // use std.process.argsAlloc for a cross-platform solution
    const argv = os.argv;

    // Create a general purpose allocator to be used
    // when reading the contents of the given file(s)
    var galloc = heap.GeneralPurposeAllocator(.{}){};
    defer _ = galloc.deinit();
    const allocator = galloc.allocator();

    // Use the first command argument to determie which function should be executed
    for (argv[1..]) |arg| {
        // Convert arg to []u8 and compare it using mem.eql
        const val: []const u8 = arg[0..mem.len(arg)];
        if ((mem.eql(u8, val, "--help") or mem.eql(u8, val, "-h"))) {
            return debug.print("{s}\n", .{get_help()});
        } else {
            // Read the contents of the given file and defer its deallocation
            const file_content = try get_file_content(allocator, val);
            defer allocator.free(file_content);
            debug.print("{s}\n", .{file_content});
        }
    }
}

// get_help returns an example of how this program might be used
fn get_help() []const u8 {
    return 
    \\Usage: grab [OPTION] ... [FILE] ...
    \\Grab FILE(s) content and show it through standard output
    \\
    \\
    \\--help, -h            display this help and exit
    \\Examples:
    \\
    \\grab foo.txt          Output 'foo.txt' contents
    \\grab foo.txt bar.txt  Output 'foo.txt' contents, then, output 'bar.txt' contents
    ;
}

// get_file_content returns the contents of the given file or an error string
fn get_file_content(allocator: mem.Allocator, path: []const u8) ![]u8 {
    // Open a file in the current working directory
    var file = try fs.cwd().openFile(path, .{});

    // Read and return the contents of the file
    return try file.readToEndAlloc(allocator, 10 * 1024 * 1024);
}

test "get file contents" {
    // Create a general purpose allocator
    var galloc = heap.GeneralPurposeAllocator(.{}){};
    defer _ = galloc.deinit();
    const allocator = galloc.allocator();

    // Create and write to 'foo.txt'
    var file = try fs.cwd().createFile("foo.txt", .{});
    _ = try file.write("foo");

    // Read the contents of 'foo.txt'
    var path: []const u8 = "foo.txt";
    const file_content = try get_file_content(allocator, path);
    defer allocator.free(file_content);

    // Assert that 'foo.txt' contains 'foo'
    try testing.expectEqualStrings("foo", file_content);

    // Remove 'foo.txt'
    try fs.cwd().deleteFile("foo.txt");
}
