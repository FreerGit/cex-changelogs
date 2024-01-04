const std = @import("std");
const assert = std.debug.assert;
const hmap = std.hash_map;

fn setup_changelog_files(comptime names: []const []const u8) ![]std.fs.File {
    const cwd = std.fs.cwd();
    var files: [names.len]std.fs.File = undefined;
    // var idx = 0;
    inline for (names[0..], 0..) |name, idx| {
        const open_file = cwd.openFile("./changelogs/" ++ name ++ ".txt", .{ .mode = .read_write }) catch blk: {
            break :blk try cwd.createFile("./changelogs/" ++ name ++ ".txt", std.fs.File.CreateFlags{ .read = true });
        };
        files[idx] = open_file;
        std.debug.print("{d} {any}", .{ idx, files[idx] });
    }

    return files[0..];
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
    const names = [_][]const u8{ "bybit", "binance" };
    const files = try setup_changelog_files(names[0..]);
    var map = std.StringHashMap([]const u8).init(arena.allocator());
    for (files, names) |file, name| {
        var read_buffer: [1024 * 1024 * 16]u8 = undefined;
        const bytes_read = try file.readAll(&read_buffer);
        try map.put(name, read_buffer[0..bytes_read]);
        // defer file.close();
    }
    std.debug.print("file: {s}\n", .{map.get("binance").?});
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
