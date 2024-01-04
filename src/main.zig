const std = @import("std");
const assert = std.debug.assert;

fn setup_changelog_files(comptime names: []const []const u8) ![]std.fs.File {
    const cwd = std.fs.cwd();
    var files: [names.len]std.fs.File = undefined;
    var idx = 0;
    inline for (names[0..]) |name| {
        const open_file = try cwd.openFile("./changelogs/" ++ name ++ ".txt", .{}) catch {
            const file = try cwd.createFile("./changelogs/" ++ name ++ ".txt", std.fs.File.CreateFlags{ .read = true });
            files[idx] = file;
            idx += 1;
        };
        files[idx] = open_file;
    }

    return files;
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
    const names = [_][]const u8{ "binance", "bybit" };
    var files = try setup_changelog_files(names[0..]);
    for (files) |file| {
        defer file.close();
    }

    // var binance_buffer: [1024 * 1024 * 16]u8 = undefined;

    // const file = try std.fs.cwd().createFile("./changelogs/binance.txt", std.fs.File.CreateFlags{ .read = true });
    // defer file.close();
    // // os.read("./changelogs/binance.txt", &binance_buffer);
    // const bytes_read = try file.readAll(&binance_buffer);

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
