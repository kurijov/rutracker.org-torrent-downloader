_            = require 'lodash'
Q            = require 'q'
Torrent      = require './db/torrent'
Config      = require './db/config'

Rutracker    = require './trackers/rutracker'
Transmission = require './downloaders/transmission'

class Manager
  constructor: ->
    @tracker      = new Rutracker
    @transmission = new Transmission

  checkTorrents: ->
    @sync_torrents()
    .then (items) =>
      Q.all (@_check_torrent_item item for item in items)
    .then(require('./sync_torrents'))

  check_torrent: (torrentId) ->
    Torrent.getById(torrentId)
      .then (item) =>
        console.log 'item to check', item
        @_check_torrent_item item
      .then ->
        Torrent.getById(torrentId)

  _check_torrent_item: (dbItemInstance) ->
    @tracker.get_torrent_title(dbItemInstance.torrent_url).then( (theNewTitle) =>
      p1 = if dbItemInstance.tracker_title isnt theNewTitle
        @reload_torrent(dbItemInstance)
      else
        Q()

      updateData = {tracker_title: theNewTitle, checked_at: new Date}
      p2         = dbItemInstance.$update(updateData)

      Q.all [p1, p2]
    )

  remove_torrent: (torrentId) ->
    Torrent.getById(torrentId).then (torrentDbInstance) =>
      Q().then =>
        @transmission.torrent_remove(torrentDbInstance.t_id)
      .then ->
        torrentDbInstance.$delete()

  reload_torrent: (dbItemInstace) ->
    # require('./mail')(dbItemInstace)
    
    Q(dbItemInstace.torrent_url).then(require('./download_torrent'))
      .then( (pathToTorrent) =>
        @transmission.add_torrent pathToTorrent, dbItemInstace.download_dir
      )
      .then( (torrentInfo) =>
        dbItemInstace.update({hash: torrentInfo.hashString}).then =>
          @transmission.torrent_remove(dbItemInstace.t_id)
      )
      .then(@sync_torrents.bind(@))

  add_torrent: (torrentUrl, params) ->
    params = {} unless params

    Q.all([
      @transmission.get_session()
      @tracker.download_torrent(torrentUrl)
      Config.get('transmission')
    ])
    .spread( (transmissionSettings, torrentPath, transmissionConfig) =>
      console.log 'adding', torrentPath
      params = _.defaults params, {
        download_dir: transmissionConfig.download_dir
      }, {
        download_dir: transmissionSettings['download-dir']
      }

      @transmission.add_torrent torrentPath, params.download_dir
    )
    .then( (torrentInfo) =>
      Q.all([
        @tracker.get_torrent_title torrentUrl
      ]).spread (title) ->
        return [torrentInfo, torrentUrl, title]
    )
    .spread( (torrentInfo, torrentUrl, title) =>
      @_create_torrent params, torrentInfo, torrentUrl, title
    )

  sync_torrents: ->
    Q.all([
      Torrent.query().all()
      @transmission.torrent_get()
    ])
    .spread (dbItems, trntInfos) ->
      toRemoveItems = []
      toUpdateIds   = []

      for dbItem in dbItems
        torrentInfo = _.findWhere trntInfos, {hashString: dbItem.hash}

        if torrentInfo
          toUpdateIds.push {item: dbItem, update: {t_id: torrentInfo.id}}
        else
          toRemoveItems.push dbItem

      removeQ = Q.all (item.$delete() for item in toRemoveItems)
      updateQ = Q.all (item.item.$update(item.update) for item in toUpdateIds)
      Q.all [removeQ, updateQ]

    .then ->
      Torrent.query().all()

  _create_torrent: (params, torrentInfo, torrentUrl, title) ->
    newTorrent = new Torrent
      t_id          : torrentInfo.id
      hash          : torrentInfo.hashString
      name          : torrentInfo.name
      tracker_title : title
      torrent_url   : torrentUrl
      download_dir  : params.download_dir
      checked_at    : new Date

    newTorrent.$save()


module.exports = new Manager