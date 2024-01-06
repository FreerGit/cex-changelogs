const std = @import("std");
const assert = std.debug.assert;
const hmap = std.hash_map;
const print = std.debug.print;

fn setup_changelog_files(comptime names: []const []const u8, files: []std.fs.File, allocator: std.mem.Allocator) !void {
    const cwd = std.fs.cwd();

    for (names, 0..) |name, idx| {
        const path = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ "./changelogs/", name, ".txt" });
        std.debug.print("{d} {s} {s}\n", .{ idx, name, path });
        const open_file = cwd.openFile(path, .{ .mode = .read_write }) catch blk: {
            break :blk try cwd.createFile(path, std.fs.File.CreateFlags{ .read = true });
        };
        files[idx] = open_file;
    }
}

//  read file
//  if not exists
//      create
//  loop http read
//  write to file any diffs
//  delete changelog

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const names = [_][]const u8{ "binance", "bybit", "OKX", "gateio" };
    var files: [names.len]std.fs.File = undefined;
    try setup_changelog_files(names[0..], &files, arena.allocator());
    var map = std.StringHashMap([]const u8).init(arena.allocator());
    var i: usize = 1;
    for (files, names) |file, name| {
        i += 1;
        print("{any}\n", .{files});
        const read_buffer = try file.readToEndAlloc(arena.allocator(), 1024 * 1024 * 16);
        try map.put(name, read_buffer);
        std.debug.print("file: t{any}\n", .{map.get(name)});
        // defer file.close();
    }
    // const file = try std.fs.cwd().createFile("./changelogs/binance.txt", std.fs.File.CreateFlags{ .read = true });
    // defer file.close();
    // // os.read("./changelogs/binance.txt", &binance_buffer);

    // var client = std.http.Client{ .allocator = arena.allocator() };
    // const binance_res = try std.http.Client.fetch(&client, arena.allocator(), .{ .location = .{ .url = "https://binance-docs.github.io/apidocs/futures/en/#change-log" } });
    // const binance_html = binance_res.body.?;
    // try file.writeAll(binance_html);
    // std.debug.print("{d}, {s}\n{s}\n", .{ bytes_read, binance_buffer[0..100], binance_html[0..100] });
    // assert(std.mem.eql(u8, binance_buffer[0..bytes_read], binance_html));
    // std.debug.print("{s}", .{binance_html});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
