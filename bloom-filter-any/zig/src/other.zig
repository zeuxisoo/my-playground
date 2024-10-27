const std = @import("std");

const info = std.log.info;
const print = std.debug.print;
const Allocator = std.mem.Allocator;

const hash = std.crypto.hash;
const BigIntManaged = std.math.big.int.Managed;

const BloomFilter = struct {
    const Self = @This();

    allocator: Allocator,

    size: u64,
    number_hashes: u64,
    salt: []const u8,

    bit_array: []u1,

    pub fn init(allocator: Allocator, size: u64, number_hashes: u64, salt: ?[]const u8) !BloomFilter {
        const bit_array = try allocator.alloc(u1, size);
        @memset(bit_array, 0);
        defer allocator.free(bit_array);

        return .{
            .allocator = allocator,
            .size = size,
            .number_hashes = number_hashes,
            .salt = salt orelse "",
            .bit_array = bit_array,
        };
    }

    pub fn add(self: *BloomFilter, element: []const u8) !void {
        for (0..self.number_hashes) |i| {
            const index = try self.calcElementIndex(element, i);

            // update the bit in related index
            self.bit_array[index] = 1;
        }
    }

    pub fn lookup(self: *BloomFilter, element: []const u8) !bool {
        for (0..self.number_hashes) |i| {
            const index = try self.calcElementIndex(element, i);

            // update the bit in related index
            if (self.bit_array[index] == 0) {
                return false;
            }
        }

        return true;
    }

    pub fn estimateDatasetSize(self: *BloomFilter) f64 {
        const m = @as(f64, @floatFromInt(self.size));
        const k = @as(f64, @floatFromInt(self.number_hashes));
        const n = -(m / k) * @log(1 - @as(f64, @floatFromInt(sum(self.bit_array))) / m);

        return n;
    }

    pub fn @"union"(self: *BloomFilter, other: BloomFilter) !BloomFilter {
        if (self.size != other.size or self.number_hashes != other.number_hashes) {
            @panic("Both filters must have the same size and hash count");
        }

        const zipped = try zip(self.bit_array, other.bit_array);
        var new_bit_array = try std.ArrayList(u1).initCapacity(self.allocator, self.size);

        for (zipped) |items| {
            const bit = items[0] | items[1];
            try new_bit_array.append(bit);
        }

        var result = try BloomFilter.init(self.allocator, self.size, self.number_hashes, self.salt);
        result.bit_array = new_bit_array.items;

        return result;
    }

    pub fn intersection(self: *BloomFilter, other: BloomFilter) !BloomFilter {
        if (self.size != other.size or self.number_hashes != other.number_hashes) {
            @panic("Both filters must have the same size and hash count");
        }

        const zipped = try zip(self.bit_array, other.bit_array);
        var new_bit_array = try std.ArrayList(u1).initCapacity(self.allocator, self.size);

        for (zipped) |items| {
            try new_bit_array.append(items[0] & items[1]);
        }

        var result = try BloomFilter.init(self.allocator, self.size, self.number_hashes, self.salt);
        result.bit_array = new_bit_array.items;

        return result;
    }

    fn calcElementIndex(self: *BloomFilter, element: []const u8, number_hash_index: usize) !u64 {
        // create hashing text
        const key_text = try std.fmt.allocPrint(self.allocator, "{s}{s}{d}", .{ self.salt, element, number_hash_index });
        defer self.allocator.free(key_text);

        // create hashed bytes from text
        var bytes: [20]u8 = undefined;
        hash.Sha1.hash(key_text, &bytes, .{});

        // create hex string from hashed bytes
        const digest = std.fmt.bytesToHex(bytes, .lower);

        // create big int value from parsed hex string in base 16
        var a = try BigIntManaged.init(self.allocator);
        defer a.deinit();
        try a.setString(16, &digest);

        // create big int value from size parameter
        var b = try BigIntManaged.initSet(self.allocator, self.size);
        defer b.deinit();

        // create rem value maybe 0
        var r = try BigIntManaged.init(self.allocator);
        defer r.deinit();

        // create query value and calc by `q = a / b (rem to r)`
        var q = try BigIntManaged.init(self.allocator);
        defer q.deinit();
        try q.divFloor(&r, &a, &b);

        // create index by BigIntManag to u64
        const index = try r.to(u64);

        return index;
    }
};

fn sum(values: []u1) u64 {
    var total: u64 = 0;

    for (values) |value| {
        total += value;
    }

    return total;
}

fn zip(item1: anytype, item2: anytype) ![][2]u1 {
    var new_items = try std.heap.page_allocator.alloc([2]u1, item1.len);
    errdefer new_items.deinit();

    for (new_items, item1, item2) |*item, x, y| {
        item.* = [2]u1{ x, y };
    }

    return new_items;
}

fn dump(value: anytype, comptime args: struct { precision: u64 = 0 }) void {
    const kind = @TypeOf(value);

    switch (kind) {
        []u1 => {
            var list = std.ArrayList([]const u8).init(std.heap.page_allocator);
            defer list.deinit();

            for (value) |bit| {
                list.append(if (bit == 0) "0" else "1") catch unreachable;
            }

            const x = list.toOwnedSlice() catch unreachable;
            const y = std.mem.join(std.heap.page_allocator, ", ", x) catch unreachable;

            print("[{s}]\n", .{y});
        },
        bool => {
            print("{}\n", .{value});
        },
        f64 => {
            const format_string = std.fmt.comptimePrint("{{d:.{}}}", .{args.precision});

            print(format_string ++ "\n", .{value});
        },
        else => @compileError("unknown dump type '" ++ @typeName(kind) ++ "'\n"),
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const coffees = [_][]const u8{
        "Iced Coffee",
        "Iced Coffee with Milk",
        "Espresso",
        "Espresso Macchiato",
        "Flat White",
        "Latte Macchiato",
        "Cappuccino",
        "Mocha",
    };

    var bloom = try BloomFilter.init(allocator, 20, 2, null);
    for (coffees) |drink| {
        try bloom.add(drink);
        dump(bloom.bit_array, .{});
    }

    print("---Experiment #1---\n", .{});
    dump(try bloom.lookup("Flat White"), .{});
    dump(try bloom.lookup("Americano"), .{});
    dump(bloom.estimateDatasetSize(), .{ .precision = 15 });

    //
    const more_coffees = [_][]const u8{
        "Iced Espresso",
        "Flat White",
        "Cappuccino",
        "Frappuccino",
        "Latte",
    };

    var bloom2 = try BloomFilter.init(allocator, 20, 2, null);
    for (more_coffees) |drink| {
        try bloom2.add(drink);
    }

    var bloom3 = try bloom2.@"union"(bloom);
    print("---Experiment #2---\n", .{});
    dump(try bloom3.lookup("Mocha"), .{});
    dump(try bloom3.lookup("Frappuccino"), .{});
    dump(bloom3.estimateDatasetSize(), .{ .precision = 15 });

    var bloom4 = try bloom2.intersection(bloom);
    print("---Experiment #3---\n", .{});
    dump(try bloom4.lookup("Mocha"), .{});
    dump(try bloom4.lookup("Flat White"), .{});
    dump(bloom4.estimateDatasetSize(), .{ .precision = 16 });
}
