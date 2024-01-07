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

fn get_filename_path(name: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    return try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ "./changelogs/", name, ".txt" });
}

fn setup_changelog_files(
    ex_info: []const ExchangeInfo,
    files: []std.fs.File,
    allocator: std.mem.Allocator,
) !void {
    const cwd = std.fs.cwd();
    for (ex_info, 0..) |e, idx| {
        const path = try get_filename_path(e.name, allocator);
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
    const cwd = std.fs.cwd();

    var idx: usize = 0;
    while (true) {
        const diff_file = try cwd.createFile("diff.txt", std.fs.File.CreateFlags{ .read = true });
        const current_changelog = try get_api_docs(exchange_info[idx], arena.allocator());
        try diff_file.writeAll(current_changelog);

        const path = try get_filename_path(exchange_info[idx].name, arena.allocator());
        const argv = .{ "diff", path, "diff.txt" };
        var proc = std.ChildProcess.init(&argv, arena.allocator());
        try proc.spawn();
        const term = try proc.wait();
        diff_file.close();
        if (term.Exited != 0) {
            print(
                "The above diffs from the following exchange: {s}\n",
                .{exchange_info[idx].name},
            );
            break;
        }
        idx += 1;
        if (idx == exchange_info.len) idx = 0;
        std.time.sleep(std.time.ns_per_s * 1);
    }
}
