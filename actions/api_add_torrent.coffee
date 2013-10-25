async = require 'async'
fs    = require 'fs'
api   = require './api'

module.exports = (torrentPath, download_dir) ->
  torrentFileContent = fs.readFileSync torrentPath, {encoding: 'base64'}

  addData = {
    metainfo       : torrentFileContent
    paused         : no
    "download-dir" : download_dir
  }

  api("torrent-add", addData)
    .then( (result) ->
      if result.result is 'success'
        return result.arguments['torrent-added']
      else
        throw new Error result.result
    )