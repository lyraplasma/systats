const std = @import("std");
const cli = @import("cli.zig");
const cmd = @import("commands.zig");

pub fn main() !void {
    // NOTE: Define available commands
    const command = [_]cli.command{
        cli.command{
            .name = "hello",
            .func = &cmd.methods.commands.helloFn,
            .opt = &.{"name"}, // "name" is optional command
        },
        cli.command{
            .name = "help",
            .func = &cmd.methods.commands.helpFn,
        },
    };

    const options = [_]cli.option{
        cli.option{
            .name = "name",
            .short = 'n',
            .long = "name",
            .func = &cmd.methods.options.nameFn,
        },
    };
    // This will start the app
    try.cli.start(&commands, &options, true);
}
