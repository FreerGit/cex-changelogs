const std = @import("std");
const assert = std.debug.assert;

fn setup_changelog_files(comptime names: []const []const u8) !void {
    const cwd = std.fs.cwd();
    inline for (names[0..]) |name| {
        var file = try cwd.createFile("./changelogs/" ++ name ++ ".txt", std.fs.File.CreateFlags{ .read = true });
        defer file.close();
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const names = [_][]const u8{ "binance", "bybit" };
    try setup_changelog_files(names[0..]);

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
