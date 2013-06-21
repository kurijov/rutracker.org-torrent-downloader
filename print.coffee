Table   = require('cli-table')
timeago = require 'timeago'
_       = require 'underscore'

module.exports = (error, torrents) ->
  if error
    console.log "Error: ", error
    return

  torrents = [torrents] unless _.isArray torrents

  tbl = new Table
    head: ["id", "title", 'last check']
    colWidths: [5, 70, 30]

  for torrent in torrents
    tbl.push [torrent.id, torrent.tracker_title, timeago(torrent.checked_at)]

  console.log tbl.toString()

