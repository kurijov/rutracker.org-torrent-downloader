program    = require 'commander'
async      = require 'async'
appCommand = require './app_command'

program
  .command('add <url>')
  .option('-D, --download_dir <path>', 'set download folder for torrent')
  .description('Add new torrent by url of tracker theme')
  .action (url, options) ->

    async.waterfall [
      (callback) -> appCommand 'add', {url: url, download_dir: options.download_dir}, callback
    ], require('./print')

program
  .command("list")
  .description("Show the list of torrents we watch")
  .action () ->
    appCommand 'list', {}, require('./print')

program
  .command("check")
  .description("Start check for the new torrents right now")
  .action () ->
    appCommand 'check', {}, require('./print')

program.parse(process.argv)