async        = require 'async'
_            = require 'lodash'
Q            = require 'q'
Torrent      = require '../db/torrent'
Transmission = new (require('../downloaders/transmission'))


createTorrent = (params, torrentInfo, torrentUrl, title) ->

  newTorrent = new Torrent
    t_id          : torrentInfo.id
    hash          : torrentInfo.hashString
    name          : torrentInfo.name
    tracker_title : title
    torrent_url   : torrentUrl
    download_dir  : params.download_dir
    checked_at    : new Date

  newTorrent.$save()

module.exports = (torrentUrl, params) ->
  params = {} unless params

  Q.all([
    transmission.get_session()
    require('./download_torrent') torrentUrl
  ])
  .spread( (transmissionSettings, torrentPath) ->
    console.log 'adding', torrentPath
    params = _.defaults params, {
      download_dir: transmissionSettings['download-dir']
    }
    transmission.add_torrent torrentPath, params.download_dir
  )
  .then( (torrentInfo) ->
    Q.all([
      require('./get_torrent_title') torrentUrl
    ]).spread (title) ->
      return [torrentInfo, torrentUrl, title]
  )
  .spread( (torrentInfo, torrentUrl, title) ->
    createTorrent params, torrentInfo, torrentUrl, title
  )