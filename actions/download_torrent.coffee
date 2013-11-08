async  = require 'async'
Q      = require 'q'
Config = require('../db/config')

url  = require 'url'
exec = require('child_process').exec

_download = Q.denodeify (config, torrentId, callback) ->
  console.log 'got config'
  async.waterfall [
    (callback) ->
      options =
        cwd: __dirname + '/../files'

      exec "#{__dirname}/../files/download.sh #{config.login} #{config.password} #{torrentId}", options, (error, stdout, stderr) ->
        console.log stdout
        console.log stderr
        callback null
    (callback) ->
      callback null, __dirname + "/../files/file.t#{torrentId}.torrent"

  ], callback

downloadTorrent = (urlToTorrentTheme) ->
  parsedUrl = url.parse urlToTorrentTheme, yes
  torrentId = parsedUrl.query.t

  throw new Error "Cant find torrent id in url" unless torrentId

  Config.get('tracker')
    .then (config) ->
      _download config, torrentId
    .fail (error) ->
      console.log 'failed to download', error
      throw new Error error

module.exports = downloadTorrent