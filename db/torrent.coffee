Q       = require 'q'
db      = require './index'
_       = require 'lodash'
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

class TorrentModel
  constructor: (data) ->
    if data instanceof Torrent
      instance = data
    else
      instance = new Torrent data

    proxyMethods = ['save', 'delete']
    _.each proxyMethods, (method) ->
      _deattachedMethod = instance[method]
      instance[method] = ->
        db.then (connection) ->
          Q.denodeify (callback) -> 
            _deattachedMethod.call instance, connection, callback

    return instance

  @query: ->
    all: ->
      db
        .then (connection) ->
          Q.ninvoke Torrent.using(connection), 'all'
        .then (items) ->
          (new TorrentModel item for item in items)

module.exports = TorrentModel