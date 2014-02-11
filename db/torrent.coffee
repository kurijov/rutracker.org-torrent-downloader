Q       = require 'q'
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
  in_job_from   : type.DATETIME

E_TORRENT = require('../errors').TORRENT

LOCK_TTL = 2 * 60 # one minute

class TorrentModel extends require('./model')
  @persistModel: Torrent

  _lock: ->
    @in_job = 1
    @in_job_from = new Date

    @$update({in_job: 1, in_job_from: @in_job_from}).then =>
      console.log 'sucessfully locked', @
      @locked = yes

  lock: () ->
    if @in_job 
      if new Date().getTime() - @in_job_from.getTime() > LOCK_TTL
        @_lock()
      else
        Q.reject E_TORRENT.locked()
    else
      @_lock()

  unlock: () ->
    if @locked
      @$update({in_job: 0}).then =>
        @locked = no
    else
      Q()
  

module.exports = TorrentModel