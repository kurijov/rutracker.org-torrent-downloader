async  = require 'async'
config = require "../config"
Q      = require 'q'
_      = require 'underscore'

updateInstace = (dbItemInstance, data) ->
  # {connection} = require('./trnt_model')()
  console.log 'updating data', data
  dbItemInstance.$update(data)

checkItem = (dbItemInstance) ->
  console.log 'checking item', dbItemInstance.tracker_title
  require('./get_torrent_title')(dbItemInstance.torrent_url)
    .then( (theNewTitle) ->

      p1 = if dbItemInstance.tracker_title isnt theNewTitle
        require('./reload_torrent')(dbItemInstance)
      else
        Q()

      updateData = {tracker_title: theNewTitle, checked_at: new Date}
      p2         = updateInstace dbItemInstance, updateData

      Q.all [p1, p2]
    )

checkNow = () ->
  console.log 'checking for new torrents...'

  # require('./trnt_model')().readyQ()
  #   .then(require('./sync_torrents'))
  require('./sync_torrents')
    .then( (items) ->
      Q.all (checkItem item for item in items)
    )
    .then(require('./sync_torrents'))

run = () ->
  console.log 'started torrent checker'
  runChecker = ->
    checkNow().then ->
      setTimeout ->
        runChecker()
      , config.check_period * 1000

  runChecker()

module.exports = 
  checkNow: checkNow
  checkItem: checkItem
  run: run