async = require 'async'
_     = require 'underscore'
Q     = require 'q'

createTorrent = Q.denodeify (params, torrentInfo, torrentUrl, title, callback) ->
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

module.exports = (torrentUrl, params) ->
  params = {} unless params

  Q.all([
    require('./get_session')
    require('./download_torrent') torrentUrl
  ])
  .spread( (transmissionSettings, torrentPath) ->
    console.log 'adding', torrentPath
    params = _.defaults params, {download_dir: transmissionSettings['download-dir']}
    require('./api_add_torrent') torrentPath, params.download_dir
  )
  .then( (torrentInfo) ->
    Q.all([
      require('./get_torrent_title') torrentUrl
      require('./trnt_model')().readyQ()
    ]).spread (title) ->
      return [torrentInfo, torrentUrl, title]
  )
  .spread( (torrentInfo, torrentUrl, title) ->
    createTorrent params, torrentInfo, torrentUrl, title
  )