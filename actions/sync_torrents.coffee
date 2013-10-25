async = require 'async'
api   = require './api'
_     = require 'underscore'
Q     = require 'q'

syncPromise = Q.denodeify (callback) ->

  async.waterfall [
    (callback) ->
      require('./trnt_model')().ready callback
    (callback) ->
      {query} = require('./trnt_model')()

      async.parallel [
        (callback) -> query.all callback
        (callback) -> 
          async.waterfall [
            (callback) -> 
              api('torrent-get', {fields: ['hashString', 'id']}).done (result) ->
                callback null, result
            (result, callback) ->
              if result.result is 'success'
                callback null, result.arguments.torrents
              else
                callback result
          ], callback
          
      ], callback

    ([dbItems, trntInfos], callback) ->
      {connection} = require('./trnt_model')()
      # torrentHashes = _.pluck trntInfos, 'hashString'

      toRemoveItems = []
      toUpdateIds   = []

      for dbItem in dbItems
        torrentInfo = _.findWhere trntInfos, {hashString: dbItem.hash}
        console.log 'we found', torrentInfo
        if torrentInfo
          toUpdateIds.push {item: dbItem, update: {t_id: torrentInfo.id}}
        else
          toRemoveItems.push dbItem
      
      async.parallel [
        (callback) ->
          async.each toRemoveItems, (item, callback) ->
            item.delete connection, callback
          , callback
        (callback) ->
          async.each toUpdateIds, (item, callback) ->
            item.item.update connection, item.update, callback
          , callback
      ], callback

    (result, callback) ->
      {query} = require('./trnt_model')()
      query.all callback
    # (items, callback) ->
    #   console.log 'synced', items
    #   callback null, items
  ], callback

module.exports = -> syncPromise()