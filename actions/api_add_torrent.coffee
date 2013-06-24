async = require 'async'
fs    = require 'fs'
api   = require './api'

module.exports = (torrentPath, download_dir, callback) ->
  async.waterfall [
    (callback) -> 
      torrentFileContent = fs.readFileSync torrentPath, {encoding: 'base64'}

      addData = {
        metainfo       : torrentFileContent
        paused         : no
        "download-dir" : download_dir
      }

      # console.log 'transmissin add data', addData

      api "torrent-add", addData, callback
    (result, callback) ->
      if result.result is 'success'
        callback null, result.arguments['torrent-added']
      else
        callback result.result

  ], callback