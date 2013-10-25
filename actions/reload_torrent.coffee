async = require 'async'
api   = require './api'
Q     = require 'q'

updateOldTorrent = Q.denodeify (dbItemInstace, torrentInfo, callback) ->
  {connection} = require('./trnt_model')()

  async.parallel [
    (callback) ->
      dbItemInstace.update connection, {hash: torrentInfo.hashString}, callback
    (callback) ->
      api 'torrent-remove', {ids: [dbItemInstace.t_id]}, callback
  ], (error) -> callback error

module.exports = (dbItemInstace, callback) ->
  console.log 'RELOAD ************************'
  console.log 'RELOAD ************************'
  console.log 'RELOAD ************************'
  console.log 'requested torrent reload', dbItemInstace

  require('./mail')(dbItemInstace)
  require('./trnt_model')().readyQ()
    .then(Q(dbItemInstace.torrent_url).then(require('./download_torrent')))
    .then( (pathToTorrent) ->
      require('./api_add_torrent') pathToTorrent, dbItemInstace.download_dir
    )
    .then( (torrentInfo) ->
      updateOldTorrent dbItemInstace, torrentInfo
    )
    .then(require('./sync_torrents'))

  # async.waterfall [
  #   (callback) -> require('./trnt_model')().ready callback

  #   (callback) -> require('./download_torrent') dbItemInstace.torrent_url, callback
  #   (pathToTorrent, callback) -> require('./api_add_torrent') pathToTorrent, dbItemInstace.download_dir, callback
  #   (torrentInfo, callback) ->
  #     {connection} = require('./trnt_model')()

  #     async.parallel [
  #       (callback) ->
  #         dbItemInstace.update connection, {hash: torrentInfo.hashString}, callback
  #       (callback) ->
  #         api 'torrent-remove', {ids: [dbItemInstace.t_id]}, callback
  #     ], (error) -> callback error

  #   (callback) ->
  #     require('./sync_torrents') callback
      
  # ], callback
