async = require 'async'
api   = require './api'
Q     = require 'q'

updateOldTorrent = (dbItemInstace, torrentInfo) ->
  
  dbItemInstace.update({hash: torrentInfo.hashString})
    .then ->
      api 'torrent-remove', {ids: [dbItemInstace.t_id]}

module.exports = (dbItemInstace, callback) ->
  console.log 'RELOAD ************************'
  console.log 'RELOAD ************************'
  console.log 'RELOAD ************************'
  console.log 'requested torrent reload', dbItemInstace

  require('./mail')(dbItemInstace)
  
  Q(dbItemInstace.torrent_url).then(require('./download_torrent')))
    .then( (pathToTorrent) ->
      require('./api_add_torrent') pathToTorrent, dbItemInstace.download_dir
    )
    .then( (torrentInfo) ->
      updateOldTorrent dbItemInstace, torrentInfo
    )
    .then(require('./sync_torrents'))
