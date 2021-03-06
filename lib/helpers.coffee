exec = require('child_process').exec
spawn = require('child_process').spawn
os = require 'os'
util = require 'util'

# Execute sequentially given shell commands with "exec"
# until there is no more command left. Exec displays the output at the end.
exports.execUntilEmpty = (commands, callback) ->
    command = commands.shift()
    exec command, (err, stdout, stderr) ->
        if err
            console.log stderr
            callback(err.code)
        else if commands.length > 0
            exports.execUntilEmpty commands, callback
        else
            callback(0)

# Execute sequentially given shell commands with "spawn"
# until there is no more command left. Spawn displays the output as it comes.
exports.spawnUntilEmpty = (commands, callback) ->
    commandDescriptor = commands.shift()
    if exports.isRunningOnWindows()
        name = commandDescriptor.name
        commandDescriptor.name = "cmd"
        commandDescriptor.args.unshift(name)
        commandDescriptor.args.unshift('/C')

    command = spawn(commandDescriptor.name, commandDescriptor.args,
                    commandDescriptor.opts)

    if os.platform().match /^win/
        name = commandDescriptor.name
        commandDescriptor.name = "cmd"
        commandDescriptor.args.unshift(name)
        commandDescriptor.args.unshift('/C')

    command.stdout.on 'data',  (data) ->
        util.print "#{data}"

    command.stderr.on 'data', (data) ->
        util.print "#{data}"

    command.on 'close', (code, signal) ->
        if commands.length > 0 and code is 0
            exports.spawnUntilEmpty commands, callback
        else
            callback(code)

exports.isRunningOnWindows = ->
    return os.platform().match /^win/
