const std = @import("std");
const builtin = @import("builtin");

// NOTE: These are the data structure stuff :))
// And these are the core cli types, according to the zig docs :)))
pub const MAX_COMMANDS: u8 = 10;
pub const MAX_OPTIONS: u8 = 20;

const Byte = u8;
const Slice = []const Byte;
const Slices = []const Slice;

pub const command = struct {
    name: Slice,
    func: ?fnType = null,
    short: Byte,
    long: Slice,
    value: Slice = "",
    const fnType = *const fn (Slice) bool;
};

pub const Error = error{
    NoArgsProvided,
    UnknownCommand,
    UnknownOption,
    MissingRequiredOption,
    UnexpectedArgument,
    CommandExecutionFailed,
    TooManyCommands,
    TooManyOptions,
};


// NOTE: Command Parser implementation below
/// This will start the CLI App
//pub fn start(commands: []const command, options: []const option, debug: bool) !void {
//    if (commands)
//}