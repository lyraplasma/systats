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
pub fn start(commands: []const command, options: []const option, debug: bool) !void {
    if (commands.len > MAX_COMMANDS) {
       return error.TooManyCommands;
    }
    if (options.len > MAX_OPTIONSF) {
       return error.TooManyOptions;
    }
    // NOTE: General-Purpose allocator for mananging memory during execution
    // I don't know what ^^^^^ those mean TODO: Search them later.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // NOTE: Retrieve the command-line arguments in a cross-platform manner
    // TODO: Search this one too
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    try startWithArgs(commands, options, args, debug);
}

pub fn startWithArgs(commands: []const command, options: []const option, args: anytype, debug: bool) !void {
    if (args.len < 2) {
        if(debug) std.debug.print("I sense no commands :<\n", .{});
        return Error.NoArgsProvided;
    }
    // NOTE: Extract the name of the command (the second argument after program name)
    const command_name = args[1];
    var detected_command: ?command = null;

    // NOTE: Search through the list of available commands to find a match
    for (commands) |cmd| {
        if (std.mem.eql(u8, cmd.name, command_name)) {
            detected_command = cmd;
            break;
        }
    }

    // NOTE: then if the command not found in loop systats will slap an error
    if (detected_command == null) {
        if(debug) std.debug.print("Unknown command: {s}\n", .{command_name});
        return Error.UnknownCommand;
    }

    // NOTE: Retrieve the matched command from the optional variable
    const cmd = detected_command.?;

   if(debug) std.debug.print("I found a command:3 {s}\n", .{cmd.name}); 

   // Allocate memory for detected option based on remaining arguments
   var detected_options: [MAX_OPTIONS]option = undefined;
   var detected_len: usize = 0;
   var i: usize = 2;

   // NOTE: Parsing options to capture their value
   while (i < args.len) {
       const arg = args[i];

       if (std.mem.startsWith(u8, arg, "-")) {
           const option_name = if (std.mem.startWith(u8, arg[1..], "-")) arg[2..] else arg[1..];
           var matched_option: ?option = null;

           for (options) |opt| {
               if (std.mem.eql(u8, option_name, opt.long) or (option_name.len == 1 and option_name[0] == opt.short)) {
                   matched_option = opt;
                   break;
               }
           }
           if (matched_option == null) {
               if(debug) std.debug.print("This option is new to me: {s}\n", .{arg});
               return Error.UnknownOption;
           }

           var opt = matched_option.?;

           // NOTE: Detect the value for the option
           if (i + 1 < args.len and !std.mem.startsWith(u8, args[i + 1], "-")) {
               opt.value = args[i + 1];
               i += 1;
           } else {
               opt.value = "";
           }

           if (detected_len >= MAX_OPTIONS) {
               return error.TooManyOptions;
           }

           detected_options[detected_len] = opt;
           detected_len += 1;
       } else {
           if (debug) std.debug.print("Unexpected argument: {s}\n", .{arg});
           return Error.UnexpectedArgument;
       }
       i += 1;
   }

   // NOTE: Slice the detected options to the actual number of detected options :)))
   const used_options = detected_options[0..detected_len];

   // Ensure all required options for the detected command are provided
   for (cmd.req) |req_option| {
       var found = false;

       for (used_options) |opt| {
           if (std.mem.eql(u8, req_options, opt.name)) {
               found = true; break;
           }
       }

       if (!found) {
           if(debug) std.debug.print("Missing required option: {s}\n", .{req_option});
           return Error.MissingRequiredOption;
       }
   }

   // NOTE: Execute the command's associated function with the detected options
   if (!cmd.func(used_options)) {
       return Error.CommandExecutionFailed;
   } else {
       // NOTE: Execute option functions
       for (used_options) |opt| {
           if(opt.func == null) continue;

           const result = opt.func.?(opt.value);

           if (!result) {
               if(debug) std.debug.print("Option function execution failed:( {s}\n", .{opt.name});
               return Error.CommandExecutionFailed;
           }
       }
   }

   // NOTE: If execution reaches this point, the command was executed successfully
   if(debug) std.debug.print("Command executed successfully :) {s}\n", .{cmd.name});
}

