async  = require 'async'
config = require "../config"

checkItem = (dbItemInstance, callback) ->
  console.log 'checking item', dbItemInstance.tracker_title
  async.waterfall [
    (callback) -> require('./get_torrent_title') dbItemInstance.torrent_url, callback
    (theNewTitle, callback) ->
      async.parallel [
        (callback) ->
          if dbItemInstance.tracker_title isnt theNewTitle
            #torrent updated, reloading
            require('./reload_torrent') dbItemInstance, callback
          else
            callback()
        (callback) ->
          {connection} = require('./trnt_model')()
          updateData = {tracker_title: theNewTitle, checked_at: new Date}
          dbItemInstance.update connection, updateData, callback
      ], callback
      
        
  ], callback

checkNow = (callback) ->
  console.log 'checking for new torrents...'
  async.waterfall [
    # (callback) -> require('./trnt_model')().ready callback
    (callback) -> require('./sync_torrents') callback
    (items, callback) -> async.eachSeries items, (item, callback) ->
      checkItem item, (error) ->
        if error
          console.log 'error happened on item check', item
        callback null
    , callback
    (callback) -> require('./sync_torrents') callback

  ], callback

run = () ->
  console.log 'started torrent checker'
  runChecker = ->
    checkNow ->
      console.log 'next check in', config.check_period, 'seconds'
      setTimeout ->
        runChecker()
      , config.check_period * 1000

  runChecker()

module.exports = 
  checkNow: checkNow
  checkItem: checkItem
  run: run