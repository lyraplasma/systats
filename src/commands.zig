const std = @import("std");
const cli = @import("cli.zig");

pub const methods = struct {
    pub const commands = struct {
        // Handler for the "hello" command
        pub fn helloFn(_options: []const cli.option) bool {
            std.debug.print("Hello, ", .{});

            // Look for a "name" option
            for (_options) |opt| {
                // TODO: Investigate later where that opt.name lies
                if (std.mem.eql(u8, opt.name, "name")) {
                   if (opt.value.len > 0) {
                      std.debug.print("{s}", .{opt.value});
                   } else {
                      std.debug.print("World", .{});
                   }
               break;
            }
        }
       std.debug.print("!\n", .{});
       return true;
       }

        pub fn helpFn(_: []const cli.option) bool {
            std.debug.print(
                "Usage: systats <command> [options]\n" ++
                "Commands:\n" ++
                " hello     Greet someone\n" ++
                " help      Get help\n" ++
                "" ++
                "Options for hello:\n" ++
                " -n, --name <value>    Name to greet\n"
                , .{}
                );
            return true
        }
    };

    pub const options = struct {
        // Handler for the "name" option
        pub fn nameFn(_: []const u8) bool {
            // Option-specific logic should go here
            return true;
        }
    };
};
