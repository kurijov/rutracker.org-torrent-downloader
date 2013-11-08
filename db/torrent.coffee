
persist = require 'persist'

type = persist.type

Torrent = persist.define "Torrent",
  t_id          : type.INTEGER
  hash          : type.STRING
  name          : type.STRING
  tracker_title : type.STRING
  torrent_url   : type.STRING
  download_dir  : type.STRING
  checked_at    : type.DATETIME
  in_job        : type.INTEGER

class TorrentModel extends require('./model')
  @persistModel: Torrent
  

module.exports = TorrentModel