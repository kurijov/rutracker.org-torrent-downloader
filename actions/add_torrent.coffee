async = require 'async'
# api   = require './api'
# fs    = require 'fs'
_     = require 'underscore'

module.exports = (torrentUrl, params, callback) ->
  if 'function' is typeof params
    callback = params
    params   = {}


  async.waterfall [
    (callback) ->
      async.parallel [
        (callback) -> require('./get_session') callback
        (callback) -> require('./download_torrent') torrentUrl, callback
      ], callback
      
    ([transmissionSettings, torrentPath], callback) ->    
      console.log 'adding', torrentPath
      params = _.defaults params, {download_dir: transmissionSettings['download-dir']}
      require('./api_add_torrent') torrentPath, params.download_dir, callback

    (torrentInfo, callback) ->
      async.parallel [
        (callback) -> require('./get_torrent_title') torrentUrl, callback
        # (callback) -> require('./get_session') callback
        (callback) -> require('./trnt_model')().ready callback
      ], (error, [title]) ->

        console.log 'got ', error, title
        return callback error if error
  
        {model, connection} = require('./trnt_model')()


        newTorrent = new model
          t_id          : torrentInfo.id
          hash          : torrentInfo.hashString
          name          : torrentInfo.name
          tracker_title : title
          torrent_url   : torrentUrl
          download_dir  : params.download_dir
          checked_at    : new Date

        newTorrent.save(connection, callback)

  ], callback
