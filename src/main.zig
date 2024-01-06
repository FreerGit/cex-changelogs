const std = @import("std");
const assert = std.debug.assert;
const hmap = std.hash_map;
const print = std.debug.print;

const ExchangeInfo = struct {
    name: []const u8,
    url: []const u8,
};

fn get_api_docs(ex_info: ExchangeInfo, allocator: std.mem.Allocator) ![]const u8 {
    var client = std.http.Client{ .allocator = allocator };
    const res = try std.http.Client.fetch(&client, allocator, .{ .location = .{ .url = ex_info.url } });
    const html = res.body.?;
    return try allocator.dupe(u8, html);
}

fn setup_changelog_files(
    ex_info: []const ExchangeInfo,
    files: []std.fs.File,
    allocator: std.mem.Allocator,
) !void {
    const cwd = std.fs.cwd();
    for (ex_info, 0..) |e, idx| {
        const path = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ "./changelogs/", e.name, ".txt" });
        std.debug.print("{d} {s} {s}\n", .{ idx, e.name, path });
        const open_file = cwd.openFile(path, .{ .mode = .read_write }) catch blk: {
            const file = try cwd.createFile(path, std.fs.File.CreateFlags{ .read = true });
            const read_bytes: []const u8 = try get_api_docs(e, allocator);
            try file.writeAll(read_bytes);
            break :blk file;
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
    const exchange_info = [_]ExchangeInfo{ .{
        .name = "binance-futures",
        .url = "https://binance-docs.github.io/apidocs/futures/en/#change-log",
    }, .{
        .name = "binance-coin-m",
        .url = "https://binance-docs.github.io/apidocs/delivery/en/#change-log",
    } };
    var files: [exchange_info.len]std.fs.File = undefined;
    try setup_changelog_files(exchange_info[0..], &files, arena.allocator());
    var map = std.StringHashMap([]const u8).init(arena.allocator());
    for (files, exchange_info) |file, exc_info| {
        const read_buffer = try file.readToEndAlloc(arena.allocator(), 1024 * 1024 * 16);
        try map.put(exc_info.name, read_buffer);
    }

    var idx: usize = 0;
    while (true) {
        const last_changelog = map.get(exchange_info[idx].name).?;
        const current_changelog = try get_api_docs(exchange_info[idx], arena.allocator());
        print("{any}", .{std.mem.eql(u8, last_changelog, current_changelog)});

        idx += 1;
        if (idx == exchange_info.len) idx = 0;
        std.time.sleep(std.time.ns_per_s * 1);
    }

    // const file = try std.fs.cwd().createFile("./changelogs/binance.txt", std.fs.File.CreateFlags{ .read = true });
    // defer file.close();
    // // os.read("./changelogs/binance.txt", &binance_buffer);

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
