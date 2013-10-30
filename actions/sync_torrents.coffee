async   = require 'async'
api     = require './api'
_       = require 'underscore'
Q       = require 'q'
Torrent = require '../db/torrent'

syncPromise = () ->

  Q.all([
    Torrent.query().all()
    api('torrent-get', {fields: ['hashString', 'id']})
      .then (result) ->
        if result.result is 'success'
          result.arguments.torrents
        else
          throw new Error result

  ])
  .spread (dbItems, trntInfos) ->
    toRemoveItems = []
    toUpdateIds   = []

    for dbItem in dbItems
      torrentInfo = _.findWhere trntInfos, {hashString: dbItem.hash}
      console.log 'we found', torrentInfo
      if torrentInfo
        toUpdateIds.push {item: dbItem, update: {t_id: torrentInfo.id}}
      else
        toRemoveItems.push dbItem

    removeQ = Q.all (item.$delete() for item in toRemoveItems)
    updateQ = Q.all (item.item.$update(item.update) for item in toUpdateIds)
    Q.all [removeQ, updateQ]

  .then ->
    Torrent.query().all()

module.exports = syncPromise