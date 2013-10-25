async  = require 'async'
config = require '../config'

url  = require 'url'
exec = require('child_process').exec

downloadTorrent = (urlToTorrentTheme, callback) ->
  parsedUrl = url.parse urlToTorrentTheme, yes
  torrentId = parsedUrl.query.t

  return callback "Cant find torrent id in url" unless torrentId

  async.waterfall [
    (callback) ->
      options =
        cwd: __dirname + '/../files'

      exec "#{__dirname}/../files/download.sh #{config.user.login} #{config.user.password} #{torrentId}", options, (error, stdout, stderr) ->
        console.log stdout
        console.log stderr
        callback null
    (callback) ->
      callback null, __dirname + "/../files/file.t#{torrentId}.torrent"

  ], callback

module.exports = downloadTorrent