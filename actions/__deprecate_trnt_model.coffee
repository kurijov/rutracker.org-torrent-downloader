persist = require('persist')
Q = require 'q'
type = persist.type

Torrent = persist.define "Torrent",
  t_id          : type.INTEGER
  hash          : type.STRING
  name          : type.STRING
  tracker_title : type.STRING
  torrent_url   : type.STRING
  download_dir  : type.STRING
  checked_at    : type.DATETIME


module.exports = ->
  query: Torrent.using(connectionObject)
  model: Torrent
  connection: connectionObject
  # ready: fnCheck
  # readyQ: Q.denodeify(fnCheck)

