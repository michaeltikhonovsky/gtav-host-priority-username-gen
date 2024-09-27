const std = @import("std");

const MAX_NAME_LENGTH = 16;
const HASH_THRESHOLD = 5;
const MAX_MIDDLE_LENGTH = 8;

fn jenkinsHash(key: []const u8) u32 {
    var hash: u32 = 0;
    var i: usize = 0;

    while (i + 4 <= key.len) : (i += 4) {
        hash +%= key[i];
        hash +%= hash << 10;
        hash ^= hash >> 6;
        hash +%= key[i + 1];
        hash +%= hash << 10;
        hash ^= hash >> 6;
        hash +%= key[i + 2];
        hash +%= hash << 10;
        hash ^= hash >> 6;
        hash +%= key[i + 3];
        hash +%= hash << 10;
        hash ^= hash >> 6;
    }

    while (i < key.len) : (i += 1) {
        hash +%= key[i];
        hash +%= hash << 10;
        hash ^= hash >> 6;
    }

    hash +%= hash << 3;
    hash ^= hash >> 11;
    hash +%= hash << 15;
    return hash;
}

fn incrementChar(c: u8) u8 {
    const char_map = "0123456789abcdefghijklmnopqrstuvwxyz";
    if (std.mem.indexOfScalar(u8, char_map, c)) |index| {
        return char_map[(index + 1) % char_map.len];
    }
    return c;
}

fn incrementString(str: []u8) void {
    var i: usize = str.len;
    while (i > 0) {
        i -= 1;
        str[i] = incrementChar(str[i]);
        if (str[i] != '0') return;
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    try stdout.writeAll("Choose formatting option:\n");
    try stdout.writeAll("1. Custom format (000_name_000)\n");
    try stdout.writeAll("2. Complete random format\n");
    try stdout.writeAll("Enter your choice (1 or 2): ");

    var buffer: [1024]u8 = undefined;
    const user_input = try stdin.readUntilDelimiter(&buffer, '\n');
    const format_choice = try std.fmt.parseInt(u8, user_input, 10);

    var name: [MAX_NAME_LENGTH + 1]u8 = undefined;
    var name_length: usize = undefined;

    switch (format_choice) {
        1 => {
            try stdout.print("Enter the name you are looking for (max {} characters): ", .{MAX_MIDDLE_LENGTH});
            const middle = try stdin.readUntilDelimiter(&buffer, '\n');
            const truncated_middle = middle[0..@min(middle.len, MAX_MIDDLE_LENGTH)];
            name_length = (try std.fmt.bufPrint(&name, "000_{s}_000", .{truncated_middle})).len;
        },
        2 => {
            try stdout.writeAll("Enter the desired length for random names (max 16): ");
            const len_input = try stdin.readUntilDelimiter(&buffer, '\n');
            name_length = @min(try std.fmt.parseInt(usize, len_input, 10), MAX_NAME_LENGTH);
            @memset(name[0..name_length], '0');
        },
        else => {
            try stdout.writeAll("Invalid choice. Exiting.\n");
            return;
        },
    }

    const prefix_end: usize = if (format_choice == 1) 3 else 0;
    const suffix_start: usize = if (format_choice == 1) name_length - 3 else name_length;

    try stdout.writeAll("\nChecking hashes for names...\n");
    try stdout.writeAll("Press Ctrl+C to stop the program.\n\n");

    var count: u64 = 0;
    while (true) {
        const hash = jenkinsHash(name[0..name_length]);
        if (hash < HASH_THRESHOLD) {
            try stdout.print("0x{x:0>8}: {s}\n", .{ hash, name[0..name_length] });
        }

        if (format_choice == 1) {
            incrementString(name[suffix_start..name_length]);
            if (std.mem.eql(u8, name[suffix_start .. suffix_start + 3], "000")) {
                incrementString(name[0..prefix_end]);
            }
        } else {
            incrementString(name[0..name_length]);
        }

        count += 1;
        if (count % 100_000_000 == 0) {
            if (count >= 1_000_000_000) {
                const billion_count: f64 = @as(f64, @floatFromInt(count)) / 1_000_000_000.0;
                try stdout.print("{d:.1} billion names\n", .{billion_count});
            } else {
                try stdout.print("{} million names\n", .{count / 1_000_000});
            }
        }
    }
}
