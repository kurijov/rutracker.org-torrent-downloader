# api     = require './api'
Torrent = require '../db/torrent'

transmission = new (require('../downloaders/transmission'))

module.exports = (torrentId) ->
  Torrent.getById(torrentId)
    .then (torrentDbInstance) ->
      transmission.torrent_remove(torrentDbInstance.t_id)
        .then ->
          torrentDbInstance.$delete()
      # apiData = {ids: [torrentDbInstance.t_id], "delete-local-data": yes}
      # api('torrent-remove', apiData).then -> torrentDbInstance.$delete()

