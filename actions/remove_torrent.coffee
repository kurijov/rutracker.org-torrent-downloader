api     = require './api'
Torrent = require '../db/torrent'

module.exports = (torrentId) ->
  Torrent.getById(torrentId)
    .then (torrentDbInstance) ->
      apiData = {ids: [torrentDbInstance.t_id], "delete-local-data": yes}
      api('torrent-remove', apiData).then -> torrentDbInstance.$delete()

