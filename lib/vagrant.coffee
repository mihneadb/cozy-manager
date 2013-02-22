require 'colors'
path = require 'path'
fs = require 'fs'
Client = require('request-json').JsonClient
exec = require('child_process').exec

helpers = require './helpers'

class exports.VagrantManager

    constructor: ->
        @baseBoxURL = 'https://www.cozycloud.cc/media/cozycloud-dev-latest.box'

        page = 'Setup-cozy-cloud-development-environment-via-a-virtual-machine'
        @docURL = "https://github.com/mycozycloud/cozy-setup/wiki/#{page}"

    checkIfVagrantIsInstalled: (callback) ->
        exec "vagrant -v", (err, stdout, stderr) ->
            if err
                msg =  "Vagrant is required to use a virtual machine." + \
                        "Please, refer to our documentation on #{docURL}"
                console.log msg.red
            else
                callback()

    vagrantBoxAdd: (callback) ->
        cmds = []
        cmds.push
            name: 'vagrant'
            args: ['box', 'add', @baseBoxURL]
        helpers.spawnUntilEmpty cmds, ->
            console.log "The base box has been added to your environment".green
            callback()

    vagrantInit: (callback) ->
        cmds = []
        cmds.push
            name: 'vagrant'
            args: ['init', "cozy-dev-latest"]
        helpers.spawnUntilEmpty cmds, callback

    vagrantUp: (callback) ->
        cmds = []
        cmds.push
            name: 'vagrant'
            args: ['up']
        helpers.spawnUntilEmpty cmds, callback

    vagrantHalt: (callback)  ->
        cmds = []
        cmds.push
            name: 'vagrant'
            args: ['halt']
        helpers.spawnUntilEmpty cmds, callback

    virtualMachineStatus: (callback) ->
        @isServiceUp "Data System", "localhost", 9101
        @isServiceUp "Cozy Proxy", "localhost", 9104
        @isServiceUp "Couchdb", "localhost", 5984
        @isServiceUp "Redis", "localhost", 6379

        # we set a timeout so the log msg is always sent at the end
        setTimeout(callback, 2000)

    isServiceUp: (service, domain, port) ->
        url = "http://#{domain}:#{port}"
        client = new Client url
        client.get '/', (err, res, body) ->
            result = if err is null then "OK".green else "KO".red
            console.log "#{service} at #{url}........." + result

